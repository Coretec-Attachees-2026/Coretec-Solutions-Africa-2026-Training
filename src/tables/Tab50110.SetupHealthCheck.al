// ============================================================
// Table 50110 - Setup Health Check
// ============================================================
// PURPOSE: Temporary table to hold SACCO system health check results.
//
// This table is populated on-demand to diagnose configuration issues.
// Each row represents one system check (e.g., "Email Account", "Loan Nos.").
// The "Status" field indicates Pass (Green), Warning (Amber), or Fail (Red).
//
// WHY TEMPORARY?
//   This data isn't meant to persist - it's calculated fresh when the
//   health check page opens. Using temporary = true means:
//   - Data doesn't clutter the database
//   - Each admin sees current config state
//   - Memory is freed when the page closes
//
// KEY CONCEPT - "Temporary = true":
//   Records exist only in memory during the current session.
//   They're not written to the database.
//   Perfect for: reports, diagnostics, calculations
// ============================================================

table 50110 "Setup Health Check"
{
    Caption = 'Setup Health Check';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }

        field(2; "Check Name"; Text[100])
        {
            Caption = 'Check Name';
            // e.g., "Member Application No. Series", "Email Account Configuration", etc.
        }

        field(3; "Status"; Option)
        {
            Caption = 'Status';
            OptionMembers = "Green","Amber","Red";
            // Green  = OK, configured correctly
            // Amber  = Warning, might need attention
            // Red    = Error, must be fixed
        }

        field(4; "Details"; Text[500])
        {
            Caption = 'Details';
            // Human-readable explanation of what's wrong or what's OK
            // e.g., "Member Application No. Series 'MEM-APP' is configured"
            // e.g., "No Email Account configured (required for welcome emails)"
        }

        field(5; "Recommendation"; Text[500])
        {
            Caption = 'Recommendation';
            // What to do if Status is Red or Amber
            // e.g., "Go to Member Setup and configure 'Member Application Nos.'"
        }

        field(6; "Link Page ID"; Integer)
        {
            Caption = 'Link Page ID';
            // If we can drill down to fix it, store the page ID here
            // e.g., 50106 for Member Setup page
            // 0 = no drill-down available
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}
