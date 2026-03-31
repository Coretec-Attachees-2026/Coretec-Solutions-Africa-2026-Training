page 50121 "Members API"
{
    PageType = API;
    Caption = 'Members API';
    APIPublisher = 'coretec';
    APIGroup = 'membership';
    APIVersion = 'v1.0';
    EntityName = 'member';
    EntitySetName = 'members';
    SourceTable = "Member";
    DelayedInsert = false;
    ODataKeyFields = SystemId;
    Extensible = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(memberId; Rec."Member ID")
                {
                    Caption = 'Member ID';
                }
                field(applicationId; Rec."Application ID")
                {
                    Caption = 'Application ID';
                }
                field(fullName; Rec."Full Name")
                {
                    Caption = 'Full Name';
                }
                field(status; Rec."Status")
                {
                    Caption = 'Status';
                }
                field(registrationDate; Rec."Registration Date")
                {
                    Caption = 'Registration Date';
                }
                field(memberCategory; Rec."Member Category")
                {
                    Caption = 'Member Category';
                }
                field(city; Rec.City)
                {
                    Caption = 'City';
                }
                field(country; Rec.Country)
                {
                    Caption = 'Country';
                }
                field(occupationCode; Rec."Occupation Code")
                {
                    Caption = 'Occupation Code';
                }
            }
        }
    }
}
