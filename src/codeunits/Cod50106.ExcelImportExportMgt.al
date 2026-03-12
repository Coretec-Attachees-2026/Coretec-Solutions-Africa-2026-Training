// ============================================================
// Codeunit 50106 - Excel Import Export Mgt
// ============================================================
// PURPOSE: Handles native .xlsx Excel import/export using BC's
//          built-in "Excel Buffer" (Table 370) instead of XMLports.
//
// WHY EXCEL BUFFER INSTEAD OF XMLPORTS?
//   XMLports produce CSV files (comma-separated text), which:
//     - Lose formatting, date/number types when opened in Excel
//     - Require the user to "Save As → CSV" before importing
//     - Don't support multiple sheets, bold headers, or formatting
//
//   The Excel Buffer produces TRUE .xlsx files, which:
//     - Open directly in Excel with proper columns and types
//     - Support bold headers, number formats, and date cells
//     - Can be imported back from .xlsx without conversion
//     - Are the standard BC approach (used by standard reports)
//
// HOW THE EXCEL BUFFER WORKS:
//   Table 370 "Excel Buffer" is a TEMPORARY table that acts as
//   a grid of cells. Each record = one cell, identified by
//   "Row No." and "Column No.". You build the Excel file in memory:
//
//   EXPORT (write .xlsx):
//     1. DeleteAll → clear the buffer
//     2. NewRow() + AddColumn() → build header row (bold)
//     3. NewRow() + AddColumn() → build each data row
//     4. CreateNewBook() → initialize the workbook
//     5. WriteSheet() → write the buffered cells to a sheet
//     6. CloseBook() → finalize the workbook
//     7. OpenExcel() → trigger browser download of the .xlsx
//
//   IMPORT (read .xlsx):
//     1. UploadIntoStream → user picks an .xlsx file
//     2. SelectSheetsNameStream() → let user pick the sheet
//     3. OpenBookStream() → open the uploaded file
//     4. ReadSheet() → load all cells into the buffer
//     5. Loop from row 2 to last row (row 1 = headers)
//     6. Get(RowNo, ColNo) → read each cell value
//     7. Create records from the cell values
//
// REFERENCE:
//   https://learn.microsoft.com/en-us/dynamics365/business-central/
//   dev-itpro/developer/devenv-excel-buffer
//
// PROCEDURES:
//   ExportMembersToExcel() → exports Member table to .xlsx
//   ImportApplicationsFromExcel() → imports applications from .xlsx
// ============================================================

