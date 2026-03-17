// ============================================================
// Page 50104 - Member Category List
// ============================================================
// PURPOSE: Shows ALL member categories in a scrollable list.
//          Categories are like "types" of members:
//          Regular, Student, Business, Senior, Group, etc.
//
// KEY CONCEPT - "CardPageId":
//   When the user double-clicks a category row, BC automatically
//   opens the "Member Category Card" page for that record.
//   This links the List and Card pages together.
//
// HOW CATEGORIES ARE USED:
//   1. Default categories are created on install (by Cod50101)
//   2. Admin can add more categories from this list page
//   3. When creating a Member Application, the user picks
//      a category from a dropdown (TableRelation)
// ============================================================

page 50104 "Member Category List"
{
    Caption = 'Member Categories';             // Title shown at the top
    PageType = List;                           // Grid/table format
    SourceTable = "Member Category Master";    // Data from Category table
    ApplicationArea = All;
    UsageCategory = Lists;                     // Appears in BC search under "Lists"
    CardPageId = "Member Category Card";       // Double-click → opens Category Card

    layout
    {
        area(Content)
        {
            // Repeater = one row per category
            repeater(General)
            {
                field("Code"; rec."Code")
                {
                    ToolTip = 'Specifies the category code';
                }
                field("Description"; rec."Description")
                {
                    ToolTip = 'Specifies the category description';
                }
                field("Active"; rec."Active")
                {
                    ToolTip = 'Specifies if the category is active';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            // --- New Category Button ---
            // Opens the Category Card page to create a new category
            // KEY CONCEPT - "Page.Run()":
            //   Opens the specified page. Here it opens a blank
            //   Category Card so the user can fill in a new category.
            action("New")
            {
                Caption = 'New';
                Image = New;
                Promoted = true;
                PromotedCategory = New;

                trigger OnAction()
                begin
                    Page.Run(Page::"Member Category Card");
                    CurrPage.Update(false);  // Refresh list after returning
                end;
            }
        }
    }
}
