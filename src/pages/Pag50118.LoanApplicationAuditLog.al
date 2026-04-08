// ============================================================
// Page 50118 - Loan Application Audit Log
// ============================================================
// PURPOSE: Displays all status changes made to loan applications,
//          including both manual changes and bulk operations.
//          Useful for tracking who changed what and when.
// ============================================================

page 50118 "Loan Application Audit Log"
{
    Caption = 'Loan Application Audit Log';
    PageType = List;
    SourceTable = "Loan Application Audit Log";
    ApplicationArea = All;
    UsageCategory = History;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(AuditLogEntries)
            {
                field("Entry No"; Rec."Entry No")
                {
                    ToolTip = 'Unique entry number in the audit log.';
                    Visible = false;
                }

                field("Loan Application No."; Rec."Loan Application No.")
                {
                    ToolTip = 'The loan application affected by this change.';
                }

                field("Old Status"; Rec."Old Status")
                {
                    ToolTip = 'The previous status.';
                }

                field("New Status"; Rec."New Status")
                {
                    ToolTip = 'The new status after change.';
                }

                field("Change Date & Time"; Rec."Change Date & Time")
                {
                    ToolTip = 'When the change was made.';
                }

                field("User ID"; Rec."User ID")
                {
                    ToolTip = 'Who made the change.';
                }

                field("Action Type"; Rec."Action Type")
                {
                    ToolTip = 'Whether this was a manual change or part of a bulk operation.';
                }

                field("Batch ID"; Rec."Batch ID")
                {
                    ToolTip = 'For bulk operations, groups all related changes.';
                }

                field("Notes"; Rec."Notes")
                {
                    ToolTip = 'Reason or additional information about the change.';
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(GoToLoanApplication)
            {
                Caption = 'Go to Loan Application';
                ToolTip = 'Open the loan application affected by this audit entry.';
                Image = Document;

                trigger OnAction()
                var
                    LoanApp: Record "Loan Application";
                begin
                    if LoanApp.Get(Rec."Loan Application No.") then
                        Page.Run(Page::"Loan Application Card", LoanApp);
                end;
            }
        }
        area(Processing)
        {
            action(FilterByBatch)
            {
                Caption = 'Filter by Batch ID';
                ToolTip = 'Show all changes from the same bulk operation.';
                Image = Filter;

                trigger OnAction()
                begin
                    if Rec."Batch ID" <> '' then begin
                        Rec.SetRange("Batch ID", Rec."Batch ID");
                        CurrPage.Update(false);
                    end else
                        Message('This entry is not part of a bulk operation.');
                end;
            }
            action(ClearFilter)
            {
                Caption = 'Clear Filters';
                ToolTip = 'Show all audit log entries.';
                Image = ClearFilter;

                trigger OnAction()
                begin
                    Rec.SetRange("Batch ID");
                    Rec.SetRange("Loan Application No.");
                    Rec.SetRange("User ID");
                    CurrPage.Update(false);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';
                actionref(FilterByBatch_Promoted; FilterByBatch) { }
                actionref(ClearFilter_Promoted; ClearFilter) { }
            }
            group(Category_Navigate)
            {
                Caption = 'Navigate';
                actionref(GoToLoanApplication_Promoted; GoToLoanApplication) { }
            }
        }
    }
}
