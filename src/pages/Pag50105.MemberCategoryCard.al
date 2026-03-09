// ============================================================
// Page 50105 - Member Category Card
// ============================================================
// PURPOSE: Shows/edits the FULL DETAILS of ONE member category.
//          This is the simplest Card page in the project.
//
// A category has just 3 fields:
//   - Code: unique short name like 'REGULAR', 'STUDENT'
//   - Description: human-readable explanation
//   - Active: on/off toggle for whether it can be used
//
// This page is opened by:
//   1. Double-clicking a row in the Category List page
//   2. Clicking "New" in the Category List page
// ============================================================

page 50105 "Member Category Card"
{
    Caption = 'Member Category';               // Title shown at the top
    PageType = Card;                           // Shows ONE category in detail
    SourceTable = "Member Category Master";    // Data from Category table
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            // Only one group needed — it's a simple record
            group(General)
            {
                field("Code"; rec."Code")
                {
                    ToolTip = 'Specifies the unique category code';
                }
                field("Description"; rec."Description")
                {
                    ToolTip = 'Specifies the category description';
                }
                field("Active"; rec."Active")
                {
                    ToolTip = 'Specifies if this category is active for selection';
                }
            }
        }
    }
}
