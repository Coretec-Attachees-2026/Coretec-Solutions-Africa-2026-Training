report 50101 "Loan Summary by Member"
// uses nested loops
// gets one member, then gets all loans for that member
{
    Caption = 'Loan Summary by Member';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = RDLlayout;

    dataset
    {
        dataitem(Member; Member)
        {
            PrintOnlyIfDetail = true;
            column(FirstName; "First Name")
            {

            }
            column(SecondName; "Last Name")
            {

            }
            column(ID_Number; "ID Number")
            {

            }
            dataitem(JoinWithLoanTable; "Loan Application")
            {
                DataItemLink = "Member ID" = field("Member ID");
                column(Loan_Application_No_; "Loan Application No.")
                {

                }
                column(LoanAmount; "Loan Amount")
                {

                }
                column(InterestRate; "Interest Rate (%)")
                {

                }
                column(LoanTermInMonths; "Loan Term (Months)")
                {

                }
                column(LoanPurpose; "Loan Purpose")
                {

                }
            }
        }
    }

    requestpage
    {
        AboutTitle = 'Loan applicatoin by member';
        AboutText = 'Shows a summary of every member loans';
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                }
            }
        }

        actions
        {
            area(processing)
            {
                action(Preview)
                {
                    Caption = 'Preview layout file';
                    Image = Accounts;
                    trigger OnAction()
                    begin

                    end;
                }
            }
        }
    }

    rendering
    {
        layout(RDLlayout)
        {
            Type = RDLC;
            LayoutFile = 'LoanSummaryByMember.rdl';
            Caption = 'Loan summary by Member';
        }
        layout(ExcelLayout)
        {
            Type = Excel;
            LayoutFile = 'LoanSummaryByMember.xlsx';
            Caption = 'Loan Summary By Member';
        }
    }

    var
        myInt: Integer;
}