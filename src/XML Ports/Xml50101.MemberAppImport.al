// ============================================================
// XMLport 50101 - Member Application Import
// ============================================================
// PURPOSE: IMPORT member applications from a CSV/Excel file.
//          Each row in the CSV becomes a new application with
//          status "Pending" — ready for admin approval.
//
// HOW IT WORKS:
//   1. Admin prepares applicant data in Excel (names, contact, etc.)
//   2. Saves as CSV (File → Save As → CSV UTF-8)
//   3. Clicks "Import Applications" on the Member Application List
//   4. Each row is imported as a new application:
//      - Application ID is AUTO-GENERATED (APP-YYYYMMDD-#####)
//      - Application Date is set to NOW
//      - Status is set to PENDING
//   5. Admin reviews and approves/rejects each application normally
//
// WHY IMPORT TO APPLICATIONS (NOT DIRECTLY TO MEMBERS)?
//   The SACCO requires all new members to go through the approval
//   workflow. Importing directly into the Member table would bypass
//   validation, approval, and audit trail. By importing into the
//   Application table, every imported person still goes through:
//     Pending → Approved → Member created
//
// CSV COLUMN ORDER (what the Excel file should contain):
//   1. First Name        2. Last Name         3. Email
//   4. Phone Number      5. Date of Birth     6. Address
//   7. City              8. Postal Code       9. Country
//  10. ID Number        11. Occupation       12. Annual Income
//  13. Member Category
//
// NOTE: Do NOT include Application ID, Application Date, Status,
//       Approval Date, or Rejection Reason — these are auto-set.
// ============================================================

