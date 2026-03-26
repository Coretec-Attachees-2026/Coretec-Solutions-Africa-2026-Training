page 50141 "Occupation Card"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = Occupation;
    
    layout
    {
        area(Content)
        {
            group("Occupation Details")
            {
                field("Occupation Code";Rec."Occupation Code") {
                    Editable = false;
                }
                field(OccupationName;Rec.Name) {      
                    ApplicationArea = all;            
                }
                field(OccupationDescription;Rec.Description)
                {
                    ApplicationArea = all;
                }
            }
        }
    }
}