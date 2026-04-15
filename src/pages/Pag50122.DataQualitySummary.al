// ============================================================
// Page 50122 - Data Quality Summary
// ============================================================
// PURPOSE: Fact box that displays summary statistics of
//          data quality issues found.
//
// SHOWS:
//   - Total issues found
//   - Issues by severity (Critical, Warning)
//   - Issues by type (Duplicate Email, Orphaned, Stalled)
//   - Quick insights
//
// ============================================================

page 50122 "Data Quality Summary"
{
    Caption = 'Data Quality Summary';
    PageType = CardPart;
    SourceTable = "Data Quality Issue";
    Editable = false;

    layout
    {
        area(Content)
        {
            field(TotalIssues; TotalIssuesCount)
            {
                Caption = 'Total Issues';
                Style = Strong;
                StyleExpr = true;
            }

            field(CriticalCount; CriticalCount)
            {
                Caption = 'Critical Issues';
                Style = Attention;
                StyleExpr = (CriticalCount > 0);
            }

            field(WarningCount; WarningCount)
            {
                Caption = 'Warning Issues';
                Style = Favorable;
                StyleExpr = (WarningCount > 0);
            }

            field(DuplicateEmailCount; DuplicateEmailCount)
            {
                Caption = 'Duplicate Emails';
            }

            field(OrphanedLoanCount; OrphanedLoanCount)
            {
                Caption = 'Orphaned Loans';
            }

            field(StalledAppCount; StalledAppCount)
            {
                Caption = 'Stalled Applications';
            }

            field(LastAnalysis; 'Data Quality Analysis Result')
            {
                Caption = 'Summary';
                Visible = false;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        CalculateSummary();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        CalculateSummary();
    end;

    local procedure CalculateSummary()
    var
        IssueTable: Record "Data Quality Issue";
    begin
        TotalIssuesCount := 0;
        CriticalCount := 0;
        WarningCount := 0;
        DuplicateEmailCount := 0;
        OrphanedLoanCount := 0;
        StalledAppCount := 0;

        if IssueTable.FindSet() then
            repeat
                TotalIssuesCount += 1;

                case IssueTable."Severity" of
                    'Critical':
                        CriticalCount += 1;
                    'Warning':
                        WarningCount += 1;
                end;

                case IssueTable."Issue Type" of
                    'Duplicate Email':
                        DuplicateEmailCount += 1;
                    'Orphaned Loan':
                        OrphanedLoanCount += 1;
                    'Stalled Application':
                        StalledAppCount += 1;
                end;
            until IssueTable.Next() = 0;
    end;

    var
        TotalIssuesCount: Integer;
        CriticalCount: Integer;
        WarningCount: Integer;
        DuplicateEmailCount: Integer;
        OrphanedLoanCount: Integer;
        StalledAppCount: Integer;
}
