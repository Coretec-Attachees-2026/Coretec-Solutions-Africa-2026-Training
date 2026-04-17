// ============================================================
// Page 50122 - Data Quality Finder
// ============================================================
// PURPOSE: Displays data quality issues found in the SACCO system.
//          Provides visual indication of severity and actions
//          to open related records for correction.
//
// FEATURES:
//   - Summary statistics (issue count, severity breakdown)
//   - Color-coded severity indicators
//   - Action buttons to navigate to problem records
//   - Refresh button to re-run analysis
//   - Filtering by issue type and severity
//
// ISSUE TYPES FOUND:
//   - Duplicate Emails: Multiple members with same email address
//   - Orphaned Loans: Loan applications with non-existent members
//   - Stuck Status: Applications pending action for > 30 days
// ============================================================

page 50122 "Data Quality Finder"
{
    PageType = Document;
    SourceTable = "Data Quality Issue";
    Caption = 'Data Quality Finder';
    ApplicationArea = All;
    UsageCategory = Administration;
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            // ----- SUMMARY SECTION -----
            group("Analysis Summary")
            {
                Caption = 'Analysis Summary';
                Visible = true;

                field(IssueCountDisplay; IssueCountDisplay)
                {
                    Caption = 'Total Issues Found';
                    Editable = false;
                    StyleExpr = IssueCountStyle;
                    ToolTip = 'Total number of data quality issues detected';
                }

                field(CriticalCountDisplay; CriticalCountDisplay)
                {
                    Caption = 'Critical Issues';
                    Editable = false;
                    StyleExpr = 'Attention';
                    ToolTip = 'Issues that pose a risk to data integrity';
                }

                field(HighCountDisplay; HighCountDisplay)
                {
                    Caption = 'High Priority Issues';
                    Editable = false;
                    ToolTip = 'Issues that should be resolved soon';
                }

                field(MediumCountDisplay; MediumCountDisplay)
                {
                    Caption = 'Medium Priority Issues';
                    Editable = false;
                    ToolTip = 'Issues that should be reviewed';
                }

                field(LastAnalysisTime; LastAnalysisTime)
                {
                    Caption = 'Last Analysis Run';
                    Editable = false;
                    ToolTip = 'When the data quality analysis was last performed';
                }
            }

            // ----- ISSUES LIST -----
            repeater(IssuesList)
            {
                Caption = 'Issues';

                field("Entry No."; rec."Entry No.")
                {
                    Visible = false;
                }

                field(SeverityDisplay; SeverityDisplayText)
                {
                    Caption = 'Priority';
                    StyleExpr = SeverityStyleText;
                    ToolTip = 'Red = Critical, Orange = High, Yellow = Medium, Green = Low';
                }

                field("Issue Type"; rec."Issue Type")
                {
                    Caption = 'Issue Type';
                    ToolTip = 'Category of issue found';
                }

                field("Record Type"; rec."Record Type")
                {
                    Caption = 'Record Type';
                    ToolTip = 'What type of record has the issue';
                }

                field("Primary Record ID"; rec."Primary Record ID")
                {
                    Caption = 'Record ID';
                    ToolTip = 'The affected record''s ID number';
                }

                field("Issue Description"; rec."Issue Description")
                {
                    Caption = 'Issue';
                    ToolTip = 'Description of the issue found';
                }

                field(DetailsDisplay; rec.Details)
                {
                    Caption = 'Details';
                    ToolTip = 'Additional details about the issue';
                }

                field("Recommendation"; rec."Recommendation")
                {
                    Caption = 'Recommended Action';
                    ToolTip = 'Steps to resolve this issue';
                }

                field(SecondaryRecordDisplay; rec."Secondary Record ID")
                {
                    Visible = false;
                    Caption = 'Related Record';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            // ----- REFRESH ANALYSIS -----
            action(RunAnalysis)
            {
                Caption = 'Run Data Quality Analysis';
                ToolTip = 'Re-run all data quality checks and refresh the list';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    RunDataQualityAnalysis();
                    Message('Data quality analysis completed. %1 issues found.', rec.Count());
                end;
            }

            // ----- OPEN MEMBER RECORD -----
            action(OpenMemberRecord)
            {
                Caption = 'Open Member Record';
                ToolTip = 'Navigate to the member record that has the issue';
                Image = Document;
                Promoted = true;
                PromotedCategory = Process;
                Enabled = IsMemberIssue;

                trigger OnAction()
                begin
                    OpenAffectedRecord();
                end;
            }

            // ----- OPEN LOAN APPLICATION -----
            action(OpenLoanRecord)
            {
                Caption = 'Open Loan Application';
                ToolTip = 'Navigate to the loan application that has the issue';
                Image = Document;
                Promoted = true;
                PromotedCategory = Process;
                Enabled = IsLoanIssue;

                trigger OnAction()
                begin
                    OpenAffectedRecord();
                end;
            }

            // ----- OPEN MEMBER APPLICATION -----
            action(OpenMemberAppRecord)
            {
                Caption = 'Open Member Application';
                ToolTip = 'Navigate to the member application that has the issue';
                Image = NewDocument;
                Promoted = true;
                PromotedCategory = Process;
                Enabled = IsMemberAppIssue;

                trigger OnAction()
                begin
                    OpenAffectedRecord();
                end;
            }

            // ----- EXPORT TO EXCEL -----
            action(ExportToExcel)
            {
                Caption = 'Export to Excel';
                ToolTip = 'Copy all issues. You can paste into Excel.';
                Image = Export;
                Promoted = true;
                PromotedCategory = Report;

                trigger OnAction()
                begin
                    Message('Copy the issues list and paste into Excel. Press Ctrl+C to copy the displayed data.');
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        // Initialize page variables
        RefreshSummary();
    end;

    trigger OnAfterGetRecord()
    begin
        // Update enabled states for record-specific actions
        UpdateActionStates();
        UpdateSeverityDisplay();
    end;

    // ===== LOCAL PROCEDURES =====

    local procedure RunDataQualityAnalysis()
    var
        DataQualityFinder: Codeunit "Data Quality Finder";
    begin
        // Run the analysis (this populates the temporary table)
        DataQualityFinder.PerformAllDataQualityChecks(rec);

        // Refresh page display
        CurrPage.Update(false);
        RefreshSummary();
        LastAnalysisTime := CurrentDateTime;
    end;

    local procedure RefreshSummary()
    var
        TempIssue: Record "Data Quality Issue";
    begin
        // Count total issues
        TempIssue.Copy(rec);
        IssueCountDisplay := TempIssue.Count();

        // Count by severity
        TempIssue.SetRange(Severity, TempIssue.Severity::Critical);
        CriticalCountDisplay := TempIssue.Count();

        TempIssue.SetRange(Severity, TempIssue.Severity::High);
        HighCountDisplay := TempIssue.Count();

        TempIssue.SetRange(Severity, TempIssue.Severity::Medium);
        MediumCountDisplay := TempIssue.Count();

        // Set color indicators
        if IssueCountDisplay = 0 then
            IssueCountStyle := 'Favorable'
        else if CriticalCountDisplay > 0 then
            IssueCountStyle := 'Unfavorable'
        else if HighCountDisplay > 0 then
            IssueCountStyle := 'Attention'
        else
            IssueCountStyle := 'Standard';

        // Clear filter for display
        TempIssue.SetRange(Severity);
    end;

    local procedure UpdateActionStates()
    begin
        IsMemberIssue := (rec."Record Type" = 'Member');
        IsLoanIssue := (rec."Record Type" = 'Loan Application');
        IsMemberAppIssue := (rec."Record Type" = 'Member Application');
    end;

    local procedure UpdateSeverityDisplay()
    begin
        SeverityStyleText := GetSeverityStyle(rec.Severity);
        SeverityDisplayText := GetSeverityDisplay(rec.Severity);
    end;

    local procedure OpenAffectedRecord()
    var
        Member: Record "Member";
        LoanApp: Record "Loan Application";
        MemberApp: Record "Member Application";
    begin
        if rec."Record Type" = 'Member' then begin
            if Member.Get(rec."Primary Record ID") then
                Page.Run(Page::"Member Card", Member)
            else
                Message('Member %1 not found.', rec."Primary Record ID");
        end else if rec."Record Type" = 'Loan Application' then begin
            if LoanApp.Get(rec."Primary Record ID") then
                Page.Run(Page::"Loan Application Card", LoanApp)
            else
                Message('Loan Application %1 not found.', rec."Primary Record ID");
        end else if rec."Record Type" = 'Member Application' then begin
            if MemberApp.Get(rec."Primary Record ID") then
                Page.Run(Page::"Member Application Card", MemberApp)
            else
                Message('Member Application %1 not found.', rec."Primary Record ID");
        end;
    end;

    local procedure GetSeverityDisplay(Severity: Option Critical,High,Medium,Low): Text
    begin
        case Severity of
            rec.Severity::Critical:
                exit('🔴 CRITICAL');
            rec.Severity::High:
                exit('🟠 HIGH');
            rec.Severity::Medium:
                exit('🟡 MEDIUM');
            rec.Severity::Low:
                exit('🟢 LOW');
            else
                exit('Unknown');
        end;
    end;

    local procedure GetSeverityStyle(Severity: Option Critical,High,Medium,Low): Text
    begin
        case Severity of
            rec.Severity::Critical:
                exit('Unfavorable');
            rec.Severity::High:
                exit('Attention');
            rec.Severity::Medium:
                exit('Standard');
            rec.Severity::Low:
                exit('Favorable');
            else
                exit('Standard');
        end;
    end;

    // ===== PAGE VARIABLES =====
    var
        IssueCountDisplay: Integer;
        CriticalCountDisplay: Integer;
        HighCountDisplay: Integer;
        MediumCountDisplay: Integer;
        LastAnalysisTime: DateTime;
        IssueCountStyle: Text;
        IsMemberIssue: Boolean;
        IsLoanIssue: Boolean;
        IsMemberAppIssue: Boolean;
        SeverityDisplayText: Text;
        SeverityStyleText: Text;
}
