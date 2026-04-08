// ============================================================
// Permission Set 50102 - Coretec Manager
// ============================================================
// PURPOSE: Full operational and administrative role
//
// PERMISSIONS:
// ✓ All Teller permissions (RIMD on applications, RM on members)
// ✓ Full access to Member Setup and configuration
// ✓ Approval/Rejection of loan applications
// ✓ Full reporting and analytics
// ✗ Still limited by Business Logic (coded validation)
//
// PRINCIPLE: Role-Based Governance
//   Managers can approve loans, configure the system, and access
//   all operational data. However, approval must follow business
//   rules enforced in AL code.
// ============================================================

permissionset 50102 "CORETEC-MANAGER"
{
    Assignable = true;
    Caption = 'CORETEC Manager - Full Operational & Administrative Access';

    // ============ TABLE PERMISSIONS ============
    // Manager: Full RIMD access to core tables + setup pages

    permissions =
        // Member Applications: Full CRUD
        tabledata "Member Application" = RIMD,
        table "Member Application" = X,

        // Member Table: Full CRUD (includes Insert and Delete)
        tabledata "Member" = RIMD,
        table "Member" = X,

        // Member Category: Full CRUD
        tabledata "Member Category Master" = RIMD,
        table "Member Category Master" = X,

        // Member Setup: Full CRUD for configuration
        tabledata "Member Setup" = RIMD,
        table "Member Setup" = X,

        // Loan Applications: Full CRUD + approval workflows
        tabledata "Loan Application" = RIMD,
        table "Loan Application" = X,

        // Loan Ledger: Read only (immutable transaction log)
        tabledata "Loan Ledger Entry" = R,
        table "Loan Ledger Entry" = X,

        // Occupation: Manage reference data
        tabledata "Occupation" = RIMD,
        table "Occupation" = X;
}
