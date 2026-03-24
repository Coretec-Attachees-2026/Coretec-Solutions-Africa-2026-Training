// ============================================================
// Page 50117 - Occupation List
// ============================================================
// PURPOSE: Grid view of all occupations for management.
//
// FEATURES:
//   - View all occupations in a list
//   - Toggle Active status on/off
//   - Click an occupation to open detailed Card view
//   - View action to see all members of that occupation
// ============================================================

page 50117 "Occupation List"
{
    Caption = 'Occupation List';
    PageType = List;
    SourceTable = "Occupation";
    UsageCategory = Lists;
    ApplicationArea = All;
    Editable = true;
    ModifyAllowed = true;
    InsertAllowed = true;
    DeleteAllowed = true;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Code"; rec."Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Unique code for the occupation (e.g., TEA for Teacher)';
                }
                field("Description"; rec."Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Full name of the occupation';
                }
                field("Active"; rec."Active")
                {
                    ApplicationArea = All;
                    ToolTip = 'Check to show this occupation in member dropdowns';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ViewMembers)
            {
                Caption = 'View Members';
                ToolTip = 'See all members with this occupation';
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                Image = Users;

                trigger OnAction()
                begin
                    // Open Member List filtered by this occupation
                    // The filter will be applied via the page's filter functionality
                    Page.Run(Page::"Member List", rec);
                end;
            }
        }
    }
}
