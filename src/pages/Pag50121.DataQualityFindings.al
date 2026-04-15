// ============================================================
// Page 50121 - Data Quality Findings
// ============================================================
// PURPOSE: Displays data quality issues found by the
//          Data Quality Management Codeunit (50111).
//
// USER EXPERIENCE:
//   1. User opens this page via an action from another page
//   2. Click "Analyze Now" to run all data quality checks
//   3. View issues organized by type and severity
//   4. Click on an issue to drill down to the affected record
//   5. Each issue shows: Type, Severity, Description, Recommendation
//
// DRILL-DOWN ACTIONS:
//   - Member ID drilldown → Opens Member Card
//   - Loan Application No. drilldown → Opens Loan App Card
//   - "Open Record" button → Direct link based on issue type
//
// STYLING:
//   - Red background for "Critical" severity
//   - Yellow background for "Warning" severity
//   - Green background for "Info" severity
//
// ============================================================

page 50121 "Data Quality Findings"
{
    Caption = 'Data Quality Findings';
    PageType = List;
    SourceTable = "Data Quality Issue";
    ApplicationArea = All;
    UsageCategory = Administration;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Issue Type"; Rec."Issue Type")
                {
                    ToolTip = 'Type of data quality issue detected';
                    Width = 20;
                }

                field("Severity"; Rec."Severity")
                {
                    ToolTip = 'Severity level: Critical, Warning, Info';
                    StyleExpr = SeverityStyle;
                    Width = 15;
                }

                field("Description"; Rec."Description")
                {
                    ToolTip = 'Detailed description of the issue';
                    Width = 50;
                }

                field("Affected Count"; Rec."Affected Count")
                {
                    ToolTip = 'Number of records affected (for duplicate emails)';
                    Width = 12;
                    Visible = ShowAffectedCount;
                }

                field("Days in Status"; Rec."Days in Status")
                {
                    ToolTip = 'Number of days stuck in current status (for stalled apps)';
                    Width = 12;
                    Visible = ShowDaysInStatus;
                }

                field("Member ID"; Rec."Member ID")
                {
                    ToolTip = 'Affected member (clickable for drill-down)';
                    Width = 15;

                    trigger OnDrillDown()
                    begin
                        if Rec."Member ID" <> '' then
                            OpenMemberCard(Rec."Member ID");
                    end;
                }

                field("Member Email"; Rec."Member Email")
                {
                    ToolTip = 'Email address involved in the issue';
                    Width = 25;
                }

                field("Loan Application No."; Rec."Loan Application No.")
                {
                    ToolTip = 'Loan application involved (clickable for drill-down)';
                    Width = 18;

                    trigger OnDrillDown()
                    begin
                        if Rec."Loan Application No." <> '' then
                            OpenLoanApplicationCard(Rec."Loan Application No.");
                    end;
                }

                field("Recommendation"; Rec."Recommendation")
                {
                    ToolTip = 'Recommended action to fix this issue';
                    Width = 60;
                }

                field("Status Since Date"; Rec."Status Since Date")
                {
                    ToolTip = 'Date when the record entered this status';
                    Width = 15;
                }
            }
        }

        area(FactBoxes)
        {
            part(SummaryFactBox; "Data Quality Summary")
            {
                ApplicationArea = All;
                UpdatePropagation = Both;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(AnalyzeNow)
            {
                Caption = 'Analyze Now';
                ToolTip = 'Run all data quality checks and refresh findings';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    DataQual: Codeunit "Data Quality Management";
                begin
                    Rec.DeleteAll();  // Clear previous results
                    DataQual.RunDataQualityChecks(Rec);
                    Message('%1 data quality issues found.', Rec.Count);
                    CurrPage.Update(false);
                end;
            }

            action(OpenRecord)
            {
                Caption = 'Open Record';
                ToolTip = 'Open the affected record to view or edit';
                Image = Open;
                Promoted = true;
                PromotedCategory = Category4;

                trigger OnAction()
                begin
                    case Rec."Issue Type" of
                        'Duplicate Email':
                            if Rec."Member ID" <> '' then
                                OpenMemberCard(Rec."Member ID");
                        'Orphaned Loan', 'Stalled Application':
                            if Rec."Loan Application No." <> '' then
                                OpenLoanApplicationCard(Rec."Loan Application No.");
                    end;
                end;
            }

            action(FilterByCritical)
            {
                Caption = 'Show Critical Only';
                ToolTip = 'Filter to show only critical severity issues';
                Image = Filter;
                Promoted = true;
                PromotedCategory = Category5;

                trigger OnAction()
                begin
                    Rec.FilterGroup(2);
                    Rec.SetRange("Severity", 'Critical');
                    Rec.FilterGroup(0);
                    Message('Filtered to Critical severity only');
                    CurrPage.Update(false);
                end;
            }

            action(ClearFilter)
            {
                Caption = 'Clear Filters';
                ToolTip = 'Show all issues';
                Image = ClearFilter;
                Promoted = true;
                PromotedCategory = Category5;

                trigger OnAction()
                begin
                    Rec.FilterGroup(2);
                    Rec.SetRange("Severity");
                    Rec.FilterGroup(0);
                    CurrPage.Update(false);
                end;
            }

            action(ExportToExcel)
            {
                Caption = 'Export to Excel';
                ToolTip = 'Export findings to Excel for analysis';
                Image = Export;
                Promoted = true;
                PromotedCategory = Category6;

                trigger OnAction()
                begin
                    // Export feature would be implemented with ExcelBuffer
                    // For now, show message with count
                    if Rec.Count = 0 then
                        Message('No issues to export. Run "Analyze Now" first.')
                    else
                        Message('Ready to export %1 data quality issues. Use Excel Buffer export in enhanced version.', Rec.Count);
                end;
            }
        }

        area(Navigation)
        {
            action(GoToMember)
            {
                Caption = 'Go to Member';
                ToolTip = 'Open the Member Card for this row';
                Image = Navigate;

                trigger OnAction()
                begin
                    if Rec."Member ID" <> '' then
                        OpenMemberCard(Rec."Member ID")
                    else
                        Message('No Member ID set for this record');
                end;
            }

            action(GoToLoan)
            {
                Caption = 'Go to Loan Application';
                ToolTip = 'Open the Loan Application Card for this row';
                Image = Navigate;

                trigger OnAction()
                begin
                    if Rec."Loan Application No." <> '' then
                        OpenLoanApplicationCard(Rec."Loan Application No.")
                    else
                        Message('No Loan Application set for this record');
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        UpdateVisibility();
        UpdateStyling();
    end;

    trigger OnOpenPage()
    begin
        UpdateVisibility();
    end;

    // ================================================================
    // LOCAL PROCEDURES
    // ================================================================

    local procedure OpenMemberCard(MemberID: Code[20])
    var
        Member: Record "Member";
    begin
        if Member.Get(MemberID) then
            Page.Run(Page::"Member Card", Member)
        else
            Message('Member %1 not found', MemberID);
    end;

    local procedure OpenLoanApplicationCard(LoanNo: Code[20])
    var
        LoanApp: Record "Loan Application";
    begin
        if LoanApp.Get(LoanNo) then
            Page.Run(Page::"Loan Application Card", LoanApp)
        else
            Message('Loan Application %1 not found', LoanNo);
    end;

    local procedure UpdateVisibility()
    begin
        // Show Affected Count only for Duplicate Email issues
        ShowAffectedCount := (Rec."Issue Type" = 'Duplicate Email');

        // Show Days in Status only for Stalled Application issues
        ShowDaysInStatus := (Rec."Issue Type" = 'Stalled Application');
    end;

    local procedure UpdateStyling()
    begin
        case Rec."Severity" of
            'Critical':
                SeverityStyle := 'Attention';  // Red
            'Warning':
                SeverityStyle := 'Favorable';  // Green
            else
                SeverityStyle := 'Standard';   // Default
        end;
    end;

    var
        ShowAffectedCount: Boolean;
        ShowDaysInStatus: Boolean;
        SeverityStyle: Text;
}
