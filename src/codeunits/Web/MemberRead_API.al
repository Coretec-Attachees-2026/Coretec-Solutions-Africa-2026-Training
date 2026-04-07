page 50104 "MemberAPI"
{
    PageType = API;
    APIPublisher = 'lenson';
    APIGroup = 'sacco';
    APIVersion = 'v2.0';
    EntityName = 'saccoMember';
    EntitySetName = 'saccoMembers';
    SourceTable = Member;
    DelayedInsert = true;
    Caption = 'Member API';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(no; Rec."Member ID") { }
                field(name; Rec."First Name") { }
                field(phone; Rec."Phone Number") { }
                field(Email; Rec.Email) { }
                field("Member_Category"; Rec."Member Category") { }
                field(Occupation; Rec.Occupation) { }
            }
        }
    }
}