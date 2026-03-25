// ============================================================
// Page 50118 - Occupation Card
// ============================================================
// PURPOSE: Shows/edits the details of ONE occupation record.
//          Opened by double-clicking a row in the Occupation List,
//          or by clicking "New" in the Occupation List.
// ============================================================

page 50118 "Occupation Card"
{
    Caption = 'Occupation';
    PageType = Card;
    SourceTable = "Occupation";
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'Occupation Details';

                field("Code"; rec."Code")
                {
                    ToolTip = 'Specifies the short occupation code, e.g. TEACHER or ENGINEER. Use uppercase letters only.';
                }
                field("Description"; rec."Description")
                {
                    ToolTip = 'Specifies the full occupation name shown to users.';
                }
                field("Active"; rec."Active")
                {
                    ToolTip = 'When active, this occupation appears in the member lookup. Uncheck to retire an occupation without deleting it.';
                }
            }
        }
    }
}
