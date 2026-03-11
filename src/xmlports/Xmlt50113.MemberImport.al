// ============================================================
// XMLport 50113 - Member Import
// ============================================================
// PURPOSE: Import Member data (Table 50101) from files.
// ============================================================

xmlport 50113 "Member Import"
{
    Caption = 'Member Import';
    Direction = Import;
    Format = VariableText;
    UseRequestPage = true;

    schema
    {
        textelement(Members)
        {
            tableelement(Member; "Member")
            {
                XmlName = 'Member';

                // IDENTIFICATION
                fieldelement(MemberID; Member."Member ID") { }
                fieldelement(ApplicationID; Member."Application ID") { }

                // PERSONAL INFORMATION
                fieldelement(FirstName; Member."First Name") { }
                fieldelement(LastName; Member."Last Name") { }
                fieldelement(FullName; Member."Full Name") { }
                fieldelement(Email; Member.Email) { }
                fieldelement(PhoneNumber; Member."Phone Number") { }
                fieldelement(DateOfBirth; Member."Date of Birth") { }

                // ADDRESS
                fieldelement(Address; Member.Address) { }
                fieldelement(City; Member.City) { }
                fieldelement(PostalCode; Member."Postal Code") { }
                fieldelement(Country; Member.Country) { }
                fieldelement(IDNumber; Member."ID Number") { }

                // STATUS & REGISTRATION
                fieldelement(RegistrationDate; Member."Registration Date") { }
                fieldelement(Status; Member.Status) { }

                // EMPLOYMENT
                fieldelement(Occupation; Member.Occupation) { }
                fieldelement(AnnualIncome; Member."Annual Income") { }
                fieldelement(MemberCategory; Member."Member Category") { }

                // FINANCIALS
                fieldelement(AccountBalance; Member."Account Balance") { }

                // ===============================================================
                // TRIGGERS - Run at specific moments during import
                // ===============================================================

                trigger OnBeforeInsertRecord()
                begin
                    // Runs for each record during IMPORT
                    // Validate or modify data before it enters BC

                    // EXAMPLE: Skip blank Member IDs
                    // if Member."Member ID" = '' then
                    //     CurrXMLport.Skip();

                    // EXAMPLE: Auto-populate Full Name if not provided
                    // if Member."Full Name" = '' then
                    //     Member."Full Name" := Member."First Name" + ' ' + Member."Last Name";
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
    }
}
