// ============================================================
// Page 50102 - Member List
// ============================================================
// PURPOSE: Shows ALL registered members in a scrollable list.
//          Members appear here AFTER their application is approved.
//          (They start as applications → get approved → become members)
//
// KEY CONCEPT - "CardPageId":
//   This tells BC: "When a user double-clicks a row in this list,
//   open the 'Member Card' page to show full details."
//   It creates the automatic link between List and Card pages.
//   Without this, double-clicking a row would do nothing.
//
// KEY CONCEPT - "Editable = false":
//   Members can't be edited from this list. Member data comes from
//   the approved application and is managed elsewhere.
//
// COLUMNS SHOWN:
//   Member ID, First/Last/Full Name, Email, Phone,
//   Status (Active/Inactive/etc.), Registration Date, Account Balance
// ============================================================

page 50102 "Member List"
{
    Caption = 'Members';                   // Title shown at the top
    PageType = List;                       // Grid/table format showing many records
    SourceTable = "Member";                // Data comes from the Member table
    ApplicationArea = All;
    UsageCategory = Lists;                 // Appears in BC search under "Lists"
    Editable = false;                      // Read-only — can't edit here
    CardPageId = "Member Card";            // Double-click a row → opens Member Card

    layout
    {
        area(Content)
        {
            // Repeater = one row per member record
            repeater(General)
            {
                field("Member ID"; rec."Member ID")
                {
                    ToolTip = 'Specifies the unique member identifier';
                }
                field("First Name"; rec."First Name")
                {
                    ToolTip = 'Specifies the member''s first name';
                }
                field("Last Name"; rec."Last Name")
                {
                    ToolTip = 'Specifies the member''s last name';
                }
                field("Full Name"; rec."Full Name")
                {
                    ToolTip = 'Specifies the member''s full name';
                }
                field("Email"; rec."Email")
                {
                    ToolTip = 'Specifies the member''s email';
                }
                field("Phone Number"; rec."Phone Number")
                {
                    ToolTip = 'Specifies the member''s phone number';
                }
                field("Status"; rec."Status")
                {
                    ToolTip = 'Specifies the member''s status';
                }
                field("Registration Date"; rec."Registration Date")
                {
                    ToolTip = 'Specifies when the member was registered';
                }
                field("Account Balance"; rec."Account Balance")
                {
                    ToolTip = 'Specifies the member''s current account balance';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            // Opens the Member Card page for the selected member
            // RunPageLink filters to show only the matching Member ID
            action("View Details")
            {
                Caption = 'View Details';
                RunObject = page "Member Card";
                RunPageLink = "Member ID" = field("Member ID");
                Image = Open;
                Promoted = true;
                PromotedCategory = Process;
            }
            action(ExportMembers)
            {
                Caption = 'Export Members';
                Image = Export;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Export members to a CSV file';
                trigger OnAction()
                var
                    ImportExportManager: Codeunit "Member Import/Export Mgt";
                begin
                    ImportExportManager.ExportMembers();
                end;
            }
        }
    }
}
