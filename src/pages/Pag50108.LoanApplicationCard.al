// ============================================================
// Page 50108 - Loan Application Card
// ============================================================
// PURPOSE: The main form where users view and edit ONE loan application.
//
// KEY CONCEPT - "PageType = Card":
//   A Card page displays a single record (like a detailed form).
//   Compare this to a List page which shows many records in a grid.
//
// KEY CONCEPT - "SourceTable":
//   This tells BC which table's data to show on this page.
//   The special variable "Rec" automatically refers to the current record.
//
// KEY CONCEPT - "Actions":
//   Actions are buttons that appear in the ribbon/toolbar.
//   Each action calls a procedure in our Loan Management codeunit.
//   We use "Enabled" property to show/hide buttons based on status.
//
// WORKFLOW ON THIS PAGE (simplified - just 3 steps!):
//   1. User creates new loan → fills in Member ID, Amount, Term, Rate, Purpose
//   2. Clicks "Submit for Approval" → status changes to Pending Approval
//   3. Loan officer clicks "Approve" (automatically posts to G/L!) or "Reject"
//   That's it! No separate "Post" step needed.
// ============================================================

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
            // ---- GENERAL INFO GROUP ----
            // Shows the loan number, status, and dates
            group(General)
            {
                Caption = 'General';

                field("Loan Application No."; Rec."Loan Application No.")
                {
                    ToolTip = 'Auto-generated loan application number.';
                    // Editable = false is set on the table field
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Current status of the loan application.';
                    // Shows a colored indicator based on status
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

            // ---- MEMBER INFO GROUP ----
            // Who is applying for the loan?
            group("Member Information")
            {
                Caption = 'Member Information';

                field("Member ID"; Rec."Member ID")
                {
                    ToolTip = 'Select the member applying for the loan. Only active members appear.';
                    // When user picks a member, the OnValidate trigger
                    // on the table automatically fills in Member Name
                }
                field("Member Name"; Rec."Member Name")
                {
                    ToolTip = 'Name of the member (filled automatically).';
                }
            }

            // ---- LOAN DETAILS GROUP ----
            // The core loan information
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

            // ---- CALCULATED FIELDS GROUP ----
            // These are calculated automatically when you enter Amount, Rate, and Term
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

            // ---- REJECTION INFO (only visible if rejected) ----
            group("Rejection Information")
            {
                Caption = 'Rejection Information';
                Visible = (Rec.Status = Enum::"Loan Application Status"::Rejected);
                // This group only shows when the loan is rejected

                field("Rejection Reason"; Rec."Rejection Reason")
                {
                    ToolTip = 'The reason why this loan was rejected.';
                    MultiLine = true;
                }
            }

            // ---- POSTING INFO (only visible if posted) ----
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

    // ============================================
    // ACTIONS (Buttons in the toolbar/ribbon)
    // ============================================
    // These are the buttons that drive the workflow.
    // Each button:
    //   - Has an "Enabled" condition (when can you click it?)
    //   - Calls a procedure in the Loan Management codeunit
    //   - Uses CurrPage.Update(false) to refresh the page after
    // ============================================
    actions
    {
        area(Processing)
        {
            // ---- STEP 1: Submit for Approval ----
            action(SubmitForApproval)
            {
                Caption = 'Submit for Approval';
                ToolTip = 'Submit this loan application for review by a loan officer.';
                Image = SendApprovalRequest;
                // Only enabled when loan is "Open"
                Enabled = (Rec.Status = Enum::"Loan Application Status"::Open);

                trigger OnAction()
                var
                    LoanMgt: Codeunit "Loan Management";
                begin
                    LoanMgt.SubmitForApproval(Rec);
                    CurrPage.Update(false);
                    // CurrPage.Update(false) refreshes the page to show the new status
                    // The "false" means don't re-trigger any validation
                end;
            }

            // ---- STEP 2a: Approve & Disburse (automatic!) ----
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
                    // Confirm() shows a Yes/No dialog - returns true if user clicks Yes
                    // We warn the user that this will ALSO post to G/L
                    if not Confirm('Are you sure you want to approve AND disburse loan %1?\\Amount: %2\\This will post to the General Ledger and cannot be undone.',
                        false, Rec."Loan Application No.", Rec."Loan Amount") then
                        exit;

                    // ApproveLoan() now automatically calls PostLoan() inside it
                    LoanMgt.ApproveLoan(Rec);
                    CurrPage.Update(false);
                end;
            }

            // ---- STEP 2b: Reject ----
            action(Reject)
            {
                Caption = 'Reject';
                ToolTip = 'Reject this loan application. You must provide a reason.';
                Image = Reject;
                Enabled = (Rec.Status = Enum::"Loan Application Status"::"Pending Approval");

                trigger OnAction()
                var
                    LoanMgt: Codeunit "Loan Management";
                    ReasonDialog: Page "Rejection Reason Input";
                    RejectionReason: Text[250];
                begin
                    // Prompt the loan officer for a custom rejection reason
                    // using a StandardDialog page instead of hardcoded text
                    if ReasonDialog.RunModal() <> Action::OK then
                        exit;
                    RejectionReason := ReasonDialog.GetRejectionReason();
                    if RejectionReason = '' then
                        Error('Please provide a reason for rejection.');

                    LoanMgt.RejectLoan(Rec, RejectionReason);
                    CurrPage.Update(false);
                end;
            }

            // NOTE: The "Post Loan" button has been REMOVED.
            // Disbursement now happens automatically when you click "Approve & Disburse".
            // This simplifies the workflow from 4 steps to 3 steps:
            //   Open → Submit → Approve & Disburse (done!)

            // ---- STEP 4: Record Repayment ----
            action(RecordRepayment)
            {
                Caption = 'Record Repayment';
                ToolTip = 'Record a repayment against this loan. Posts G/L entries and updates balance.';
                Image = Payment;
                Enabled = (Rec.Status = Enum::"Loan Application Status"::Disbursed) or
                           (Rec.Status = Enum::"Loan Application Status"::"Partially Paid");

                trigger OnAction()
                var
                    LoanMgt: Codeunit "Loan Management";
                    RepaymentInput: Page "Loan Repayment Input";
                    PaymentAmount: Decimal;
                begin
                    // Default to the monthly payment amount
                    RepaymentInput.SetPaymentAmount(Rec."Monthly Payment");
                    if RepaymentInput.RunModal() <> Action::OK then
                        exit;

                    PaymentAmount := RepaymentInput.GetPaymentAmount();
                    if PaymentAmount <= 0 then
                        Error('Payment amount must be greater than zero.');

                    LoanMgt.RecordRepayment(Rec, PaymentAmount);
                    CurrPage.Update(false);
                end;
            }
        }

        // ---- NAVIGATION: Link to related pages ----
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
            action(LoanRepayments)
            {
                Caption = 'Loan Repayments';
                ToolTip = 'View all repayments for this loan.';
                Image = PaymentHistory;
                RunObject = page "Loan Repayment List";
                RunPageLink = "Loan Application No." = field("Loan Application No.");
            }
        }

        area(Promoted)
        {
            // "Promoted" actions appear as big buttons at the top of the page
            // making them easy to find
            group(Category_Process)
            {
                Caption = 'Process';
                actionref(SubmitForApproval_Promoted; SubmitForApproval) { }
                actionref(Approve_Promoted; Approve) { }
                actionref(Reject_Promoted; Reject) { }
                actionref(RecordRepayment_Promoted; RecordRepayment) { }
            }
            group(Category_Navigate)
            {
                Caption = 'Navigate';
                actionref(LoanLedgerEntries_Promoted; LoanLedgerEntries) { }
                actionref(LoanRepayments_Promoted; LoanRepayments) { }
            }
        }
    }

    // ============================================
    // STATUS STYLING
    // ============================================
    // This makes the Status field change color based on its value:
    //   Open             = Standard (normal)
    //   Pending Approval = Attention (yellow)
    //   Approved         = Favorable (green)
    //   Rejected         = Unfavorable (red)
    //   Disbursed        = Favorable (green)
    // ============================================
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
            Enum::"Loan Application Status"::"Partially Paid":
                StatusStyle := 'Attention';
            Enum::"Loan Application Status"::"Fully Paid":
                StatusStyle := 'Favorable';
        end;
    end;
}
