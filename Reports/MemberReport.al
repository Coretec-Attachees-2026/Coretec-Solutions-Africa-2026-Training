report 50110 "Member Report"
{
    ApplicationArea = All;
    Caption = 'Member Report';
    UsageCategory = ReportsAndAnalysis;
    RDLCLayout='Item Report.RDL';
    DefaultLayout=RDLC;
    dataset
    {
        dataitem(Member; Member)
        {
            column(AccountBalance; "Account Balance")
            {
            }
            column(Address; Address)
            {
            }
            column(AnnualIncome; "Annual Income")
            {
            }
            column(ApplicationID; "Application ID")
            {
            }
            column(City; City)
            {
            }
            column(Country; Country)
            {
            }
            column(DateofBirth; "Date of Birth")
            {
            }
            column(Email; Email)
            {
            }
            column(FirstName; "First Name")
            {
            }
            column(FullName; "Full Name")
            {
            }
            column(IDNumber; "ID Number")
            {
            }
            column(LastName; "Last Name")
            {
            }
            column(MemberCategory; "Member Category")
            {
            }
            column(MemberID; "Member ID")
            {
            }
            column(Occupation; Occupation)
            {
            }
            column(PhoneNumber; "Phone Number")
            {
            }
            column(PostalCode; "Postal Code")
            {
            }
            column(RegistrationDate; "Registration Date")
            {
            }
            column(Status; Status)
            {
            }
            column(SystemCreatedAt; SystemCreatedAt)
            {
            }
            column(SystemCreatedBy; SystemCreatedBy)
            {
            }
            column(SystemId; SystemId)
            {
            }
            column(SystemModifiedAt; SystemModifiedAt)
            {
            }
            column(SystemModifiedBy; SystemModifiedBy)
            {
            }
        }
    }
    requestpage
    {
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
            area(Processing)
            {
            }
        }
    }
}

