// ============================================================
// Enum 50103 - Bulk Operation Type
// ============================================================
// PURPOSE: Defines the types of bulk operations that can be performed
//
// VALUES:
// - "Bulk Approve" = Approve and disburse multiple loans
// - "Bulk Reject" = Reject multiple loans (future)
// - "Bulk Status Change" = Change status in bulk (future)
// ============================================================

enum 50103 "Bulk Operation Type"
{
    Extensible = true;

    value(1; "Bulk Approve")
    {
        Caption = 'Bulk Approve';
    }
    value(2; "Bulk Reject")
    {
        Caption = 'Bulk Reject';
    }
    value(3; "Bulk Status Change")
    {
        Caption = 'Bulk Status Change';
    }
}
