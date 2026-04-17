// ============================================================
// Report 50123 - Data Quality Report
// ============================================================
// PURPOSE: Processing report that generates a formal data quality
//          audit report. Runs analysis and displays results.
//
// USAGE: Run this report from role/menu to generate a formal
//        data quality audit that can be exported or emailed.
// ============================================================

report 50123 "Data Quality Report"
{
    ProcessingOnly = true;
    Caption = 'Data Quality Report';
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {

    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Report Options';
                    field(SeverityFilter; SeverityFilter)
                    {
                        Caption = 'Show Issues With Severity:';
                        ToolTip = 'Select which severity levels to include in report';
                    }

                    field(ExportToExcel; ExportToExcel)
                    {
                        Caption = 'Export to Excel?';
                        ToolTip = 'If yes, results will be exported to Excel';
                    }
                }
            }
        }
    }

    trigger OnPreReport()
    begin
        // Run the analysis
        RunAnalysis();
    end;

    local procedure RunAnalysis()
    var
        DataQualityFinder: Codeunit "Data Quality Finder";
    begin
        // Run all checks
        DataQualityFinder.PerformAllDataQualityChecks(IssueTable);

        // Apply severity filter
        ApplySeverityFilter();

        // Display results
        if IssueTable.FindSet() then begin
            Message('Data Quality Analysis Complete. Total Issues: ' + Format(IssueTable.Count()) +
                '. Analysis run: ' + Format(CurrentDateTime));

            // Open the finder page to display results
            Page.Run(Page::"Data Quality Finder", IssueTable);
        end else
            Message('No issues found! Your data quality is healthy.');
    end;

    local procedure ApplySeverityFilter()
    begin
        case SeverityFilter of
            1:
                IssueTable.SetRange(Severity, IssueTable.Severity::Critical);
            2:
                begin
                    IssueTable.FilterGroup(0);
                    IssueTable.SetFilter(Severity, '%1|%2', IssueTable.Severity::Critical, IssueTable.Severity::High);
                    IssueTable.FilterGroup(-1);
                end;
            3:
                IssueTable.SetFilter(Severity, '<>%1', IssueTable.Severity::Low);
        end;
    end;

    var
        IssueTable: Record "Data Quality Issue";
        SeverityFilter: Integer;
        ExportToExcel: Boolean;
}
