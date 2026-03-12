// ============================================================
// XMLport 50100 - Member Export
// ============================================================
// PURPOSE: EXPORT-ONLY for Member data (Table 50101) to CSV files.
//          CSV files open directly in Excel with proper columns.
//          Use for: reporting, backups, audits, and data sharing.
//
// WHY EXPORT-ONLY?
//   Members should NOT be imported directly into the Member table.
//   The correct flow is:
//     1. Import applicants via the Member Application XMLport (50101)
//     2. Applications land as "Pending" for admin review
//     3. Admin approves → system creates the Member record automatically
//   This preserves the approval workflow and data integrity.
//
// ============================================================
// PART 1: WHAT IS AN XMLPORT?
// ============================================================
//
// An XMLport is a Business Central object used to IMPORT and EXPORT data
// between a Business Central database and external files.
// Despite the name "XMLport", it can handle multiple file formats:
//   - XML files (structured markup)
//   - CSV files (comma-separated values)
//   - Tab-delimited text files (which Excel opens natively)
//   - Fixed-width text files
//
// Think of an XMLport as a BRIDGE between Business Central tables and
// external data files. It defines:
//   1. WHICH table(s) to read from or write to
//   2. WHICH fields to include in the file
//   3. The FORMAT of the file (XML, CSV, tab-delimited, etc.)
//   4. The DIRECTION of data flow (Import, Export, or Both)
//
// An XMLport has THREE main parts:
//
//   A) SCHEMA (the structure block below)
//      - Defines the XML structure: root element → table element → fields
//      - tableelement = one XML node per database TABLE (maps to records)
//      - fieldelement = one XML node per FIELD (maps to table columns)
//
//   B) DIRECTION
//      - Import: Read XML file → insert/update records in BC
//      - Export: Read BC records → write to XML file
//      - Both: User chooses on the Request Page
//
//   C) TRIGGERS
//      - OnPreXmlItem / OnPostXmlItem: Run before/after each record
//      - OnAfterGetRecord: Custom logic when reading a record (export)
//      - OnBeforeInsertRecord: Validate or modify before insert (import)
//
// WHEN THE XMLPORT RUNS:
//   EXPORT: For each Member record → write XML nodes for each field
//   IMPORT: For each <Member> node in XML → create/update Member record
//
// ============================================================
// PART 2: PURPOSE IN THIS SACCO PROJECT (MEMBERS)
// ============================================================
//
// This XMLport works with the Member table (Table 50101), which stores
// active SACCO members — people whose membership applications have
// been approved. It allows SACCO administrators to:
//
//   1. EXPORT MEMBERS:
//      - Generate a full list of all SACCO members for reporting
//      - Share member data with auditors, regulators, or management
//      - Create backups of member records
//      - Produce data for analysis outside Business Central
//
//   2. IMPORT MEMBERS:
//      - Bulk-load member data during initial SACCO system setup
//      - Migrate member records from legacy systems (e.g., spreadsheets)
//      - Update member information in bulk (e.g., category changes)
//      - Restore member data from a previously exported backup
//
// WHY THIS MATTERS FOR A SACCO:
//   SACCOs (Savings and Credit Cooperative Organizations) manage
//   hundreds or thousands of members. Manual data entry is slow
//   and error-prone. This XMLport enables:
//     - Fast onboarding when migrating from another system
//     - Regulatory reporting (export member lists for compliance)
//     - Data sharing with partner organizations
//     - Periodic backups of critical member data
//
// MEMBER FIELDS INCLUDED (all 19 fields from Table 50101):
//   Identification:  Member ID, Application ID
//   Personal:        First Name, Last Name, Full Name
//   Contact:         Email, Phone Number, Date of Birth
//   Address:         Address, City, Postal Code, Country, ID Number
//   Status:          Registration Date, Status
//   Employment:      Occupation, Annual Income, Member Category
//   Financial:       Account Balance
//
// ============================================================
// PART 3: PROCESSING-ONLY / CODE-BASED USAGE
// ============================================================
//
// You can run an XMLport from CODE instead of the UI:
//
//   IMPORT from a file:
//     MemberXMLport.Import(File);
//
//   EXPORT to a file:
//     MemberXMLport.Export(File);
//
//   RUN with Request Page (user picks file, Import/Export):
//     Xmlport.Run(Xmlport::"Member Import/Export");
//
// Use from code when:
//   - Scheduled Job Queue (e.g., nightly export to FTP)
//   - Integration: import from web service, export to API
//   - Batch processing in a codeunit
//
// ============================================================
// PART 4: CSV STRUCTURE PRODUCED/CONSUMED (Opens in Excel)
// ============================================================
//
// With Format = VariableText and FieldSeparator = ',', this XMLport
// produces/expects CSV (Comma-Separated Values) files.
// CSV files open directly in Microsoft Excel with each field in its
// own column.
//
// EXPORTED CSV FORMAT (each row = one member, columns separated by commas):
//
//   "MEM-20260303-0001","APP-0001","John","Doe","John Doe","john@example.com","+254712345678","1990-05-15","123 Kenyatta Avenue","Nairobi","00100","KE","12345678","2026-03-03T10:00:00","Active","Software Engineer","1200000","REGULAR","50000"
//
// COLUMN ORDER (matches field order in schema):
//   1. Member ID         2. Application ID    3. First Name
//   4. Last Name         5. Full Name         6. Email
//   7. Phone Number      8. Date of Birth     9. Address
//  10. City             11. Postal Code      12. Country
//  13. ID Number        14. Registration Date 15. Status
//  16. Occupation       17. Annual Income    18. Member Category
//  19. Account Balance
//
// HOW TO USE IN EXCEL:
//   1. Export members using the "Export Members" button on the Member List
//   2. The file downloads as Members.csv
//   3. Double-click the .csv file — Excel opens it automatically
//   4. Each member appears as a row, each field as a column
//
// TO IMPORT FROM EXCEL:
//   1. Prepare data in Excel following the column order above
//   2. Save as CSV (File → Save As → CSV UTF-8)
//   3. Use the "Import Members" button on the Member List
//   4. Select the .csv file — members are loaded into BC
//
// ============================================================

