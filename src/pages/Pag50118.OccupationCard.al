// ============================================================
// Page 50118 - Occupation Card
// ============================================================
// PURPOSE: Detailed view of a single occupation.
//
// FEATURES:
//   - Edit occupation code and description
//   - Toggle active status
//   - View all members with this occupation
// ============================================================

page 50118 "Occupation Card"
{
    Caption = 'Occupation Card';
    PageType = Card;
    SourceTable = "Occupation";
    UsageCategory = Documents;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Code"; rec."Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Enter a unique code for this occupation (e.g., TEA, NUR, FAR)';
                }
                field("Description"; rec."Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Enter the full name or description of the occupation';
                }
                field("Active"; rec."Active")
                {
                    ApplicationArea = All;
                    ToolTip = 'Check to show this occupation in member dropdowns. Uncheck to hide old occupations.';
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
                Caption = 'View Members with This Occupation';
                ToolTip = 'See all members who have selected this occupation';
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                Image = Users;

                trigger OnAction()
                var
                    MemberList: Page "Member List";
                begin
                    // Create and run the Member List page
                    MemberList.SetRecord(rec);
                    MemberList.RunModal();
                end;
            }
        }
    }
}
