// ============================================================
// Permission Set 50130 - CORETEC-TELLER
// ============================================================
// PURPOSE: Basic SACCO Teller role with read/update access to members
//          and loan applications. No delete, no access to setup pages.
//
// PRINCIPLE: Least Privilege Access
//   - Tellers can process daily member and loan operations
//   - Cannot delete master data (audit trail / data integrity)
//   - Cannot modify setup or configuration
//   - Cannot send bulk emails or change system settings
//
// WORKFLOW COVERAGE:
//   ✓ View member list and details
//   ✓ Update member information (contact, status)
//   ✓ View and update loan applications (submit, track)
//   ✓ Cannot approve/reject loans (Manager only)
//   ✓ Cannot configure member categories or setup
//   ✓ Cannot delete members or applications
// ============================================================

permissionset 50130 "CORETEC-TELLER"
{
    Assignable = true;
    Caption = 'CORETEC Teller';

    Permissions =
        // Member Application
        table "Member Application" = X,
        page "Member Application List" = X,
        page "Member Application Card" = X,

        // Member
        table "Member" = X,
        page "Member List" = X,
        page "Member Card" = X,
        page "Member Edit Card" = X,

        // Member Category (Read-only access via dropdowns)
        table "Member Category Master" = X,
        page "Member Category List" = X,
        page "Member Category Card" = X,

        // Loan Application
        table "Loan Application" = X,
        page "Loan Application List" = X,
        page "Loan Application Card" = X,

        // Loan Ledger Entry (View-only)
        table "Loan Ledger Entry" = X,
        page "Loan Ledger Entries" = X,

        // SMS Log (View-only)
        table "SMS Log" = X,
        page "SMS Log List" = X,

        // Occupation (Read-only via dropdowns)
        table "Occupation" = X,
        page "Occupation List" = X,
        page "Occupation Card" = X,

        // Dashboard (Analytics view)
        page "Member Dashboard" = X,
        page "Member Loans Part" = X;
}
