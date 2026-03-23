query 50130 "Member Loan Query"
// uses sql join types, queries translate directly to SQL
// Queries with one statements for all records
{
    QueryType = Normal;
    Caption = 'Member Loan Query';
    AboutTitle = 'Analyze active member Loans';
    AboutText = 'Member names and their amounts and repayment periods';
    UsageCategory = ReportsAndAnalysis;
    
    elements
    {
        dataitem(Members; Member)
        {
            column(First_Name; "First Name")
            {
                
            }
            column(Last_Name;"Last Name") {

            }
            dataitem(Loans; "Loan Ledger Entry") {
                DataItemLink = "Member ID" = Members."Member ID";
                SqlJoinType = RightOuterJoin;
                column(LoanAmount; "Loan Amount") {

                }
                column(LoanPeriod; "Loan Term (Months)") {

                }
            }
            
        }
    }
    
    trigger OnBeforeOpen()
    begin
        
    end;
}