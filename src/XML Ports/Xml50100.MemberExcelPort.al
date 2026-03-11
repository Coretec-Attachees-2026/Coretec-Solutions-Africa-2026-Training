// ============================================================
// XMLport 50100 - Member Excel Import/Export
// ============================================================
//
// WHAT IS AN XMLPORT?
// -------------------
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
// HOW AN XMLPORT WORKS:
//   EXPORTING: Reads records from a BC table → writes them to a file
//   IMPORTING: Reads data from a file → inserts/updates records in a BC table
//
// KEY CONCEPT - "Direction":
//   Direction = Import  → only allows importing data INTO Business Central
//   Direction = Export  → only allows exporting data OUT OF Business Central
//   Direction = Both    → allows the user to choose import or export at runtime
//
// KEY CONCEPT - "Format":
//   Format = Xml           → produces/reads XML files
//   Format = VariableText  → produces/reads delimited text files (CSV, TSV)
//   Format = FixedText     → produces/reads fixed-width text files
//
// KEY CONCEPT - "schema":
//   The schema section defines the STRUCTURE of the file.
//   - "textelement" = a wrapper node (required for the root)
//   - "tableelement" = maps to a BC table (each record = one row in the file)
//   - "fieldelement" = maps to a specific field in the table (each field = one column)
//
// ============================================================
//
// PURPOSE IN THIS SACCO PROJECT:
// ------------------------------
// This XMLport allows SACCO administrators to:
//
//   1. EXPORT MEMBERS TO EXCEL:
//      - Generate a full list of all SACCO members for reporting
//      - Share member data with auditors, regulators, or management
//      - Create backups of member records in Excel format
//      - Produce data for analysis outside Business Central
//
//   2. IMPORT MEMBERS FROM EXCEL:
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
// HOW TO USE THIS XMLPORT:
//   1. In Business Central, search for "Member Excel Import/Export"
//   2. Choose whether to Import or Export
//   3. For EXPORT: Select filters (optional) → Download the file → Open in Excel
//   4. For IMPORT: Prepare a tab-delimited .txt file with matching columns → Upload
//
// FILE FORMAT:
//   The exported file is tab-delimited text (.txt), which Excel can open directly.
//   Each row represents one member. Each column maps to a field below.
//   Column order: MemberID, ApplicationID, FirstName, LastName, FullName,
//                 Email, PhoneNumber, DateOfBirth, Address, City, PostalCode,
//                 Country, IDNumber, RegistrationDate, Status, Occupation,
//                 AnnualIncome, MemberCategory, AccountBalance
//
// ============================================================

