report 50115 "Loan Summary by Member"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultLayout = RDLC;
    RDLCLayout = 'src/Layouts/LoanSummaryByMember.rdl';

    dataset
    {
        dataitem(Member; "Member")
        {
            column(MemberID; "Member ID") { }
            column(FullName; "Full Name") { }

            dataitem(LoanApp; "Loan Application")
            {
                DataItemLink = "Member ID" = field("Member ID");
                column(LoanAppNo; "Loan Application No.") { }
                column(LoanAmount; "Loan Amount") { }
                column(Status; Status) { }
            }
        }
    }

    requestpage
    {
        layout
        {
            area(content)
            {
                group(Group)
                {
                    field(MemberID_Filter; Member."Member ID") { ApplicationArea = All; }
                    field(FullName_Filter; Member."Full Name") { ApplicationArea = All; }
                }
            }
        }
    }
}