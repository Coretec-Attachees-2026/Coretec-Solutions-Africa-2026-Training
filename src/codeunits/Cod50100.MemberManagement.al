// ============================================================
// Codeunit 50100 - Member Management
// ============================================================
// PURPOSE: Contains all the business logic for managing SACCO/Organization members.
//
// WHAT IS A CODEUNIT?
//   A Codeunit is a container for AL procedures (functions).
//   Think of it like a toolbox — it holds tools (procedures) that
//   do specific jobs. Pages call these procedures when users click buttons.
//
// KEY CONCEPT - "Separation of Concerns":
//   We keep business logic in Codeunits, NOT in Pages or Tables.
//   This makes code reusable, testable, and easier to maintain.
//   The Page handles the UI, the Codeunit handles the logic.
//
// PROCEDURES IN THIS CODEUNIT:
//   1. TransferApplicationToMember()  → Copies approved application data to Member table
//   2. ApproveApplication()           → Approves an application and creates the member
//   3. RejectApplication()            → Rejects an application with a reason
//   4. GenerateMemberID()             → Creates unique member IDs like MEM-20260303-0001
// ============================================================

codeunit 50100 "Member Management"
{

    // -------------------------------------------------------
    // TransferApplicationToMember
    // -------------------------------------------------------
    // PURPOSE: When an application is approved, this procedure
    //          copies all the applicant's data from the Application
    //          table (50100) to the Member table (50101).
    //
    // PARAMETERS:
    //   ApplicationID: Code[20] - The ID of the approved application
    //
    // RETURNS:
    //   Boolean - true if transfer was successful
    //
    // KEY CONCEPT - "Record":
    //   A Record variable (like MemberApp, Member) represents a row
    //   in a table. You can read fields, modify them, and save.
    //
    // KEY CONCEPT - ".Get()":
    //   RecordVariable.Get(PrimaryKeyValue) loads a specific record.
    //   Returns true if found, false if not.
    //
    // KEY CONCEPT - ".Init()":
    //   Initializes a new empty record (sets all fields to defaults).
    //   Must be called before .Insert() when creating new records.
    //
    // KEY CONCEPT - ".Insert()":
    //   Saves the new record to the database.
    // -------------------------------------------------------
    procedure TransferApplicationToMember(ApplicationID: Code[20]): Boolean
    var
        MemberApp: Record "Member Application";   // The application to read from
        Member: Record "Member";                    // The new member to create
        MemberID: Code[20];                         // Generated member ID
    begin
        // Step 1: Find the application
        // .Get() loads the record by its primary key
        if not MemberApp.Get(ApplicationID) then
            Error('Member Application %1 not found', ApplicationID);

        // Step 2: Verify it's been approved
        // We only create members from APPROVED applications
        if MemberApp.Status <> Enum::"Member Application Status"::Approved then
            Error('Application must be Approved before transferring to Members table');

        // Step 3: Check for duplicates
        // .SetRange() filters records - here we check if a member
        // already exists for this application
        Member.SetRange("Application ID", ApplicationID);
        if Member.FindFirst() then
            Error('Member for this application already exists');

        // Step 4: Generate a unique Member ID
        MemberID := GenerateMemberID();

        // Step 5: Create the new member record
        // Init() prepares an empty record
        // Then we copy each field from the application
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
        Member."Occupation Code" := MemberApp."Occupation Code";  // Copy occupation code from application
        Member."Annual Income" := MemberApp."Annual Income";
        Member."Member Category" := MemberApp."Member Category";
        Member."Account Balance" := 0;  // New member starts with zero balance

        // Step 6: Save to database
        Member.Insert();

        exit(true);  // Return success
    end;

    // -------------------------------------------------------
    // ApproveApplication
    // -------------------------------------------------------
    // PURPOSE: Approves a pending application and automatically
    //          creates the member record.
    //
    // WHAT HAPPENS:
    //   1. Finds the application by ID
    //   2. Checks it's in "Pending" status (can't approve twice!)
    //   3. Changes status to "Approved"
    //   4. Records the approval date
    //   5. Calls TransferApplicationToMember() to create the member
    //   6. Shows a success message
    //
    // KEY CONCEPT - ".Modify()":
    //   Saves changes to an EXISTING record in the database.
    //   (.Insert() creates NEW records, .Modify() updates existing ones)
    //
    // KEY CONCEPT - "Message()":
    //   Shows a pop-up dialog with information to the user.
    //   Unlike Error(), it doesn't stop the process.
    // -------------------------------------------------------
    procedure ApproveApplication(ApplicationID: Code[20])
    var
        MemberApp: Record "Member Application";
        NewMember: Record "Member";
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
        if TransferApplicationToMember(ApplicationID) then begin
            // Get the newly created member to send welcome email and SMS
            NewMember.SetRange("Application ID", ApplicationID);
            if NewMember.FindFirst() then begin
                SendWelcomeEmailToMember(NewMember);
                SendApprovalSMS(NewMember);
            end;
            Message('Application %1 approved and member created successfully', ApplicationID);
        end;
    end;

    // -------------------------------------------------------
    // RejectApplication
    // -------------------------------------------------------
    // PURPOSE: Rejects a pending application with a reason.
    //          No member record is created, but rejection email is sent.
    //
    // PARAMETERS:
    //   ApplicationID    - Which application to reject
    //   RejectionReason  - Why it was rejected (shown to the applicant)
    // -------------------------------------------------------
    procedure RejectApplication(ApplicationID: Code[20]; RejectionReason: Text[250])
    var
        MemberApp: Record "Member Application";
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

        // Send rejection email to applicant
        SendRejectionEmailToApplicant(MemberApp, RejectionReason);

        Message('Application %1 has been rejected and email sent to applicant', ApplicationID);
    end;

    // -------------------------------------------------------
    // GenerateMemberID (local)
    // -------------------------------------------------------
    // PURPOSE: Creates a unique Member ID like "MEM-20260303-0001"
    //
    // HOW IT WORKS:
    //   1. Counts how many members exist already
    //   2. Uses that count + 1 as the sequence number
    //   3. Builds ID: MEM-YYYYMMDD-#### (date + padded number)
    //
    // KEY CONCEPT - "local procedure":
    //   "local" means only THIS codeunit can call this procedure.
    //   External code (pages, other codeunits) cannot use it.
    //
    // KEY CONCEPT - Format():
    //   Format(Today, 0, '<Year4><Month,2><Day,2>') converts
    //   today's date into text like "20260303"
    //   Format(5, 0, '<Integer,4>') converts 5 into "0005" (padded)
    //
    // KEY CONCEPT - exit():
    //   exit(value) returns a value from a procedure.
    //   Similar to "return" in other programming languages.
    // -------------------------------------------------------
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

    // -------------------------------------------------------
    // SendWelcomeEmailToMember
    // -------------------------------------------------------
    // PURPOSE: Sends a welcome/registration email to the member
    //          when they are created from an approved application.
    //
    // HOW EMAIL WORKS IN BUSINESS CENTRAL:
    //   1. EmailMessage - Creates the email message object
    //   2. Email.Send() - Sends it using configured Email Account
    //
    // SETUP REQUIRED:
    //   Admin must configure an Email Account (search "Email Accounts" in BC).
    //   Options: Microsoft 365, SMTP, or Current User.
    //   Without setup, Email.Send returns false (we show message but don't block).
    //
    // HOW TO CONFIGURE EMAIL ACCOUNTS:
    //   1. Search "Email Accounts" in Business Central
    //   2. Click "+ New"
    //   3. Choose account type:
    //      - "SMTP" for mail servers (Gmail, Outlook SMTP, etc.)
    //      - "Microsoft 365" for Office 365 accounts
    //      - "Current User" for Windows authentication
    //   4. Fill in credentials (SMTP server, port, username, password)
    //   5. Test connection
    //   6. Save
    //
    // -------------------------------------------------------
    local procedure SendWelcomeEmailToMember(Member: Record "Member")
    var
        Email: Codeunit Email;
        EmailMessage: Codeunit "Email Message";
        Recipients: List of [Text];
        Subject: Text;
        Body: Text;
        TrimmedEmail: Text;
    begin
        // Trim the email address (remove leading/trailing spaces)
        TrimmedEmail := Member.Email.Trim();

        // Skip if member has no email address or name
        if (TrimmedEmail = '') or (Member."Full Name" = '') then
            exit;

        // Validate email format (must contain @ symbol)
        if TrimmedEmail.IndexOf('@') = 0 then begin
            Message('Invalid email format for member %1: %2. Email must contain @ symbol.', Member."Member ID", TrimmedEmail);
            exit;
        end;

        // Build the email subject
        Subject := 'Welcome to the SACCO - Registration Confirmed';

        // Build the email body (use HTML for better formatting with <br/> for line breaks)
        Body := 'Dear ' + Member."Full Name" + ',<br/><br/>';
        Body += 'Congratulations! Your membership has been approved.<br/>';
        Body += 'Your Member ID is: <strong>' + Member."Member ID" + '</strong><br/><br/>';
        Body += 'You can now access your account and apply for loans.<br/>';
        Body += 'Visit our member portal to get started.<br/><br/>';
        Body += 'Best regards,<br/>';
        Body += 'The SACCO Team<br/>';
        Body += '---<br/>';
        Body += 'Registration Date: ' + Format(Member."Registration Date", 0, '<Day>/<Month>/<Year>');

        // Add recipient to the email (use trimmed email)
        Recipients.Add(TrimmedEmail);

        // Create the email message (true = HTML formatted body for rich text)
        EmailMessage.Create(Recipients, Subject, Body, true);

        // Send the email using configured Email Account from BC
        if not Email.Send(EmailMessage) then
            Message('Email could not be sent to: %1. Please verify: (1) Email account is configured in BC, (2) Email account credentials are correct, (3) Email address is valid. Go to "Email Accounts" in Business Central.', TrimmedEmail);
    end;

    // -------------------------------------------------------
    // SendRejectionEmailToApplicant
    // -------------------------------------------------------
    // PURPOSE: Sends a rejection email to applicant with reason
    //          when their application is rejected.
    //
    // PARAMETERS:
    //   MemberApp: Record "Member Application" - The rejected application
    //   RejectionReason: Text - The reason for rejection
    //
    // EMAIL TEMPLATE SUPPORT:
    //   This procedure uses a template from Member Setup if configured.
    //   Template variables:
    //   - {First Name}       → Applicant's first name
    //   - {Application ID}   → Application reference number
    //   - {Rejection Reason} → Admin's reason for rejection
    //
    // FALLBACK:
    //   If no template configured, uses default message.
    //
    // -------------------------------------------------------
    local procedure SendRejectionEmailToApplicant(MemberApp: Record "Member Application"; RejectionReason: Text)
    var
        Email: Codeunit Email;
        EmailMessage: Codeunit "Email Message";
        MemberSetup: Record "Member Setup";
        Recipients: List of [Text];
        Subject: Text;
        Body: Text;
        TrimmedEmail: Text;
    begin
        // Trim the email address (remove leading/trailing spaces)
        TrimmedEmail := MemberApp.Email.Trim();

        // Skip if applicant has no email address or name
        if (TrimmedEmail = '') or (MemberApp."First Name" = '') then
            exit;

        // Get setup record to check for custom template
        MemberSetup.GetOrCreateSetup();

        // Use custom subject if configured, otherwise use default
        if MemberSetup."Rejection Email Subject" <> '' then
            Subject := MemberSetup."Rejection Email Subject"
        else
            Subject := 'Your SACCO Application - Status Update';

        // Replace variables in subject
        Subject := ReplaceTemplateVariables(Subject, MemberApp."First Name", MemberApp."Application ID", RejectionReason);

        // Build the email body with rejection reason
        Body := 'Dear ' + MemberApp."First Name" + ',<br/><br/>';
        Body += 'Thank you for your interest in our SACCO.<br/><br/>';
        Body += 'Unfortunately, we regret to inform you that your application (ID: <strong>' + MemberApp."Application ID" + '</strong>) has been <strong>rejected</strong>.<br/><br/>';
        Body += '<strong>Reason for Rejection:</strong><br/>';
        Body += RejectionReason + '<br/><br/>';
        Body += 'If you have any questions or would like to appeal this decision, please contact our office.<br/><br/>';
        Body += 'Best regards,<br/>';
        Body += 'The SACCO Team<br/>';
        Body += '---<br/>';
        Body += 'Application Date: ' + Format(MemberApp."Application Date", 0, '<Day>/<Month>/<Year>');

        // Add recipient to the email
        Recipients.Add(TrimmedEmail);

        // Create the email message (true = HTML formatted body for rich text)
        EmailMessage.Create(Recipients, Subject, Body, true);

        // Send the email using configured Email Account from BC
        if not Email.Send(EmailMessage) then
            Message('Rejection email could not be sent to: %1. Please verify email account setup in Business Central.', TrimmedEmail);
    end;

    // -------------------------------------------------------
    // ReplaceTemplateVariables
    // -------------------------------------------------------
    // PURPOSE: Replaces template variables with actual values
    //
    // VARIABLES:
    //   {First Name}       → Applicant's first name
    //   {Application ID}   → Application ID
    //   {Rejection Reason} → Rejection reason text
    //
    // -------------------------------------------------------
    local procedure ReplaceTemplateVariables(TemplateText: Text; FirstName: Text; ApplicationID: Code[20]; RejectionReason: Text): Text
    var
        Result: Text;
    begin
        Result := TemplateText;
        Result := Result.Replace('{First Name}', FirstName);
        Result := Result.Replace('{Application ID}', ApplicationID);
        Result := Result.Replace('{Rejection Reason}', RejectionReason);
        exit(Result);
    end;

    // -------------------------------------------------------
    // SendApprovalSMS
    // -------------------------------------------------------
    // PURPOSE: Sends an approval SMS to the newly created member
    //          when their application is approved.
    //
    // PARAMETERS:
    //   Member: Record "Member" - The newly created member
    //
    // -------------------------------------------------------
    local procedure SendApprovalSMS(Member: Record "Member")
    var
        AfricasTalkingSMS: Codeunit "Africa's Talking SMS";
    begin
        // Call the SMS codeunit to send approval notification
        // Only send if member has a phone number
        if Member."Phone Number" <> '' then
            AfricasTalkingSMS.SendApprovalSMS(Member."Phone Number", Member."Full Name", Member."Member ID");
    end;
}

