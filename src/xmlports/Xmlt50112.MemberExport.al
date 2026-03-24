// ============================================================
// XMLport 50112 - Member Export
// ============================================================
// PURPOSE: Export Member data (Table 50101) to files.
// ============================================================

xmlport 50112 "Member Export"
{
    Caption = 'Member Export';
    Direction = Export;
    Format = VariableText;
    FieldSeparator = ',';
    FieldDelimiter = '"';
    UseRequestPage = true;

    schema
    {
        textelement(Members)
        {
            tableelement(Member; "Member")
            {
                XmlName = 'Member';
                RequestFilterFields = "Member ID", "Status", "Member Category";

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
                fieldelement(OccupationCode; Member."Occupation Code") { }
                fieldelement(AnnualIncome; Member."Annual Income") { }
                fieldelement(MemberCategory; Member."Member Category") { }

                // FINANCIALS
                fieldelement(AccountBalance; Member."Account Balance") { }

                // ===============================================================
                // TRIGGERS - Run at specific moments during import/export
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

                trigger OnAfterGetRecord()
                begin
                    // Runs for each Member record during EXPORT
                    // Filter or transform data before writing

                    // EXAMPLE: Skip inactive members on export
                    // if Member.Status = Member.Status::Inactive then
                    //     CurrXMLport.Skip();
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
                    Caption = 'Import/Export CSV Options';
                }
            }
        }
    }
}
