// ============================================================
// Page 50116 - Member Loans Part (FactBox ListPart)
// ============================================================
// PURPOSE: Shows a list of loans for a specific member in a FactBox.
//          This page is embedded in the Member Card (Page 50103).
//
// HOW IT WORKS:
//   1. The Member Card passes the current Member ID
//   2. This page filters Loan Application records using SubPageLink
//   3. Only loans for that member are displayed
//
// KEY CONCEPT - PageType = ListPart:
//   A ListPart is a page fragment designed to be embedded in other pages.
//   It can't be opened independently - it always appears within a Card or another page.
//
// KEY CONCEPT - SubPageLink:
//   Creates a filter that ties this page to the parent page.
//   Format: "Field in this table" = field("Field in parent table")
//   Example: "Member ID" = field("Member ID") from Member Card
// ============================================================

page 50116 "Member Loans Part"
{
    Caption = 'Member Loans';
    PageType = ListPart;                    // This is a part, not standalone
    SourceTable = "Loan Application";       // Shows Loan Application records
    ApplicationArea = All;
    Editable = false;                       // Read-only - managed via Card page

    layout
    {
        area(Content)
        {
            repeater(LoanList)
            {
                // This repeater creates rows for each loan of the member

                field("Loan Application No."; Rec."Loan Application No.")
                {
                    ToolTip = 'The unique loan application number';
                    Width = 20;
                }
                field("Loan Amount"; Rec."Loan Amount")
                {
                    ToolTip = 'The amount requested in the loan application';
                    Width = 20;
                }
                field("Interest Rate (%)"; Rec."Interest Rate (%)")
                {
                    ToolTip = 'The annual interest rate';
                    Width = 15;
                }
                field("Monthly Payment"; Rec."Monthly Payment")
                {
                    ToolTip = 'The calculated monthly payment amount';
                    Width = 20;
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'The current status of the loan application';
                    Width = 15;
                    StyleExpr = StatusStyle;
                }
                field("Application Date"; Rec."Application Date")
                {
                    ToolTip = 'The date the loan was applied for';
                    Width = 15;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(OpenLoanApplication)
            {
                Caption = 'Open Loan Application';
                ToolTip = 'Open the loan application details';
                Image = Open;
                RunObject = page "Loan Application Card";
                RunPageLink = "Loan Application No." = field("Loan Application No.");
            }
        }
    }

    var
        StatusStyle: Text;

    trigger OnAfterGetRecord()
    begin
        // Apply styling based on loan status
        case Rec.Status of
            Enum::"Loan Application Status"::Open:
                StatusStyle := 'Standard';
            Enum::"Loan Application Status"::"Pending Approval":
                StatusStyle := 'Attention';
            Enum::"Loan Application Status"::Approved:
                StatusStyle := 'Favorable';
            Enum::"Loan Application Status"::Rejected:
                StatusStyle := 'Unfavorable';
            Enum::"Loan Application Status"::Disbursed:
                StatusStyle := 'Favorable';
        end;
    end;
}