xmlport 50101 "Member Application Import"
{
    Caption = 'Member Application Import';
    Direction = Import;          // Import-only — applications come IN from CSV
    Format = VariableText;       // CSV format (comma-separated)
    FieldSeparator = ',';        // Comma between each column
    FieldDelimiter = '"';        // Text values wrapped in double quotes
    TextEncoding = UTF8;         // Supports special characters

    // TableSeparator: Each line break = new record (default for CSV)
    // The first row CAN be a header row — the trigger below detects and skips it.

    schema
    {
        textelement(RootNode)
        {
            tableelement(MemberApp; "Member Application")
            {
                // ========================================
                // PERSONAL INFORMATION (from CSV columns)
                // ========================================
                // Only the fields the user provides in the CSV.
                // Application ID, Date, and Status are set automatically
                // in the OnBeforeInsertRecord trigger below.

                fieldelement(FirstName; MemberApp."First Name")
                {
                }
                fieldelement(LastName; MemberApp."Last Name")
                {
                }

                // ========================================
                // CONTACT INFORMATION
                // ========================================
                fieldelement(Email; MemberApp."Email")
                {
                }
                fieldelement(PhoneNumber; MemberApp."Phone Number")
                {
                }
                textelement(DateOfBirthText)
                {
                }

                // ========================================
                // ADDRESS FIELDS
                // ========================================
                fieldelement(Address; MemberApp."Address")
                {
                }
                fieldelement(City; MemberApp."City")
                {
                }
                fieldelement(PostalCode; MemberApp."Postal Code")
                {
                }
                textelement(CountryText)
                {
                }
                fieldelement(IDNumber; MemberApp."ID Number")
                {
                }

                // ========================================
                // EMPLOYMENT FIELDS
                // ========================================
                fieldelement(Occupation; MemberApp."Occupation")
                {
                }
                textelement(AnnualIncomeText)
                {
                }
                textelement(MemberCategoryText)
                {
                }

                // ===============================================================
                // TRIGGER: Auto-generate Application ID and set defaults
                // ===============================================================
                // This runs BEFORE each row is inserted into the database.
                // It replicates the same logic as the table's OnInsert trigger:
                //   - Generates a unique Application ID (APP-YYYYMMDD-#####)
                //   - Sets Application Date to current date/time
                //   - Sets Status to Pending
                //
                // We must do this here because XMLport.Import does NOT fire
                // the table's OnInsert trigger — it inserts directly.
                // ===============================================================
                trigger OnBeforeInsertRecord()
                var
                    MemberSetup: Record "Member Setup";
                    MemberAppNoSeriesMgt: Codeunit "Member App No. Series Mgt";
                    NoSeries: Codeunit "No. Series";
                    RawSequenceNo: Code[20];
                    SequenceNoInteger: Integer;
                    SequenceNoText: Text[20];
                    SequencePart: Text[5];
                    ApplicationIDText: Text[30];
                    ParsedDate: Date;
                    ParsedIncome: Decimal;
                begin
                    // -------------------------------------------------------
                    // ROW COUNTER — track which row we're on
                    // -------------------------------------------------------
                    RowCount += 1;

                    // -------------------------------------------------------
                    // SKIP HEADER ROW — if first row contains column names
                    // -------------------------------------------------------
                    // Detects if the first row is a header (e.g., "First Name")
                    // by checking if the First Name field matches common header text.
                    // This lets users keep the header row in their Excel/CSV file.
                    if RowCount = 1 then
                        if (UpperCase(MemberApp."First Name") = 'FIRST NAME') or
                           (UpperCase(MemberApp."First Name") = 'FIRSTNAME') or
                           (UpperCase(MemberApp."First Name") = 'NAME') then begin
                            currXMLport.Skip();
                            exit;
                        end;

                    // -------------------------------------------------------
                    // SKIP BLANK ROWS — empty lines at end of CSV
                    // -------------------------------------------------------
                    // Must call exit after Skip() to prevent falling through
                    // to the validation logic below, which would Error on
                    // a blank First Name.
                    if (MemberApp."First Name" = '') and (MemberApp."Last Name" = '') then begin
                        currXMLport.Skip();
                        exit;
                    end;

                    // -------------------------------------------------------
                    // VALIDATE REQUIRED FIELDS
                    // -------------------------------------------------------
                    // These fields are essential for an application to be useful.
                    // If missing, the row is rejected with a clear error message
                    // showing which row has the problem.
                    if MemberApp."First Name" = '' then
                        Error('Row %1: First Name is required.', RowCount);

                    if MemberApp."Last Name" = '' then
                        Error('Row %1: Last Name is required.', RowCount);

                    if MemberApp."Email" = '' then
                        Error('Row %1: Email is required.', RowCount);

                    if MemberApp."ID Number" = '' then
                        Error('Row %1: ID Number is required.', RowCount);

                    // -------------------------------------------------------
                    // VALIDATE EMAIL FORMAT (basic check)
                    // -------------------------------------------------------
                    if (StrPos(MemberApp."Email", '@') = 0) or (StrPos(MemberApp."Email", '.') = 0) then
                        Error('Row %1: Email "%2" is not valid. Must contain @ and a domain.',
                            RowCount, MemberApp."Email");

                    // -------------------------------------------------------
                    // ASSIGN COUNTRY from text (bypasses TableRelation validation on header)
                    // -------------------------------------------------------
                    if (CountryText <> '') and (UpperCase(CountryText) <> 'COUNTRY') then
                        MemberApp."Country" := CopyStr(UpperCase(CountryText), 1, MaxStrLen(MemberApp."Country"));

                    // -------------------------------------------------------
                    // PARSE DATE OF BIRTH from text (locale-independent)
                    // Supports yyyy-mm-dd, mm/dd/yyyy, dd/mm/yyyy formats
                    // -------------------------------------------------------
                    if (DateOfBirthText <> '') and (UpperCase(DateOfBirthText) <> 'DATE OF BIRTH') then begin
                        // Try XML/ISO format first (yyyy-mm-dd) — most reliable
                        if not Evaluate(ParsedDate, DateOfBirthText, 9) then
                            // Fallback: try server locale format
                            if not Evaluate(ParsedDate, DateOfBirthText) then
                                Error('Row %1: Cannot parse Date of Birth "%2". Use yyyy-mm-dd format (e.g. 1990-11-15).', RowCount, DateOfBirthText);
                        MemberApp."Date of Birth" := ParsedDate;

                        if MemberApp."Date of Birth" >= Today then
                            Error('Row %1: Date of Birth cannot be today or in the future.', RowCount);
                        if MemberApp."Date of Birth" > CalcDate('-18Y', Today) then
                            Error('Row %1: Applicant must be at least 18 years old.', RowCount);
                    end;

                    // -------------------------------------------------------
                    // PARSE AND VALIDATE ANNUAL INCOME from text
                    // -------------------------------------------------------
                    if (AnnualIncomeText <> '') and (UpperCase(AnnualIncomeText) <> 'ANNUAL INCOME') then begin
                        if not Evaluate(ParsedIncome, AnnualIncomeText) then
                            Error('Row %1: Cannot parse Annual Income "%2". Use a number (e.g. 1200000).', RowCount, AnnualIncomeText);
                        if ParsedIncome < 0 then
                            Error('Row %1: Annual Income cannot be negative.', RowCount);
                        MemberApp."Annual Income" := ParsedIncome;
                    end;

                    // -------------------------------------------------------
                    // ASSIGN MEMBER CATEGORY from text
                    // -------------------------------------------------------
                    if (MemberCategoryText <> '') and (UpperCase(MemberCategoryText) <> 'MEMBER CATEGORY') then
                        MemberApp."Member Category" := CopyStr(UpperCase(MemberCategoryText), 1, MaxStrLen(MemberApp."Member Category"));

                    // -------------------------------------------------------
                    // CHECK FOR DUPLICATE ID NUMBER
                    // -------------------------------------------------------
                    // Prevents importing the same person twice.
                    // Checks BOTH tables: existing applications AND approved members.
                    DuplicateCheck.Reset();
                    DuplicateCheck.SetRange("ID Number", MemberApp."ID Number");
                    if DuplicateCheck.FindFirst() then
                        Error('Row %1: ID Number "%2" already exists in application %3.',
                            RowCount, MemberApp."ID Number", DuplicateCheck."Application ID");

                    DuplicateMemberCheck.Reset();
                    DuplicateMemberCheck.SetRange("ID Number", MemberApp."ID Number");
                    if DuplicateMemberCheck.FindFirst() then
                        Error('Row %1: ID Number "%2" already exists as member %3.',
                            RowCount, MemberApp."ID Number", DuplicateMemberCheck."Member ID");

                    // --- Auto-generate Application ID ---
                    // Same logic as Table 50100's AssignApplicationID procedure
                    MemberAppNoSeriesMgt.EnsureMemberApplicationNoSeriesAndSetup();
                    MemberSetup.GetOrCreateSetup();

                    if MemberSetup."Member Application Nos." = '' then
                        Error('Member Application Nos. is not configured. Open Member Setup and set a No. Series.');

                    RawSequenceNo := NoSeries.GetNextNo(MemberSetup."Member Application Nos.", Today);
                    SequenceNoText := Format(RawSequenceNo);

                    if not Evaluate(SequenceNoInteger, SequenceNoText) then
                        Error('Invalid No. Series value %1. Configure numeric values only.', SequenceNoText);

                    if StrLen(SequenceNoText) > MaxStrLen(SequencePart) then
                        Error('No. Series value %1 exceeds 5 digits.', SequenceNoText);

                    SequencePart := CopyStr(
                        PadStr('', MaxStrLen(SequencePart) - StrLen(SequenceNoText), '0') + SequenceNoText,
                        1, MaxStrLen(SequencePart));

                    ApplicationIDText := 'APP-' + Format(Today, 0, '<Year4><Month,2><Day,2>') + '-' + SequencePart;

                    if StrLen(ApplicationIDText) > MaxStrLen(MemberApp."Application ID") then
                        Error('Generated Application ID %1 exceeds max length.', ApplicationIDText);

                    MemberApp."Application ID" := CopyStr(ApplicationIDText, 1, MaxStrLen(MemberApp."Application ID"));

                    // --- Set defaults ---
                    MemberApp."Application Date" := Today;
                    MemberApp."Status" := Enum::"Member Application Status"::Pending;

                    ImportedCount += 1;
                end;
            }
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Import Options';
                }
            }
        }
    }

    var
        DuplicateCheck: Record "Member Application";
        DuplicateMemberCheck: Record "Member";
        RowCount: Integer;      // Tracks current CSV row number (for error messages)
        ImportedCount: Integer;  // Counts successfully imported rows
}
