xmlport 50124 "Import Members XMLport"
// Member Category validation - existing(BUSINESS, DORMANT, GROUP, INSTITUTIONAL, REGULAR ,SENIOR, STUDENT)
// Generate Member Application's "Application ID"
// Link the above ID to PK "Member ID" on the member table
// 
{
    Caption = 'Import Members XMLport';
    Format = VariableText;
    Direction = Import;
    FieldSeparator = ',';
    TextEncoding = UTF8;
    schema
    {
        textelement(RootNodeName)
        {   

            tableelement(Member; "Member Application")
            {
                AutoSave = true;
                fieldelement(Address; Member.Address)
                {

                }
                fieldelement(AnnualIncome; Member."Annual Income")
                {
                }
                fieldelement(City; Member.City)
                {
                }
                fieldelement(Country; Member.Country)
                {
                }
                fieldelement(DateofBirth; Member."Date of Birth")
                {
                }
                fieldelement(Email; Member.Email)
                {
                }
                fieldelement(FirstName; Member."First Name")
                {
                }
                fieldelement(IDNumber; Member."ID Number")
                {
                }
                fieldelement(LastName; Member."Last Name")
                {
                }
                fieldelement(MemberCategory; Member."Member Category")
                {
                }
                fieldelement(Occupation; Member.Occupation)
                {
                }
                fieldelement(PhoneNumber; Member."Phone Number")
                {
                }
                fieldelement(PostalCode; Member."Postal Code")
                {
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
