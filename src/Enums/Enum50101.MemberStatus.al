// ============================================================
// Enum 50101 - Member Status
// ============================================================
// PURPOSE: Defines the possible states a SACCO member can be in.
//
// Unlike the APPLICATION status (which tracks the signup process),
// this tracks the member's status AFTER they've been approved.
//
// STATUS MEANINGS:
// "Active"    = Member is in good standing, can use all services
// "Inactive"  = Member hasn't used their account for a while
// "Suspended" = Member temporarily blocked (e.g., unpaid dues)
// "Closed"    = Member has left the SACCO permanently
//
// LIFECYCLE:
//   Active → Inactive (no activity)
//   Active → Suspended (rule violation or unpaid debts)
//   Active → Closed (member requests to leave)
//   Inactive → Active (member becomes active again)
//   Suspended → Active (issue resolved)
// ============================================================

enum 50101 "Member Status"
{
    Extensible = true;

    value(0; Active)
    {
        Caption = 'Active';       // Default state for new members
    }
    value(1; Inactive)
    {
        Caption = 'Inactive';     // Dormant account
    }
    value(2; Suspended)
    {
        Caption = 'Suspended';    // Temporarily blocked
    }
    value(3; Closed)
    {
        Caption = 'Closed';       // Permanently closed
    }
}
