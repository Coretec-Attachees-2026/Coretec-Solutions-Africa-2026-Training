// ============================================================
// Page 50112 - Occupation List
// ============================================================
// PURPOSE: Shows ALL occupations in a scrollable list.
//          Occupations are job types: Teacher, Nurse, Farmer, etc.
//
// HOW OCCUPATIONS ARE USED:
//   1. Default occupations are created on install
//   2. Admin can add more occupations from this list page
//   3. When creating a Member Application or editing a Member,
//      the user picks an occupation from a dropdown
//      (via TableRelation to Occupation table)
//
// KEY CONCEPT - "CardPageId":
//   When the user double-clicks an occupation row, BC opens
//   the "Occupation Card" page for that record.
// ============================================================

page 50112 "Occupation List"
{
    Caption = 'Occupations';                   // Title shown at the top
    PageType = List;                           // Grid/table format
    SourceTable = "Occupation";                // Data from Occupation table
    ApplicationArea = All;
    UsageCategory = Lists;                     // Appears in BC search under "Lists"
    CardPageId = "Occupation Card";            // Double-click → opens Occupation Card

    layout
    {
        area(Content)
        {
            // Repeater = one row per occupation
            repeater(General)
            {
                field("Code"; rec."Code")
                {
                    ToolTip = 'Specifies the occupation code';
                }
                field("Description"; rec."Description")
                {
                    ToolTip = 'Specifies the occupation description';
                }
                field("Active"; rec."Active")
                {
                    ToolTip = 'Specifies if the occupation is active and available for selection';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            // --- New Occupation Button ---
            // Opens the Occupation Card page to create a new occupation
            action("New")
            {
                Caption = 'New';
                Image = New;
                Promoted = true;
                PromotedCategory = New;

                trigger OnAction()
                begin
                    Page.Run(Page::"Occupation Card");
                    CurrPage.Update(false);  // Refresh list after returning
                end;
            }
        }
    }
}
