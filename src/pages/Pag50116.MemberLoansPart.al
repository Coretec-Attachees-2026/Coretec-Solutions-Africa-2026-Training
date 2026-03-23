page 50116 "Member Loans Part"
{
    PageType = ListPart;
    SourceTable = "Loan Application";
    ApplicationArea = All;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Loan Application No."; Rec."Loan Application No.") { ApplicationArea = All; }
                field("Loan Amount"; Rec."Loan Amount") { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
                field("Application Date"; Rec."Application Date") { ApplicationArea = All; }
            }
        }
    }
}