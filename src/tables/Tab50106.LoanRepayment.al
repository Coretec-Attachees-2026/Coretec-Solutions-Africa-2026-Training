// ============================================================
// Table 50106 - Loan Repayment
// ============================================================
// PURPOSE: Records every repayment made against a disbursed loan.
//
// HOW IT WORKS:
//   When a member makes a loan payment, a new record is created here.
//   Each record stores how much was paid, how much went to principal
//   vs interest, and the remaining balance after payment.
//
// KEY CONCEPT - "AutoIncrement":
//   Entry No. auto-increments (1, 2, 3, ...) so each repayment
//   gets a unique number automatically.
// ============================================================

table 50106 "Loan Repayment"
{
    Caption = 'Loan Repayment';
    DataClassification = ToBeClassified;
    DrillDownPageId = "Loan Repayment List";
    LookupPageId = "Loan Repayment List";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "Loan Application No."; Code[20])
        {
            Caption = 'Loan Application No.';
            TableRelation = "Loan Application"."Loan Application No.";
        }
        field(3; "Member ID"; Code[20])
        {
            Caption = 'Member ID';
            TableRelation = "Member"."Member ID";
        }
        field(4; "Member Name"; Text[200])
        {
            Caption = 'Member Name';
        }
        field(5; "Payment Date"; Date)
        {
            Caption = 'Payment Date';
        }
        field(6; "Amount Paid"; Decimal)
        {
            Caption = 'Amount Paid';
        }
        field(7; "Principal Applied"; Decimal)
        {
            Caption = 'Principal Applied';
        }
        field(8; "Interest Applied"; Decimal)
        {
            Caption = 'Interest Applied';
        }
        field(9; "Remaining Balance"; Decimal)
        {
            Caption = 'Remaining Balance';
        }
        field(10; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(11; "Description"; Text[100])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(SK1; "Loan Application No.") { }
        key(SK2; "Member ID") { }
    }
}
