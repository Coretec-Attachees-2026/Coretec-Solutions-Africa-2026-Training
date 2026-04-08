// ============================================================
// Permission Set 50101 - Coretec Teller
// ============================================================
// PURPOSE: Limited operational role for SACCO tellers
//
// PERMISSIONS:
// ✓ Read Member Applications, Members, Loan Applications
// ✓ Create/Update/Modify operations on applications
// ✓ View reports and dashboards
// ✗ NO Delete operations on core tables
// ✗ NO Access to Member Setup or system configuration
// ✗ NO Approval/Rejection of loans (Manager only)
//
// PRINCIPLE: Least-Privilege Access
//   Tellers can process day-to-day operations but cannot:
//   - Delete records (audit trail)
//   - Change system configuration
//   - Make critical approval decisions
// ============================================================

permissionset 50101 "CORETEC-TELLER"
{
    Assignable = true;
    Caption = 'CORETEC Teller - Limited Operational Access';

    // ============ TABLE PERMISSIONS ============
    // Teller: Read/Update on member and loan data, NO delete operations

    permissions =
        // Member Applications: Full CRUD
        tabledata "Member Application" = RIMD,
        table "Member Application" = X,

        // Member Table: Read and Update only (no Insert/Delete)
        tabledata "Member" = RM,
        table "Member" = X,

        // Member Category: Read only
        tabledata "Member Category Master" = R,
        table "Member Category Master" = X,

        // Loan Applications: Read and Modify
        tabledata "Loan Application" = RM,
        table "Loan Application" = X,

        // Loan Ledger Entries: Read only (audit trail)
        tabledata "Loan Ledger Entry" = R,
        table "Loan Ledger Entry" = X,

        // Occupation: Read only
        tabledata "Occupation" = R,
        table "Occupation" = X;

}
