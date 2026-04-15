page 50121 "Health Check"
{
    Caption = 'Health Check';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    Editable = false;

    layout
    {
        area(Content)
        {
            part("Member Setup Health Check"; "Member Setup Health Check")
            {

            }
            part("Email Account Setup Status"; "Email Account Setup Status") {

            }
            part("Welcome Email Setup Check"; "Welcome Email Setup Check") {

            }
            part("Rejection Email Setup Check"; "Rejection Email Setup Check") {

            }
            part("Occupation Setup Check"; "Occupation Setup Check") {

            }
            part("Member Category Setup Check"; "Member Category Setup Check") {

            }
        }
    }
}

page 50123 "Member Setup Health Check"
{

    Description = 'A subsection of the health check page for the member setup health check / status check';
    PageType = CardPart;
    ApplicationArea = All;
    SourceTable = "Member Setup";


    layout
    {
        area(Content)
        {
            group("Member Setup Status")
            {
                ShowCaption = false;
                field(MemberSetup_is_set; MemberSetup_is_set)
                {
                    Caption = 'Set up?';
                }
                field(LoanApplicationSeries; LoanApplicationSeries)
                {
                    Caption = 'Loan Application Series';
                }
                field("Loans Receivable Account"; LoansReceivableAccount)
                {
                    Caption = 'Loans Receivable Account';
                }
                field("Loan Disbursement Account"; LoanDisbursementAccount)
                {
                    Caption = 'Loan Disbursement Account';
                }

            }
        }
    }
    trigger OnAfterGetRecord()
    var
        MemberSetup: Record "Member Setup";

    begin
        if MemberSetup.FindFirst() then begin
            MemberSetup_is_set := 'Yes';
            StyleVariable := 'Favourable';

            if MemberSetup."Member Application Nos." <> '' then
                MemberSeries := MemberSetup."Member Application Nos."
            else
                MemberSeries := 'Not set';

            if MemberSetup."Loan Application Nos." <> '' then
                LoanApplicationSeries := MemberSetup."Loan Application Nos."
            else
                LoanApplicationSeries := 'Not set';

            if MemberSetup."Loans Receivable Account" <> '' then
                LoansReceivableAccount := MemberSetup."Loans Receivable Account"
            else
                LoansReceivableAccount := 'Not set';

            if MemberSetup."Loan Disbursement Account" <> '' then
                LoanDisbursementAccount := MemberSetup."Loan Disbursement Account"
            else
                LoanDisbursementAccount := 'Not set';
        end else begin
            MemberSetup_is_set := 'No';
            MemberSeries := 'NO DATA';
            LoanApplicationSeries := 'NO DATA';
            LoansReceivableAccount := 'NO DATA';
            LoanDisbursementAccount := 'NO DATA';
            StyleVariable := 'Unfavourable';
        end;

    end;

    var
        MemberSetup_is_set: Text;
        StyleVariable: Text;

        MemberSeries: Code[20];
        LoanApplicationSeries: Code[20];
        LoansReceivableAccount: Code[20];
        LoanDisbursementAccount: Code[20];

}

page 50124 "Welcome Email Setup Check"
{

    Description = 'A subsection of the health check to display status of the welcome email setup';
    PageType = CardPart;
    ApplicationArea = all;
    SourceTable = WelcomeEmailSetupTable;

    layout
    {
        area(Content)
        {
            group("Welcome Email Setup Status")
            {
                ShowCaption = false;
                field(IsSet; WelcomeEmailSetup_is_set)
                {
                    Caption = 'Is Set?';
                    StyleExpr = 'Favourable';

                }
                field(EmailFormat; Format)
                {
                    Caption = 'Email Format';
                }
            }
        }
    }
    trigger OnAfterGetCurrRecord()
    var
        // Something wrong, we are using another variable instead of using Rec
        WelcomeEmail: Record WelcomeEmailSetupTable;
    begin
        if WelcomeEmail.FindSet() then begin
            WelcomeEmailSetup_is_set := 'Yes';
            Format := 'See Table for Details';
            StyleVariable := 'Favourable';
        end else begin
            WelcomeEmailSetup_is_set := 'No';
            Format := 'Not set up';
            StyleVariable := 'Unfavourable';
        end;

    end;

    var
        WelcomeEmailSetup_is_set: Text;
        Format: Text;
        StyleVariable: Text;
}

page 50125 "Rejection Email Setup Check"
{

    Description = 'A subsection of the health check to display status of the Rejection email setup';
    PageType = CardPart;
    ApplicationArea = all;
    SourceTable = RejectionEmailSetupTable;

    layout
    {
        area(Content)
        {
            group("Rejection Email Setup Status")
            {
                ShowCaption = false;
                field(IsSet; RejectionEmailSetup_is_set)
                {
                    Caption = 'Is Set?';
                    StyleExpr = StyleVariable;

                }
                field(EmailFormat; Format)
                {
                    Caption = 'Email Format';
                }
            }
        }
    }
    trigger OnAfterGetCurrRecord()
    var
        // Something wrong, we are using another variable instead of using Rec
        RejectionEmail: Record RejectionEmailSetupTable;
    begin
        if RejectionEmail.FindSet() then begin
            RejectionEmailSetup_is_set := 'Yes';
            Format := 'See Table for Details';
            StyleVariable := 'Favourable';
        end else begin
            RejectionEmailSetup_is_set := 'No';
            Format := 'Not set up';
            StyleVariable := 'Unfavourable';
        end;

    end;

    var
        RejectionEmailSetup_is_set: Text;
        Format: Text;
        StyleVariable: Text;
}

