// ============================================================
// Page 50110 - Loan Repayment List
// ============================================================
// PURPOSE: Shows a read-only list of all loan repayments.
//
// This is an audit log of payments made against loans.
// Entries are only created by the Loan Management codeunit.
// ============================================================

page 50110 "Loan Repayment List"
{
    Caption = 'Loan Repayments';
    PageType = List;
    SourceTable = "Loan Repayment";
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
                field("Payment Date"; Rec."Payment Date")
                {
                    ToolTip = 'Date when this payment was made.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'The document number linking to G/L entries.';
                }
                field("Loan Application No."; Rec."Loan Application No.")
                {
                    ToolTip = 'The loan this payment applies to.';
                }
                field("Member ID"; Rec."Member ID")
                {
                    ToolTip = 'The member who made the payment.';
                }
                field("Member Name"; Rec."Member Name")
                {
                    ToolTip = 'Name of the member.';
                }
                field("Amount Paid"; Rec."Amount Paid")
                {
                    ToolTip = 'Total amount paid in this transaction.';
                }
                field("Principal Applied"; Rec."Principal Applied")
                {
                    ToolTip = 'Portion of payment applied to principal.';
                }
                field("Interest Applied"; Rec."Interest Applied")
                {
                    ToolTip = 'Portion of payment applied to interest.';
                }
                field("Remaining Balance"; Rec."Remaining Balance")
                {
                    ToolTip = 'Outstanding loan balance after this payment.';
                }
                field("Description"; Rec."Description")
                {
                    ToolTip = 'Description of the repayment.';
                }
            }
        }
    }
}
