// ============================================================
// Page 50106 - Member Setup
// ============================================================
// PURPOSE: Configuration page where admin sets up No. Series
//          and G/L accounts for the SACCO system.
//
// KEY CONCEPT - "PageType = Card":
//   A Card page shows ONE record at a time (like a form).
//   Since Member Setup has only 1 record, Card is perfect.
//
// KEY CONCEPT - "InsertAllowed = false; DeleteAllowed = false":
//   We don't want users creating multiple setup records or deleting it.
//   The system creates the one-and-only record automatically.
// ============================================================

page 50106 "Member Setup"
{
    Caption = 'Member Setup';
    PageType = Card;
    SourceTable = "Member Setup";
    ApplicationArea = All;
    UsageCategory = Administration;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            // ----- Member Application Settings -----
            group("Member Application")
            {
                Caption = 'Member Application';
                field("Member Application Nos."; rec."Member Application Nos.")
                {
                    ToolTip = 'Specifies the No. Series used to generate member application IDs.';
                }
            }

            // ----- Loan Settings (NEW) -----
            group("Loan Settings")
            {
                Caption = 'Loan Settings';

                field("Loan Application Nos."; rec."Loan Application Nos.")
                {
                    ToolTip = 'Specifies the No. Series used to generate loan application numbers (e.g., LN-20260101-00001).';
                }
                field("Loans Receivable Account"; rec."Loans Receivable Account")
                {
                    ToolTip = 'The G/L Account to DEBIT when a loan is disbursed. This is an asset account - it represents money members owe the SACCO.';
                }
                field("Loan Disbursement Account"; rec."Loan Disbursement Account")
                {
                    ToolTip = 'The G/L Account to CREDIT when a loan is disbursed. This is typically the bank account from which loan money is paid out.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("SACCO Health Check")
            {
                Caption = 'SACCO Health Check';
                ToolTip = 'Run system configuration health checks. View pass/fail status for all critical settings and get recommendations for fixes.';
                Image = CheckList;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    Page.Run(Page::"SACCO Health Check");
                end;
            }

            action("View Dashboard")
            {
                Caption = 'View Dashboard';
                ToolTip = 'Open the Member Dashboard to view SACCO statistics and summaries.';
                Image = BarChart;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    Page.Run(Page::"Member Dashboard");
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        MemberAppNoSeriesMgt: Codeunit "Member App No. Series Mgt";
    begin
        MemberAppNoSeriesMgt.EnsureMemberApplicationNoSeriesAndSetup();
        rec.GetOrCreateSetup();
    end;
}