page 50126 "Email Account Setup Status"
{
    PageType = CardPart;
    ApplicationArea = all;
    SourceTable = "Email Account";

    layout
    {
        area(Content)
        { 
            group("Email Account Setup Status")
            {
                ShowCaption = false;
                field(EmailAccountExists; EmailAccountExists)
                {
                    Caption = 'Email Account Exists';
                    StyleExpr = StyleVariable;
                }
                field(EmailAccountExisting; EmailAccountExisting)
                {
                    Caption = 'Active Email Account';
                    StyleExpr = StyleVariable;
                }
            }
        }
    }
    trigger OnAfterGetCurrRecord()
    var
        EmailAccount: Record "Email Account" temporary;
        EmailAccountMgmt: Codeunit "Email Account";
    begin
        // This codeunit fetches all the accounts from SMTP/Exchange/M365 into our temporary record
        EmailAccountMgmt.GetAllAccounts(EmailAccount);

        if EmailAccount.FindSet() then begin
            repeat
                if CheckWhetherEmailAccountCanSendEmail(EmailAccount) then begin
                    EmailAccountExists := 'Yes';
                    EmailAccountExisting := EmailAccount."Email Address";
                    StyleVariable := 'Favourable';
                    break;
                end;
            until EmailAccount.Next() = 0;
        end else begin
            EmailAccountExists := 'No';
            EmailAccountExisting := 'No Email Account Found';
            StyleVariable := 'Unfavourable';
        end;

    end;

    local procedure CheckWhetherEmailAccountCanSendEmail(EmailAccount: Record "Email Account"): Boolean
    var
        MemberManagement: Codeunit "Member Management";
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        Subject: Text[100];
        Body: Text;
    begin
        Body := 'This is a Test Email *please Ignore';
        Subject := 'Test Email: Health check';
        EmailMessage.Create('lensonisinparis@gmail.com', Subject, Body, true);
        if not Email.Send(EmailMessage, EmailAccount) then begin
            exit(false);
        end else begin
            exit(true);
        end;
    end;

    var
        EmailAccountExists: Text;
        EmailAccountExisting: Text[250];
        StyleVariable: Text;
}

page 50127 "Occupation Setup Check"
{
    Description = 'A subsection of the health check to display status of the Occupation setup';
    PageType = CardPart;
    ApplicationArea = All;
    SourceTable = Occupation;

    layout
    {
        area(Content)
        {
            group("Occupation Setup Status")
            {
                ShowCaption = false;
                field(IsSet; Occupation_is_set)
                {
                    Caption = 'Is Set?';
                    StyleExpr = StyleVariable;
                }
                field(DataStatus; DataStatus)
                {
                    Caption = 'Data Status';
                }
            }
        }
    }
    trigger OnAfterGetCurrRecord()
    var
        OccupationRec: Record Occupation;
    begin
        if not OccupationRec.IsEmpty() then begin
            Occupation_is_set := 'Yes';
            DataStatus := 'Data exists';
            StyleVariable := 'Favourable';
        end else begin
            Occupation_is_set := 'No';
            DataStatus := 'No occupations found';
            StyleVariable := 'Unfavourable';
        end;
    end;

    var
        Occupation_is_set: Text;
        DataStatus: Text;
        StyleVariable: Text;
}

page 50128 "Member Category Setup Check"
{
    Description = 'A subsection of the health check to display status of the Member Category setup';
    PageType = CardPart;
    ApplicationArea = All;
    SourceTable = "Member Category Master";

    layout
    {
        area(Content)
        {
            group("Member Category Setup Status")
            {
                ShowCaption = false;
                field(IsSet; MemberCategory_is_set)
                {
                    Caption = 'Is Set?';
                    StyleExpr = StyleVariable;
                }
                field(DataStatus; DataStatus)
                {
                    Caption = 'Data Status';
                }
            }
        }
    }
    trigger OnAfterGetCurrRecord()
    var
        MemberCategoryRec: Record "Member Category Master";
    begin
        if not MemberCategoryRec.IsEmpty() then begin
            MemberCategory_is_set := 'Yes';
            DataStatus := 'Data exists';
            StyleVariable := 'Favourable';
        end else begin
            MemberCategory_is_set := 'No';
            DataStatus := 'No member categories found';
            StyleVariable := 'Unfavourable';
        end;
    end;

    var
        MemberCategory_is_set: Text;
        DataStatus: Text;
        StyleVariable: Text;
}