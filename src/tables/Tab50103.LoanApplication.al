// ============================================================
// Table 50103 - Loan Application
// ============================================================
// PURPOSE: Stores every loan request made by a SACCO member.
//
// HOW IT WORKS:
// 1. When a new record is inserted, it auto-generates an ID like "LN-20260303-00001"
// 2. When you pick a Member ID, it automatically fills in the member's name
// 3. When you enter Amount, Term, or Interest Rate, it recalculates Monthly & Total Payment
// 4. The Status field tracks where the loan is in the workflow
//
// KEY CONCEPT - "TableRelation":
//   field "Member ID" has TableRelation = "Member"."Member ID"
//   This means you can ONLY enter a Member ID that already exists in the Member table.
//   It's like a foreign key in a database.
//
// KEY CONCEPT - "FlowField" (field 11 "Member Name"):
//   A FlowField does NOT store data. It calculates its value on-the-fly
//   by looking up data from another table. Here it grabs the Full Name
//   from the Member table matching our Member ID.
// ============================================================

table 50103 "Loan Application"
{
    Caption = 'Loan Application';
    DataClassification = ToBeClassified;

    fields
    {
        // ---------- IDENTIFICATION ----------
        field(1; "Loan Application No."; Code[20])
        {
            Caption = 'Loan Application No.';
            Editable = false;
            // This is the primary key - auto-generated in OnInsert trigger
        }

        // ---------- MEMBER INFORMATION ----------
        field(2; "Member ID"; Code[20])
        {
            Caption = 'Member ID';
            // TableRelation links this field to the Member table
            // so you can only pick valid, existing members
            TableRelation = "Member"."Member ID";

            trigger OnValidate()
            var
                Member: Record "Member";
            begin
                // When user picks a Member ID, look up their name automatically
                if Member.Get("Member ID") then
                    "Member Name" := Member."Full Name"
                else
                    "Member Name" := '';
            end;
        }

        field(3; "Member Name"; Text[200])
        {
            Caption = 'Member Name';
            Editable = false;
            // This is filled automatically when Member ID is validated
        }

        // ---------- LOAN DETAILS ----------
        field(4; "Loan Amount"; Decimal)
        {
            Caption = 'Loan Amount';
            MinValue = 0;
            // MinValue = 0 prevents negative loan amounts

            trigger OnValidate()
            begin
                // Recalculate payments whenever amount changes
                CalculatePayments();
            end;
        }

        field(5; "Loan Term (Months)"; Integer)
        {
            Caption = 'Loan Term (Months)';
            MinValue = 1;
            // Minimum 1 month loan term

            trigger OnValidate()
            begin
                CalculatePayments();
            end;
        }

        field(6; "Interest Rate (%)"; Decimal)
        {
            Caption = 'Interest Rate (%)';
            MinValue = 0;

            trigger OnValidate()
            begin
                CalculatePayments();
            end;
        }

        field(7; "Monthly Payment"; Decimal)
        {
            Caption = 'Monthly Payment';
            Editable = false;
            // Calculated automatically - user cannot type here
        }

        field(8; "Total Repayment"; Decimal)
        {
            Caption = 'Total Repayment';
            Editable = false;
            // = Monthly Payment × Loan Term
        }

        field(9; "Total Interest"; Decimal)
        {
            Caption = 'Total Interest';
            Editable = false;
            // = Total Repayment - Loan Amount
        }

        // ---------- DATES ----------
        field(10; "Application Date"; Date)
        {
            Caption = 'Application Date';
            Editable = false;
            // Set automatically when record is created
        }

        field(11; "Approval Date"; Date)
        {
            Caption = 'Approval Date';
            Editable = false;
            // Set when loan is approved
        }

        field(12; "Disbursement Date"; Date)
        {
            Caption = 'Disbursement Date';
            Editable = false;
            // Set when loan is posted to G/L
        }

        // ---------- STATUS & WORKFLOW ----------
        field(13; "Status"; Enum "Loan Application Status")
        {
            Caption = 'Status';
            Editable = false;
            // Changed by codeunit actions, not manually by user
        }

        field(14; "Rejection Reason"; Text[250])
        {
            Caption = 'Rejection Reason';
            Editable = false;
        }

        field(15; "Loan Purpose"; Text[250])
        {
            Caption = 'Loan Purpose';
            // Member explains why they need the loan
        }

        // ---------- POSTING REFERENCE ----------
        field(16; "Posted"; Boolean)
        {
            Caption = 'Posted';
            Editable = false;
            // True after loan is posted to the General Ledger
        }

        field(17; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            Editable = false;
            // The G/L Entry document number created during posting
        }
    }

    keys
    {
        // Primary Key - every table needs one
        key(PK; "Loan Application No.")
        {
            Clustered = true;
        }
        // Secondary keys help with filtering and sorting
        key(SK1; "Member ID") { }
        key(SK2; "Status") { }
        key(SK3; "Application Date") { }
    }

    // -------------------------------------------------------
    // OnInsert Trigger
    // -------------------------------------------------------
    // This runs automatically when a new record is created.
    // It generates a unique Loan Application No. like "LN-20260303-00001"
    // and sets the initial status to "Open".
    // -------------------------------------------------------
    trigger OnInsert()
    begin
        if "Loan Application No." = '' then
            AssignLoanApplicationNo();

        "Application Date" := Today;
        "Status" := Enum::"Loan Application Status"::Open;
    end;

    // -------------------------------------------------------
    // CalculatePayments
    // -------------------------------------------------------
    // Simple interest calculation:
    //   Total Interest  = Loan Amount × (Interest Rate / 100) × (Term in years)
    //   Total Repayment = Loan Amount + Total Interest
    //   Monthly Payment = Total Repayment / Term in months
    //
    // EXAMPLE: Loan 100,000 at 12% for 12 months
    //   Total Interest  = 100,000 × 0.12 × 1 = 12,000
    //   Total Repayment = 100,000 + 12,000 = 112,000
    //   Monthly Payment = 112,000 / 12 = 9,333.33
    // -------------------------------------------------------
    local procedure CalculatePayments()
    begin
        if ("Loan Amount" = 0) or ("Loan Term (Months)" = 0) then begin
            "Monthly Payment" := 0;
            "Total Repayment" := 0;
            "Total Interest" := 0;
            exit;
        end;

        // Simple interest formula
        "Total Interest" := "Loan Amount" * ("Interest Rate (%)" / 100) * ("Loan Term (Months)" / 12);
        "Total Repayment" := "Loan Amount" + "Total Interest";
        "Monthly Payment" := "Total Repayment" / "Loan Term (Months)";
    end;

    // -------------------------------------------------------
    // AssignLoanApplicationNo
    // -------------------------------------------------------
    // Generates IDs like: LN-20260303-00001
    // Uses the No. Series system from Member Setup
    // -------------------------------------------------------
    local procedure AssignLoanApplicationNo()
    var
        MemberSetup: Record "Member Setup";
        NoSeriesMgt: Codeunit "No. Series";
        LoanNoSeriesMgt: Codeunit "Loan No. Series Mgt";
        RawNo: Code[20];
        SeqInt: Integer;
        SeqText: Text[5];
    begin
        // Make sure the No. Series exists
        LoanNoSeriesMgt.EnsureLoanNoSeriesAndSetup();
        MemberSetup.GetOrCreateSetup();

        if MemberSetup."Loan Application Nos." = '' then
            Error('Loan Application Nos. is not configured. Go to Member Setup and set a No. Series.');

        // Get next number from the series
        RawNo := NoSeriesMgt.GetNextNo(MemberSetup."Loan Application Nos.", WorkDate());

        // Convert to integer for formatting
        if not Evaluate(SeqInt, Format(RawNo)) then
            Error('No. Series %1 must return numeric values.', MemberSetup."Loan Application Nos.");

        // Format as 5-digit padded number
        SeqText := PadStr('', 5 - StrLen(Format(SeqInt)), '0') + Format(SeqInt);

        // Build final ID: LN-YYYYMMDD-#####
        "Loan Application No." := 'LN-' + Format(Today, 0, '<Year4><Month,2><Day,2>') + '-' + SeqText;
    end;
}