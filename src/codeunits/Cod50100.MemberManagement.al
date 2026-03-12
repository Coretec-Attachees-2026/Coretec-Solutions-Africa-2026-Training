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
        Member."Registration Date" := Today;  // Date of member creation
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
        MemberApp."Approval Date" := Today;
        MemberApp.Modify();  // Save the changes

        // Create the member from the approved application
        if TransferApplicationToMember(ApplicationID) then begin
            LogAuditEntry('Approved', 'Member Application', ApplicationID,
                StrSubstNo('Application %1 approved and member created.', ApplicationID));
            Message('Application %1 approved and member created successfully', ApplicationID);
        end;
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
        MemberApp."Approval Date" := Today;  // Records when the decision was made
        MemberApp.Modify();

        LogAuditEntry('Rejected', 'Member Application', ApplicationID,
            StrSubstNo('Application %1 rejected. Reason: %2', ApplicationID, RejectionReason));

        Message('Application %1 has been rejected', ApplicationID);
    end;

    // -------------------------------------------------------
    // GenerateMemberID (local)
    // -------------------------------------------------------
    // PURPOSE: Creates a unique Member ID like "MEM-20260303-0001"
    //
    // HOW IT WORKS:
    //   1. Finds the LAST existing Member ID (sorted alphabetically)
    //   2. Extracts the numeric suffix after the last '-'
    //   3. Increments that number by 1 for the new ID
    //   This avoids duplicate IDs if records are ever deleted,
    //   because we base the sequence on the highest existing ID
    //   rather than on the record count.
    //
    // KEY CONCEPT - "local procedure":
    //   "local" means only THIS codeunit can call this procedure.
    //   External code (pages, other codeunits) cannot use it.
    // -------------------------------------------------------
    local procedure GenerateMemberID(): Code[20]
    var
        Member: Record "Member";
        NextSeqNo: Integer;
        LastID: Code[20];
        DashPos: Integer;
        SeqText: Text;
    begin
        // Find the member with the highest Member ID (alphabetical sort)
        Member.SetCurrentKey("Member ID");
        if Member.FindLast() then begin
            // Extract the numeric suffix after the last '-'
            // e.g., from "MEM-20260303-0005" extract "0005"
            LastID := Member."Member ID";
            DashPos := StrLen(LastID);
            while (DashPos > 0) and (LastID[DashPos] <> '-') do
                DashPos -= 1;
            if DashPos > 0 then begin
                SeqText := CopyStr(Format(LastID), DashPos + 1);
                if not Evaluate(NextSeqNo, SeqText) then
                    NextSeqNo := 0;
            end;
            // Increment to get the next sequence number
            NextSeqNo += 1;
        end else
            // No members exist yet — start at 1
            NextSeqNo := 1;

        // Build and return the ID string
        // e.g., 'MEM-20260303-0001'
        exit('MEM-' + Format(Today, 0, '<Year4><Month,2><Day,2>') + '-' + Format(NextSeqNo, 0, '<Integer,4>'));
    end;

    // -------------------------------------------------------
    // LogAuditEntry (local helper)
    // -------------------------------------------------------
    // PURPOSE: Creates an audit log record for tracking actions
    //          taken on member applications.
    // -------------------------------------------------------
    local procedure LogAuditEntry(ActionType: Text[50]; DocumentType: Text[50]; DocumentNo: Code[20]; Description: Text[250])
    var
        AuditLog: Record "Application Audit Log";
    begin
        AuditLog.Init();
        AuditLog."Date-Time" := CurrentDateTime;
        AuditLog."User ID" := CopyStr(UserId, 1, 50);
        AuditLog."Action Type" := ActionType;
        AuditLog."Document Type" := DocumentType;
        AuditLog."Document No." := DocumentNo;
        AuditLog.Description := Description;
        AuditLog.Insert(true);
    end;
}
