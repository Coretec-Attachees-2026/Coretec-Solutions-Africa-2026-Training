// ============================================================
// Page 50113 - Occupation Card
// ============================================================
// PURPOSE: Shows/edits the FULL DETAILS of ONE occupation.
//          This is a simple Card page for managing occupation data.
//
// An occupation has 3 fields:
//   - Code: unique short name like 'TEACHER', 'NURSE', 'FARMER'
//   - Description: human-readable explanation
//   - Active: on/off toggle for whether it can be used in dropdowns
//
// This page is opened by:
//   1. Double-clicking a row in the Occupation List page
//   2. Clicking "New" in the Occupation List page
// ============================================================

page 50113 "Occupation Card"
{
    Caption = 'Occupation';                    // Title shown at the top
    PageType = Card;                           // Shows ONE occupation in detail
    SourceTable = "Occupation";                // Data from Occupation table
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            // Single group for occupation details
            group(General)
            {
                field("Code"; rec."Code")
                {
                    ToolTip = 'Specifies the unique occupation code (e.g., TEACHER, NURSE, FARMER)';
                }
                field("Description"; rec."Description")
                {
                    ToolTip = 'Specifies the full description of the occupation';
                }
                field("Active"; rec."Active")
                {
                    ToolTip = 'Specifies if this occupation is active and available for member selection';
                }
            }
        }
    }
}
