// ============================================================
// Page 50109 - Loan Ledger Entries
// ============================================================
// PURPOSE: Shows a read-only list of all posted loan transactions.
//
// This is an audit log - you can see every loan that was disbursed,
// who got it, how much, and when.
//
// KEY CONCEPT - "Editable = false":
//   Ledger entries should NEVER be edited directly.
//   They are permanent records created during posting.
//   If there's a mistake, you create a reversal entry instead.
//
// KEY CONCEPT - "InsertAllowed/DeleteAllowed = false":
//   No one can manually add or remove entries from this page.
//   Entries are only created by the Loan Management codeunit.
// ============================================================

page 50109 "Loan Ledger Entries"
{
    Caption = 'Loan Ledger Entries';
    PageType = List;
    SourceTable = "Loan Ledger Entry";
    ApplicationArea = All;
    UsageCategory = History;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Unique sequential entry number.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ToolTip = 'Date when this entry was posted.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'The document number linking to G/L entries.';
                }
                field("Loan Application No."; Rec."Loan Application No.")
                {
                    ToolTip = 'The loan application this entry belongs to.';
                }
                field("Member ID"; Rec."Member ID")
                {
                    ToolTip = 'The member who received this loan.';
                }
                field("Member Name"; Rec."Member Name")
                {
                    ToolTip = 'Name of the member.';
                }
                field("Loan Amount"; Rec."Loan Amount")
                {
                    ToolTip = 'The principal loan amount disbursed.';
                }
                field("Interest Rate (%)"; Rec."Interest Rate (%)")
                {
                    ToolTip = 'Annual interest rate applied.';
                }
                field("Loan Term (Months)"; Rec."Loan Term (Months)")
                {
                    ToolTip = 'Loan duration in months.';
                }
                field("Total Interest"; Rec."Total Interest")
                {
                    ToolTip = 'Total interest calculated for the loan.';
                }
                field("Total Repayment"; Rec."Total Repayment")
                {
                    ToolTip = 'Total amount to be repaid.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Description of the transaction.';
                }
            }
        }
    }
}
