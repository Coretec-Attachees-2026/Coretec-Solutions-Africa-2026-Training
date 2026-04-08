// ============================================================
// Table 50107 - Loan Application Audit Log
// ============================================================
// PURPOSE: Records all status changes made to loan applications
//          (both manual and bulk operations).
//
// FIELDS:
//   1. Entry No              → Auto-incremented unique ID
//   2. Loan Application No.  → Which loan was changed
//   3. Old Status            → Previous status
//   4. New Status            → Status after change
//   5. Change Date & Time    → When it happened
//   6. User ID               → Who made the change
//   7. Action Type           → "Bulk Action" or "Manual"
//   8. Batch ID              → Groups related bulk changes
//   9. Notes / Reason        → Why the change was made
// ============================================================

table 50107 "Loan Application Audit Log"
{
    Caption = 'Loan Application Audit Log';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No"; Integer)
        {
            Caption = 'Entry No';
            AutoIncrement = true;
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(2; "Loan Application No."; Code[20])
        {
            Caption = 'Loan Application No.';
            DataClassification = CustomerContent;
            TableRelation = "Loan Application"."Loan Application No.";
        }

        field(3; "Old Status"; Enum "Loan Application Status")
        {
            Caption = 'Old Status';
            DataClassification = CustomerContent;
        }

        field(4; "New Status"; Enum "Loan Application Status")
        {
            Caption = 'New Status';
            DataClassification = CustomerContent;
        }

        field(5; "Change Date & Time"; DateTime)
        {
            Caption = 'Change Date & Time';
            DataClassification = SystemMetadata;
            Editable = false;
        }

        field(6; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
        }

        field(7; "Action Type"; Option)
        {
            Caption = 'Action Type';
            OptionMembers = "Manual Change","Bulk Update";
            OptionCaption = 'Manual Change,Bulk Update';
            DataClassification = SystemMetadata;
        }

        field(8; "Batch ID"; Code[20])
        {
            Caption = 'Batch ID';
            DataClassification = SystemMetadata;
            // Groups multiple records from same bulk action
        }

        field(9; "Notes"; Text[250])
        {
            Caption = 'Notes / Reason';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No")
        {
            Clustered = true;
        }
        key(SK1; "Loan Application No.") { }
        key(SK2; "Change Date & Time") { }
        key(SK3; "User ID") { }
        key(SK4; "Batch ID") { }
    }
}
