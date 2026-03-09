// ============================================================
// Report 50100 - Member Report
// ============================================================
// PURPOSE: Generates a list of all SACCO members with their
//          personal details, category, status, and financials.
//
// HOW IT WORKS:
//   1. User runs the report from the Member List page
//   2. A request page lets the user filter by Status, Category, etc.
//   3. The report fetches data from the Member table (50101)
//   4. Results are rendered using an RDLC layout
//
// KEY CONCEPT - "dataitem":
//   A dataitem defines WHICH TABLE the report reads from.
//   Think of it as a "for each record in this table" loop.
//
// KEY CONCEPT - "column":
//   A column maps a table field to the report layout.
//   The layout file uses these column names to display data.
//
// KEY CONCEPT - "RequestFilterFields":
//   These fields appear as filters on the request page,
//   letting users narrow down which records appear in the report.
// ============================================================

report 50100 "Member Report"
{
    Caption = 'Member Report';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultLayout = RDLC;
    RDLCLayout = 'src\Layouts\MemberReport.rdl';

    // -------------------------------------------------------
    // DATASET - defines what data the report reads
    // -------------------------------------------------------
    dataset
    {
        // ---------- PRIMARY DATA ITEM: Member Table ----------
        dataitem(Member; "Member")
        {
            // RequestFilterFields: these fields appear as filter options
            // on the request page so the user can narrow results
            RequestFilterFields = "Member ID", "Status", "Member Category", "City";

            // ---------- IDENTIFICATION COLUMNS ----------
            column(MemberID; "Member ID")
            {
                IncludeCaption = true;
            }
            column(ApplicationID; "Application ID")
            {
                IncludeCaption = true;
            }

            // ---------- PERSONAL INFO COLUMNS ----------
            column(FirstName; "First Name")
            {
                IncludeCaption = true;
            }
            column(LastName; "Last Name")
            {
                IncludeCaption = true;
            }
            column(FullName; "Full Name")
            {
                IncludeCaption = true;
            }
            column(IDNumber; "ID Number")
            {
                IncludeCaption = true;
            }
            column(DateOfBirth; "Date of Birth")
            {
                IncludeCaption = true;
            }

            // ---------- CONTACT COLUMNS ----------
            column(Email; "Email")
            {
                IncludeCaption = true;
            }
            column(PhoneNumber; "Phone Number")
            {
                IncludeCaption = true;
            }

            // ---------- ADDRESS COLUMNS ----------
            column(Address; "Address")
            {
                IncludeCaption = true;
            }
            column(City; "City")
            {
                IncludeCaption = true;
            }
            column(PostalCode; "Postal Code")
            {
                IncludeCaption = true;
            }
            column(Country; "Country")
            {
                IncludeCaption = true;
            }

            // ---------- STATUS & MEMBERSHIP COLUMNS ----------
            column(RegistrationDate; "Registration Date")
            {
                IncludeCaption = true;
            }
            column(Status; "Status")
            {
                IncludeCaption = true;
            }
            column(MemberCategory; "Member Category")
            {
                IncludeCaption = true;
            }

            // ---------- EMPLOYMENT & FINANCIAL COLUMNS ----------
            column(Occupation; "Occupation")
            {
                IncludeCaption = true;
            }
            column(AnnualIncome; "Annual Income")
            {
                IncludeCaption = true;
            }
            column(AccountBalance; "Account Balance")
            {
                IncludeCaption = true;
            }

            // ---------- COMPUTED COLUMNS ----------
            // These provide extra info to the layout that isn't stored in the table
            column(CompanyName; CompanyName)
            {
                // Built-in function: returns the current company name
                // Useful for the report header
            }
            column(ReportTitle; ReportTitleLbl)
            {
                // A label constant defined in the labels section
            }
            column(PrintDate; PrintDateText)
            {
                // The date/time when the report was generated
            }

            // ---------- TRIGGER: runs before each record is processed ----------
            trigger OnAfterGetRecord()
            begin
                // Format the current date/time for display in the report footer
                PrintDateText := Format(CurrentDateTime, 0, '<Day,2>/<Month,2>/<Year4> <Hours24,2>:<Minutes,2>');
            end;
        }
    }

    // -------------------------------------------------------
    // REQUEST PAGE - filter options shown before running
    // -------------------------------------------------------
    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Report Options';
                    // Additional options can be added here
                    // The RequestFilterFields on the dataitem already provide
                    // Member ID, Status, Member Category, and City filters
                }
            }
        }
    }

    // -------------------------------------------------------
    // RENDERING - links to the layout file
    // -------------------------------------------------------
    // rendering
    // {
    //     layout(MemberReportRDLC)
    //     {
    //         Type = RDLC;
    //         LayoutFile = '../Layouts/MemberReport.rdl';
    //         Caption = 'Member Report (RDLC)';
    //     }
    // }

    // -------------------------------------------------------
    // LABELS - text constants used in the report layout
    // -------------------------------------------------------
    labels
    {
        PageNoLbl = 'Page', Comment = 'Page number label';
        PrintedOnLbl = 'Printed on:', Comment = 'Label for print date';
        MemberDetailsLbl = 'Member Details', Comment = 'Section header';
        ContactInfoLbl = 'Contact Information', Comment = 'Section header';
        FinancialInfoLbl = 'Financial Information', Comment = 'Section header';
        TotalMembersLbl = 'Total Members:', Comment = 'Summary label';
    }

    // -------------------------------------------------------
    // VARIABLES
    // -------------------------------------------------------
    var
        ReportTitleLbl: Label 'SACCO Member Report';
        PrintDateText: Text[50];
}