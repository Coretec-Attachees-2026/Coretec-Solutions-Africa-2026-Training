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

            // ----- Email Templates (NEW) -----
            group("Email Templates")
            {
                Caption = 'Email Templates';

                field("Rejection Email Template"; rec."Rejection Email Template")
                {
                    ToolTip = 'The email template sent to applicants when their application is rejected. Variables: {First Name}, {Rejection Reason}, {Application ID}. Example: "Dear {First Name}, Your application {Application ID} has been rejected. Reason: {Rejection Reason}"';
                    MultiLine = true;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(OpenDashboard)
            {
                Caption = 'Member Dashboard';
                Image = Edit;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Open the Member Dashboard to view key statistics and performance indicators';

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
