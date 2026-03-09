// ============================================================
// Enum 50102 - Loan Application Status
// ============================================================
// PURPOSE: Defines the possible states a loan can be in.
//
// WORKFLOW:  Open  →  Pending Approval  →  Approved  →  Disbursed
//                                        ↘ Rejected
//
// "Open"              = Just created, member is still filling in details
// "Pending Approval"  = Submitted for review by a loan officer
// "Approved"          = Loan officer said YES
// "Rejected"          = Loan officer said NO
// "Disbursed"         = Money has been sent out (posted to General Ledger)
// ============================================================

enum 50102 "Loan Application Status"
{
    Extensible = true;

    value(0; Open)
    {
        Caption = 'Open';
    }
    value(1; "Pending Approval")
    {
        Caption = 'Pending Approval';
    }
    value(2; Approved)
    {
        Caption = 'Approved';
    }
    value(3; Rejected)
    {
        Caption = 'Rejected';
    }
    value(4; Disbursed)
    {
        Caption = 'Disbursed';
    }
}
