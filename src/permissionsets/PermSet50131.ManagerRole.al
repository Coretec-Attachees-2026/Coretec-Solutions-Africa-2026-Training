// ============================================================
// Permission Set 50131 - CORETEC-MANAGER
// ============================================================
// PURPOSE: Full SACCO Manager role with complete operational access.
//          Inherits all Teller permissions via IncludedPermissionSets,
//          then adds Manager-only objects on top.
//
// PRINCIPLE: Elevated Privilege with Governance
//   - Managers oversee all member and loan operations
//   - Can approve/reject loans and member applications
//   - Can manage system configuration and setup
//   - Can send bulk emails and SMS
//   - Can access Members API for integrations
//   - Responsible for data governance
//
// WORKFLOW COVERAGE:
//   ✓ All Teller permissions (inherited from CORETEC-TELLER)
//   ✓ Approve/reject member applications
//   ✓ Approve/reject loan applications
//   ✓ Configure member setup
//   ✓ Manage email preview / notifications
//   ✓ Access Members API for integrations
//
// NOTE ON LEAST-PRIVILEGE:
//   BC AL only allows = X for custom extension objects.
//   Teller vs Manager action restrictions (e.g. approve/reject)
//   are enforced inside page/codeunit AL code using role checks,
//   not at the permission set level.
// ============================================================

permissionset 50131 "CORETEC-MANAGER"
{
    Assignable = true;
    Caption = 'CORETEC Manager';

    // Inherit everything from the Teller role.
    // No need to repeat Member, Loan, SMS, Occupation etc.
    IncludedPermissionSets = "CORETEC-TELLER";

    Permissions =
        // Member Setup (Manager ONLY - not in Teller)
        table "Member Setup" = X,
        page "Member Setup" = X,

        // Email Preview (Manager setup for notifications)
        page "Email Preview Dialog" = X,

        // Members API (Integration oversight - Manager ONLY)
        page "Members API" = X;
}
