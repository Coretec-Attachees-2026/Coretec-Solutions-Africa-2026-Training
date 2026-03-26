// ============================================================
// Page 50106 - Member Setup (UPDATED for SMS Integration)
// ============================================================
// PURPOSE: Configuration page for the SACCO system.
//
// CHANGE LOG (SMS Integration):
//   Added "SMS Settings" group with two new fields:
//     - SMS Webhook URL    → URL of the Python Flask server
//     - SMS Webhook Secret → Shared security token
//   Added "Test SMS" action so admins can verify the connection
//   is working without needing to approve a real member.
// ============================================================

page 50106 "Member Setup"
{
    Caption = 'Member Setup';
    PageType = Card;
    SourceTable = "Member Setup";
    ApplicationArea = All;
    UsageCategory = Administration;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group("Member Application")
            {
                Caption = 'Member Application';
                field("Member Application Nos."; rec."Member Application Nos.")
                {
                    ToolTip = 'Specifies the No. Series used to generate member application IDs.';
                }
            }

            group("Loan Settings")
            {
                Caption = 'Loan Settings';
                field("Loan Application Nos."; rec."Loan Application Nos.")
                {
                    ToolTip = 'Specifies the No. Series used to generate loan application numbers.';
                }
                field("Loans Receivable Account"; rec."Loans Receivable Account")
                {
                    ToolTip = 'The G/L Account to DEBIT when a loan is disbursed.';
                }
                field("Loan Disbursement Account"; rec."Loan Disbursement Account")
                {
                    ToolTip = 'The G/L Account to CREDIT when a loan is disbursed (typically your bank account).';
                }
            }

            // ─── NEW: SMS Settings ──────────────────────────────────────────
            group("SMS Settings")
            {
                Caption = 'SMS Settings (Africa''s Talking Integration)';
                InstructionalText = 'Enter the URL of your Python SMS webhook server. Leave blank to disable SMS notifications. For testing, use an ngrok HTTPS URL.';

                field("SMS Webhook URL"; rec."SMS Webhook URL")
                {
                    ToolTip = 'The base URL of your Python Flask SMS webhook server. Example: https://xxxx.ngrok-free.app The system appends /sms/send automatically. Leave blank to disable SMS notifications.';
                }
                field("SMS Webhook Secret"; rec."SMS Webhook Secret")
                {
                    ToolTip = 'A shared secret token sent in the X-Webhook-Secret header. Must match AT_WEBHOOK_SECRET in your Python .env file. Leave blank to skip the security check (local testing only).';
                    ExtendedDatatype = Masked;
                    // Masked = shown as *** in the UI, protecting the secret
                    // from shoulder-surfing. Stored as plain text in the DB.
                }
                // New field for test phone number
                field("Test Phone Number"; rec."Test Phone Number")
                {
                    ToolTip = 'Enter a phone number (international format: +254712345678) to use for sending test SMS.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            // ── Test SMS ────────────────────────────────────────────────────
            // Sends a test SMS to a phone number the admin enters.
            // Confirms the webhook URL is reachable and AT credentials work
            // BEFORE a real member approval triggers SMS.
            action(TestSMS)
            {
                Caption = 'Send Test SMS';
                ApplicationArea = All;
                Image = Email;        // Closest available icon
                // Promoted properties removed for compatibility
                ToolTip = 'Send a test SMS to verify the webhook URL and Africa''s Talking credentials are working correctly.';

                trigger OnAction()
                var
                    SMSMgt: Codeunit "SMS Notification Mgt";
                    TestMessage: Text;
                begin
                    if rec."Test Phone Number" = '' then begin
                        Message('Please enter a phone number in the Test Phone Number field.');
                        exit;
                    end;

                    TestMessage := StrSubstNo(
                        'TEST: SACCO SMS integration is working correctly. Sent from Business Central at %1.',
                        Format(CurrentDateTime, 0, '<Day,2>/<Month,2>/<Year4> <Hours24,2>:<Minutes,2>'));

                    // SMSMgt reads the URL and secret from this same setup record
                    SMSMgt.SendTestSMS(rec."Test Phone Number", TestMessage);
                    Message('Test SMS sent. Check the phone and the Application Audit Log for the result.');
                end;
            }

            // ── Member Dashboard ─────────────────────────────────────────────
            action(MemberDashboard)
            {
                Caption = 'Member Dashboard';
                ApplicationArea = All;
                Image = UserInterface;
                // Promoted properties removed for compatibility

                trigger OnAction()
                begin
                    Page.Run(Page::"Member Dashboard");
                end;
            }
        }
        area(Promoted)
        {
            actionref(TestSMS_Promoted; TestSMS) { }
            actionref(MemberDashboard_Promoted; MemberDashboard) { }
        }
    }

    trigger OnOpenPage()
    var
        MemberAppNoSeriesMgt: Codeunit "Member App No. Series Mgt";
    begin
        MemberAppNoSeriesMgt.EnsureMemberApplicationNoSeriesAndSetup();
        rec.GetOrCreateSetup();
    end;
}
