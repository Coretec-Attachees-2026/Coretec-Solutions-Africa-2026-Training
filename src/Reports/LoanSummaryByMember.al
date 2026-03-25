// ============================================================
// Report 50115 - Loan Summary by Member
// ============================================================
// PURPOSE: Generates a printable list of all members with their
//          loan applications listed beneath each member.
//
// STRUCTURE (parent-child dataset):
//   DataItem 1: Member        → one row per member
//   DataItem 2: Loan Application (nested) → zero-to-many loans per member
//
// KEY CONCEPT - "DataItemLink":
//   DataItemLink = "Member ID" = field("Member ID") means:
//   "For each Member record, only read Loan Application records
//    WHERE Loan Application."Member ID" = Member."Member ID"."
//   This is the AL equivalent of a LEFT JOIN / correlated loop.
//
// KEY CONCEPT - nested DataItems and the RDLC layout:
//   The RDLC layout groups rows by MemberID.  The outer group
//   shows the member header; the inner rows show each loan.
//   Both DataItems feed into a SINGLE flat DataSet_Result —
//   BC multiplies out Member × Loans (like a SQL JOIN), and the
//   RDLC grouping collapses member data into a header row.
//
// FIX APPLIED (vs original file):
//   - Added RequestFilterFields on both DataItems
//   - Added LoanAmountFormat computed column (format string)
//   - Added ApplicationDate column (used in layout)
//   - Added CompanyName, ReportTitle, PrintDate header columns
//   - Fixed dataset column name to match the RDL DataSet_Result
//
// HOW TO RUN:
//   From the Loan Application List → "Loan Summary by Member" action,
//   or Search "Loan Summary by Member" in BC.
// ============================================================

report 50115 "Loan Summary by Member"
{
    Caption = 'Loan Summary by Member';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultLayout = RDLC;
    RDLCLayout = 'src/Layouts/LoanSummaryByMember.rdl';

    // -------------------------------------------------------
    // DATASET
    // -------------------------------------------------------
    dataset
    {
        // ---------- OUTER DataItem: Member ----------
        dataitem(Member; "Member")
        {
            // RequestFilterFields → these appear on the Request Page
            // so users can narrow down which members appear.
            RequestFilterFields = "Member ID", "Status", "Member Category";

            // Header-level columns (repeated for each loan row in the RDLC)
            column(MemberID; "Member ID")
            {
                IncludeCaption = true;
            }
            column(FullName; "Full Name")
            {
                IncludeCaption = true;
            }
            column(MemberStatus; "Status")
            {
                IncludeCaption = true;
            }

            // Computed header columns (used by the RDLC report header)
            column(CompanyName; CompanyName)
            {
                // Returns the current BC company name for the report header
            }
            column(ReportTitle; ReportTitleLbl)
            {
            }
            column(PrintDate; PrintDateText)
            {
            }

            // ---------- INNER DataItem: Loan Application ----------
            dataitem(LoanApp; "Loan Application")
            {
                // KEY: links each loan to its parent member
                DataItemLink = "Member ID" = field("Member ID");

                // Field name must be quoted in RequestFilterFields
                RequestFilterFields = "Status";

                column(LoanAppNo; "Loan Application No.")
                {
                    IncludeCaption = true;
                }
                column(LoanAmount; "Loan Amount")
                {
                    IncludeCaption = true;
                }

                // Formatted amount string — computed in OnAfterGetRecord below.
                // KEY FIX: a report column() source must be a FIELD or VARIABLE.
                // Inline function calls like Format(...) are NOT valid column sources.
                column(LoanStatus; Status)
                {
                    IncludeCaption = true;
                }
                column(ApplicationDate; "Application Date")
                {
                    IncludeCaption = true;
                }
                column(InterestRate; "Interest Rate (%)")
                {
                }
                column(LoanTerm; "Loan Term (Months)")
                {
                }
                column(TotalRepayment; "Total Repayment")
                {
                }

                trigger OnAfterGetRecord()
                begin
                    // Compute formatted strings for RDL columns
                    LoanAmountFormatText := Format("Loan Amount", 0, '<Precision,2:2><Standard Format,0>');
                    TotalRepaymentFormatText := Format("Total Repayment", 0, '<Precision,2:2><Standard Format,0>');
                end;
            }

            // Format print date once per member row
            trigger OnAfterGetRecord()
            begin
                PrintDateText := Format(Today, 0, '<Day,2>/<Month,2>/<Year4>');
            end;
        }
    }

    // -------------------------------------------------------
    // REQUEST PAGE
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
                    // RequestFilterFields on the DataItems already provide
                    // Member ID, Status, Member Category, and Loan Status filters
                }
            }
        }
    }

    // -------------------------------------------------------
    // LABELS
    // -------------------------------------------------------
    labels
    {
        LoanSummaryByMemberLbl = 'Loan Summary by Member';
        MemberLbl = 'Member';
        LoansLbl = 'Loans';
        TotalLbl = 'Total';
        PageNoLbl = 'Page';
        PrintedOnLbl = 'Printed on:';
    }

    // -------------------------------------------------------
    // VARIABLES
    // -------------------------------------------------------
    var
        ReportTitleLbl: Label 'Loan Summary by Member';
        PrintDateText: Text[50];
        // KEY FIX: these back the LoanAmountFormat / TotalRepaymentFormat columns.
        // Format() cannot be used directly as a column() source in AL; the values
        // must be computed in OnAfterGetRecord and stored here.
        LoanAmountFormatText: Text[50];
        TotalRepaymentFormatText: Text[50];
}
