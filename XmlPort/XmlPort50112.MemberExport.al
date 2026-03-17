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
        textelement(Sheet)
        {
            tableelement(Member; Member)
            {
                // RequestPage filters - which members to export
                RequestFilterFields = "Member ID", "Status", "Member Category";

                // ---------- FIELD ELEMENTS ----------

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

                trigger OnAfterGetRecord()
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
                    Caption = 'Export Options';
                    // Add custom options, e.g.:
                    // field(ExcludeInactive; ExcludeInactive)
                    // {
                    //     Caption = 'Exclude inactive members';
                    //     ApplicationArea = All;
                    // }
                }
            }
        }
        actions
        {
            // Default: File picker and filters are automatic
        }
    }

    // -----------------------------------------------------------------------
    // VARIABLES - For use in triggers
    // -----------------------------------------------------------------------

    var
    // ExportCount: Integer;  // Uncomment for processing-only counting
}
