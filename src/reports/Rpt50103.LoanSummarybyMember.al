// ============================================================
// Report 50103 - Loan Summary by Member
// ============================================================
// PURPOSE: Shows each member with their loans listed underneath.
//
// STRUCTURE:
//   DataItem 1: Member - the parent/main level
//   DataItem 2: Loan Application - nested under Member, linked by Member ID
//
// KEY CONCEPT - DataItemLink:
//   Links the Loan Application to Member using the Member ID field.
//   This ensures that for each member, only their loans are shown below.
//
// DISPLAY:
//   - Member ID, Full Name (from Member table)
//   - Loan Application No., Loan Amount, Status (from Loan Application)
// ============================================================

report 50103 "Loan Summary by Member"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    Caption = 'Loan Summary by Member';
    DefaultLayout = RDLC;
    RDLCLayout = 'src/layouts/Rpt50103.LoanSummarybyMember.rdl';

    dataset
    {
        // ------ DataItem 1: Member (Parent Level) ------
        dataitem(Member; "Member")
        {
            RequestFilterFields = "Member ID", "Status";

            column(Member_ID; "Member ID")
            {
                IncludeCaption = true;
            }
            column(Full_Name; "Full Name")
            {
                IncludeCaption = true;
            }
            column(Member_Status; Status)
            {
                IncludeCaption = true;
            }

            // ------ DataItem 2: Loan Application (Nested under Member) ------
            // This dataitem shows all loans FOR EACH member
            dataitem(LoanApplication; "Loan Application")
            {
                // CRITICAL: This link ensures only loans for the current member are shown
                // It matches the "Member ID" field in Loan Application
                // to the "Member ID" field in the parent Member dataitem
                DataItemLink = "Member ID" = field("Member ID");
                RequestFilterFields = "Status", "Application Date";

                column(Loan_Application_No; "Loan Application No.")
                {
                    IncludeCaption = true;
                }
                column(Loan_Amount; "Loan Amount")
                {
                    IncludeCaption = true;
                }
                column(Loan_Status; Status)
                {
                    IncludeCaption = true;
                }
                column(Application_Date; "Application Date")
                {
                    IncludeCaption = true;
                }
                column(Loan_Term_Months; "Loan Term (Months)")
                {
                    IncludeCaption = true;
                }
                column(Monthly_Payment; "Monthly Payment")
                {
                    IncludeCaption = true;
                }
                column(Interest_Rate; "Interest Rate (%)")
                {
                    IncludeCaption = true;
                }
                column(Total_Repayment; "Total Repayment")
                {
                    IncludeCaption = true;
                }
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
                    Caption = 'Options';
                    // Filter options are defined in DataItemRequestFilterFields above
                    // Users can filter by Member ID, Status, Loan Status, and Application Date
                }
            }
        }
    }



    var
        ReportTitle: Label 'Loan Summary by Member';
}
