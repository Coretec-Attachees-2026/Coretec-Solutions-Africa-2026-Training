// ============================================================
// Query 50114 - Loan Application Overview
// ============================================================
// PURPOSE: Retrieves Loan Application data with related Member
//          and Member Category information for analysis and
//          monitoring of active loans in the system.
//
// USE CASES:
//   - Monitor pending, approved, and rejected loan applications
//   - Analyze loan portfolio by member category
//   - Track loan amounts and application dates
//   - Generate reports on loan approval trends
//
// JOINS:
//   - Loan Application → Member (shows who applied)
//   - Member → Member Category Master (categorizes members)
//
// ============================================================

query 50114 "Loan Application Overview"
{
    Caption = 'Loan Application Overview';
    QueryType = Normal;
    UsageCategory = ReportsAndAnalysis;

    elements
    {
        // ---------------------------------------------------------------
        // DATAITEM - Loan Application (main source)
        // ---------------------------------------------------------------

        dataitem(LoanApplication; "Loan Application")
        {
            // ---------- COLUMNS from Loan Application table ----------

            column(LoanApplicationNo; "Loan Application No.")
            {
                Caption = 'Loan ID';
            }
            column(MemberID; "Member ID")
            {
                Caption = 'Member ID';
            }
            column(LoanAmount; "Loan Amount")
            {
                Caption = 'Loan Amount';
            }
            column(InterestRate; "Interest Rate (%)")
            {
                Caption = 'Interest Rate %';
            }
            column(LoanTerm; "Loan Term (Months)")
            {
                Caption = 'Term (Months)';
            }
            column(ApplicationDate; "Application Date")
            {
                Caption = 'Application Date';
            }
            column(ApprovalDate; "Approval Date")
            {
                Caption = 'Approval Date';
            }
            column(MonthlyPayment; "Monthly Payment")
            {
                Caption = 'Monthly Payment';
            }
            column(TotalRepayment; "Total Repayment")
            {
                Caption = 'Total Repayment';
            }
            column(Status; Status)
            {
                Caption = 'Status';
            }
            column(LoanPurpose; "Loan Purpose")
            {
                Caption = 'Loan Purpose';
            }
            column(DisbursementDate; "Disbursement Date")
            {
                Caption = 'Disbursement Date';
            }
            column(RejectionReason; "Rejection Reason")
            {
                Caption = 'Rejection Reason';
            }

            // -----------------------------------------------------------
            // NESTED DATAITEM - Member (linked via Member ID)
            // -----------------------------------------------------------
            //
            // Shows Member details (name, email, phone, etc.)
            // for each loan application
            //
            // -----------------------------------------------------------

            dataitem(Member; Member)
            {
                DataItemLink = "Member ID" = LoanApplication."Member ID";
                SqlJoinType = LeftOuterJoin;

                column(MemberFullName; "Full Name")
                {
                    Caption = 'Member Name';
                }
                column(MemberEmail; Email)
                {
                    Caption = 'Email';
                }
                column(MemberPhone; "Phone Number")
                {
                    Caption = 'Phone Number';
                }
                column(MemberStatus; Status)
                {
                    Caption = 'Member Status';
                }
                column(MemberCategoryCode; "Member Category")
                {
                    Caption = 'Member Category Code';
                }
                column(AccountBalance; "Account Balance")
                {
                    Caption = 'Account Balance';
                }

                // -----------------------------------------------------------
                // NESTED DATAITEM - Member Category Master
                // -----------------------------------------------------------
                //
                // Shows category description (e.g., "Salaried", "Self-Employed")
                //
                // -----------------------------------------------------------

                dataitem(MemberCategoryMaster; "Member Category Master")
                {
                    DataItemLink = Code = Member."Member Category";
                    SqlJoinType = LeftOuterJoin;

                    column(CategoryDescription; Description)
                    {
                        Caption = 'Category';
                    }
                }
            }
        }
    }
}