xmlport 50100 "Member Export"
{
    Caption = 'Member Export';
    Direction = Export;          // Export-only — members cannot be imported directly
    Format = VariableText;       // Produces CSV (comma-separated) instead of XML
    FieldSeparator = ',';        // Comma between each column
    FieldDelimiter = '"';        // Wraps text values in double quotes
    TextEncoding = UTF8;         // Supports special characters (e.g., accents)
    UseRequestPage = true;

    schema
    {
        // ---------------------------------------------------------------
        // ROOT ELEMENT - Must be a textelement (required for XML format)
        // ---------------------------------------------------------------
        //
        // The root wraps all Member records. Name it clearly (e.g., "Members").
        // When exporting: BC creates <Members> and nests each <Member> inside.
        // When importing: BC expects the same structure.
        //
        // ---------------------------------------------------------------

        textelement(Members)
        {
            // -----------------------------------------------------------
            // TABLE ELEMENT - Links to the Member table (Table 50101)
            // -----------------------------------------------------------
            //
            // tableelement(VariableName; "Table Name")
            //   - VariableName: Use in triggers to access current record
            //   - "Table Name": The BC table (Member)
            //
            // XmlName: The tag name in the XML file (e.g., <Member>)
            //
            // On export: Loops through Member records, writes each as <Member>
            // On import: Reads each <Member> node, inserts/updates a record
            //
            // -----------------------------------------------------------

            tableelement(Member; Member)
            {
                XmlName = 'Member';

                // RequestPage filters - which members to export (ignored on import)
                RequestFilterFields = "Member ID", "Status";

                // ========================================
                // IDENTIFICATION FIELDS
                // ========================================
                //
                // fieldelement(XmlTagName; TableVariable.FieldName)
                //   - XmlTagName: The XML element name (e.g., <MemberID>)
                //   - Field: The table field to read/write
                //
                // Order matters for readability; XML structure follows this order.
                //
                // ----------

                // The unique member ID (e.g., MEM-20260303-0001)
                // This is the primary key - used to identify each member
                fieldelement(MemberID; Member."Member ID")
                {
                }
                // Links back to the original membership application
                // Shows which application created this member record
                fieldelement(ApplicationID; Member."Application ID")
                {
                }

                // ========================================
                // PERSONAL INFORMATION FIELDS
                // ========================================
                fieldelement(FirstName; Member."First Name")
                {
                }
                fieldelement(LastName; Member."Last Name")
                {
                }
                // Computed full name (First + Last)
                // Auto-generated but included for readability in exports
                fieldelement(FullName; Member."Full Name")
                {
                }

                // ========================================
                // CONTACT INFORMATION FIELDS
                // ========================================
                fieldelement(Email; Member.Email)
                {
                }
                fieldelement(PhoneNumber; Member."Phone Number")
                {
                }
                // Must be at least 18 years old (validated by the Member table)
                fieldelement(DateOfBirth; Member."Date of Birth")
                {
                }

                // ========================================
                // ADDRESS FIELDS
                // ========================================
                fieldelement(Address; Member.Address)
                {
                }
                fieldelement(City; Member.City)
                {
                }
                fieldelement(PostalCode; Member."Postal Code")
                {
                }
                // Country code (linked to BC's Country/Region table)
                fieldelement(Country; Member.Country)
                {
                }
                // National ID or Passport number
                fieldelement(IDNumber; Member."ID Number")
                {
                }

                // ========================================
                // STATUS & REGISTRATION FIELDS
                // ========================================
                // Set automatically when a membership application is approved
                fieldelement(RegistrationDate; Member."Registration Date")
                {
                }
                // Current member status (Active, Inactive, Suspended, Closed)
                // Uses Enum 50101 "Member Status"
                fieldelement(Status; Member.Status)
                {
                }

                // ========================================
                // EMPLOYMENT FIELDS
                // ========================================
                fieldelement(Occupation; Member.Occupation)
                {
                }
                // Yearly income (used for loan eligibility assessment)
                fieldelement(AnnualIncome; Member."Annual Income")
                {
                }
                // Category code (e.g., REGULAR, STUDENT, BUSINESS)
                // Links to the Member Category Master table
                fieldelement(MemberCategory; Member."Member Category")
                {
                }

                // ========================================
                // FINANCIAL FIELDS
                // ========================================
                // Current savings account balance
                // This is a calculated/managed field - be cautious when importing
                fieldelement(AccountBalance; Member."Account Balance")
                {
                }

                // ===============================================================
                // TRIGGERS - Run code at specific moments
                // ===============================================================
                //
                // OnBeforeInsertRecord (Import only): Before inserting a new record
                //   Use for: Validation, set default values, skip invalid rows
                //
                // OnAfterGetRecord (Export only): After reading each record
                //   Use for: Skip records, transform data before export
                //
                // OnAfterInsertRecord (Import only): After inserting
                //   Use for: Post-processing, update related tables
                //
                // ===============================================================

                trigger OnAfterGetRecord()
                begin
                    // Runs for each Member record during EXPORT
                    // Use to filter or transform data before writing to XML

                    // EXAMPLE: Skip inactive members on export
                    // if Member.Status = Member.Status::Inactive then
                    //     currXMLport.Skip();

                    // PROCESSING-ONLY EXAMPLE: Count exported records
                    // ExportCount += 1;
                end;
            }
        }
    }

    // -----------------------------------------------------------------------
    // REQUEST PAGE - Dialog before Import/Export
    // -----------------------------------------------------------------------
    //
    // Users can:
    //   - Choose Import or Export (when Direction = Both)
    //   - Pick the file to import from / save export to
    //   - Apply filters (from RequestFilterFields) to limit export data
    //
    // -----------------------------------------------------------------------

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    // Add custom options, e.g.:
                    // field(ReplaceExisting; ReplaceExisting)
                    // {
                    //     Caption = 'Replace existing members on import';
                    //     ApplicationArea = All;
                    // }
                }
            }
        }
        actions
        {
            // Default: Import/Export choice and file picker are automatic
        }
    }

    // -----------------------------------------------------------------------
    // VARIABLES - For use in triggers
    // -----------------------------------------------------------------------

    var
    // ExportCount: Integer;  // Uncomment for processing-only counting
}
