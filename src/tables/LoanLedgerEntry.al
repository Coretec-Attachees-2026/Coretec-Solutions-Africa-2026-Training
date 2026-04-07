// ============================================================
// Table 50103 - Loan Ledger Entry
// ============================================================
// PURPOSE: Records every loan transaction posted to the General Ledger.
//
// WHAT IS A LEDGER ENTRY?
//   Think of it as a diary/log of financial transactions.
//   Every time we disburse a loan, we create entries here so we
//   have a history of what happened, when, and for how much.
//
// WHY DO WE NEED THIS?
//   - Audit trail: you can always see who got a loan and when
//   - Reconciliation: match these entries against G/L entries
//   - Reporting: total loans disbursed, outstanding, etc.
//
// KEY CONCEPT - "AutoIncrement":
//   The Entry No. field auto-increments (1, 2, 3, ...).
//   Each entry gets a unique number automatically.
// ============================================================

table 50103 "Loan Ledger Entry"
{
    Caption = 'Loan Ledger Entry';
    DataClassification = ToBeClassified;
    // DrillDownPageId tells BC which page to open when you click on this table
    DrillDownPageId = "Loan Ledger Entries";
    LookupPageId = "Loan Ledger Entries";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            // AutoIncrement means BC automatically assigns 1, 2, 3, etc.
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
        field(5; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(6; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            // This links back to the G/L Entry created during posting
        }
        field(7; "Loan Amount"; Decimal)
        {
            Caption = 'Loan Amount';
        }
        field(8; "Interest Rate (%)"; Decimal)
        {
            Caption = 'Interest Rate (%)';
        }
        field(9; "Loan Term (Months)"; Integer)
        {
            Caption = 'Loan Term (Months)';
        }
        field(10; "Total Interest"; Decimal)
        {
            Caption = 'Total Interest';
        }
        field(11; "Total Repayment"; Decimal)
        {
            Caption = 'Total Repayment';
        }
        field(12; "Description"; Text[100])
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
        key(SK3; "Posting Date") { }
    }
}
