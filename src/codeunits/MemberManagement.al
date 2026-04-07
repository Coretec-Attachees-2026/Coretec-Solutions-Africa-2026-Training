codeunit 50104 "Member Management"
{
    procedure TransferApplicationToMember(ApplicationID: Code[20]): Boolean
    var
        MemberApp: Record "Member Application";   // The application to read from
        Member: Record "Member";                    // The new member to create
        MemberID: Code[20];                         // Generated member ID
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
        Member."Member ID" := MemberID;
        Member."Application ID" := MemberApp."Application ID";
        Member."First Name" := MemberApp."First Name";
        Member."Last Name" := MemberApp."Last Name";
        Member."Full Name" := MemberApp."First Name" + ' ' + MemberApp."Last Name";
        Member."Email" := MemberApp."Email";
        Member."Phone Number" := MemberApp."Phone Number";
        Member."Date of Birth" := MemberApp."Date of Birth";
        Member."Address" := MemberApp."Address";
        Member."City" := MemberApp."City";
        Member."Postal Code" := MemberApp."Postal Code";
        Member."Country" := MemberApp."Country";
        Member."ID Number" := MemberApp."ID Number";
        Member."Registration Date" := CurrentDateTime;  // Now
        Member."Status" := Enum::"Member Status"::Active;  // Start as Active
        Member."Occupation" := MemberApp."Occupation";
        Member."Annual Income" := MemberApp."Annual Income";
        Member."Member Category" := MemberApp."Member Category";
        Member."Account Balance" := 0;  // New member starts with zero balance

        // Step 6: Save to database
        Member.Insert();

        exit(true);  // Return success
    end;

    procedure ApproveApplication(ApplicationID: Code[20])
    var
        MemberApp: Record "Member Application";
    begin
        // Find the application
        if not MemberApp.Get(ApplicationID) then
            Error('Member Application %1 not found', ApplicationID);

        // Only "Pending" applications can be approved
        if MemberApp.Status <> Enum::"Member Application Status"::Pending then
            Error('Only Pending applications can be approved. Current status is %1.', MemberApp.Status);

        // Update the application status to Approved
        MemberApp.Status := Enum::"Member Application Status"::Approved;
        MemberApp."Approval Date" := CurrentDateTime;
        MemberApp.Modify();  // Save the changes

        // Create the member from the approved application
        if TransferApplicationToMember(ApplicationID) then
            Message('Application %1 approved and member created successfully', ApplicationID);
    end;


    procedure RejectApplication(ApplicationID: Code[20]; RejectionReason: Text[250])
    var
        MemberApp: Record "Member Application";
        jobQueueEntry: Record "Job Queue Entry";
        jobQueueEnqueue: Codeunit "Job Queue - Enqueue";
        Application: Record "Member Application";
    begin
        if not MemberApp.Get(ApplicationID) then
            Error('Member Application %1 not found', ApplicationID);

        // Only "Pending" applications can be rejected
        if MemberApp.Status <> Enum::"Member Application Status"::Pending then
            Error('Only Pending applications can be rejected. Current status is %1.', MemberApp.Status);

        // Update status and save the reason
        MemberApp.Status := Enum::"Member Application Status"::Rejected;
        MemberApp."Rejection Reason" := RejectionReason;
        MemberApp."Approval Date" := CurrentDateTime;  // Records when the decision was made
        MemberApp.Modify();

        Message('Application %1 has been rejected', ApplicationID);
        jobQueueEntry.Init();
        jobQueueEntry."Object Type to Run" := jobQueueEntry."Object Type to Run"::Codeunit;
        jobQueueEntry."Object ID to Run" := Codeunit::"Approve Email";
        // SelectedRecord := // Continuateion
        // JobQueueEntry."Record ID to Process" := Application.Get();
        jobQueueEntry."Earliest Start Date/Time" := CurrentDateTime();
        jobQueueEntry.Status := jobQueueEntry.Status::Ready;
        jobQueueEntry.Insert();
        jobQueueEnqueue.Run(jobQueueEntry);
        SendRejectionEmailToMember(MemberApp);
    end;

    local procedure GenerateMemberID(): Code[20]
    var
        Member: Record "Member";
        MemberCount: Integer;
    begin
        // Sort by Registration Date to find the last member
        Member.SetCurrentKey("Registration Date");

        // Count existing members (or start at 1 if none exist)
        if Member.FindLast() then
            MemberCount := Member.Count + 1
        else
            MemberCount := 1;

        // Build and return the ID string
        // e.g., 'MEM-20260303-0001'
        exit('MEM-' + Format(Today, 0, '<Year4><Month,2><Day,2>') + '-' + Format(MemberCount, 0, '<Integer,4>'));
    end;

    procedure SendWelcomeEmailToMember(Member: Record Member)
    var
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        Subject: Text[100];
        Body: Text;
    begin
        if (Member.Email = '') or (Member."Full Name" = '') then
            exit;
        Subject := 'Welcome to the SACCO - Regisration Confirmed';

        Body += FindReplaceWelcomeEmailSetup(Body, Member);

        EmailMessage.Create(Member."Email", Subject, Body, true);
        if not Email.Send(EmailMessage) then
            Message('Member created successfully, but the welcome email could not be sent. Please check Email Account setup (search "Email Accounts")');

    end;

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

        Body += FindReplaceRejectionEmailSetup(Body, Member);

        EmailMessage.Create(Member."Email", Subject, Body, true);
        if not Email.Send(EmailMessage) then
            Message('Member created successfully, but the welcome email could not be sent. Please check Email Account setup (search "Email Accounts")');

    end;

    procedure FindReplaceWelcomeEmailSetup(EmailText: Text; Member: Record Member): Text
    var
        WelcomeEmailSetupRecord: Record WelcomeEmailSetupTable;
        EmailBody: Text;
    begin
        if not WelcomeEmailSetupRecord.FindFirst() then
            exit(EmailText);

        EmailBody := WelcomeEmailSetupRecord.GetRichText();

        EmailBody := EmailBody.Replace('{Member ID}', Member."Member ID");
        EmailBody := EmailBody.Replace('{Application ID}', Member."Application ID");
        EmailBody := EmailBody.Replace('{First Name}', Member."First Name");
        EmailBody := EmailBody.Replace('{Last Name}', Member."Last Name");
        EmailBody := EmailBody.Replace('{Full Name}', Member."Full Name");
        EmailBody := EmailBody.Replace('{Email}', Member."Email");
        EmailBody := EmailBody.Replace('{Phone Number}', Member."Phone Number");
        EmailBody := EmailBody.Replace('{Date of Birth}', Format(Member."Date of Birth"));
        EmailBody := EmailBody.Replace('{Address}', Member."Address");
        EmailBody := EmailBody.Replace('{City}', Member."City");
        EmailBody := EmailBody.Replace('{Postal Code}', Member."Postal Code");
        EmailBody := EmailBody.Replace('{Country}', Member."Country");
        EmailBody := EmailBody.Replace('{ID/Passport Number}', Member."ID Number");
        EmailBody := EmailBody.Replace('{Registration Date}', Format(Member."Registration Date"));
        EmailBody := EmailBody.Replace('{Member Status}', Format(Member."Status"));
        EmailBody := EmailBody.Replace('{Occupation}', Member."Occupation");
        EmailBody := EmailBody.Replace('{Annual Income}', Format(Member."Annual Income"));
        EmailBody := EmailBody.Replace('{Member Category}', Member."Member Category");

        exit(EmailBody);
    end;

    procedure FindReplaceRejectionEmailSetup(EmailText: Text; MemberRejected: Record "Member Application"): Text
    var
        RejectionEmailSetupRecord: Record RejectionEmailSetupTable;
        EmailBody: Text;
    begin
        if not RejectionEmailSetupRecord.FindFirst() then
            exit(EmailText);

        EmailBody := RejectionEmailSetupRecord.GetRichText();

        EmailBody := EmailBody.Replace('{Application ID}', MemberRejected."Application ID");
        EmailBody := EmailBody.Replace('{First Name}', MemberRejected."First Name");
        EmailBody := EmailBody.Replace('{Last Name}', MemberRejected."Last Name");
        EmailBody := EmailBody.Replace('{Email}', MemberRejected."Email");
        EmailBody := EmailBody.Replace('{Phone Number}', MemberRejected."Phone Number");
        EmailBody := EmailBody.Replace('{Date of Birth}', Format(MemberRejected."Date of Birth"));
        EmailBody := EmailBody.Replace('{Address}', MemberRejected."Address");
        EmailBody := EmailBody.Replace('{City}', MemberRejected."City");
        EmailBody := EmailBody.Replace('{Postal Code}', MemberRejected."Postal Code");
        EmailBody := EmailBody.Replace('{Country}', MemberRejected."Country");
        EmailBody := EmailBody.Replace('{ID Number}', MemberRejected."ID Number");
        EmailBody := EmailBody.Replace('{Application Date}', Format(MemberRejected."Application Date"));
        EmailBody := EmailBody.Replace('{Status}', Format(MemberRejected."Status"));
        EmailBody := EmailBody.Replace('{Approval Date}', Format(MemberRejected."Approval Date"));
        EmailBody := EmailBody.Replace('{Rejection Reason}', MemberRejected."Rejection Reason");
        EmailBody := EmailBody.Replace('{Occupation}', MemberRejected."Occupation");
        EmailBody := EmailBody.Replace('{Annual Income}', Format(MemberRejected."Annual Income"));
        EmailBody := EmailBody.Replace('{Member Category}', MemberRejected."Member Category");

        exit(EmailBody);
    end;
}
