page 50142 "Occupation List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = Occupation;
    Editable = false;
    
    layout
    {
        area(Content)
        {
            repeater(Occupations)
            {
                field("Occupation Code";Rec."Occupation Code")
                {
                    
                }
                field(Name;Rec.Name) {

                }
                field(Description;Rec.Description) {

                }
            }
        }
    }
    actions {
        area(Processing) {
            action(InsertNewOccupation) {
                Caption = 'New Occupation';
                Image = Add;
                RunObject = page "Occupation Card";
                RunPageMode = create;
            }
        }
        area(Promoted) {
            actionref(InsertNewOcc; InsertNewOccupation) {

            }
        }
    }
    
}