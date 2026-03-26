// ============================================================
// Page 50102 - SMS Log List
// ============================================================
// PURPOSE: Shows all SMS messages that have been sent or failed.
//          Admin can use this to verify SMS was sent and
//          debug any failures.
//
// FEATURES:
//   - View all sent/failed SMS messages
//   - Filter by Status (Sent / Failed)
//   - See which application triggered each SMS
//   - Clear old logs with one button
// ============================================================

page 50114 "SMS Log List"
{
    Caption = 'SMS Log';
    PageType = List;
    SourceTable = "SMS Log";
    SourceTableView = sorting("Sent DateTime") order(descending);  // ← added
    ApplicationArea = All;
    UsageCategory = Lists;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Entry No"; rec."Entry No")
                {
                    ToolTip = 'Specifies the unique log entry number';
                }
                field("Sent DateTime"; rec."Sent DateTime")
                {
                    ToolTip = 'Specifies when the SMS was sent';
                }
                field("Status"; rec."Status")
                {
                    ToolTip = 'Specifies whether the SMS was sent successfully or failed';

                    // KEY CONCEPT - StyleExpr:
                    //   Changes the text color based on the field value.
                    //   "Favorable" = green, "Unfavorable" = red
                    StyleExpr = StatusStyle;
                }
                field("Member Name"; rec."Member Name")
                {
                    ToolTip = 'Specifies the name of the member the SMS was sent to';
                }
                field("Phone Number"; rec."Phone Number")
                {
                    ToolTip = 'Specifies the phone number the SMS was sent to';
                }
                field("Application ID"; rec."Application ID")
                {
                    ToolTip = 'Specifies the application that triggered this SMS';
                }
                field("Triggered By"; rec."Triggered By")
                {
                    ToolTip = 'Specifies the event that triggered this SMS';
                }
                field("Message"; rec."Message")
                {
                    ToolTip = 'Specifies the content of the SMS message';
                }
                field("Error Message"; rec."Error Message")
                {
                    ToolTip = 'Specifies the error message if the SMS failed';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            // --- Clear Old Logs ---
            // Deletes all log entries older than 30 days
            action("Clear Old Logs")
            {
                Caption = 'Clear Logs Older Than 30 Days';
                Image = Delete;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    SMSLog: Record "SMS Log";
                    CutoffDate: DateTime;
                begin
                    if not Confirm('Delete all SMS logs older than 30 days?', false) then
                        exit;

                    // Calculate date 30 days ago
                    CutoffDate := CreateDateTime(CalcDate('<-30D>', Today), 0T);

                    // Filter and delete old records
                    SMSLog.SetFilter("Sent DateTime", '<%1', CutoffDate);
                    SMSLog.DeleteAll();

                    Message('Old SMS logs have been cleared successfully.');
                    CurrPage.Update(false);
                end;
            }

            // --- Show Only Failed ---
            action("Show Failed Only")
            {
                Caption = 'Show Failed SMS Only';
                Image = Warning;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    rec.SetRange(rec.Status, rec.Status::Failed);
                    CurrPage.Update(false);
                end;
            }

            // --- Show All ---
            action("Show All")
            {
                Caption = 'Show All';
                Image = List;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    rec.SetRange(rec.Status);
                    CurrPage.Update(false);
                end;
            }
        }
    }

    // KEY CONCEPT - Variables for StyleExpr:
    //   These are page-level variables used to color the Status field.
    //   OnAfterGetRecord fires every time a row is loaded.
    var
        StatusStyle: Text;

    trigger OnAfterGetRecord()
    begin
        // Color the status field green for Sent, red for Failed
        case rec.Status of
            rec.Status::Sent:
                StatusStyle := 'Favorable';
            rec.Status::Failed:
                StatusStyle := 'Unfavorable';
        end;
    end;
}
