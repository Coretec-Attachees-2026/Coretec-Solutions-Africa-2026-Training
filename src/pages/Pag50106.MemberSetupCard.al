// ============================================================
// Page 50106 - Member Setup
// ============================================================
// PURPOSE: Configuration page where admin sets up No. Series
//          and G/L accounts for the SACCO system.
//
// KEY CONCEPT - "PageType = Card":
//   A Card page shows ONE record at a time (like a form).
//   Since Member Setup has only 1 record, Card is perfect.
//
// KEY CONCEPT - "InsertAllowed = false; DeleteAllowed = false":
//   We don't want users creating multiple setup records or deleting it.
//   The system creates the one-and-only record automatically.
// ============================================================

page 50106 "Member Setup"
{
    Caption = 'Member Setup';
    PageType = Card;
    SourceTable = "Member Setup";
    Permissions = tabledata "Sent Email" = RIMD,
                  tabledata "Email Outbox" = RIMD,
                  tabledata "Email Related Record" = RIMD,
                  tabledata "Email Account" = R;
    ApplicationArea = All;
    UsageCategory = Administration;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            // ----- Member Application Settings -----
            group("Member Application")
            {
                Caption = 'Member Application';
                field("Member Application Nos."; rec."Member Application Nos.")
                {
                    ToolTip = 'Specifies the No. Series used to generate member application IDs.';
                }
            }

            // ----- Loan Settings (NEW) -----
            group("Loan Settings")
            {
                Caption = 'Loan Settings';

                field("Loan Application Nos."; rec."Loan Application Nos.")
                {
                    ToolTip = 'Specifies the No. Series used to generate loan application numbers (e.g., LN-20260101-00001).';
                }
                field("Loans Receivable Account"; rec."Loans Receivable Account")
                {
                    ToolTip = 'The G/L Account to DEBIT when a loan is disbursed. This is an asset account - it represents money members owe the SACCO.';
                }
                field("Loan Disbursement Account"; rec."Loan Disbursement Account")
                {
                    ToolTip = 'The G/L Account to CREDIT when a loan is disbursed. This is typically the bank account from which loan money is paid out.';
                }
            }

            group("Email Settings")
            {
                Caption = 'Email Settings';
                InstructionalText = 'Approval and rejection emails now use hardcoded system messages only. Use Send Test Email to verify email account and scenario setup.';
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Send Test Email")
            {
                Caption = 'Send Test Email';
                ApplicationArea = All;
                Image = Email;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Send a test email now to verify that Email Accounts and scenario mapping are working before member approvals.';

                trigger OnAction()
                var
                    TestEmailInput: Page "Test Email Input";
                    RecipientEmail: Text[100];
                    StatusMessage: Text;
                begin
                    if TestEmailInput.RunModal() <> Action::OK then
                        exit;

                    RecipientEmail := DelChr(TestEmailInput.GetRecipientEmail(), '<>', ' ');
                    if RecipientEmail = '' then
                        Error('Please enter a recipient email address.');

                    SendTestEmail(RecipientEmail, StatusMessage);
                    Message('%1', StatusMessage);
                end;
            }

            action("Member Dashboard")
            {
                Caption = 'Member Dashboard';
                ApplicationArea = All;
                Image = AnalysisView;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Open the Member Dashboard with summary SACCO statistics.';

                trigger OnAction()
                begin
                    Page.Run(Page::"Member Dashboard");
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        MemberAppNoSeriesMgt: Codeunit "Member App No. Series Mgt";
    begin
        MemberAppNoSeriesMgt.EnsureMemberApplicationNoSeriesAndSetup();
        rec.GetOrCreateSetup();
    end;

    local procedure SendTestEmail(RecipientEmail: Text[100]; var StatusMessage: Text)
    var
        EmailAccount: Record "Email Account";
        EmailMessage: Codeunit "Email Message";
        Subject: Text[100];
        Body: Text;
        SendFailureDetails: Text;
    begin
        if not HasEmailSendPermissions(StatusMessage) then
            exit;

        Subject := 'BOOMPOP SACCO - Email Setup Test';
        Body := 'This is a test email sent from Member Setup.<br/><br/>';
        Body += 'If you received this, your Business Central email configuration is working.<br/><br/>';
        Body += 'Sent at: ' + Format(CurrentDateTime) + '<br/>';
        Body += 'Company: ' + CompanyName();

        EmailMessage.Create(RecipientEmail, Subject, Body, true);

        ClearLastError();
        if TrySendTestEmailDefaultScenario(EmailMessage) then begin
            StatusMessage := StrSubstNo('Test email sent successfully to %1 using Default Email Scenario.', RecipientEmail);
            exit;
        end;

        SendFailureDetails := GetLastErrorText();

        if EmailAccount.FindFirst() then begin
            ClearLastError();
            if TrySendTestEmailByAccount(EmailMessage, EmailAccount."Account Id", EmailAccount.Connector) then begin
                StatusMessage := StrSubstNo('Test email sent successfully to %1 using configured email account fallback.', RecipientEmail);
                exit;
            end;

            if GetLastErrorText() <> '' then
                SendFailureDetails := GetLastErrorText();
        end;

        if EmailAccount.IsEmpty() then
            StatusMessage := 'Test email failed: no Email Account is configured. Search "Email Accounts" and add an account.'
        else
            if SendFailureDetails = '' then
                StatusMessage := 'Test email failed: Email Account exists, but sending failed. Check connector credentials and scenario mapping.'
            else
                StatusMessage := CopyStr(
                    'Test email failed: ' + SendFailureDetails,
                    1,
                    250);
    end;

    local procedure HasEmailSendPermissions(var FailureText: Text): Boolean
    var
        [SecurityFiltering(SecurityFilter::Ignored)]
        SentEmail: Record "Sent Email";
        [SecurityFiltering(SecurityFilter::Ignored)]
        EmailOutbox: Record "Email Outbox";
        [SecurityFiltering(SecurityFilter::Ignored)]
        EmailRelatedRecord: Record "Email Related Record";
    begin
        if not SentEmail.ReadPermission() or
           not SentEmail.WritePermission() or
           not EmailOutbox.ReadPermission() or
           not EmailOutbox.WritePermission() or
           not EmailRelatedRecord.ReadPermission() or
           not EmailRelatedRecord.WritePermission()
        then begin
            FailureText := 'Test email failed: current user lacks required permissions for Sent Email, Email Outbox, or Email Related Record.';
            exit(false);
        end;

        exit(true);
    end;

    [TryFunction]
    local procedure TrySendTestEmailDefaultScenario(var EmailMessage: Codeunit "Email Message")
    var
        Email: Codeunit Email;
    begin
        if not Email.Send(EmailMessage, Enum::"Email Scenario"::Default) then
            Error('Email send returned false using Default scenario.');
    end;

    [TryFunction]
    local procedure TrySendTestEmailByAccount(var EmailMessage: Codeunit "Email Message"; EmailAccountId: Guid; EmailConnector: Enum "Email Connector")
    var
        Email: Codeunit Email;
    begin
        if not Email.Send(EmailMessage, EmailAccountId, EmailConnector) then
            Error('Email send returned false using configured email account.');
    end;
}
