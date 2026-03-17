report 50133 "Member Report"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = MemberReportLayout;
    Caption = 'Member Report';

    dataset
    {
        dataitem(Member; Member)
        {
            RequestFilterFields = "Member ID", Status, "Member Category", City;

            column(MemberId; "Member ID")
            {
            }
            column(FirstName; "First Name")
            {
            }
            column(LastName; "Last Name")
            {
            }
            column(FullName; "Full Name")
            {
            }
            column(MemberCategory; "Member Category")
            {
            }
            column(MemberStatus; Status)
            {
            }
            column(RegistrationDate; "Registration Date")
            {
            }
            column(Email; Email)
            {
            }
            column(PhoneNumber; "Phone Number")
            {
            }
            column(Address; Address)
            {
            }
            column(City; City)
            {
            }
            column(PostalCode; "Postal Code")
            {
            }
            column(Country; Country)
            {
            }
            column(Occupation; Occupation)
            {
            }
            column(AnnualIncome; "Annual Income")
            {
            }
            column(IDNumber; "ID Number")
            {
            }
        }
    }

    requestpage
    {
        AboutTitle = 'Member Report';
        AboutText = 'This report displays active members with their details. You can filter by Member ID, Status, Category, or City.';
        layout
        {
            area(Content)
            {
                group("Report Options")
                {
                    Caption = 'Report Options';
                    field(IncludeInactiveMembers; IncludeInactive)
                    {
                        ApplicationArea = All;
                        Caption = 'Include Inactive Members';
                        ToolTip = 'Check to include inactive and suspended members';
                    }
                }
            }
        }

        actions
        {
            area(processing)
            {
                action(LayoutName)
                {
                    ApplicationArea = All;
                    Caption = 'Preview';
                }
            }
        }
    }

    rendering
    {
        layout(MemberReportLayout)
        {
            Type = RDLC;
            LayoutFile = 'MemberReport.rdl';
        }
    }

    var
        IncludeInactive: Boolean;
}