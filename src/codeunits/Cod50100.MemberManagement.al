
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
        Member."Registration Date" := Today;  // Now (Date type)
        Member."Status" := Enum::"Member Status"::Active;  // Start as Active
        Member."Occupation" := MemberApp."Occupation";
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
    begin
        // Find the application
        if not MemberApp.Get(ApplicationID) then
            Error('Member Application %1 not found', ApplicationID);

        // Only "Pending" applications can be approved
        if MemberApp.Status <> Enum::"Member Application Status"::Pending then
            Error('Only Pending applications can be approved. Current status is %1.', MemberApp.Status);

        // Update the application status to Approved
        MemberApp.Status := Enum::"Member Application Status"::Approved;
        MemberApp."Approval Date" := Today;  // Records when the decision was made (Date type)
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
        MemberApp."Approval Date" := Today;  // Records when the decision was made (Date type)
        MemberApp.Modify();

        Message('Application %1 has been rejected', ApplicationID);
        SendRejectionEmailToMember(MemberApp);
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
