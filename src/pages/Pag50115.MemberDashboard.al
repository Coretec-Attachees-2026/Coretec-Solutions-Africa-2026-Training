// ============================================================
// Page 50115 - Member Dashboard
// ============================================================
// PURPOSE: Displays SACCO summary metrics on a single card page.
//
// DESIGN:
// - No SourceTable is used.
// - Values are calculated into page variables in OnOpenPage.
//
// METRICS:
//   1. Total Members
//   2. Active Members
//   3. Total Account Balance
//   4. Pending Member Applications
// ============================================================

page 50115 "Member Dashboard"
{
    Caption = 'Member Dashboard';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;

    layout
    {
        area(Content)
        {
            group("SACCO Summary")
            {
                Caption = 'SACCO Summary';

                field(TotalMembersField; TotalMembers)
                {
                    Caption = 'Total Members';
                    ToolTip = 'Shows the total number of registered members.';
                    Editable = false;
                }
                field(ActiveMembersField; ActiveMembers)
                {
                    Caption = 'Active Members';
                    ToolTip = 'Shows the number of members with Active status.';
                    Editable = false;
                }
                field(TotalAccountBalanceField; TotalAccountBalance)
                {
                    Caption = 'Total Account Balance';
                    ToolTip = 'Shows the summed account balance across all members.';
                    Editable = false;
                }
                field(PendingApplicationsField; PendingApplications)
                {
                    Caption = 'Pending Applications';
                    ToolTip = 'Shows the number of member applications waiting for approval.';
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(RefreshDashboard)
            {
                Caption = 'Refresh';
                ApplicationArea = All;
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Recalculate and refresh dashboard metrics.';

                trigger OnAction()
                begin
                    CalculateDashboard();
                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        CalculateDashboard();
    end;

    local procedure CalculateDashboard()
    var
        Member: Record "Member";
        MemberApplication: Record "Member Application";
    begin
        TotalMembers := Member.Count();

        Member.Reset();
        Member.SetRange(Status, Enum::"Member Status"::Active);
        ActiveMembers := Member.Count();

        Member.Reset();
        Member.CalcSums("Account Balance");
        TotalAccountBalance := Member."Account Balance";

        MemberApplication.Reset();
        MemberApplication.SetRange(Status, Enum::"Member Application Status"::Pending);
        PendingApplications := MemberApplication.Count();
    end;

    var
        TotalMembers: Integer;
        ActiveMembers: Integer;
        PendingApplications: Integer;
        TotalAccountBalance: Decimal;
}
