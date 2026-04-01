// ============================================================
// Codeunit 50100 - Member Management (UPDATED with SMS)
// ============================================================
// PURPOSE: All business logic for managing SACCO members.
//
// SMS INTEGRATION CHANGE LOG:
//   ApproveApplication() now calls SMSMgt.SendMemberApprovalSMS()
//   AFTER the member record is created.  The SMS call is placed
//   AFTER the email call and is also fully non-blocking — an SMS
//   failure will never roll back the member creation.
//
// HOW THE CALL CHAIN WORKS:
//   ApproveApplication()
//       │
//       ├─ MemberApp.Status := Approved  (update application)
//       ├─ TransferApplicationToMember() (create Member record)
//       │       └─ SendWelcomeEmailToMember()   (email — uses AT email table)
//       └─ SendMemberApprovalSMS()              (SMS — calls Python webhook)
//
// RejectApplication() similarly calls SendRejectionEmailToMember()
// followed by nothing for SMS (rejection email is sufficient, but
// you could add SMS rejection here if desired).
// ============================================================

codeunit 50100 "Member Management"
{
    // -------------------------------------------------------
    // TransferApplicationToMember
    // -------------------------------------------------------
    procedure TransferApplicationToMember(ApplicationID: Code[20]): Boolean
    var
        MemberApp: Record "Member Application";
        Member: Record "Member";
        MemberID: Code[20];
    begin
        if not MemberApp.Get(ApplicationID) then
            Error('Member Application %1 not found', ApplicationID);

        if MemberApp.Status <> Enum::"Member Application Status"::Approved then
            Error('Application must be Approved before transferring to Members table');

        Member.SetRange("Application ID", ApplicationID);
        if Member.FindFirst() then
            Error('Member for this application already exists');

        MemberID := GenerateMemberID();

        Member.Init();
        Member."Member ID"         := MemberID;
        Member."Application ID"    := MemberApp."Application ID";
        Member."First Name"        := MemberApp."First Name";
        Member."Last Name"         := MemberApp."Last Name";
        Member."Full Name"         := MemberApp."First Name" + ' ' + MemberApp."Last Name";
        Member."Email"             := MemberApp."Email";
        Member."Phone Number"      := MemberApp."Phone Number";
        Member."Date of Birth"     := MemberApp."Date of Birth";
        Member."Address"           := MemberApp."Address";
        Member."City"              := MemberApp."City";
        Member."Postal Code"       := MemberApp."Postal Code";
        Member."Country"           := MemberApp."Country";
        Member."ID Number"         := MemberApp."ID Number";
        Member."Registration Date" := Today;
        Member."Status"            := Enum::"Member Status"::Active;
        Member."Occupation"        := MemberApp."Occupation";
        Member."Annual Income"     := MemberApp."Annual Income";
        Member."Member Category"   := MemberApp."Member Category";
        Member."Account Balance"   := 0;

        Member.Insert();

        // Send welcome email using the rich-text email template
        // (this uses WelcomeEmailSetupTable, not the AT email API)
        SendWelcomeEmailToMember(Member);

        exit(true);
    end;

    // -------------------------------------------------------
    // ApproveApplication
    // -------------------------------------------------------
    // CHANGE: After TransferApplicationToMember() succeeds,
    // we look up the newly created Member record and send an
    // SMS via the Python/Africa's Talking webhook.
    // -------------------------------------------------------
    procedure ApproveApplication(ApplicationID: Code[20])
    var
        MemberApp: Record "Member Application";
        Member: Record "Member";
        SMSMgt: Codeunit "SMS Notification Mgt";   // ← SMS integration
    begin
        if not MemberApp.Get(ApplicationID) then
            Error('Member Application %1 not found', ApplicationID);

        if MemberApp.Status <> Enum::"Member Application Status"::Pending then
            Error('Only Pending applications can be approved. Current status is %1.', MemberApp.Status);

        MemberApp.Status          := Enum::"Member Application Status"::Approved;
        MemberApp."Approval Date" := Today;
        MemberApp.Modify();

        if TransferApplicationToMember(ApplicationID) then begin
            Message('Application %1 approved and member created successfully', ApplicationID);

            // ── SMS: Notify the member of their approval ─────────────────
            // Re-read the Member record that TransferApplicationToMember()
            // just created so we have the generated Member ID and phone.
            //
            // KEY DESIGN DECISION: we call SMS AFTER Message() so the user
            // sees the success confirmation even if SMS is misconfigured.
            // The SMSMgt codeunit is entirely non-blocking — it logs failures
            // to the Audit Log but never raises an Error().
            Member.SetRange("Application ID", ApplicationID);
            if Member.FindFirst() then
                SMSMgt.SendMemberApprovalSMS(
                    Member."Phone Number",    // Where to send the SMS
                    Member."First Name",      // Personalises the greeting
                    Member."Member ID");      // Included in the message body
        end;
    end;

    // -------------------------------------------------------
    // RejectApplication -  
    // -------------------------------------------------------
    procedure RejectApplication(ApplicationID: Code[20]; RejectionReason: Text[250])
    var
        MemberApp: Record "Member Application";
    begin
        if not MemberApp.Get(ApplicationID) then
            Error('Member Application %1 not found', ApplicationID);

        if MemberApp.Status <> Enum::"Member Application Status"::Pending then
            Error('Only Pending applications can be rejected. Current status is %1.', MemberApp.Status);

        MemberApp.Status             := Enum::"Member Application Status"::Rejected;
        MemberApp."Rejection Reason" := RejectionReason;
        MemberApp."Approval Date"    := Today;
        MemberApp.Modify();

        Message('Application %1 has been rejected', ApplicationID);
        SendRejectionEmailToMember(MemberApp);
        // NOTE: If you also want an SMS on rejection, add this line:
        // SMSMgt.SendRejectionSMS(MemberApp."Phone Number", MemberApp."First Name", RejectionReason);
    end;

    // -------------------------------------------------------
    // SendWelcomeEmailToMember — uses the rich-text email template////
    // -------------------------------------------------------
    procedure SendWelcomeEmailToMember(Member: Record Member)
    var
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        Subject: Text[100];
        Body: Text;
    begin
        if (Member.Email = '') or (Member."Full Name" = '') then
            exit;

        Subject := 'Welcome to the SACCO - Registration Confirmed';
        Body    += FindReplaceWelcomeEmailSetup(Body, Member);

        EmailMessage.Create(Member."Email", Subject, Body, true);
        if not Email.Send(EmailMessage) then
            Message('Member created successfully, but the welcome email could not be sent. ' +
                    'Please check Email Account setup (search "Email Accounts").');
    end;

    // -------------------------------------------------------
    // SendRejectionEmailToMember — uses the rejection email template
    // -------------------------------------------------------
    procedure SendRejectionEmailToMember(Member: Record "Member Application")
    var
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        Subject: Text[100];
        Body: Text;
    begin
        if (Member.Email = '') or (Member."First Name" = '') then
            exit;

        Subject := 'Application not approved - Action required';
        Body    += FindReplaceRejectionEmailSetup(Body, Member);

        EmailMessage.Create(Member."Email", Subject, Body, true);
        if not Email.Send(EmailMessage) then
            Message('Rejection recorded, but the email could not be sent. ' +
                    'Please check Email Account setup (search "Email Accounts").');
    end;

    // -------------------------------------------------------
    // FindReplaceWelcomeEmailSetup
    // -------------------------------------------------------
    procedure FindReplaceWelcomeEmailSetup(EmailText: Text; Member: Record Member): Text
    var
        WelcomeEmailSetupRecord: Record WelcomeEmailSetupTable;
        EmailBody: Text;
    begin
        if not WelcomeEmailSetupRecord.FindFirst() then
            exit(EmailText);

        EmailBody := WelcomeEmailSetupRecord.GetRichText();
        EmailBody := EmailBody.Replace('{Member ID}',          Member."Member ID");
        EmailBody := EmailBody.Replace('{Application ID}',     Member."Application ID");
        EmailBody := EmailBody.Replace('{First Name}',         Member."First Name");
        EmailBody := EmailBody.Replace('{Last Name}',          Member."Last Name");
        EmailBody := EmailBody.Replace('{Full Name}',          Member."Full Name");
        EmailBody := EmailBody.Replace('{Email}',              Member."Email");
        EmailBody := EmailBody.Replace('{Phone Number}',       Member."Phone Number");
        EmailBody := EmailBody.Replace('{Date of Birth}',      Format(Member."Date of Birth"));
        EmailBody := EmailBody.Replace('{Address}',            Member."Address");
        EmailBody := EmailBody.Replace('{City}',               Member."City");
        EmailBody := EmailBody.Replace('{Postal Code}',        Member."Postal Code");
        EmailBody := EmailBody.Replace('{Country}',            Member."Country");
        EmailBody := EmailBody.Replace('{ID/Passport Number}', Member."ID Number");
        EmailBody := EmailBody.Replace('{Registration Date}',  Format(Member."Registration Date"));
        EmailBody := EmailBody.Replace('{Member Status}',      Format(Member."Status"));
        EmailBody := EmailBody.Replace('{Occupation}',         Member."Occupation");
        EmailBody := EmailBody.Replace('{Annual Income}',      Format(Member."Annual Income"));
        EmailBody := EmailBody.Replace('{Member Category}',    Member."Member Category");
        exit(EmailBody);
    end;

    // -------------------------------------------------------
    // FindReplaceRejectionEmailSetup
    // -------------------------------------------------------
    procedure FindReplaceRejectionEmailSetup(EmailText: Text; MemberRejected: Record "Member Application"): Text
    var
        RejectionEmailSetupRecord: Record RejectionEmailSetupTable;
        EmailBody: Text;
    begin
        if not RejectionEmailSetupRecord.FindFirst() then
            exit(EmailText);

        EmailBody := RejectionEmailSetupRecord.GetRichText();
        EmailBody := EmailBody.Replace('{Application ID}',   MemberRejected."Application ID");
        EmailBody := EmailBody.Replace('{First Name}',       MemberRejected."First Name");
        EmailBody := EmailBody.Replace('{Last Name}',        MemberRejected."Last Name");
        EmailBody := EmailBody.Replace('{Email}',            MemberRejected."Email");
        EmailBody := EmailBody.Replace('{Phone Number}',     MemberRejected."Phone Number");
        EmailBody := EmailBody.Replace('{Date of Birth}',    Format(MemberRejected."Date of Birth"));
        EmailBody := EmailBody.Replace('{Address}',          MemberRejected."Address");
        EmailBody := EmailBody.Replace('{City}',             MemberRejected."City");
        EmailBody := EmailBody.Replace('{Postal Code}',      MemberRejected."Postal Code");
        EmailBody := EmailBody.Replace('{Country}',          MemberRejected."Country");
        EmailBody := EmailBody.Replace('{ID Number}',        MemberRejected."ID Number");
        EmailBody := EmailBody.Replace('{Application Date}', Format(MemberRejected."Application Date"));
        EmailBody := EmailBody.Replace('{Status}',           Format(MemberRejected."Status"));
        EmailBody := EmailBody.Replace('{Approval Date}',    Format(MemberRejected."Approval Date"));
        EmailBody := EmailBody.Replace('{Rejection Reason}', MemberRejected."Rejection Reason");
        EmailBody := EmailBody.Replace('{Occupation}',       MemberRejected."Occupation");
        EmailBody := EmailBody.Replace('{Annual Income}',    Format(MemberRejected."Annual Income"));
        EmailBody := EmailBody.Replace('{Member Category}',  MemberRejected."Member Category");
        exit(EmailBody);
    end;

    // -------------------------------------------------------
    // GenerateMemberID (local)
    // -------------------------------------------------------
    local procedure GenerateMemberID(): Code[20]
    var
        Member: Record "Member";
        NextSeqNo: Integer;
        LastID: Code[20];
        DashPos: Integer;
        SeqText: Text;
    begin
        Member.SetCurrentKey("Member ID");
        if Member.FindLast() then begin
            LastID  := Member."Member ID";
            DashPos := StrLen(LastID);
            while (DashPos > 0) and (LastID[DashPos] <> '-') do
                DashPos -= 1;
            if DashPos > 0 then begin
                SeqText := CopyStr(Format(LastID), DashPos + 1);
                if not Evaluate(NextSeqNo, SeqText) then
                    NextSeqNo := 0;
            end;
            NextSeqNo += 1;
        end else
            NextSeqNo := 1;

        exit('MEM-' + Format(Today, 0, '<Year4><Month,2><Day,2>') +
             '-' + Format(NextSeqNo, 0, '<Integer,4>'));
    end;
}
