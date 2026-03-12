// ============================================================
// Page 50113 - Rejection Reason Input
// ============================================================
// PURPOSE: A simple input dialog for entering a rejection reason.
//          Reused by both the Member Application Card and
//          the Loan Application Card reject actions.
// ============================================================

page 50113 "Rejection Reason Input"
{
    Caption = 'Enter Rejection Reason';
    PageType = StandardDialog;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(Input)
            {
                Caption = 'Rejection Details';

                field(RejectionReasonField; RejectionReason)
                {
                    Caption = 'Reason for Rejection';
                    ToolTip = 'Enter the reason why this application is being rejected.';
                    MultiLine = true;
                }
            }
        }
    }

    var
        RejectionReason: Text[250];

    procedure GetRejectionReason(): Text[250]
    begin
        exit(RejectionReason);
    end;

    procedure SetRejectionReason(Reason: Text[250])
    begin
        RejectionReason := Reason;
    end;
}
