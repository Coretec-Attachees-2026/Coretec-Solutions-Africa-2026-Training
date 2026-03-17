// ============================================================
// Page 50115 - Member Dashboard
// ============================================================
// PURPOSE: A dashboard card showing SACCO summary statistics
//          and key performance indicators at a glance.
//
// KEY CONCEPT - "PageType = Card with no SourceTable":
//   Instead of showing data from a table, we use only variables
//   to display calculated metrics. This is perfect for dashboards
//   and summary pages.
//
// KEY CONCEPT - "OnOpenPage trigger":
//   This code runs when the page opens (before the user sees anything).
//   We use it to calculate all the dashboard metrics.
//
// KEY CONCEPT - "Record.Count":
//   Counts how many records match the current filters.
//   Example: Member.SetRange("Status", Member.Status::Active); Member.Count;
//
// KEY CONCEPT - "Record.CalcSums()":
//   Sums numeric fields (Decimal, Integer) across filtered records.
//   Must call on a field defined as a SumIndexFields in the key.
//   Example: Member.CalcSums("Account Balance");
//
// METRICS DISPLAYED:
//   1. Total Members        - All active members in the system
//   2. Active Members       - Members with Status = Active
//   3. Total Account Balance - Sum of all member account balances
//   4. Pending Applications - Member applications waiting for approval
// ============================================================

page 50115 "Member Dashboard"
{
    Caption = 'Member Dashboard';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Documents;
    SourceTable = "Member";
    SourceTableTemporary = true;  // Use temporary table to avoid record display

    layout
    {
        area(Content)
        {
            // ===== HEADER SECTION =====
            group(Header)
            {
                Caption = 'SACCO Dashboard';
                Enabled = false;

                field(DashboardTitle; 'Summary Statistics')
                {
                    ShowCaption = false;
                    Style = Strong;
                    StyleExpr = true;
                }
            }

            // ===== MEMBER STATISTICS SECTION =====
            group("Member Statistics")
            {
                Caption = 'Member Statistics';

                field(TotalMembersLabel; 'Total Members')
                {
                    ShowCaption = true;
                    Editable = false;
                }
                field(TotalMembers; TotalMembers)
                {
                    Caption = 'Total Members';
                    Editable = false;
                    Style = Strong;
                    StyleExpr = true;
                }

                field(ActiveMembersLabel; 'Active Members')
                {
                    ShowCaption = true;
                    Editable = false;
                }
                field(ActiveMembers; ActiveMembers)
                {
                    Caption = 'Active Members';
                    Editable = false;
                    Style = Strong;
                    StyleExpr = true;
                }
            }

            // ===== ACCOUNT BALANCE SECTION =====
            group("Account Information")
            {
                Caption = 'Account Information';

                field(TotalBalanceLabel; 'Total Account Balance')
                {
                    ShowCaption = true;
                    Editable = false;
                }
                field(TotalAccountBalance; TotalAccountBalance)
                {
                    Caption = 'Total Account Balance';
                    Editable = false;
                    Style = Strong;
                    StyleExpr = true;
                    DecimalPlaces = 2;
                    ToolTip = 'The sum of all member savings/account balances in the system';
                }
            }

            // ===== APPLICATION STATISTICS SECTION =====
            group("Application Status")
            {
                Caption = 'Application Status';

                field(PendingApplicationsLabel; 'Pending Applications')
                {
                    ShowCaption = true;
                    Editable = false;
                }
                field(PendingApplications; PendingApplications)
                {
                    Caption = 'Pending Applications';
                    Editable = false;
                    Style = Strong;
                    StyleExpr = true;
                    ToolTip = 'The number of member applications waiting for approval';
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
                Caption = 'Refresh Dashboard';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Recalculate all dashboard metrics';

                trigger OnAction()
                begin
                    CalculateDashboardMetrics();
                    Message('Dashboard updated successfully');
                end;
            }

            action(OpenMemberList)
            {
                Caption = 'View All Members';
                Image = List;
                Promoted = true;
                PromotedCategory = Category4;
                ToolTip = 'Open the complete member list';

                trigger OnAction()
                begin
                    Page.Run(Page::"Member List");
                end;
            }

            action(OpenApplicationList)
            {
                Caption = 'View Applications';
                Image = List;
                Promoted = true;
                PromotedCategory = Category4;
                ToolTip = 'Open the member application list';

                trigger OnAction()
                begin
                    Page.Run(Page::"Member Application List");
                end;
            }

            action(OpenLoanApplicationList)
            {
                Caption = 'View Loan Applications';
                Image = List;
                Promoted = true;
                PromotedCategory = Category4;
                ToolTip = 'Open the loan application list';

                trigger OnAction()
                begin
                    Page.Run(Page::"Loan Application List");
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        CalculateDashboardMetrics();
    end;

    // -------------------------------------------------------
    // CalculateDashboardMetrics
    // -------------------------------------------------------
    // PURPOSE: Calculates all dashboard metrics by querying
    //          the Member and Member Application tables.
    //
    // HOW IT WORKS:
    //   1. Count total members using Record.Count()
    //   2. Count active members using Record.Count with filter
    //   3. Sum account balances using Record.CalcSums()
    //   4. Count pending applications using Record.Count with filter
    // -------------------------------------------------------
    local procedure CalculateDashboardMetrics()
    var
        Member: Record "Member";
        MemberApp: Record "Member Application";
    begin
        // ===== TOTAL MEMBERS =====
        // Count all members regardless of status
        TotalMembers := Member.Count();

        // ===== ACTIVE MEMBERS =====
        // Count only members with Status = Active
        Member.SetRange("Status", Member.Status::Active);
        ActiveMembers := Member.Count();
        Member.SetRange("Status");  // Clear the filter for next operation

        // ===== TOTAL ACCOUNT BALANCE =====
        // Sum all account balances across all members
        Member.SetCurrentKey("Account Balance");
        // Note: CalcSums requires the field to be included in a SumIndexFields key
        // If the Member table doesn't have this configured, we'll sum manually
        if Member.FindSet() then
            repeat
                TotalAccountBalance += Member."Account Balance";
            until Member.Next() = 0
        else
            TotalAccountBalance := 0;

        // ===== PENDING APPLICATIONS =====
        // Count member applications waiting for approval
        MemberApp.SetRange("Status", MemberApp.Status::Pending);
        PendingApplications := MemberApp.Count();
        MemberApp.SetRange("Status");  // Clear the filter
    end;

    // -------------------------------------------------------
    // Variable Declarations
    // -------------------------------------------------------
    // These variables hold the calculated dashboard metrics
    var
        TotalMembers: Integer;
        ActiveMembers: Integer;
        TotalAccountBalance: Decimal;
        PendingApplications: Integer;
}
