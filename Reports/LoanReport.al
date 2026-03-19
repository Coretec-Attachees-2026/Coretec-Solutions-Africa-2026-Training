report 50136 "Loan Summary by Member"
{
    Caption = 'Loan Summary by Member';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = RDLlayout;

    dataset
    {
        dataitem(Member; Member)
        {
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
        AboutTitle = 'Teaching tip title';
        AboutText = 'Teaching tip content';
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
        layout(ExcelLayout) {
            Type = Excel;
            LayoutFile = 'LoanSummaryByMember.xlsx';
            Caption = 'Loan Summary By Member';
        }
    }

    var
        myInt: Integer;
}