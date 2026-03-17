xmlport 50111 "Member Import"
{
    Caption = 'Member Import';
    Direction = Import;
    Format = VariableText;
    FieldSeparator = ',';
    FieldDelimiter = '"';
    UseRequestPage = true;

    schema
    {
        textelement(Sheet)
        {
            tableelement(Member; Member)
            {
                fieldelement(MemberID; Member."Member ID")
                {
                }
                fieldelement(ApplicationID; Member."Application ID")
                {
                }
                fieldelement(FirstName; Member."First Name")
                {
                }
                fieldelement(LastName; Member."Last Name")
                {
                }
                fieldelement(FullName; Member."Full Name")
                {
                }
                fieldelement(Email; Member.Email)
                {
                }
                fieldelement(PhoneNumber; Member."Phone Number")
                {
                }
                fieldelement(DateOfBirth; Member."Date of Birth")
                {
                }
                fieldelement(Address; Member.Address)
                {
                }
                fieldelement(City; Member.City)
                {
                }
                fieldelement(PostalCode; Member."Postal Code")
                {
                }
                fieldelement(Country; Member.Country)
                {
                }
                fieldelement(IDNumber; Member."ID Number")
                {
                }
                fieldelement(RegistrationDate; Member."Registration Date")
                {
                }
                fieldelement(Status; Member.Status)
                {
                }
                fieldelement(Occupation; Member.Occupation)
                {
                }
                fieldelement(AnnualIncome; Member."Annual Income")
                {
                }
                fieldelement(MemberCategory; Member."Member Category")
                {
                }
                fieldelement(AccountBalance; Member."Account Balance")
                {
                }
                trigger OnBeforeInsertRecord()
                begin

                end;
            }
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Import Options';

                }
            }
        }
        actions
        {
        }
    }
}
