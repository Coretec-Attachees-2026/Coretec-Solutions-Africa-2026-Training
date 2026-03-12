// ============================================================
// Page 50111 - Loan Repayment Input
// ============================================================
// PURPOSE: A simple input dialog for entering a loan repayment amount.
//          Used by the Record Repayment action on the Loan Application Card.
// ============================================================

page 50111 "Loan Repayment Input"
{
    Caption = 'Enter Repayment Amount';
    PageType = StandardDialog;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(Input)
            {
                Caption = 'Repayment Details';

                field(PaymentAmountField; PaymentAmount)
                {
                    Caption = 'Payment Amount';
                    ToolTip = 'Enter the amount the member is paying.';
                    MinValue = 0;
                }
            }
        }
    }

    var
        PaymentAmount: Decimal;

    procedure GetPaymentAmount(): Decimal
    begin
        exit(PaymentAmount);
    end;

    procedure SetPaymentAmount(Amount: Decimal)
    begin
        PaymentAmount := Amount;
    end;
}
