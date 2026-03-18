// ============================================================
// Page 50110 - Email Preview Dialog
// ============================================================
// PURPOSE: Lets the admin edit the email subject and body
//          before it is sent to the member.
// ============================================================
page 50111 "Email Preview Dialog"
{
    PageType = StandardDialog;
    Caption = 'Preview & Edit Email Before Sending';
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group("Email Details")
            {
                field(ToAddress; ToAddress)
                {
                    Caption = 'To (Email Address)';
                    Editable = false;  // Admin can't change who it goes to
                    ApplicationArea = All;
                }
                field(Subject; Subject)
                {
                    Caption = 'Subject';
                    ApplicationArea = All;  // Admin can edit this
                }
                field(Body; Body)
                {
                    Caption = 'Message Body';
                    ApplicationArea = All;
                    MultiLine = true;  // Makes it a big text box
                }
            }
        }
    }

    // These variables hold the email content
    var
        ToAddress: Text[100];
        Subject: Text[100];
        Body: Text;

    // Called from codeunit to pre-fill the fields
    procedure SetEmailContent(NewTo: Text[100]; NewSubject: Text[100]; NewBody: Text)
    begin
        ToAddress := NewTo;
        Subject := NewSubject;
        Body := NewBody;
    end;

    // Called from codeunit to read the (possibly edited) content
    procedure GetEmailContent(var NewSubject: Text[100]; var NewBody: Text)
    begin
        NewSubject := Subject;
        NewBody := Body;
    end;
}