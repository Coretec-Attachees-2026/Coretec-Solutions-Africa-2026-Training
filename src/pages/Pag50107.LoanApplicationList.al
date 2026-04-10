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
            action(BulkApprove)
            {
                Caption = 'Bulk Approve & Disburse';
                ToolTip = 'Approve and disburse all selected loans. Only loans in "Pending Approval" status will be processed.';
                Image = Approve;

                trigger OnAction()
                var
                    LoanApp: Record "Loan Application";
                    BulkLoanMgt: Codeunit "Bulk Loan Approval Mgt";
                begin
                    // Step 1: Get all selected records from the list
                    CurrPage.SetSelectionFilter(LoanApp);

                    // Step 2: Validate that at least one record is selected
                    if not BulkLoanMgt.ValidateSelection(LoanApp) then
                        exit;

                    // Step 3: Process the bulk approval
                    BulkLoanMgt.ApproveSelected(LoanApp);

                    // Step 4: Refresh the page to show updated statuses
                    CurrPage.Update(false);
                end;
            }

            action(LoanSummaryReport)
            {
                Caption = 'Loan Summary by Member';
                ToolTip = 'View a summary report of all members with their loans listed underneath.';
                Image = Report;
                RunObject = report "Loan Summary by Member";
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
                Caption = 'Bulk Operation Audit Log';
                ToolTip = 'View audit log of all bulk operations performed on loan applications.';
                Image = Approve;
                RunObject = page "Audit Log Entries";
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
                actionref(BulkApprove_Promoted; BulkApprove) { }
                actionref(LoanSummaryReport_Promoted; LoanSummaryReport) { }
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
