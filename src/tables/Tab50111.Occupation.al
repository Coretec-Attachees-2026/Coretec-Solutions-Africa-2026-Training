// ============================================================
// Table 50111 - Occupation
// ============================================================
// PURPOSE: Stores occupation/profession lookup values.
//
// WHY A MASTER TABLE?
//   - Members need to specify their occupation (job type)
//   - Instead of free text entry (inconsistent), we use a dropdown
//   - This ensures data consistency and enables better reporting
//
// EXAMPLES:
//   Teacher, Nurse, Farmer, Engineer, Accountant, Manager,
//   Student, Retired, Self-Employed, Unemployed, etc.
//
// These occupations are seeded when the extension is installed
// (see Codeunit 50103 - Member Application Install).
//
// KEY CONCEPT - Code[20]:
//   Code[20] = uppercase auto-formatting, max 20 characters
//   Perfect for dropdown keys (e.g., TEACHER, NURSE, FARMER)
//
// KEY CONCEPT - InitValue = true:
//   New occupations are automatically set to Active
// ============================================================

table 50111 "Occupation"
{
    Caption = 'Occupation';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            // Short identifier like TEACHER, NURSE, FARMER, etc.
            // Code[20] = uppercase, max 20 characters
        }
        field(2; "Description"; Text[100])
        {
            Caption = 'Description';
            // Full description: "Teacher in Primary School", "Registered Nurse", etc.
        }
        field(3; "Active"; Boolean)
        {
            Caption = 'Active';
            InitValue = true;
            // Boolean = true/false (yes/no)
            // InitValue = true means new occupations are active by default
            // Inactive occupations won't appear in member dropdown selections
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
            // Each occupation has a unique Code as its primary key
        }
    }
}
