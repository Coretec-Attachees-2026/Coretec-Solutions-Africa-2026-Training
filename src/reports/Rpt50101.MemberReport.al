report 50101 "Member Report"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    Caption = 'Member Report';
    DefaultLayout = RDLC;
    RDLCLayout = 'src/layouts/Rpt50101.MemberReport.rdl';

    dataset
    {
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
            column(Email; Email)
            {
                IncludeCaption = true;
            }
            column(Phone_Number; "Phone Number")
            {
                IncludeCaption = true;
            }
            column(City; City)
            {
                IncludeCaption = true;
            }
            column(Status; Status)
            {
                IncludeCaption = true;
            }
            column(Account_Balance; "Account Balance")
            {
                IncludeCaption = true;
            }
            column(CompanyName; CompanyProperty.DisplayName())
            {
            }
            column(ReportTitle; ReportTitle)
            {
            }
            column(ReportDate; WorkDate())
            {
            }
        }
    }

    var
        ReportTitle: Label 'Member Report';
}
