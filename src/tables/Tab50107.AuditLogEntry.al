// ============================================================
// Table 50107 - Audit Log Entry
// ============================================================
// PURPOSE: Records ALL bulk operations performed on loan applications
// for compliance, audit, and historical tracking.
//
// WHAT IT TRACKS:
// - WHO initiated the bulk operation (user ID)
// - WHEN it was run (date and time)
// - What operation was performed (Bulk Approve, etc.)
// - HOW MANY records were selected, approved, skipped
// - Summary description of results
//
// WHY WE NEED THIS:
// - Compliance: Show all changes made to system
// - Audit: Who changed what and when
// - Transparency: Management can see bulk operation history
// - Recovery: If something goes wrong, we know who/when/what
// ============================================================

table 50107 "Audit Log Entry"
{
    Caption = 'Audit Log Entry';
    DataClassification = ToBeClassified;
    LookupPageId = "Audit Log Entries";
    DrillDownPageId = "Audit Log Entries";

    fields
    {
        // ---------- IDENTIFICATION ----------
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            // AutoIncrement means BC automatically assigns 1, 2, 3, etc.
            // Each audit entry gets a unique number
        }

        // ---------- WHO & WHEN ----------
        field(2; "User ID"; Code[50])
        {
            Caption = 'User ID';
            Editable = false;
            // Automatically filled by system (who is logged in)
        }

        field(3; "Operation Date"; DateTime)
        {
            Caption = 'Operation Date';
            Editable = false;
            // Automatically filled by system (current date/time)
        }

        // ---------- WHAT OPERATION ----------
        field(4; "Operation Type"; Enum "Bulk Operation Type")
        {
            Caption = 'Operation Type';
            Editable = false;
            // Examples: "Bulk Approve", "Bulk Reject", etc.
        }

        // ---------- SUMMARY COUNTS ----------
        field(5; "Total Selected"; Integer)
        {
            Caption = 'Total Selected';
            Editable = false;
            // How many records user selected
            // e.g., 10
        }

        field(6; "Approved Count"; Integer)
        {
            Caption = 'Approved Count';
            Editable = false;
            // How many were successfully processed
            // e.g., 8
        }

        field(7; "Skipped Count"; Integer)
        {
            Caption = 'Skipped Count';
            Editable = false;
            // How many were skipped (validation errors)
            // e.g., 2 (missing member, wrong status)
        }

        // ---------- DESCRIPTION & NOTES ----------
        field(8; "Description"; Text[500])
        {
            Caption = 'Description';
            Editable = false;
            // Example:
            // "Bulk approved 8 loans, skipped 2 (already disbursed)"
        }

        field(9; "Success"; Boolean)
        {
            Caption = 'Success';
            Editable = false;
            // TRUE if all selected records were approved
            // FALSE if some were skipped
        }
    }

    keys
    {
        // Primary Key - every table needs one
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        // Secondary keys help with filtering and sorting
        key(SK1; "User ID") { }
        key(SK2; "Operation Date") { }
        key(SK3; "Operation Type") { }
    }
}