xmlport 50100 "Member Excel Import/Export"
{
    Caption = 'Member Excel Import/Export';

    // Direction = Both → user can choose to Import or Export at runtime
    // This is useful because the same XMLport serves both purposes
    Direction = Both;

    // Format = VariableText → the file is a delimited text file (not XML)
    // This makes the output compatible with Excel (tab-separated values)
    Format = VariableText;

    // FormatEvaluate = Legacy → uses the older format evaluation method
    // This ensures compatibility with how BC processes field values
    FormatEvaluate = Legacy;

    // TextEncoding = UTF8 → supports international characters (accents, symbols)
    // Important for SACCO members with non-English names
    TextEncoding = UTF8;

    // FieldSeparator = '<TAB>' → columns are separated by tab characters
    // Tab-separated files open cleanly in Excel without delimiter issues
    FieldSeparator = '<TAB>';

    // FieldDelimiter = '<None>' → field values are NOT wrapped in quotes
    // This keeps the file clean and simple
    FieldDelimiter = '<None>';

    // UseRequestPage = true → shows a dialog before running
    // The dialog lets the user set filters or options before import/export
    UseRequestPage = true;

    // -------------------------------------------------------
    // SCHEMA - Defines the structure of the import/export file
    // -------------------------------------------------------
    // The schema maps Business Central table fields to file columns.
    // When EXPORTING: each field becomes a column in the output file
    // When IMPORTING: each column in the file maps back to a table field
    schema
    {
        // Root element - required wrapper for the data structure
        // In VariableText format, this doesn't appear in the file output;
        // it's just a structural requirement of the XMLport definition
        textelement(RootNodeName)
        {
            // tableelement maps to the "Member" table (Table 50101)
            // Each record in the Member table becomes one row in the file
            // The variable name "Member" is used to reference fields below
            tableelement(Member; "Member")
            {
                // ========================================
                // IDENTIFICATION FIELDS
                // ========================================
                // Column 1: The unique member ID (e.g., MEM-20260303-0001)
                // This is the primary key - used to identify each member
                fieldelement(MemberID; Member."Member ID")
                {
                }
                // Column 2: Links back to the original membership application
                // Shows which application created this member record
                fieldelement(ApplicationID; Member."Application ID")
                {
                }

                // ========================================
                // PERSONAL INFORMATION FIELDS
                // ========================================
                // Column 3: Member's first name
                fieldelement(FirstName; Member."First Name")
                {
                }
                // Column 4: Member's last name / surname
                fieldelement(LastName; Member."Last Name")
                {
                }
                // Column 5: Computed full name (First + Last)
                // This field is auto-generated but included for readability in exports
                fieldelement(FullName; Member."Full Name")
                {
                }

                // ========================================
                // CONTACT INFORMATION FIELDS
                // ========================================
                // Column 6: Member's email address
                fieldelement(Email; Member."Email")
                {
                }
                // Column 7: Member's phone number
                fieldelement(PhoneNumber; Member."Phone Number")
                {
                }
                // Column 8: Member's date of birth
                // Must be at least 18 years old (validated by the Member table)
                fieldelement(DateOfBirth; Member."Date of Birth")
                {
                }

                // ========================================
                // ADDRESS FIELDS
                // ========================================
                // Column 9: Street address or P.O. Box
                fieldelement(Address; Member."Address")
                {
                }
                // Column 10: City or town
                fieldelement(City; Member."City")
                {
                }
                // Column 11: Postal/ZIP code
                fieldelement(PostalCode; Member."Postal Code")
                {
                }
                // Column 12: Country code (linked to BC's Country/Region table)
                fieldelement(Country; Member."Country")
                {
                }
                // Column 13: National ID or Passport number
                fieldelement(IDNumber; Member."ID Number")
                {
                }

                // ========================================
                // STATUS & REGISTRATION FIELDS
                // ========================================
                // Column 14: Date and time the member was registered
                // Set automatically when a membership application is approved
                fieldelement(RegistrationDate; Member."Registration Date")
                {
                }
                // Column 15: Current member status (Active, Inactive, Suspended, Closed)
                // Uses Enum 50101 "Member Status"
                fieldelement(Status; Member."Status")
                {
                }

                // ========================================
                // EMPLOYMENT FIELDS
                // ========================================
                // Column 16: Member's job title or profession
                fieldelement(Occupation; Member."Occupation")
                {
                }
                // Column 17: Member's yearly income (used for loan eligibility)
                fieldelement(AnnualIncome; Member."Annual Income")
                {
                }
                // Column 18: Category code (e.g., REGULAR, STUDENT, BUSINESS)
                // Links to the Member Category Master table
                fieldelement(MemberCategory; Member."Member Category")
                {
                }

                // ========================================
                // FINANCIAL FIELDS
                // ========================================
                // Column 19: Current savings account balance
                // This is a calculated/managed field - be cautious when importing
                fieldelement(AccountBalance; Member."Account Balance")
                {
                }
            }
        }
    }

    // -------------------------------------------------------
    // REQUEST PAGE
    // -------------------------------------------------------
    // The request page is the dialog that appears before the XMLport runs.
    // It allows the user to set options or apply filters before importing/exporting.
    // Currently it has an empty Options group - additional options can be added
    // here in the future (e.g., checkboxes to skip certain fields during import).
    requestpage
    {
        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                }
            }
        }
    }
}
