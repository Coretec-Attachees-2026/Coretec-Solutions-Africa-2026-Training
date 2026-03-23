// ============================================================
// Page 50116 - Member Loans Part
// ============================================================
// PURPOSE: A ListPart page (FactBox) that shows loans for a member.
//          Displayed on the Member Card to show related loans.
//
// KEY CONCEPT - "PageType = ListPart":
//   A ListPart is a smaller page designed to be embedded
//   inside another page as a FactBox or info panel.
//   It shows a list of related records filtered by criteria.
//
// KEY CONCEPT - "SubPageLink":
//   When added to a Card page, this defines how to link
//   the ListPart to the parent record.
//   Example from Member Card:
//     part(MemberLoansPart; "Member Loans Part")
//     {
//         Provider = rec;
//         SubPageLink = "Member ID" = field("Member ID");
//     }
//
// USAGE:
//   Add this to the Member Card page in the FactBoxes area.
//   When viewing a member, this page will automatically show
//   only that member's loans via the SubPageLink filter.
// ============================================================

page 50116 "Member Loans Part"
{
    Caption = 'Member Loans';
    PageType = ListPart;
    SourceTable = "Loan Application";
    ApplicationArea = All;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(LoanLines)
            {
                // "repeater" creates the list grid
                // Each field becomes a column

                field("Loan Application No."; Rec."Loan Application No.")
                {
                    ToolTip = 'The unique loan application number.';
                }

                field("Loan Amount"; Rec."Loan Amount")
                {
                    ToolTip = 'The amount of the loan.';
                }

                field(Status; Rec.Status)
                {
                    ToolTip = 'Current status of the loan.';
                    StyleExpr = StatusStyle;
                }

                field("Application Date"; Rec."Application Date")
                {
                    ToolTip = 'Date the loan application was created.';
                }

                field("Loan Term (Months)"; Rec."Loan Term (Months)")
                {
                    ToolTip = 'Loan duration in months.';
                }

                field("Monthly Payment"; Rec."Monthly Payment")
                {
                    ToolTip = 'Calculated monthly payment.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ViewLoanDetails)
            {
                Caption = 'View Loan Details';
                ToolTip = 'Open the loan application card to see full details.';
                Image = Card;
                RunObject = page "Loan Application Card";
                RunPageLink = "Loan Application No." = field("Loan Application No.");
            }

            action(NewLoan)
            {
                Caption = 'New Loan Application';
                ToolTip = 'Create a new loan application for this member.';
                Image = New;
                RunObject = page "Loan Application Card";
                RunPageMode = Create;
                Visible = false; // Hidden because SubPageLink would auto-fill Member ID
            }
        }
    }

    // Status styling - visual indicators
    var
        StatusStyle: Text;

    trigger OnAfterGetRecord()
    begin
        // Apply color coding based on loan status
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
