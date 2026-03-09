// ============================================================
// Table 50100 - Member Application
// ============================================================
// PURPOSE: Stores new membership applications for the SACCO.
//
// HOW IT WORKS:
// 1. A person wants to join the SACCO
// 2. They fill in their details on the Member Application Card page
// 3. When the record is saved (OnInsert), it auto-generates an ID
//    like "APP-20260303-00001" and sets status to "Pending"
// 4. An administrator can then Approve or Reject the application
// 5. If approved, the member data is copied to the Member table
//
// KEY CONCEPT - "Table":
//   A table in AL defines the STRUCTURE of your data.
//   Think of it like a spreadsheet: each "field" is a column,
//   and each record is a row.
//
// KEY CONCEPT - "DataClassification = ToBeClassified":
//   Business Central requires you to classify data for privacy
//   (GDPR compliance). "ToBeClassified" means you need to update
//   this later. Options include CustomerContent, EndUserIdentifiableInfo, etc.
//
// KEY CONCEPT - "Code[20]" vs "Text[100]":
//   Code = uppercase text with no leading/trailing spaces (for IDs)
//   Text = regular text that keeps its case (for names, etc.)
//   The number in brackets is the maximum length.
//
// KEY CONCEPT - "keys":
//   Keys define how records can be sorted and searched.
//   The first key (PK) is the Primary Key - it uniquely identifies each record.
//   "Clustered = true" means data is physically stored in this order.
// ============================================================

