// ============================================================
// Table 50104 - Member Setup (UPDATED for SMS Integration)
// ============================================================
// PURPOSE: Stores configuration settings for the SACCO system.
//
// WHAT'S NEW (SMS Integration):
//   field 6 "SMS Webhook URL"    → The base URL of your Python webhook server
//                                   e.g. https://xxxx.ngrok-free.app
//                                   or   https://sms.yoursacco.co.ke
//   field 7 "SMS Webhook Secret" → Shared secret (optional) that BC sends
//                                   in the X-Webhook-Secret header so the
//                                   Python server can verify calls come
//                                   from your BC instance only.
//
// WHY STORE THE URL IN SETUP INSTEAD OF HARDCODING IT?
//   The URL changes whenever you restart ngrok (during testing) or
//   redeploy the server (in production).  Storing it in the setup
//   page means admins can update it without a developer, and without
//   needing to republish the BC extension.
// ============================================================

table 50104 "Member Setup"
{
    Caption = 'Member Setup';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            Editable = false;
        }
        field(2; "Member Application Nos."; Code[20])
        {
            Caption = 'Member Application Nos.';
            TableRelation = "No. Series";
        }
        field(3; "Loan Application Nos."; Code[20])
        {
            Caption = 'Loan Application Nos.';
            TableRelation = "No. Series";
        }
        field(4; "Loans Receivable Account"; Code[20])
        {
            Caption = 'Loans Receivable Account';
            TableRelation = "G/L Account"."No." where("Direct Posting" = const(true));
        }
        field(5; "Loan Disbursement Account"; Code[20])
        {
            Caption = 'Loan Disbursement Account';
            TableRelation = "G/L Account"."No." where("Direct Posting" = const(true));
        }

        // ─── SMS INTEGRATION FIELDS (NEW) ─────────────────────────────────

        field(6; "SMS Webhook URL"; Text[250])
        {
            Caption = 'SMS Webhook URL';
            // The base URL of the Python Flask server.
            // In development (ngrok): https://xxxx.ngrok-free.app
            // In production:          https://sms.yoursacco.co.ke
            //
            // The AL code appends "/sms/send" automatically.
            // Leave blank to disable SMS notifications entirely.
            //
            // KEY CONCEPT — why Text[250] not Code[250]?
            //   URLs are case-sensitive (especially query strings and paths).
            //   Code type auto-converts to UPPERCASE, which would break URLs.
            //   Always use Text for URLs, email addresses, and paths.
        }
        field(7; "SMS Webhook Secret"; Text[100])
        {
            Caption = 'SMS Webhook Secret';
            // A shared secret that BC sends in the X-Webhook-Secret header
            // and the Python server validates before processing the request.
            // Think of it as a password for the webhook.
            //
            // Generate one with:
            //   python -c "import secrets; print(secrets.token_hex(32))"
            //
            // SAME value must be in both:
            //   - This field in Member Setup (BC side)
            //   - AT_WEBHOOK_SECRET in .env (Python side)
            //
            // Leave blank to skip the security check (local testing only).
        }
        field(8; "Test Phone Number"; Text[20])
        {
            Caption = 'Test Phone Number';
            // Used for the Test SMS action on the setup page.
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        if "Primary Key" = '' then
            "Primary Key" := 'SETUP';
    end;

    procedure GetOrCreateSetup()
    begin
        if not Get('SETUP') then begin
            Init();
            "Primary Key" := 'SETUP';
            Insert(true);
        end;
    end;
}
