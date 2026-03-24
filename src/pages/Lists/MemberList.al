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
            action(ViewDetails)
            {
                Caption = 'View Details';
                RunObject = page "Member Card";
                RunPageLink = "Member ID" = field("Member ID");
                Image = Open;
            }

        }
        area(Promoted) {
            actionref("View details"; ViewDetails) {

            }
        }
    }
}