table 50100 "Member Application"
{
    Caption = 'Member Application';
    DataClassification = ToBeClassified;

    fields
    {
        // ---------- IDENTIFICATION ----------
        field(1; "Application ID"; Code[20])
        {
            Caption = 'Application ID';
            Editable = false;
            // Editable = false → user cannot type in this field
            // The ID is auto-generated in the OnInsert trigger below
        }
        // ---------- PERSONAL INFORMATION ----------
        field(2; "First Name"; Text[100])
        {
            Caption = 'First Name';
            // Text[100] allows up to 100 characters of text
        }
        field(3; "Last Name"; Text[100])
        {
            Caption = 'Last Name';
        }

        // ---------- CONTACT INFORMATION ----------
        field(4; "Email"; Text[100])
        {
            Caption = 'Email';
        }
        field(5; "Phone Number"; Text[20])
        {
            Caption = 'Phone Number';
        }
        field(6; "Date of Birth"; Date)
        {
            Caption = 'Date of Birth';

            // KEY CONCEPT - "trigger OnValidate()":
            //   This code runs EVERY TIME the user changes this field.
            //   We use it to check that the entered date is valid.
            //   If something is wrong, Error() stops the save and shows a message.
            trigger OnValidate()
            var
                MinimumAgeDate: Date;  // Variable to hold the cutoff date
            begin
                // 0D means "empty date" - if no date entered, skip validation
                if "Date of Birth" = 0D then
                    exit;

                // Rule 1: Date of Birth cannot be today or in the future
                if "Date of Birth" >= Today then
                    Error('Date of Birth cannot be today or in the future. Please enter a valid past date.');

                // Rule 2: Applicant must be at least 35 years old
                // CalcDate('-35Y', Today) calculates "35 years before today"
                // The '-35Y' means: subtract 35 Years
                MinimumAgeDate := CalcDate('-35Y', Today);

                // If their birth date is AFTER the cutoff, they're too young
                if "Date of Birth" > MinimumAgeDate then
                    Error('Applicant must be at least 35 years old. Minimum Date of Birth allowed: %1', MinimumAgeDate);
                // %1 is a placeholder - it gets replaced with the actual date
            end;
        }
        field(7; "Address"; Text[150])
        {
            Caption = 'Address';
        }
        field(8; "City"; Text[50])
        {
            Caption = 'City';
        }
        field(9; "Postal Code"; Code[20])
        {
            Caption = 'Postal Code';
        }
        field(10; "Country"; Code[10])
        {
            Caption = 'Country';
            // TableRelation links this field to the standard BC "Country/Region" table
            // This means the user picks from a dropdown of valid countries
            // instead of typing freely (prevents invalid entries)
            TableRelation = "Country/Region".Code;
        }
        field(11; "ID Number"; Text[20])
        {
            Caption = 'ID/Passport Number';
        }
        field(12; "Application Date"; DateTime)
        {
            Caption = 'Application Date';
            Editable = false;
        }
        // ---------- STATUS & WORKFLOW ----------
        field(13; "Status"; Enum "Member Application Status")
        {
            Caption = 'Status';
            // Uses our Enum 50100 which has: Pending, Approved, Rejected
            // The status is managed by code, not directly by the user
        }
        field(14; "Approval Date"; DateTime)
        {
            Caption = 'Approval Date';
        }
        field(15; "Rejection Reason"; Text[250])
        {
            Caption = 'Rejection Reason';
        }
        field(16; "Occupation"; Text[100])
        {
            Caption = 'Occupation';
        }
        field(17; "Annual Income"; Decimal)
        {
            Caption = 'Annual Income';
        }
        field(18; "Member Category"; Code[20])
        {
            Caption = 'Member Category';
            // TableRelation to "Member Category Master" table
            // Shows dropdown with categories like REGULAR, STUDENT, BUSINESS, etc.
            // These categories were created by the install codeunit (Cod50101)
            TableRelation = "Member Category Master".Code;
        }
    }

    // -------------------------------------------------------
    // KEYS
    // -------------------------------------------------------
    // Keys define how records are sorted and searched.
    // PK (Primary Key) = unique identifier for each record
    // SK (Secondary Keys) = additional sort/filter options
    // -------------------------------------------------------
    keys
    {
        key(PK; "Application ID")
        {
            Clustered = true;  // Data is physically stored in this order
        }
        key(SK; "Application Date")
        {
            // Allows sorting/filtering by date
        }
        key(SK2; "Status")
        {
            // Allows efficient filtering by status
        }
    }

    // -------------------------------------------------------
    // OnInsert Trigger
    // -------------------------------------------------------
    // This runs automatically when a new record is created.
    // It does 3 things:
    //   1. Generates a unique Application ID (like APP-20260303-00001)
    //   2. Records the current date and time
    //   3. Sets the initial status to "Pending"
    //
    // KEY CONCEPT - "Trigger":
    //   A trigger is code that runs automatically when something happens.
    //   OnInsert = runs when a new record is inserted into the table.
    //   Other triggers: OnModify, OnDelete, OnRename
    // -------------------------------------------------------
    trigger OnInsert()
    begin
        // Only generate an ID if one hasn't been set already
        if "Application ID" = '' then
            AssignApplicationID();

        // Record when the application was created
        "Application Date" := CurrentDateTime;

        // All new applications start as "Pending"
        "Status" := Enum::"Member Application Status"::Pending;
    end;

    // -------------------------------------------------------
    // AssignApplicationID
    // -------------------------------------------------------
    // Generates IDs like: APP-20260303-00001
    //   APP       = prefix showing it's an application
    //   20260303  = today's date (YYYYMMDD)
    //   00001     = sequence number from the No. Series
    //
    // KEY CONCEPT - "local procedure":
    //   "local" means this procedure can only be called from within
    //   this table. Other codeunits or pages can't call it directly.
    //   A regular "procedure" (without local) can be called from anywhere.
    //
    // KEY CONCEPT - "var" (Variables):
    //   Variables are declared in the "var" section below.
    //   Each has a name, a type (Record, Codeunit, Code, Integer, etc.)
    //   Think of them as containers that hold temporary data.
    // -------------------------------------------------------
    local procedure AssignApplicationID()
    var
        MemberSetup: Record "Member Setup";                     // Access the setup table
        MemberAppNoSeriesMgt: Codeunit "Member App No. Series Mgt"; // Ensures No. Series exists
        NoSeries: Codeunit "No. Series";                         // BC built-in for getting next number
        RawSequenceNo: Code[20];       // Raw number from No. Series (e.g., '00001')
        SequenceNoInteger: Integer;     // Same number as an integer
        SequenceNoText: Text[20];       // Same number as text for formatting
        SequencePart: Text[5];          // 5-digit padded number (e.g., '00001')
        ApplicationIDText: Text[30];    // Final ID string (e.g., 'APP-20260303-00001')
    begin
        // Step 1: Make sure the No. Series exists (creates it if not)
        MemberAppNoSeriesMgt.EnsureMemberApplicationNoSeriesAndSetup();

        // Step 2: Read the setup to get the No. Series code
        MemberSetup.GetOrCreateSetup();

        // Step 3: Validate that the No. Series is configured
        if MemberSetup."Member Application Nos." = '' then
            Error(
              'Member Application Nos. is not configured. Open Member Application List, choose Member Setup, and set a No. Series (for example MEMAPPSEQ).');

        // Step 4: Get the next number from the series (e.g., '00001')
        RawSequenceNo := NoSeries.GetNextNo(MemberSetup."Member Application Nos.", WorkDate());
        SequenceNoText := Format(RawSequenceNo);

        // Step 5: Convert to integer to validate it's a number
        // Evaluate() tries to convert text to a number - returns false if it fails
        if not Evaluate(SequenceNoInteger, SequenceNoText) then
            Error(
              'Invalid value %1 returned from No. Series %2. Configure the series to return numeric values only for Application ID format APP-YYYYMMDD-#####.',
              SequenceNoText,
              MemberSetup."Member Application Nos.");

        // Step 6: Check the number isn't too long
        // StrLen() returns the length of a string
        // MaxStrLen() returns the maximum allowed length of a variable
        if StrLen(SequenceNoText) > MaxStrLen(SequencePart) then
            Error(
              'No. Series %1 returned %2, which exceeds %3 digits required for Application ID format APP-YYYYMMDD-#####.',
              MemberSetup."Member Application Nos.",
              SequenceNoText,
              MaxStrLen(SequencePart));

        // Step 7: Pad with leading zeros (e.g., '1' becomes '00001')
        // PadStr('', 4, '0') creates '0000', then we append the number
        // CopyStr() extracts a portion of a string
        SequencePart := CopyStr(PadStr('', MaxStrLen(SequencePart) - StrLen(SequenceNoText), '0') + SequenceNoText, 1, MaxStrLen(SequencePart));

        // Step 8: Build the final ID: APP-YYYYMMDD-#####
        // Format(WorkDate(), 0, '<Year4><Month,2><Day,2>') produces e.g., '20260303'
        ApplicationIDText := 'APP-' + Format(WorkDate(), 0, '<Year4><Month,2><Day,2>') + '-' + SequencePart;

        // Step 9: Safety check - make sure it fits in the field
        if StrLen(ApplicationIDText) > MaxStrLen("Application ID") then
            Error(
              'Generated Application ID %1 exceeds maximum length %2. Review No. Series setup.',
              ApplicationIDText,
              MaxStrLen("Application ID"));

        // Step 10: Assign the generated ID to the record
        "Application ID" := CopyStr(ApplicationIDText, 1, MaxStrLen("Application ID"));
    end;
}
