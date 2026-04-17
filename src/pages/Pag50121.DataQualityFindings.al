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
                    ApplicationArea = All;
                }

                field("Severity"; Rec."Severity")
                {
                    ToolTip = 'Severity level: Critical, Warning, Info';
                    StyleExpr = SeverityStyle;
                    Width = 15;
                    ApplicationArea = All;
                }

                field("Description"; Rec."Description")
                {
                    ToolTip = 'Detailed description of the issue';
                    Width = 50;
                    ApplicationArea = All;
                }

                field("Affected Count"; Rec."Affected Count")
                {
                    ToolTip = 'Number of records affected (for duplicate emails)';
                    Width = 12;
                    Visible = ShowAffectedCount;
                    ApplicationArea = All;
                }

                field("Days in Status"; Rec."Days in Status")
                {
                    ToolTip = 'Number of days stuck in current status (for stalled apps)';
                    Width = 12;
                    Visible = ShowDaysInStatus;
                    ApplicationArea = All;
                }

                field("Member ID"; Rec."Member ID")
                {
                    ToolTip = 'Affected member (clickable for drill-down)';
                    Width = 15;
                    ApplicationArea = All;

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
                    ApplicationArea = All;
                }

                field("Loan Application No."; Rec."Loan Application No.")
                {
                    ToolTip = 'Loan application involved (clickable for drill-down)';
                    Width = 18;
                    ApplicationArea = All;

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
                    ApplicationArea = All;
                }

                field("Status Since Date"; Rec."Status Since Date")
                {
                    ToolTip = 'Date when the record entered this status';
                    Width = 15;
                    ApplicationArea = All;
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
                ApplicationArea = All;

                trigger OnAction()
                var
                    DataQual: Codeunit "Data Quality Management";
                    IssueCount: Integer;
                begin
                    IssueCount := DataQual.RunDataQualityChecks(Rec);
                    CurrPage.SummaryFactBox.Page.SetSummary(Rec);
                    Message('%1 data quality issues found.', IssueCount);
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
                ApplicationArea = All;

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
                ApplicationArea = All;

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
                ApplicationArea = All;

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
                ApplicationArea = All;

                trigger OnAction()
                begin
                    ExportToExcelBuffer();
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
                ApplicationArea = All;

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
                ApplicationArea = All;

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
        ShowAffectedCount := (Rec."Issue Type" = 'Duplicate Email');
        ShowDaysInStatus := (Rec."Issue Type" = 'Stalled Application');
    end;

    local procedure UpdateStyling()
    begin
        case Rec."Severity" of
            'Critical':
                SeverityStyle := 'Attention';
            'Warning':
                SeverityStyle := 'Favorable';
            else
                SeverityStyle := 'Standard';
        end;
    end;

    local procedure ExportToExcelBuffer()
    var
        IssueRec: Record "Data Quality Issue";
        ExcelBuffer: Record "Excel Buffer" temporary;
        FileName: Text;
    begin
        if Rec.Count = 0 then begin
            Message('No issues to export. Run "Analyze Now" first.');
            exit;
        end;

        // Initialize Excel Buffer
        ExcelBuffer.DeleteAll();

        // Add header row
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('Issue ID', false, '', true, false, false, '', 0);
        ExcelBuffer.AddColumn('Issue Type', false, '', true, false, false, '', 0);
        ExcelBuffer.AddColumn('Severity', false, '', true, false, false, '', 0);
        ExcelBuffer.AddColumn('Description', false, '', true, false, false, '', 0);
        ExcelBuffer.AddColumn('Member ID', false, '', true, false, false, '', 0);
        ExcelBuffer.AddColumn('Member Email', false, '', true, false, false, '', 0);
        ExcelBuffer.AddColumn('Loan Application No.', false, '', true, false, false, '', 0);
        ExcelBuffer.AddColumn('Affected Count', false, '', true, false, false, '', 0);
        ExcelBuffer.AddColumn('Days in Status', false, '', true, false, false, '', 0);
        ExcelBuffer.AddColumn('Status Since Date', false, '', true, false, false, '', 0);
        ExcelBuffer.AddColumn('Recommendation', false, '', true, false, false, '', 0);

        // Copy issues to ExcelBuffer
        IssueRec.Copy(Rec, true);
        IssueRec.Reset();

        if IssueRec.FindSet() then
            repeat
                ExcelBuffer.NewRow();
                ExcelBuffer.AddColumn(Format(IssueRec."Issue ID"), false, '', false, false, false, '', 0);
                ExcelBuffer.AddColumn(IssueRec."Issue Type", false, '', false, false, false, '', 0);
                ExcelBuffer.AddColumn(IssueRec."Severity", false, '', false, false, false, '', 0);
                ExcelBuffer.AddColumn(IssueRec."Description", false, '', false, false, false, '', 0);
                ExcelBuffer.AddColumn(IssueRec."Member ID", false, '', false, false, false, '', 0);
                ExcelBuffer.AddColumn(IssueRec."Member Email", false, '', false, false, false, '', 0);
                ExcelBuffer.AddColumn(IssueRec."Loan Application No.", false, '', false, false, false, '', 0);
                ExcelBuffer.AddColumn(Format(IssueRec."Affected Count"), false, '', false, false, false, '', 0);
                ExcelBuffer.AddColumn(Format(IssueRec."Days in Status"), false, '', false, false, false, '', 0);
                ExcelBuffer.AddColumn(Format(IssueRec."Status Since Date"), false, '', false, false, false, '', 0);
                ExcelBuffer.AddColumn(IssueRec."Recommendation", false, '', false, false, false, '', 0);
            until IssueRec.Next() = 0;

        // Generate Excel file with timestamp
        FileName := 'Data Quality Issues ' + Format(Today, 0, '<Year4><Month,2><Day,2>') + '.xlsx';
        ExcelBuffer.CreateNewBook(FileName);
        ExcelBuffer.WriteSheet(FileName, '', '');
        ExcelBuffer.CloseBook();
        ExcelBuffer.OpenExcel();

        Message('Successfully exported %1 data quality issues to Excel.', IssueRec.Count);
    end;

    var
        ShowAffectedCount: Boolean;
        ShowDaysInStatus: Boolean;
        SeverityStyle: Text;
}