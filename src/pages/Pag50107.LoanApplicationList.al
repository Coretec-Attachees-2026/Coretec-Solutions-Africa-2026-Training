// ============================================================
// Page 50107 - Loan Application List
// ============================================================
// PURPOSE: Shows ALL loan applications in a grid/list format.
//
// KEY CONCEPT - "PageType = List":
//   A List page shows multiple records in rows and columns.
//   When you click on a row, it opens the Card page for that record.
//
// KEY CONCEPT - "CardPageId":
//   Tells BC which Card page to open when you click a row.
//   Here it opens "Loan Application Card" (Page 50108).
//
// KEY CONCEPT - "UsageCategory = Lists":
//   This makes the page appear in the Business Central search bar
//   when users type "Loan Application".
//
// KEY CONCEPT - "Editable = false":
//   You can't edit records directly on the list.
//   You must open the Card page to edit.
// ============================================================

page 50107 "Loan Application List"
{
    Caption = 'Loan Applications';
    PageType = List;
    SourceTable = "Loan Application";
    ApplicationArea = All;
    UsageCategory = Lists;
    // CardPageId links this list to the card page
    // Double-clicking a row opens the card
    CardPageId = "Loan Application Card";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(LoanLines)
            {
                // "repeater" is what creates the grid/table of rows
                // Each field below becomes a column

                field("Loan Application No."; Rec."Loan Application No.")
                {
                    ToolTip = 'The unique loan application number.';
                }
                field("Member ID"; Rec."Member ID")
                {
                    ToolTip = 'The member who applied for this loan.';
                }
                field("Member Name"; Rec."Member Name")
                {
                    ToolTip = 'Name of the member.';
                }
                field("Loan Amount"; Rec."Loan Amount")
                {
                    ToolTip = 'Amount requested.';
                }
                field("Interest Rate (%)"; Rec."Interest Rate (%)")
                {
                    ToolTip = 'Annual interest rate.';
                }
                field("Loan Term (Months)"; Rec."Loan Term (Months)")
                {
                    ToolTip = 'Loan duration in months.';
                }
                field("Monthly Payment"; Rec."Monthly Payment")
                {
                    ToolTip = 'Calculated monthly payment.';
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Current status of the loan.';
                    StyleExpr = StatusStyle;
                }
                field("Application Date"; Rec."Application Date")
                {
                    ToolTip = 'Date the application was created.';
                }
                field(Posted; Rec.Posted)
                {
                    ToolTip = 'Whether the loan has been posted to the G/L.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(BulkActions)
            {
                Caption = 'Bulk Actions';
                ToolTip = 'Apply operations to multiple selected loan applications at once.';
                Image = Action;

                action(BulkMoveToUnderReview)
                {
                    Caption = 'Move Selected to Under Review';
                    ToolTip = 'Move all selected applications from Open to Pending Approval.';
                    Image = Approve;

                    trigger OnAction()
                    var
                        LoanApp: Record "Loan Application";
                        BulkProcessor: Codeunit "Loan Bulk Processing";
                    begin
                        CurrPage.SetSelectionFilter(LoanApp);
                        BulkProcessor.BulkUpdateLoanStatus(
                            LoanApp,
                            Enum::"Loan Application Status"::Open,
                            Enum::"Loan Application Status"::"Pending Approval",
                            'Bulk moved to Under Review'
                        );
                        CurrPage.Update(false);
                    end;
                }

                action(BulkApprove)
                {
                    Caption = 'Approve Selected';
                    ToolTip = 'Approve all selected applications (move from Pending Approval to Approved).';
                    Image = Approve;

                    trigger OnAction()
                    var
                        LoanApp: Record "Loan Application";
                        BulkProcessor: Codeunit "Loan Bulk Processing";
                    begin
                        CurrPage.SetSelectionFilter(LoanApp);
                        BulkProcessor.BulkUpdateLoanStatus(
                            LoanApp,
                            Enum::"Loan Application Status"::"Pending Approval",
                            Enum::"Loan Application Status"::Approved,
                            'Bulk approved by loan officer'
                        );
                        CurrPage.Update(false);
                    end;
                }

                action(BulkReject)
                {
                    Caption = 'Reject Selected';
                    ToolTip = 'Reject all selected applications (move from Pending Approval to Rejected).';
                    Image = Reject;

                    trigger OnAction()
                    var
                        LoanApp: Record "Loan Application";
                        BulkProcessor: Codeunit "Loan Bulk Processing";
                    begin
                        CurrPage.SetSelectionFilter(LoanApp);
                        BulkProcessor.BulkUpdateLoanStatus(
                            LoanApp,
                            Enum::"Loan Application Status"::"Pending Approval",
                            Enum::"Loan Application Status"::Rejected,
                            'Bulk rejected by loan officer'
                        );
                        CurrPage.Update(false);
                    end;
                }

                action(BulkMarkDisbursed)
                {
                    Caption = 'Mark Selected as Disbursed';
                    ToolTip = 'Mark all selected applications as disbursed (Approved → Disbursed).';
                    Image = Post;

                    trigger OnAction()
                    var
                        LoanApp: Record "Loan Application";
                        BulkProcessor: Codeunit "Loan Bulk Processing";
                    begin
                        CurrPage.SetSelectionFilter(LoanApp);
                        BulkProcessor.BulkUpdateLoanStatus(
                            LoanApp,
                            Enum::"Loan Application Status"::Approved,
                            Enum::"Loan Application Status"::Disbursed,
                            'Bulk marked as disbursed'
                        );
                        CurrPage.Update(false);
                    end;
                }
            }
        }
        area(Navigation)
        {
            action(LoanLedgerEntries)
            {
                Caption = 'Loan Ledger Entries';
                ToolTip = 'View all loan ledger entries.';
                Image = LedgerEntries;
                RunObject = page "Loan Ledger Entries";
            }
            action(AuditLog)
            {
                Caption = 'Audit Log';
                ToolTip = 'View all changes made to loan applications.';
                Image = Log;
                RunObject = page "Loan Application Audit Log";
            }
            action(MemberSetup)
            {
                Caption = 'Loan Setup';
                ToolTip = 'Open Member Setup to configure loan G/L accounts and No. Series.';
                Image = Setup;
                RunObject = page "Member Setup";
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';
                actionref(BulkMoveToUnderReview_Promoted; BulkMoveToUnderReview) { }
                actionref(BulkApprove_Promoted; BulkApprove) { }
                actionref(BulkReject_Promoted; BulkReject) { }
                actionref(BulkMarkDisbursed_Promoted; BulkMarkDisbursed) { }
            }
            group(Category_Navigate)
            {
                Caption = 'Navigate';
                actionref(LoanLedgerEntries_Promoted; LoanLedgerEntries) { }
                actionref(AuditLog_Promoted; AuditLog) { }
                actionref(MemberSetup_Promoted; MemberSetup) { }
            }
        }
    }

    // Status styling - same as the Card page
    var
        StatusStyle: Text;

    trigger OnAfterGetRecord()
    begin
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
