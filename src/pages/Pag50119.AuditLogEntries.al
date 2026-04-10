// ============================================================
// Page 50119 - Audit Log Entries
// ============================================================
// PURPOSE: Shows a list of all bulk operations performed on loan applications
//
// KEY FEATURES:
// - SearchBox to find operations by user or date
// - Filter by operation type
// - View summary counts for each operation
// - See who did what and when
//
// KEY CONCEPT - "PageType = List":
//   Shows multiple records in rows and columns.
//   Each row is one bulk operation.
// ============================================================

page 50119 "Audit Log Entries"
{
    Caption = 'Audit Log Entries';
    PageType = List;
    SourceTable = "Audit Log Entry";
    ApplicationArea = All;
    UsageCategory = Lists;
    Editable = false;
    // Can't edit audit entries (read-only for compliance)

    layout
    {
        area(Content)
        {
            repeater(AuditLines)
            {
                // "repeater" creates the grid/table of rows
                // Each field below becomes a column

                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Unique entry number for this audit record.';
                }
                field("User ID"; Rec."User ID")
                {
                    ToolTip = 'The user who performed this operation.';
                }
                field("Operation Date"; Rec."Operation Date")
                {
                    ToolTip = 'Date and time the operation was performed.';
                }
                field("Operation Type"; Rec."Operation Type")
                {
                    ToolTip = 'Type of bulk operation (Bulk Approve, etc.).';
                }
                field("Total Selected"; Rec."Total Selected")
                {
                    ToolTip = 'How many records were selected.';
                }
                field("Approved Count"; Rec."Approved Count")
                {
                    ToolTip = 'How many records were successfully processed.';
                }
                field("Skipped Count"; Rec."Skipped Count")
                {
                    ToolTip = 'How many records were skipped due to validation errors.';
                }
                field("Success"; Rec."Success")
                {
                    ToolTip = 'Whether all records were successfully processed.';
                }
                field("Description"; Rec."Description")
                {
                    ToolTip = 'Summary description of the operation and results.';
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(Refresh)
            {
                Caption = 'Refresh';
                ToolTip = 'Refresh the list to see latest audit entries.';
                Image = Refresh;

                trigger OnAction()
                begin
                    CurrPage.Update(false);
                end;
            }
        }
    }
}
