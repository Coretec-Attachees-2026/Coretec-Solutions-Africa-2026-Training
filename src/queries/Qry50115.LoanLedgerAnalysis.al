// ============================================================
// Query 50115 - Loan Ledger Analysis
// ============================================================
// PURPOSE: Retrieves Loan Ledger Entries for financial tracking,
//          payment history, and loan status monitoring. Shows
//          individual transactions (payments, interest, penalties).
//
// USE CASES:
//   - Track payment history for each loan
//   - Monitor overdue payments
//   - Analyze interest accrual and penalties
//   - Generate member account statements
//   - Reconcile loan balances
//
// JOINS:
//   - Loan Ledger Entry → Loan Application (loan details)
//   - Loan Application → Member (member details)
//
// ============================================================

query 50115 "Loan Ledger Analysis"
{
    Caption = 'Loan Ledger Analysis';
    QueryType = Normal;
    UsageCategory = ReportsAndAnalysis;

    elements
    {
        // ---------------------------------------------------------------
        // DATAITEM - Loan Ledger Entry (main source)
        // ---------------------------------------------------------------

        dataitem(LoanLedgerEntry; "Loan Ledger Entry")
        {
            // ---------- COLUMNS from Loan Ledger Entry table ----------

            column(EntryNo; "Entry No.")
            {
                Caption = 'Entry No.';
            }
            column(LoanApplicationNo; "Loan Application No.")
            {
                Caption = 'Loan ID';
            }
            column(MemberIDLedger; "Member ID")
            {
                Caption = 'Member ID';
            }
            column(PostingDate; "Posting Date")
            {
                Caption = 'Posting Date';
            }
            column(DocumentNo; "Document No.")
            {
                Caption = 'Document No.';
            }
            column(LoanAmountLedger; "Loan Amount")
            {
                Caption = 'Loan Amount';
            }
            column(InterestRateLedger; "Interest Rate (%)")
            {
                Caption = 'Interest Rate %';
            }
            column(LoanTermLedger; "Loan Term (Months)")
            {
                Caption = 'Term (Months)';
            }
            column(TotalInterest; "Total Interest")
            {
                Caption = 'Total Interest';
            }
            column(Description; Description)
            {
                Caption = 'Description';
            }

            // -----------------------------------------------------------
            // NESTED DATAITEM - Loan Application
            // -----------------------------------------------------------
            //
            // Shows the loan details (amount, term, interest rate)
            // for each ledger entry
            //
            // -----------------------------------------------------------

            dataitem(LoanApplication; "Loan Application")
            {
                DataItemLink = "Loan Application No." = LoanLedgerEntry."Loan Application No.";
                SqlJoinType = LeftOuterJoin;

                column(OriginalLoanAmount; "Loan Amount")
                {
                    Caption = 'Original Loan Amount';
                }
                column(InterestRateApp; "Interest Rate (%)")
                {
                    Caption = 'Interest Rate %';
                }
                column(LoanTermApp; "Loan Term (Months)")
                {
                    Caption = 'Term (Months)';
                }
                column(ApplicationStatus; Status)
                {
                    Caption = 'Loan Status';
                }
                column(MemberIDApp; "Member ID")
                {
                    Caption = 'Member ID';
                }

                // -----------------------------------------------------------
                // NESTED DATAITEM - Member
                // -----------------------------------------------------------
                //
                // Shows member details for easy identification
                //
                // -----------------------------------------------------------

                dataitem(Member; Member)
                {
                    DataItemLink = "Member ID" = LoanApplication."Member ID";
                    SqlJoinType = LeftOuterJoin;

                    column(MemberName; "Full Name")
                    {
                        Caption = 'Member Name';
                    }
                    column(MemberEmail_Ledger; Email)
                    {
                        Caption = 'Email';
                    }
                    column(MemberPhone_Ledger; "Phone Number")
                    {
                        Caption = 'Phone';
                    }
                }
            }
        }
    }
}
