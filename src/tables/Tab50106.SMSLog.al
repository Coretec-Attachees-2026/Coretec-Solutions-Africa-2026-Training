// ============================================================
// Table 50102 - SMS Log
// ============================================================
// PURPOSE: Records every SMS sent from Business Central.
//          Useful for audit trails, debugging, and reports.
//
// FIELDS:
//   1. Entry No       → Auto-incremented unique ID per log entry
//   2. Phone Number   → Who the SMS was sent to
//   3. Message        → What was sent
//   4. Status         → Sent or Failed
//   5. Sent DateTime  → Exactly when it was sent
//   6. Application ID → Which application triggered the SMS
//   7. Member Name    → Who the member is
//   8. Error Message  → If failed, why it failed
// ============================================================

table 50106 "SMS Log"
{
    Caption = 'SMS Log';
    DataClassification = CustomerContent;

    fields
    {
        // Auto-incremented primary key
        // KEY CONCEPT - AutoIncrement:
        //   BC automatically assigns the next number.
        //   You never set this manually.
        field(1; "Entry No"; Integer)
        {
            Caption = 'Entry No';
            AutoIncrement = true;
            DataClassification = CustomerContent;
        }

        field(2; "Phone Number"; Text[20])
        {
            Caption = 'Phone Number';
            DataClassification = CustomerContent;
        }

        field(3; "Message"; Text[250])
        {
            Caption = 'Message';
            DataClassification = CustomerContent;
        }

        // KEY CONCEPT - Option vs Enum:
        //   We use a simple Option here for Status.
        //   Sent = SMS was delivered successfully
        //   Failed = Something went wrong
        field(4; "Status"; Option)
        {
            Caption = 'Status';
            OptionMembers = Sent,Failed;
            OptionCaption = 'Sent,Failed';
            DataClassification = CustomerContent;
        }

        field(5; "Sent DateTime"; DateTime)
        {
            Caption = 'Sent Date/Time';
            DataClassification = CustomerContent;
        }

        field(6; "Application ID"; Code[20])
        {
            Caption = 'Application ID';
            DataClassification = CustomerContent;
        }

        field(7; "Member Name"; Text[100])
        {
            Caption = 'Member Name';
            DataClassification = CustomerContent;
        }

        // Only filled in when Status = Failed
        field(8; "Error Message"; Text[250])
        {
            Caption = 'Error Message';
            DataClassification = CustomerContent;
        }

        // Which event triggered this SMS
        // e.g. "Application Approved", "Application Rejected"
        field(9; "Triggered By"; Text[100])
        {
            Caption = 'Triggered By';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        // Primary key — Entry No uniquely identifies each log
        key(PK; "Entry No")
        {
            Clustered = true;
        }

        // Secondary key — lets you filter logs by date quickly
        key(K1; "Sent DateTime") { }

        // Secondary key — lets you find all SMS for one application
        key(K2; "Application ID") { }
    }
}