codeunit 50106 "Excel Import Export Mgt"
{
    // -------------------------------------------------------
    // EXPORT: Members → .xlsx
    // -------------------------------------------------------
    // Reads all members from Table 50101 and writes them into
    // a proper Excel workbook with bold headers and typed cells.
    // The file downloads automatically in the user's browser.
    //
    // COLUMN ORDER (19 columns matching Member table fields):
    //   A: Member ID         B: Application ID    C: First Name
    //   D: Last Name         E: Full Name          F: Email
    //   G: Phone Number      H: Date of Birth      I: Address
    //   J: City              K: Postal Code         L: Country
    //   M: ID Number         N: Registration Date   O: Status
    //   P: Occupation        Q: Annual Income       R: Member Category
    //   S: Account Balance
    // -------------------------------------------------------
    procedure ExportMembersToExcel()
    var
        Member: Record "Member";
        ExcelBuffer: Record "Excel Buffer" temporary;
    begin
        ExcelBuffer.DeleteAll();

        // --- HEADER ROW (bold) ---
        ExcelBuffer.NewRow();
        AddHeaderCell(ExcelBuffer, 'Member ID');
        AddHeaderCell(ExcelBuffer, 'Application ID');
        AddHeaderCell(ExcelBuffer, 'First Name');
        AddHeaderCell(ExcelBuffer, 'Last Name');
        AddHeaderCell(ExcelBuffer, 'Full Name');
        AddHeaderCell(ExcelBuffer, 'Email');
        AddHeaderCell(ExcelBuffer, 'Phone Number');
        AddHeaderCell(ExcelBuffer, 'Date of Birth');
        AddHeaderCell(ExcelBuffer, 'Address');
        AddHeaderCell(ExcelBuffer, 'City');
        AddHeaderCell(ExcelBuffer, 'Postal Code');
        AddHeaderCell(ExcelBuffer, 'Country');
        AddHeaderCell(ExcelBuffer, 'ID Number');
        AddHeaderCell(ExcelBuffer, 'Registration Date');
        AddHeaderCell(ExcelBuffer, 'Status');
        AddHeaderCell(ExcelBuffer, 'Occupation');
        AddHeaderCell(ExcelBuffer, 'Annual Income');
        AddHeaderCell(ExcelBuffer, 'Member Category');
        AddHeaderCell(ExcelBuffer, 'Account Balance');

        // --- DATA ROWS ---
        if Member.FindSet() then
            repeat
                ExcelBuffer.NewRow();
                // Identification
                AddTextCell(ExcelBuffer, Member."Member ID");
                AddTextCell(ExcelBuffer, Member."Application ID");
                // Personal
                AddTextCell(ExcelBuffer, Member."First Name");
                AddTextCell(ExcelBuffer, Member."Last Name");
                AddTextCell(ExcelBuffer, Member."Full Name");
                // Contact
                AddTextCell(ExcelBuffer, Member."Email");
                AddTextCell(ExcelBuffer, Member."Phone Number");
                if Member."Date of Birth" <> 0D then
                    AddDateCell(ExcelBuffer, Member."Date of Birth")
                else
                    AddTextCell(ExcelBuffer, '');
                // Address
                AddTextCell(ExcelBuffer, Member."Address");
                AddTextCell(ExcelBuffer, Member."City");
                AddTextCell(ExcelBuffer, Member."Postal Code");
                AddTextCell(ExcelBuffer, Member."Country");
                AddTextCell(ExcelBuffer, Member."ID Number");
                // Status & Registration
                if Member."Registration Date" <> 0D then
                    AddTextCell(ExcelBuffer, Format(Member."Registration Date"))
                else
                    AddTextCell(ExcelBuffer, '');
                AddTextCell(ExcelBuffer, Format(Member."Status"));
                // Employment
                AddTextCell(ExcelBuffer, Member."Occupation");
                AddNumberCell(ExcelBuffer, Member."Annual Income");
                AddTextCell(ExcelBuffer, Member."Member Category");
                // Financials
                AddNumberCell(ExcelBuffer, Member."Account Balance");
            until Member.Next() = 0;

        // --- CREATE AND DOWNLOAD THE .XLSX FILE ---
        ExcelBuffer.CreateNewBook('Members');
        ExcelBuffer.WriteSheet('SACCO Members', CompanyName, UserId);
        ExcelBuffer.CloseBook();
        ExcelBuffer.SetFriendlyFilename('Members');
        ExcelBuffer.OpenExcel();
    end;

    // -------------------------------------------------------
    // IMPORT: .xlsx → Member Applications
    // -------------------------------------------------------
    // Reads an Excel file uploaded by the user, validates each
    // row, and creates Member Application records with:
    //   - Auto-generated Application ID (APP-YYYYMMDD-#####)
    //   - Status = Pending (goes through approval workflow)
    //   - Application Date = now
    //
    // EXPECTED COLUMN ORDER (13 columns):
    //   A: First Name     B: Last Name      C: Email
    //   D: Phone Number   E: Date of Birth  F: Address
    //   G: City           H: Postal Code    I: Country
    //   J: ID Number      K: Occupation     L: Annual Income
    //   M: Member Category
    //
    // Row 1 must be the header row (automatically skipped).
    // -------------------------------------------------------
    procedure ImportApplicationsFromExcel()
    var
        MemberApp: Record "Member Application";
        ExcelBuffer: Record "Excel Buffer" temporary;
        MemberSetup: Record "Member Setup";
        MemberAppNoSeriesMgt: Codeunit "Member App No. Series Mgt";
        NoSeries: Codeunit "No. Series";
        DuplicateCheck: Record "Member Application";
        DuplicateMemberCheck: Record "Member";
        MemberCat: Record "Member Category Master";
        CountryRegion: Record "Country/Region";
        InStr: InStream;
        FileName: Text;
        SheetName: Text;
        RowNo: Integer;
        LastRow: Integer;
        ImportedCount: Integer;
        RawSequenceNo: Code[20];
        SequenceNoInteger: Integer;
        SequenceNoText: Text[20];
        SequencePart: Text[5];
        ApplicationIDText: Text[30];
        TempDate: Date;
        TempDecimal: Decimal;
        CellValue: Text;
        CleanedIDNumber: Text;
    begin
        // --- STEP 1: Upload the .xlsx file ---
        if not UploadIntoStream(
            'Select Excel File (.xlsx)', '',
            'Excel Files (*.xlsx)|*.xlsx', FileName, InStr) then
            exit;

        // --- STEP 2: Let user pick the sheet ---
        SheetName := ExcelBuffer.SelectSheetsNameStream(InStr);
        if SheetName = '' then
            exit;

        // --- STEP 3: Read all cells into buffer ---
        ExcelBuffer.OpenBookStream(InStr, SheetName);
        ExcelBuffer.ReadSheet();

        // --- STEP 4: Find the last row ---
        if ExcelBuffer.FindLast() then
            LastRow := ExcelBuffer."Row No."
        else begin
            Message('The Excel file is empty.');
            exit;
        end;

        if LastRow < 2 then begin
            Message('The Excel file has no data rows (only a header row).');
            exit;
        end;

        // --- STEP 5: Ensure No. Series is configured BEFORE the loop ---
        // Moving this outside the loop avoids redundant setup checks
        // on every single row, improving import performance.
        MemberAppNoSeriesMgt.EnsureMemberApplicationNoSeriesAndSetup();
        MemberSetup.GetOrCreateSetup();

        if MemberSetup."Member Application Nos." = '' then
            Error('Member Application Nos. not configured. Open Member Setup.');

        // --- STEP 6: Loop through data rows (skip row 1 = header) ---
        for RowNo := 2 to LastRow do begin

            // Skip blank rows (no First Name and no Last Name)
            if (GetCellValue(ExcelBuffer, RowNo, 1) <> '') or
               (GetCellValue(ExcelBuffer, RowNo, 2) <> '') then begin

                // -------------------------------------------------------
                // VALIDATE REQUIRED FIELDS
                // -------------------------------------------------------
                if GetCellValue(ExcelBuffer, RowNo, 1) = '' then
                    Error('Row %1: First Name is required.', RowNo);

                if GetCellValue(ExcelBuffer, RowNo, 2) = '' then
                    Error('Row %1: Last Name is required.', RowNo);

                if GetCellValue(ExcelBuffer, RowNo, 3) = '' then
                    Error('Row %1: Email is required.', RowNo);

                if GetCellValue(ExcelBuffer, RowNo, 10) = '' then
                    Error('Row %1: ID Number is required.', RowNo);

                // -------------------------------------------------------
                // VALIDATE EMAIL FORMAT
                // -------------------------------------------------------
                CellValue := GetCellValue(ExcelBuffer, RowNo, 3);
                if (StrPos(CellValue, '@') = 0) or (StrPos(CellValue, '.') = 0) then
                    Error('Row %1: Email "%2" is not valid. Must contain @ and a domain.',
                        RowNo, CellValue);

                // -------------------------------------------------------
                // VALIDATE DATE OF BIRTH (if provided)
                // -------------------------------------------------------
                CellValue := GetCellValue(ExcelBuffer, RowNo, 5);
                if CellValue <> '' then begin
                    if not Evaluate(TempDate, CellValue) then
                        Error('Row %1: Date of Birth "%2" is not a valid date format.', RowNo, CellValue);
                    if TempDate >= Today then
                        Error('Row %1: Date of Birth cannot be today or in the future.', RowNo);
                    if TempDate > CalcDate('-18Y', Today) then
                        Error('Row %1: Applicant must be at least 18 years old.', RowNo);
                end;

                // -------------------------------------------------------
                // VALIDATE ANNUAL INCOME (if provided)
                // -------------------------------------------------------
                CellValue := GetCellValue(ExcelBuffer, RowNo, 12);
                if CellValue <> '' then begin
                    if not Evaluate(TempDecimal, CellValue) then
                        Error('Row %1: Annual Income "%2" is not a valid number.', RowNo, CellValue);
                    if TempDecimal < 0 then
                        Error('Row %1: Annual Income cannot be negative.', RowNo);
                end;

                // -------------------------------------------------------
                // CHECK FOR DUPLICATE ID NUMBER
                // -------------------------------------------------------
                // Clean ID Number first: Excel may store numeric IDs with
                // trailing ".0" or in scientific notation (e.g. 1.23E+07).
                CleanedIDNumber := FormatNumericText(GetCellValue(ExcelBuffer, RowNo, 10));

                DuplicateCheck.Reset();
                DuplicateCheck.SetRange("ID Number", CleanedIDNumber);
                if DuplicateCheck.FindFirst() then
                    Error('Row %1: ID Number "%2" already exists in application %3.',
                        RowNo, CleanedIDNumber, DuplicateCheck."Application ID");

                DuplicateMemberCheck.Reset();
                DuplicateMemberCheck.SetRange("ID Number", CleanedIDNumber);
                if DuplicateMemberCheck.FindFirst() then
                    Error('Row %1: ID Number "%2" already exists as member %3.',
                        RowNo, CleanedIDNumber, DuplicateMemberCheck."Member ID");

                // -------------------------------------------------------
                // VALIDATE MEMBER CATEGORY (if provided)
                // -------------------------------------------------------
                // Users must enter a valid category code (e.g. REGULAR,
                // STUDENT, BUSINESS). Code fields auto-uppercase on assign.
                CellValue := GetCellValue(ExcelBuffer, RowNo, 13);
                if CellValue <> '' then begin
                    if not MemberCat.Get(UpperCase(CellValue)) then
                        Error('Row %1: Member Category "%2" does not exist. Valid categories include REGULAR, STUDENT, BUSINESS, SENIOR, GROUP, INSTITUTIONAL.',
                            RowNo, CellValue);
                    if not MemberCat.Active then
                        Error('Row %1: Member Category "%2" is inactive.',
                            RowNo, UpperCase(CellValue));
                end;

                // -------------------------------------------------------
                // VALIDATE COUNTRY CODE (if provided)
                // -------------------------------------------------------
                // Users must enter a valid ISO country code (e.g. KE for
                // Kenya, UG for Uganda). Full country names are not accepted.
                CellValue := GetCellValue(ExcelBuffer, RowNo, 9);
                if CellValue <> '' then
                    if not CountryRegion.Get(UpperCase(CellValue)) then
                        Error('Row %1: Country code "%2" is not valid. Use ISO country codes (e.g. KE, UG, TZ, US).',
                            RowNo, CellValue);

                // -------------------------------------------------------
                // AUTO-GENERATE APPLICATION ID (APP-YYYYMMDD-#####)
                // -------------------------------------------------------
                // No. Series setup has been validated before the loop
                RawSequenceNo := NoSeries.GetNextNo(
                    MemberSetup."Member Application Nos.", Today);
                SequenceNoText := Format(RawSequenceNo);

                if not Evaluate(SequenceNoInteger, SequenceNoText) then
                    Error('Invalid No. Series value %1.', SequenceNoText);

                if StrLen(SequenceNoText) > MaxStrLen(SequencePart) then
                    Error('No. Series value %1 exceeds 5 digits.', SequenceNoText);

                SequencePart := CopyStr(
                    PadStr('', MaxStrLen(SequencePart) - StrLen(SequenceNoText), '0')
                    + SequenceNoText,
                    1, MaxStrLen(SequencePart));

                ApplicationIDText := 'APP-'
                    + Format(Today, 0, '<Year4><Month,2><Day,2>')
                    + '-' + SequencePart;

                // -------------------------------------------------------
                // CREATE THE APPLICATION RECORD
                // -------------------------------------------------------
                MemberApp.Init();
                MemberApp."Application ID" := CopyStr(
                    ApplicationIDText, 1, MaxStrLen(MemberApp."Application ID"));

                // Personal info (columns 1-2)
                MemberApp."First Name" := CopyStr(
                    GetCellValue(ExcelBuffer, RowNo, 1), 1, MaxStrLen(MemberApp."First Name"));
                MemberApp."Last Name" := CopyStr(
                    GetCellValue(ExcelBuffer, RowNo, 2), 1, MaxStrLen(MemberApp."Last Name"));

                // Contact (columns 3-5)
                MemberApp."Email" := CopyStr(
                    GetCellValue(ExcelBuffer, RowNo, 3), 1, MaxStrLen(MemberApp."Email"));

                // Phone Number needs special handling because Excel strips
                // the '+' prefix from international numbers like +254756985666,
                // treating them as plain numbers (254756985666).
                // We detect this and re-add the '+' prefix.
                CellValue := GetCellValue(ExcelBuffer, RowNo, 4);
                CellValue := FormatPhoneNumber(CellValue);
                MemberApp."Phone Number" := CopyStr(
                    CellValue, 1, MaxStrLen(MemberApp."Phone Number"));

                // Date of Birth: try standard date parse first, then
                // handle Excel serial numbers (e.g. 33000 = 05/05/1990)
                CellValue := GetCellValue(ExcelBuffer, RowNo, 5);
                if CellValue <> '' then begin
                    if not Evaluate(TempDate, CellValue) then begin
                        // Excel may store dates as serial numbers (days since 30/12/1899)
                        if Evaluate(TempDecimal, CellValue) then begin
                            if (TempDecimal > 1) and (TempDecimal < 100000) then
                                TempDate := CalcDate('<+' + Format(Round(TempDecimal, 1, '<') - 2, 0, 1) + 'D>',
                                    DMY2Date(1, 1, 1900))
                            else
                                Error('Row %1: Date of Birth "%2" is not a valid date or Excel serial number.', RowNo, CellValue);
                        end else
                            Error('Row %1: Date of Birth "%2" is not a valid date format. Use DD/MM/YYYY or YYYY-MM-DD.', RowNo, CellValue);
                    end;
                    MemberApp."Date of Birth" := TempDate;
                end;

                // Address (columns 6-10)
                MemberApp."Address" := CopyStr(
                    GetCellValue(ExcelBuffer, RowNo, 6), 1, MaxStrLen(MemberApp."Address"));
                MemberApp."City" := CopyStr(
                    GetCellValue(ExcelBuffer, RowNo, 7), 1, MaxStrLen(MemberApp."City"));

                // Postal Code: strip decimals Excel may add (e.g. 100.0 → 100)
                MemberApp."Postal Code" := CopyStr(
                    FormatNumericText(GetCellValue(ExcelBuffer, RowNo, 8)),
                    1, MaxStrLen(MemberApp."Postal Code"));

                MemberApp."Country" := CopyStr(
                    GetCellValue(ExcelBuffer, RowNo, 9), 1, MaxStrLen(MemberApp."Country"));

                // ID Number: clean scientific notation / decimals from Excel
                MemberApp."ID Number" := CopyStr(
                    CleanedIDNumber, 1, MaxStrLen(MemberApp."ID Number"));

                // Employment (columns 11-13)
                MemberApp."Occupation" := CopyStr(
                    GetCellValue(ExcelBuffer, RowNo, 11), 1, MaxStrLen(MemberApp."Occupation"));

                CellValue := GetCellValue(ExcelBuffer, RowNo, 12);
                if CellValue <> '' then
                    if Evaluate(TempDecimal, CellValue) then
                        MemberApp."Annual Income" := TempDecimal;

                MemberApp."Member Category" := CopyStr(
                    GetCellValue(ExcelBuffer, RowNo, 13), 1, MaxStrLen(MemberApp."Member Category"));

                // --- Set defaults ---
                MemberApp."Application Date" := Today;
                MemberApp."Status" := Enum::"Member Application Status"::Pending;

                // Insert with false = skip table OnInsert trigger
                // (we handle ID generation and defaults ourselves)
                MemberApp.Insert(false);
                ImportedCount += 1;
            end;
        end;

        Message('%1 application(s) imported successfully from "%2". They are now Pending approval.',
            ImportedCount, FileName);
    end;

    // -------------------------------------------------------
    // HELPER: Add a bold header cell
    // -------------------------------------------------------
    local procedure AddHeaderCell(var ExcelBuffer: Record "Excel Buffer"; HeaderText: Text)
    begin
        ExcelBuffer.AddColumn(
            HeaderText, false, '', true, false, false, '',
            ExcelBuffer."Cell Type"::Text);
    end;

    // -------------------------------------------------------
    // HELPER: Add a text cell
    // -------------------------------------------------------
    local procedure AddTextCell(var ExcelBuffer: Record "Excel Buffer"; CellText: Text)
    begin
        ExcelBuffer.AddColumn(
            CellText, false, '', false, false, false, '',
            ExcelBuffer."Cell Type"::Text);
    end;

    // -------------------------------------------------------
    // HELPER: Add a number cell with formatting
    // -------------------------------------------------------
    local procedure AddNumberCell(var ExcelBuffer: Record "Excel Buffer"; CellNumber: Decimal)
    begin
        ExcelBuffer.AddColumn(
            CellNumber, false, '', false, false, false, '#,##0.00',
            ExcelBuffer."Cell Type"::Number);
    end;

    // -------------------------------------------------------
    // HELPER: Add a date cell
    // -------------------------------------------------------
    local procedure AddDateCell(var ExcelBuffer: Record "Excel Buffer"; CellDate: Date)
    begin
        ExcelBuffer.AddColumn(
            CellDate, false, '', false, false, false, '',
            ExcelBuffer."Cell Type"::Date);
    end;

    // -------------------------------------------------------
    // HELPER: Read a cell value from the Excel Buffer
    // -------------------------------------------------------
    // The Excel Buffer stores cells as (Row No., Column No.) pairs.
    // Get() retrieves the record by primary key. If the cell exists,
    // return its text value; otherwise return empty string.
    // -------------------------------------------------------
    local procedure GetCellValue(var ExcelBuffer: Record "Excel Buffer"; RowNo: Integer; ColNo: Integer): Text
    begin
        if ExcelBuffer.Get(RowNo, ColNo) then
            exit(ExcelBuffer."Cell Value as Text");
        exit('');
    end;

    // -------------------------------------------------------
    // HELPER: Clean numeric text mangled by Excel
    // -------------------------------------------------------
    // Excel converts text-that-looks-like-numbers into actual numbers:
    //   "00100"    → 100     (leading zeros stripped)
    //   "12345678" → 12345678.0 (decimal added)
    //   Very long numbers → scientific notation (1.23E+07)
    // This helper reverses those transformations so fields like
    // ID Number and Postal Code import correctly.
    // -------------------------------------------------------
    local procedure FormatNumericText(RawValue: Text): Text
    var
        DotPos: Integer;
        EPos: Integer;
        Mantissa: Decimal;
        Exponent: Integer;
        FullNumber: Decimal;
        ExponentText: Text;
    begin
        if RawValue = '' then
            exit('');

        // Handle scientific notation (e.g. 1.23457E+07 or 2.55E+11)
        EPos := StrPos(UpperCase(RawValue), 'E');
        if EPos > 0 then begin
            if Evaluate(Mantissa, CopyStr(RawValue, 1, EPos - 1)) then begin
                ExponentText := CopyStr(RawValue, EPos + 1);
                // Remove '+' sign if present
                if CopyStr(ExponentText, 1, 1) = '+' then
                    ExponentText := CopyStr(ExponentText, 2);
                if Evaluate(Exponent, ExponentText) then begin
                    FullNumber := Mantissa * Power(10, Exponent);
                    exit(Format(FullNumber, 0, 1));
                end;
            end;
            // If parsing failed, return as-is
            exit(RawValue);
        end;

        // Strip trailing decimal portion (e.g. 12345678.0 → 12345678)
        DotPos := StrPos(RawValue, '.');
        if DotPos > 0 then
            RawValue := CopyStr(RawValue, 1, DotPos - 1);

        exit(RawValue);
    end;

    // -------------------------------------------------------
    // HELPER: Normalize phone number after Excel import
    // -------------------------------------------------------
    // Excel treats entries like +254756985666 as positive numbers,
    // stripping the '+' prefix and possibly appending '.0'.
    // This procedure restores the expected international format:
    //  1. Remove any trailing decimal portion (e.g. ".0")
    //  2. Re-add the '+' prefix if missing
    // -------------------------------------------------------
    local procedure FormatPhoneNumber(PhoneValue: Text): Text
    var
        DotPos: Integer;
    begin
        if PhoneValue = '' then
            exit('');

        // Strip any decimal portion Excel may have added (e.g. 254756985666.0)
        DotPos := StrPos(PhoneValue, '.');
        if DotPos > 0 then
            PhoneValue := CopyStr(PhoneValue, 1, DotPos - 1);

        // If value starts with a digit, Excel likely stripped the '+' prefix
        if PhoneValue[1] in ['0' .. '9'] then
            PhoneValue := '+' + PhoneValue;

        exit(PhoneValue);
    end;

    // -------------------------------------------------------
    // EXPORT: Members → .csv (using XMLport 50100)
    // -------------------------------------------------------
    // Uses the existing "Member Export" XMLport to produce a CSV
    // file. CSV is useful when the recipient needs a lightweight
    // text file or doesn't have Excel installed.
    // -------------------------------------------------------
    procedure ExportMembersToCSV()
    var
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        InStr: InStream;
        FileName: Text;
    begin
        TempBlob.CreateOutStream(OutStr);
        Xmlport.Export(Xmlport::"Member Export", OutStr);
        TempBlob.CreateInStream(InStr);
        FileName := 'Members.csv';
        DownloadFromStream(InStr, 'Export Members', '', 'CSV Files (*.csv)|*.csv', FileName);
    end;

    // -------------------------------------------------------
    // IMPORT: .csv → Member Applications (using XMLport 50101)
    // -------------------------------------------------------
    // Uses the existing "Member Application Import" XMLport which
    // handles header-row detection, validation, auto-generated IDs,
    // and sets Status = Pending. CSV import is useful when users
    // prepare data in a simple text editor or legacy system.
    // -------------------------------------------------------
    procedure ImportApplicationsFromCSV()
    var
        InStr: InStream;
        FileName: Text;
    begin
        if not UploadIntoStream(
            'Select CSV File', '',
            'CSV Files (*.csv)|*.csv', FileName, InStr) then
            exit;

        Xmlport.Import(Xmlport::"Member Application Import", InStr);
        Message('Applications imported successfully from "%1". They are now Pending approval.', FileName);
    end;

    // -------------------------------------------------------
    // TEMPLATE: Download an empty .xlsx import template
    // -------------------------------------------------------
    // Generates a ready-to-fill Excel file with:
    //   - Bold header row matching the expected 13-column layout
    //   - A sample data row showing the correct format for each field
    // This helps users prepare import data without guessing columns.
    // -------------------------------------------------------
    procedure DownloadImportTemplate()
    var
        ExcelBuffer: Record "Excel Buffer" temporary;
    begin
        ExcelBuffer.DeleteAll();

        // --- HEADER ROW (bold) ---
        ExcelBuffer.NewRow();
        AddHeaderCell(ExcelBuffer, 'First Name');
        AddHeaderCell(ExcelBuffer, 'Last Name');
        AddHeaderCell(ExcelBuffer, 'Email');
        AddHeaderCell(ExcelBuffer, 'Phone Number');
        AddHeaderCell(ExcelBuffer, 'Date of Birth');
        AddHeaderCell(ExcelBuffer, 'Address');
        AddHeaderCell(ExcelBuffer, 'City');
        AddHeaderCell(ExcelBuffer, 'Postal Code');
        AddHeaderCell(ExcelBuffer, 'Country');
        AddHeaderCell(ExcelBuffer, 'ID Number');
        AddHeaderCell(ExcelBuffer, 'Occupation');
        AddHeaderCell(ExcelBuffer, 'Annual Income');
        AddHeaderCell(ExcelBuffer, 'Member Category');

        // --- SAMPLE ROW (shows expected formats) ---
        ExcelBuffer.NewRow();
        AddTextCell(ExcelBuffer, 'Jane');
        AddTextCell(ExcelBuffer, 'Mwangi');
        AddTextCell(ExcelBuffer, 'jane.mwangi@example.com');
        AddTextCell(ExcelBuffer, '+254756985666');
        AddTextCell(ExcelBuffer, '15/05/1990');
        AddTextCell(ExcelBuffer, '456 Moi Avenue');
        AddTextCell(ExcelBuffer, 'Nairobi');
        AddTextCell(ExcelBuffer, '00100');
        AddTextCell(ExcelBuffer, 'KE');
        AddTextCell(ExcelBuffer, '12345678');
        AddTextCell(ExcelBuffer, 'Software Engineer');
        AddNumberCell(ExcelBuffer, 1200000);
        AddTextCell(ExcelBuffer, 'REGULAR');

        ExcelBuffer.CreateNewBook('Import Template');
        ExcelBuffer.WriteSheet('Application Import Template', CompanyName, UserId);
        ExcelBuffer.CloseBook();
        ExcelBuffer.SetFriendlyFilename('MemberApplicationImportTemplate');
        ExcelBuffer.OpenExcel();
    end;
}
