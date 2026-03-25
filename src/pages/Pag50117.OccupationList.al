// ============================================================
// Page 50117 - Occupation List
// ============================================================
// PURPOSE: Shows all valid occupations in a scrollable list.
//          Admins use this to manage the occupation lookup values
//          that appear on the Member Card.
//
// ACCESSED FROM:
//   - BC search ("Occupation")
//   - Lookup dropdown on Member Card → "Occupation Code" field
// ============================================================

page 50117 "Occupation List"
{
    Caption = 'Occupations';
    PageType = List;
    SourceTable = "Occupation";
    ApplicationArea = All;
    UsageCategory = Lists;
    CardPageId = "Occupation Card";    // Double-click row → opens Occupation Card

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Code"; rec."Code")
                {
                    ToolTip = 'Specifies the short occupation code (e.g. TEACHER, ENGINEER).';
                }
                field("Description"; rec."Description")
                {
                    ToolTip = 'Specifies the full occupation name.';
                }
                field("Active"; rec."Active")
                {
                    ToolTip = 'Specifies whether this occupation appears in member dropdowns.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(NewOccupation)
            {
                Caption = 'New';
                Image = New;
                Promoted = true;
                PromotedCategory = New;

                trigger OnAction()
                begin
                    Page.Run(Page::"Occupation Card");
                    CurrPage.Update(false);
                end;
            }
        }
    }
}
