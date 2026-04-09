page 50112 "Loan Application List"
{
    Caption = 'Loan Applications';
    PageType = List;
    SourceTable = "Loan Application";
    ApplicationArea = All;
    UsageCategory = Lists;
    CardPageId = "Loan Application Card";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(LoanLines)
            {
                field("Loan Application No."; Rec."Loan Application No.")
                {
                    ToolTip = 'The unique loan application number.';
                }
                field("Member ID"; Rec."Member ID")
                {
                    ToolTip = 'The member who applied for this loan.';
                }
                field("Member Name"; Rec."Member Name")
                {
                    ToolTip = 'Name of the member.';
                }
                field("Loan Amount"; Rec."Loan Amount")
                {
                    ToolTip = 'Amount requested.';
                }
                field("Interest Rate (%)"; Rec."Interest Rate (%)")
                {
                    ToolTip = 'Annual interest rate.';
                }
                field("Loan Term (Months)"; Rec."Loan Term (Months)")
                {
                    ToolTip = 'Loan duration in months.';
                }
                field("Monthly Payment"; Rec."Monthly Payment")
                {
                    ToolTip = 'Calculated monthly payment.';
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Current status of the loan.';
                    StyleExpr = StatusStyle;
                }
                field("Application Date"; Rec."Application Date")
                {
                    ToolTip = 'Date the application was created.';
                }
                field(Posted; Rec.Posted)
                {
                    ToolTip = 'Whether the loan has been posted to the G/L.';
                }
            }
        }
        // area(FactBoxes) {
        //     systempart("Reviewer Notes"; Notes) {
        //         Caption = 'Add Reviewer Notes';
        //         ApplicationArea = All;
        //     }
        // }
        // add an action to add reviewer notes instead
    }

    actions
    {
        area(Navigation)
        {
            action(LoanLedgerEntries)
            {
                Caption = 'Loan Ledger Entries';
                ToolTip = 'View all loan ledger entries.';
                Image = LedgerEntries;
                RunObject = page "Loan Ledger Entries";
            }
            action(MemberSetup)
            {
                Caption = 'Loan Setup';
                ToolTip = 'Open Member Setup to configure loan G/L accounts and No. Series.';
                Image = Setup;
                RunObject = page "Member Setup";
            }
            action(MoveApplication) {
                Caption = 'Move Application';
                Image = AdjustEntries;
                trigger OnAction()
                var
                    LoanManager: Codeunit "Loan Management";
                    SelectedRecord: Record "Loan Application";
                    ChangeCount: Integer;
                    RunObject: page "Loan Reviewer Notes";
                begin
                    if ReviewerNotesGlobal = '' then begin
                        if Confirm('You don''t have Reviwer Notes, would you like to add some?') then
                            if RunObject.RunModal() = Action::OK then begin
                                ReviewerNotesGlobal := RunObject.GetEnteredText();
                            end
                        else begin
                            Message('Approvals will be audited without reviewer notes');
                        end;
                    end;
                    CurrPage.SetSelectionFilter(SelectedRecord);
                    ChangeCount := LoanManager.RunLoanBulkActionMoveStatus(SelectedRecord, ReviewerNotesGlobal);
                    if ChangeCount <> 0 then begin
                        Message(Format(ChangeCount) + ' Loan Applications Moved');
                    end else begin
                        Message(Format(ChangeCount) + ' Loan Applications Approved Successfully');
                        CurrPage.Update();
                    end;
                end;
            }
            action("Add Reviewer Notes") {
                Caption = 'Add Reviewer Notes';
                
                trigger OnAction()
                var
                    myInt: Integer;
                    RunObject: page "Loan Reviewer Notes";
                begin
                    if RunObject.RunModal() = Action::OK then begin
                        ReviewerNotesGlobal := RunObject.GetEnteredText();
                    end;
                    
                end;
            }
        }
        area(Promoted)
        {
                actionref(LoanLedgerEntries_Promoted; LoanLedgerEntries) { }
                actionref(MemberSetup_Promoted; MemberSetup) { }
                actionref(MoveApplication_promoted; MoveApplication) {}
                actionref(AddReviewerNotes_promoted; "Add Reviewer Notes") {

                }
        }

    }
    var
        StatusStyle: Text;
        ReviewerNotesGlobal: Text;

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

// page 50121 "Reviewer Notes Part"
// {
//     PageType = ListPart;
//     ApplicationArea = All;
//     UsageCategory = Lists;
//     SourceTable = "Loan Application";
    
//     layout
//     {
//         area(Content)
//         {
//             repeater(Reviewer Notes)
//             {
//                 field(Name; NameSource)
//                 {
                    
//                 }
//             }
//         }

//     }
// }

page 50122 "Loan Reviewer Notes"
{
    PageType = PromptDialog;
    Extensible = false;
    ApplicationArea = all;
    layout {
        area(Content) {
            field("Reviewer Notes Input"; "Reviewer Notes") {

            }
        }
    }
    var
        "Reviewer Notes": Text;
    procedure GetEnteredText(): Text
    begin
        exit("Reviewer Notes");
    end;
}
