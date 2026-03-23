// ============================================================
// Page 50114 - Test Email Input
// ============================================================
// PURPOSE: Collects a recipient email address for sending a
//          setup verification email from Member Setup.
// ============================================================

page 50114 "Test Email Input"
{
    Caption = 'Send Test Email';
    PageType = StandardDialog;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(Input)
            {
                Caption = 'Recipient';

                field(RecipientEmailField; RecipientEmail)
                {
                    Caption = 'Recipient Email';
                    ToolTip = 'Enter the email address that should receive the test message.';
                }
            }
        }
    }

    var
        RecipientEmail: Text[100];

    procedure GetRecipientEmail(): Text[100]
    begin
        exit(RecipientEmail);
    end;
}
