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
        Member."Occupation" := MemberApp."Occupation";
        Member."Annual Income" := MemberApp."Annual Income";
        Member."Member Category" := MemberApp."Member Category";
        Member."Account Balance" := 0;  // New member starts with zero balance

        // Step 6: Save to database
        Member.Insert();

        // Step 7: Send welcome email to the new member
        SendWelcomeEmailToMember(Member);

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

    // -------------------------------------------------------
    // RejectApplication
    // -------------------------------------------------------
    // PURPOSE: Rejects a pending application with a reason.
    //          No member record is created.
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

        Message('Application %1 has been rejected', ApplicationID);
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
    //   1. EmailMessage.Create() - Builds the email (to, subject, body)
    //   2. Email.Send() - Sends it using the configured Email Account
    //
    // SETUP REQUIRED:
    //   Admin must configure an Email Account (search "Email Accounts" in BC).
    //   Options: Microsoft 365, SMTP, or Current User.
    //   Without setup, Email.Send returns false (we show a message but don't block).
    //
    // HOW TO SETUP EMAIL ACCOUNTS IN BUSINESS CENTRAL:
    //   1. Search "Email Accounts" in BC
    //   2. Click "New" to add an account
    //   3. Choose Account Type:
    //      - SMTP: Use any SMTP server (Gmail, corporate email, etc.)
    //      - Microsoft 365: Use your Office 365 account (recommended for Office integration)
    //      - Current User: Uses the currently logged-in Windows user's email
    //   4. Fill in your credentials:
    //      - For SMTP: Server, Port, Username, Password
    //      - For Microsoft 365: Your tenant email and consent
    //      - For Current User: Configure Windows authentication
    //   5. Click "Test" to verify the setup works
    //   6. Click "OK" to save
    //
    //   TROUBLESHOOTING:
    //   - If emails fail: Check that you have at least one Email Account configured
    //   - If using SMTP: Ensure port is correct (usually 587 for TLS, 465 for SSL)
    //   - If using Microsoft 365: May need to enable low-security app access or use app passwords
    //   - Test the account configuration by sending a test email from the Email Accounts page
    //
    // KEY CONCEPT - "Email.Send()" vs "Email.Enqueue()":
    //   Email.Send() - Sends immediately in the current session (blocking)
    //   Email.Enqueue() - Sends in background (better for batch operations)
    //   We use Email.Send() here for immediate confirmation, but you can change to
    //   Email.Enqueue() if you prefer background email processing.
    //
    // WHAT HAPPENS IF EMAIL ACCOUNT IS NOT CONFIGURED:
    //   - Email.Send() returns false (no error thrown)
    //   - We catch this and show a friendly message
    //   - Member is STILL created (email is not critical to membership)
    //   - Admin can resend the email later once Email Account is configured
    // -------------------------------------------------------
    local procedure SendWelcomeEmailToMember(Member: Record "Member")
    var
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        Subject: Text[100];
        Body: Text;
    begin
        // Skip if member has no email address
        if (Member.Email = '') or (Member."Full Name" = '') then
            exit;

        // Build the email content (use HTML for line breaks)
        Subject := 'Welcome to the SACCO - Registration Confirmed';
        Body := 'Dear ' + Member."Full Name" + ',<br/><br/>';
        Body += 'Congratulations! Your membership has been approved.<br/>';
        Body += 'Your Member ID is: ' + Member."Member ID" + '<br/><br/>';
        Body += 'You can now access your account and apply for loans.<br/><br/>';
        Body += 'Best regards,<br/>';
        Body += 'The SACCO Team';

        // Create the email message (true = HTML formatted body)
        EmailMessage.Create(Member.Email, Subject, Body, true);

        // Send the email (uses default Email Account from BC setup)
        // Email.Send() sends immediately; Email.Enqueue() sends in background
        if not Email.Send(EmailMessage) then
            Message('Member created successfully, but the welcome email could not be sent. ' +
                    'Please ensure an Email Account is configured. ' +
                    'Go to Search > "Email Accounts" and add an account (SMTP, Microsoft 365, or Current User).');
    end;
}
