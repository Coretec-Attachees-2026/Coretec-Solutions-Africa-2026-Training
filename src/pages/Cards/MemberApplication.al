page 50101 "Member Application Card"
{
    Caption = 'Member Application';
    PageType = Card;
    SourceTable = "Member Application";
    ApplicationArea = All;
    DelayedInsert = true;
    InsertAllowed = true;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group("Personal Information")
            {
                field("First Name"; rec."First Name")
                {
                    ToolTip = 'Specifies the applicant''s first name';
                }
                field("Last Name"; rec."Last Name")
                {
                    ToolTip = 'Specifies the applicant''s last name';
                }
                field("Date of Birth"; rec."Date of Birth")
                {
                    ToolTip = 'Specifies the applicant''s date of birth';
                }
                field("ID Number"; rec."ID Number")
                {
                    ToolTip = 'Specifies the applicant''s ID or passport number';
                }
            }
            group("Contact Information")
            {
                field("Phone Number"; rec."Phone Number")
                {
                    ToolTip = 'Specifies the applicant''s phone number';
                }
                field("Email"; rec."Email")
                {
                    ToolTip = 'Specifies the applicant''s email address';
                }
                field("Address"; rec."Address")
                {
                    ToolTip = 'Specifies the applicant''s street address';
                }
                field("City"; rec."City")
                {
                    ToolTip = 'Specifies the applicant''s city';
                }
                field("Postal Code"; rec."Postal Code")
                {
                    ToolTip = 'Specifies the applicant''s postal code';
                }
                field("Country"; rec."Country")
                {
                    ToolTip = 'Specifies the applicant''s country';
                }
            }

            group("Employment Information")
            {
                field("Occupation"; rec."Occupation")
                {
                    ToolTip = 'Specifies the applicant''s occupation';
                }
                field("Annual Income"; rec."Annual Income")
                {
                    ToolTip = 'Specifies the applicant''s annual income';
                }
                field("Member Category"; rec."Member Category")
                {
                    ToolTip = 'Specifies the member category';
                }
            }
            group("General Information")
            {
                field("Application ID"; rec."Application ID")
                {
                    ToolTip = 'Specifies the unique identifier for this application';
                    Editable = false;
                }
                field("Status"; rec."Status")
                {
                    ToolTip = 'Specifies the current status of the application';
                    Editable = false;
                }
                field("Application Date"; rec."Application Date")
                {
                    ToolTip = 'Specifies when the application was submitted';
                    Editable = false;
                }
            }
            group("Approval Information")
            {
                Editable = false; 
                field("Approval Date"; rec."Approval Date")
                {
                    ToolTip = 'Specifies when the application was approved or rejected';
                }
                field("Rejection Reason"; rec."Rejection Reason")
                {
                    ToolTip = 'Specifies the reason for rejection, if applicable';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Approve")
            {
                Caption = 'Approve';
                Visible = NotApproved;
                Image = Approve;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    MemberMgmt: Codeunit "Member Management";
                begin
                    if Confirm('Do you want to approve this application?', false) then begin
                        MemberMgmt.ApproveApplication(rec."Application ID");
                        NotApproved := false;
                        CurrPage.Update(false); 
                    end;
                end;
            }
            action("Reject")
            {
                Caption = 'Reject';
                Image = Reject;
                Visible = NotApproved;
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
                        NotApproved := false;
                        CurrPage.Update(false);
                    end;
                end;
            }
        }
    }
    trigger OnAfterGetCurrRecord()
    begin
        if Rec.Status <> Rec.Status::Approved then
            NotApproved := true
        else
            NotApproved := false;
        end;

    var
        NotApproved: Boolean;
}
