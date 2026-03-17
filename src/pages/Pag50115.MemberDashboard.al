// ============================================================
// Page 50115 - Member Dashboard
// ============================================================
// PURPOSE: Displays SACCO summary statistics.
//
// FEATURES:
//   - Shows: Total Members, Active Members, Account Balance, Pending Apps
//   - No SourceTable - uses variables and calculations
//   - OnOpenPage calculates aggregated values from tables
//   - Refresh button to recalculate statistics
//
// ============================================================

page 50115 "Member Dashboard"
{
    Caption = 'Member Dashboard';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Documents;
    Editable = false;

    layout
    {
        area(Content)
        {
            group("Membership Summary")
            {
                Caption = 'Membership Summary';

                field(TotalMembers; TotalMembers)
                {
                    Caption = 'Total Members';
                    ToolTip = 'Total number of registered members';
                }

                field(ActiveMembers; ActiveMembers)
                {
                    Caption = 'Active Members';
                    ToolTip = 'Number of members with Active status';
                }

                field(InactiveMembers; InactiveMembers)
                {
                    Caption = 'Inactive Members';
                    ToolTip = 'Number of members with Inactive status';
                }
            }

            group("Applications Status")
            {
                Caption = 'Applications Status';

                field(PendingApplications; PendingApplications)
                {
                    Caption = 'Pending Applications';
                    ToolTip = 'Applications awaiting approval';
                }

                field(ApprovedApplications; ApprovedApplications)
                {
                    Caption = 'Approved Applications';
                    ToolTip = 'Approved applications';
                }

                field(RejectedApplications; RejectedApplications)
                {
                    Caption = 'Rejected Applications';
                    ToolTip = 'Rejected applications';
                }
            }

            group("Financial Summary")
            {
                Caption = 'Financial Summary';

                field(TotalAccountBalance; TotalAccountBalance)
                {
                    Caption = 'Total Member Balance';
                    ToolTip = 'Sum of all member account balances';
                    DecimalPlaces = 2;
                }

                field(AverageBalance; AverageBalance)
                {
                    Caption = 'Average Balance per Member';
                    ToolTip = 'Total balance divided by number of members';
                    DecimalPlaces = 2;
                }
            }

            group("Last Update")
            {
                Caption = 'Information';

                field(LastUpdated; LastUpdated)
                {
                    Caption = 'Last Refreshed';
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Refresh)
            {
                Caption = 'Refresh Dashboard';
                ToolTip = 'Recalculate all statistics';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction()
                begin
                    CalculateStatistics();
                    LastUpdated := CurrentDateTime;
                    Message('Dashboard refreshed at %1', Format(LastUpdated, 0, '<Hours24>:<Minutes>'));
                end;
            }

            action("View Members")
            {
                Caption = 'View All Members';
                ToolTip = 'Open the Members list';
                Image = List;
                Promoted = true;
                PromotedCategory = Category4;
                trigger OnAction()
                begin
                    Page.Run(Page::"Member List");
                end;
            }

            action("View Applications")
            {
                Caption = 'View Applications';
                ToolTip = 'Open Member Applications';
                Image = Document;
                Promoted = true;
                PromotedCategory = Category4;
                trigger OnAction()
                begin
                    Page.Run(Page::"Member Application List");
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        CalculateStatistics();
        LastUpdated := CurrentDateTime;
    end;

    // ===================================================================
    // CALCULATE ALL STATISTICS
    // ===================================================================

    local procedure CalculateStatistics()
    var
        Member: Record "Member";
        MemberApp: Record "Member Application";
    begin
        // Total Members
        TotalMembers := Member.Count;

        // Active Members
        Member.SetRange("Status", Enum::"Member Status"::Active);
        ActiveMembers := Member.Count;
        Member.SetRange("Status");

        // Inactive Members
        Member.SetRange("Status", Enum::"Member Status"::Inactive);
        InactiveMembers := Member.Count;
        Member.SetRange("Status");

        // Pending Applications
        MemberApp.SetRange("Status", Enum::"Member Application Status"::Pending);
        PendingApplications := MemberApp.Count;
        MemberApp.SetRange("Status");

        // Approved Applications
        MemberApp.SetRange("Status", Enum::"Member Application Status"::Approved);
        ApprovedApplications := MemberApp.Count;
        MemberApp.SetRange("Status");

        // Rejected Applications
        MemberApp.SetRange("Status", Enum::"Member Application Status"::Rejected);
        RejectedApplications := MemberApp.Count;
        MemberApp.SetRange("Status");

        // Total Account Balance
        Member.CalcSums("Account Balance");
        TotalAccountBalance := Member."Account Balance";

        // Average Balance
        if ActiveMembers > 0 then
            AverageBalance := TotalAccountBalance / ActiveMembers
        else
            AverageBalance := 0;
    end;

    var
        TotalMembers: Integer;
        ActiveMembers: Integer;
        InactiveMembers: Integer;
        PendingApplications: Integer;
        ApprovedApplications: Integer;
        RejectedApplications: Integer;
        TotalAccountBalance: Decimal;
        AverageBalance: Decimal;
        LastUpdated: DateTime;
}
