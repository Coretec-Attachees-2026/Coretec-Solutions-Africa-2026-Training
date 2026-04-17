page 50122 "Data Quality Summary"
{
    Caption = 'Data Quality Summary';
    PageType = CardPart;
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
                ApplicationArea = All;
            }

            field(CriticalCount; CriticalCount)
            {
                Caption = 'Critical Issues';
                Style = Attention;
                StyleExpr = (CriticalCount > 0);
                ApplicationArea = All;
            }

            field(WarningCount; WarningCount)
            {
                Caption = 'Warning Issues';
                Style = Favorable;
                StyleExpr = (WarningCount > 0);
                ApplicationArea = All;
            }

            field(DuplicateEmailCount; DuplicateEmailCount)
            {
                Caption = 'Duplicate Emails';
                ApplicationArea = All;
            }

            field(OrphanedLoanCount; OrphanedLoanCount)
            {
                Caption = 'Orphaned Loans';
                ApplicationArea = All;
            }

            field(StalledAppCount; StalledAppCount)
            {
                Caption = 'Stalled Applications';
                ApplicationArea = All;
            }
        }
    }

    procedure SetSummary(Issues: Record "Data Quality Issue")
    begin
        TotalIssuesCount := 0;
        CriticalCount := 0;
        WarningCount := 0;
        DuplicateEmailCount := 0;
        OrphanedLoanCount := 0;
        StalledAppCount := 0;

        Issues.Reset();
        if Issues.FindSet() then
            repeat
                TotalIssuesCount += 1;

                case Issues."Severity" of
                    'Critical':
                        CriticalCount += 1;
                    'Warning':
                        WarningCount += 1;
                end;

                case Issues."Issue Type" of
                    'Duplicate Email':
                        DuplicateEmailCount += 1;
                    'Orphaned Loan':
                        OrphanedLoanCount += 1;
                    'Stalled Application':
                        StalledAppCount += 1;
                end;
            until Issues.Next() = 0;

        Currpage.update(false);
    end;

    var
        TotalIssuesCount: Integer;
        CriticalCount: Integer;
        WarningCount: Integer;
        DuplicateEmailCount: Integer;
        OrphanedLoanCount: Integer;
        StalledAppCount: Integer;
}