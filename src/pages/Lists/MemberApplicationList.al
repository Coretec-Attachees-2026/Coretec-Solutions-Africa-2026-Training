page 50100 "Member Application List"
{
    Caption = 'Member Applications';
    PageType = List;
    SourceTable = "Member Application";
    ApplicationArea = All;
    UsageCategory = Lists;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Application ID"; rec."Application ID")
                {
                    ToolTip = 'Specifies the value of the Application ID field';
                }
                field("First Name"; rec."First Name")
                {
                    ToolTip = 'Specifies the value of the First Name field';
                }
                field("Last Name"; rec."Last Name")
                {
                    ToolTip = 'Specifies the value of the Last Name field';
                }
                field("Email"; rec."Email")
                {
                    ToolTip = 'Specifies the value of the Email field';
                }
                field("Phone Number"; rec."Phone Number")
                {
                    ToolTip = 'Specifies the value of the Phone Number field';
                }
                field("Application Date"; rec."Application Date")
                {
                    ToolTip = 'Specifies the value of the Application Date field';
                }
                field("Status"; rec."Status")
                {
                    ToolTip = 'Specifies the value of the Status field';
                }
                field("Member Category"; rec."Member Category")
                {
                    ToolTip = 'Specifies the value of the Member Category field';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("New Application")
            {
                Caption = 'New Application';
                Image = Add; 
                Promoted = true;                         
                PromotedCategory = Process;
                RunObject = page "Member Application Card";
                RunPageMode = Create;
            }
            action("Approve Application")
            {
                Caption = 'Approve Application';
                Image = Approve;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    MemberSendEmail: Record Member;
                    MemberMgmt: Codeunit "Member Management";
                begin
                    if Confirm('Do you want to approve this application?', false) then
                        MemberMgmt.ApproveApplication(rec."Application ID");
                        MemberSendEmail.FindFirst();
                        MemberMgmt.SendWelcomeEmailToMember(MemberSendEmail);

                    CurrPage.Update(false);
                end;
            }
            action("Reject Application")
            {
                Caption = 'Reject Application';
                Image = Reject;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    MemberMgmt: Codeunit "Member Management";
                    RejectionReason: Text[250];
                begin
                    if Confirm('Do you want to reject this application?', false) then begin
                        RejectionReason := 'Application rejected by administrator';
                        MemberMgmt.RejectApplication(rec."Application ID", RejectionReason);
                        CurrPage.Update(false);  // Refresh the list
                    end;
                end;
            }
            action(ExportMembers)
            {
                Caption = 'Export members';
                Image = Import;
                trigger OnAction()
                begin
                    Xmlport.Run(Xmlport::"Export Member XMLport", true, false);
                end;
            }
            action(ImportMembers)
            {
                Promoted = true;
                PromotedCategory = Process;
                Caption = 'Import Members';
                Image = Export;
                trigger OnAction()
                begin
                    Xmlport.Run(Xmlport::"Import Members XMLport", true, true);
                end;
            }
            action("Member Setup")
            {
                Caption = 'Member Setup';
                Image = Setup;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    Page.Run(Page::"Member Setup");
                end;
            }
            action("View Details")
            {
                Caption = 'View Details';
                RunObject = page "Member Application Card";
                RunPageLink = "Application ID" = field("Application ID");
                Image = Open;
                Promoted = true;
                PromotedCategory = Process;
            }
        }
    }
    
}
