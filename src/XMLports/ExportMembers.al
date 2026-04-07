xmlport 50100 "Export Member XMLport"
{
    Caption = 'Member XML port';
    Format = Xml;
    Direction = Export;
    // FieldSeparator = ',';
    // TextEncoding = UTF8;
    schema
    {
        textelement(RootNodeName)
        {
            tableelement(Member; Member)
            {
                fieldelement(FirstName; Member."First Name")
                {
                }
                fieldelement(LastName; Member."Last Name")
                {
                }
                fieldelement(MemberCategory; Member."Member Category")
                {
                }
                fieldelement(IDNumber; Member."ID Number")
                {
                }
                fieldelement(PhoneNumber; Member."Phone Number")
                {
                }
                fieldelement(Email; Member.Email)
                {
                }
                fieldelement(Status; Member.Status)
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
