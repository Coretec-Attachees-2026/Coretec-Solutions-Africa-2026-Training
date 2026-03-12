xmlport 50113 "Member Import"
{
    Caption = 'Member Import';
    Direction = Import;
    Format = VariableText;
    FieldSeparator = ',';        // ← Match the CSV comma separator
    FieldDelimiter = '"';        // ← Handle quoted fields
    UseRequestPage = false;      // ← Disabled since codeunit handles file picking

    schema
    {
        textelement(Members)
        {
            tableelement(Member; "Member")
            {
                XmlName = 'Member';
                AutoSave = false;       // ← We control when/how records are saved

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

                trigger OnBeforeInsertRecord()
                var
                    ExistingMember: Record Member;
                begin
                    // Skip rows with blank Member ID
                    if Member."Member ID" = '' then
                        CurrXMLport.Skip();

                    // Auto-populate Full Name if not provided
                    if Member."Full Name" = '' then
                        Member."Full Name" := Member."First Name" + ' ' + Member."Last Name";

                    // Set Registration Date if missing
                    if Member."Registration Date" = 0DT then
                        Member."Registration Date" := CurrentDateTime();

                    // Set default Status if missing
                    if Member.Status = Member.Status::Active then
                        Member.Status := Member.Status::Active;

                    // If member already exists → update instead of insert
                    if ExistingMember.Get(Member."Member ID") then begin
                        ExistingMember.TransferFields(Member, false); // false = don't overwrite PK
                        ExistingMember.Modify();
                        CurrXMLport.Skip(); // Skip insert since we already modified
                    end else
                        Member.Insert();    // New member → insert
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