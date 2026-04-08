table 50105 "Loan Application"
{
    Caption = 'Loan Application';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Loan Application No."; Code[20])
        {
            Caption = 'Loan Application No.';
            Editable = false;
        }

        field(2; "Member ID"; Code[20])
        {
            Caption = 'Member ID';
            TableRelation = "Member";

            trigger OnValidate()
            var
                Member: Record "Member";
            begin
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
        }

        field(4; "Loan Amount"; Decimal)
        {
            Caption = 'Loan Amount';
            MinValue = 0;

            trigger OnValidate()
            begin
                CalculatePayments();
            end;
        }

        field(5; "Loan Term (Months)"; Integer)
        {
            Caption = 'Loan Term (Months)';
            MinValue = 1;

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
        }

        field(8; "Total Repayment"; Decimal)
        {
            Caption = 'Total Repayment';
            Editable = false;
        }

        field(9; "Total Interest"; Decimal)
        {
            Caption = 'Total Interest';
            Editable = false;
        }

        field(10; "Application Date"; Date)
        {
            Caption = 'Application Date';
            Editable = false;
        }

        field(11; "Approval Date"; Date)
        {
            Caption = 'Approval Date';
            Editable = false;
        }

        field(12; "Disbursement Date"; Date)
        {
            Caption = 'Disbursement Date';
            Editable = false;
        }

        field(13; "Status"; Enum "Loan Application Status")
        {
            Caption = 'Status';
            Editable = false;
        }

        field(14; "Rejection Reason"; Text[250])
        {
            Caption = 'Rejection Reason';
            Editable = false;
        }

        field(15; "Loan Purpose"; Text[250])
        {
            Caption = 'Loan Purpose';
        }

        field(16; "Posted"; Boolean)
        {
            Caption = 'Posted';
            Editable = false;
        }

        field(17; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            Editable = false;
        }
        field(18; "Reviewer Notes"; Text[2048]) {
            Caption = 'Reviewer Notes';
        }
    }

    keys
    {
        key(PK; "Loan Application No.")
        {
            Clustered = true;
        }
        key(SK1; "Member ID") { }
        key(SK2; "Status") { }
        key(SK3; "Application Date") { }
    }

    trigger OnInsert()
    begin
        if "Loan Application No." = '' then
            AssignLoanApplicationNo();

        "Application Date" := Today;
        "Status" := Enum::"Loan Application Status"::Open;
    end;

    local procedure CalculatePayments()
    begin
        if ("Loan Amount" = 0) or ("Loan Term (Months)" = 0) then begin
            "Monthly Payment" := 0;
            "Total Repayment" := 0;
            "Total Interest" := 0;
            exit;
        end;

        "Total Interest" := "Loan Amount" * ("Interest Rate (%)" / 100) * ("Loan Term (Months)" / 12);
        "Total Repayment" := "Loan Amount" + "Total Interest";
        "Monthly Payment" := "Total Repayment" / "Loan Term (Months)";
    end;
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