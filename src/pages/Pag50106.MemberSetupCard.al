
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
            group("Member Application")
            {
                Caption = 'Member Application';
                field("Member Application Nos."; rec."Member Application Nos.")
                {
                    ToolTip = 'Specifies the No. Series used to generate member application IDs.';
                }
            }
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

    actions {
        area(Processing) {
            action(MemberDashboard) {

                Caption = 'Member Dashboard';
                Image = UserInterface;
                ApplicationArea = all;
                trigger OnAction()
                var
                    MemberDashboardPage: Page "Member Dashboard";
                begin
                    CurrPage.Close();
                    MemberDashboardPage.Run();
                end;

            }
        }
        area(Promoted) {
            actionref("Member Dashboard"; MemberDashboard) {

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
