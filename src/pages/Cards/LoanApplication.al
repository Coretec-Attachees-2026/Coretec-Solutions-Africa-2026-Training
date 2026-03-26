page 50108 "Loan Application Card"
{
    Caption = 'Loan Application Card';
    PageType = Card;
    SourceTable = "Loan Application";
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group("Member Information")
            {
                Caption = 'Member Information';

                field("Member ID"; Rec."Member ID")
                {
                    ToolTip = 'Select the member applying for the loan. Only active members appear.';
                }
                field("Member Name"; Rec."Member Name")
                {
                    ToolTip = 'Name of the member (filled automatically).';
                }
            }
            group("Loan Details")
            {
                Caption = 'Loan Details';

                field("Loan Amount"; Rec."Loan Amount")
                {
                    ToolTip = 'The amount of money the member wants to borrow.';
                }
                field("Interest Rate (%)"; Rec."Interest Rate (%)")
                {
                    ToolTip = 'Annual interest rate (e.g., 12 means 12% per year).';
                }
                field("Loan Term (Months)"; Rec."Loan Term (Months)")
                {
                    ToolTip = 'How many months to repay the loan.';
                }
                field("Loan Purpose"; Rec."Loan Purpose")
                {
                    ToolTip = 'Why the member needs this loan (e.g., School fees, Business, Emergency).';
                    MultiLine = true;
                    // MultiLine = true shows a bigger text box
                }
            }
            
            group(General)
            {
                Caption = 'General';

                field("Loan Application No."; Rec."Loan Application No.")
                {
                    ToolTip = 'Auto-generated loan application number.';
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Current status of the loan application.';
                    StyleExpr = StatusStyle;
                }
                field("Application Date"; Rec."Application Date")
                {
                    ToolTip = 'Date when this loan application was created.';
                }
                field("Approval Date"; Rec."Approval Date")
                {
                    ToolTip = 'Date when this loan was approved.';
                }
                field("Disbursement Date"; Rec."Disbursement Date")
                {
                    ToolTip = 'Date when the loan was posted/disbursed.';
                }
                field(Posted; Rec.Posted)
                {
                    ToolTip = 'Indicates whether this loan has been posted to the General Ledger.';
                }
            }

            group("Payment Summary")
            {
                Caption = 'Payment Summary (Calculated Automatically)';

                field("Monthly Payment"; Rec."Monthly Payment")
                {
                    ToolTip = 'How much the member pays each month. Calculated automatically.';
                }
                field("Total Interest"; Rec."Total Interest")
                {
                    ToolTip = 'Total interest over the loan period. Calculated automatically.';
                }
                field("Total Repayment"; Rec."Total Repayment")
                {
                    ToolTip = 'Total amount to be repaid (Loan Amount + Total Interest).';
                }
            }

            group("Rejection Information")
            {
                Caption = 'Rejection Information';
                Visible = (Rec.Status = Enum::"Loan Application Status"::Rejected);

                field("Rejection Reason"; Rec."Rejection Reason")
                {
                    ToolTip = 'The reason why this loan was rejected.';
                    MultiLine = true;
                }
            }

            group("Posting Information")
            {
                Caption = 'Posting Information';
                Visible = Rec.Posted;

                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'The General Ledger document number created when this loan was posted.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SubmitForApproval)
            {
                Caption = 'Submit for Approval';
                ToolTip = 'Submit this loan application for review by a loan officer.';
                Image = SendApprovalRequest;
                Enabled = (Rec.Status = Enum::"Loan Application Status"::Open);

                trigger OnAction()
                var
                    LoanMgt: Codeunit "Loan Management";
                begin
                    LoanMgt.SubmitForApproval(Rec);
                    CurrPage.Update(false);
                end;
            }

            action(Approve)
            {
                Caption = 'Approve & Disburse';
                ToolTip = 'Approve this loan and automatically disburse it (post to General Ledger). This is a single-step process.';
                Image = Approve;
                Enabled = (Rec.Status = Enum::"Loan Application Status"::"Pending Approval");

                trigger OnAction()
                var
                    LoanMgt: Codeunit "Loan Management";
                begin
                    if not Confirm('Are you sure you want to approve AND disburse loan %1?\\Amount: %2\\This will post to the General Ledger and cannot be undone.',
                        false, Rec."Loan Application No.", Rec."Loan Amount") then
                        exit;
                    LoanMgt.ApproveLoan(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(Reject)
            {
                Caption = 'Reject';
                ToolTip = 'Reject this loan application. You must provide a reason.';
                Image = Reject;
                Enabled = (Rec.Status = Enum::"Loan Application Status"::"Pending Approval");

                trigger OnAction()
                var
                    LoanMgt: Codeunit "Loan Management";
                    RejectionReason: Text[250];
                begin
                    RejectionReason := '';
                    if RejectionReason = '' then begin
                        if not Confirm('Are you sure you want to reject loan %1?',
                            false, Rec."Loan Application No.") then
                            exit;
                        RejectionReason := 'Loan application rejected by officer';
                    end;

                    LoanMgt.RejectLoan(Rec, RejectionReason);
                    CurrPage.Update(false);
                end;
            }
        }


        area(Navigation)
        {
            action(LoanLedgerEntries)
            {
                Caption = 'Loan Ledger Entries';
                ToolTip = 'View the ledger entries for this loan.';
                Image = LedgerEntries;
                RunObject = page "Loan Ledger Entries";
                RunPageLink = "Loan Application No." = field("Loan Application No.");
            }
        }

        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';
                actionref(SubmitForApproval_Promoted; SubmitForApproval) { }
                actionref(Approve_Promoted; Approve) { }
                actionref(Reject_Promoted; Reject) { }
            }
            group(Category_Navigate)
            {
                Caption = 'Navigate';
                actionref(LoanLedgerEntries_Promoted; LoanLedgerEntries) { }
            }
        }
    }
    var
        StatusStyle: Text;

    trigger OnAfterGetRecord()
    begin
        case Rec.Status of
            Enum::"Loan Application Status"::Open:
                StatusStyle := 'Standard';
            Enum::"Loan Application Status"::"Pending Approval":
                StatusStyle := 'Attention';
            Enum::"Loan Application Status"::Approved:
                StatusStyle := 'Favorable';
            Enum::"Loan Application Status"::Rejected:
                StatusStyle := 'Unfavorable';
            Enum::"Loan Application Status"::Disbursed:
                StatusStyle := 'Favorable';
        end;
    end;
}
