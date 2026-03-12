// ============================================================
// Page 50112 - Application Audit Log
// ============================================================
// PURPOSE: Shows a read-only list of all audit log entries.
//          Cannot be edited, inserted, or deleted by users.
// ============================================================

page 50112 "Application Audit Log"
{
    Caption = 'Application Audit Log';
    PageType = List;
    SourceTable = "Application Audit Log";
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
                field("Date-Time"; Rec."Date-Time")
                {
                    ToolTip = 'When the action was performed.';
                }
                field("User ID"; Rec."User ID")
                {
                    ToolTip = 'Who performed the action.';
                }
                field("Action Type"; Rec."Action Type")
                {
                    ToolTip = 'What type of action was taken.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ToolTip = 'The type of document this action relates to.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'The document ID this action relates to.';
                }
                field("Description"; Rec."Description")
                {
                    ToolTip = 'Description of the action taken.';
                }
            }
        }
    }
}
