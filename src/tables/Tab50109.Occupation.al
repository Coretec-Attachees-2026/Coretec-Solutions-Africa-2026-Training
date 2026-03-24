// ============================================================
// Table 50109 - Occupation Master
// ============================================================
// PURPOSE: Stores the list of occupations that members can select from.
//
// HOW IT'S USED:
//   When creating/editing a Member, the "Occupation Code" field
//   has a TableRelation to this table.
//   This creates a dropdown showing all active occupations.
//
// FIELDS:
//   Code - Unique identifier (e.g., TEA for Teacher)
//   Description - Full occupation name (e.g., Teacher)
//   Active - Only active occupations show in dropdowns
//
// DATA SETUP:
//   The Install Codeunit (50103) automatically seeds
//   10 common occupations when the extension is installed.
// ============================================================

table 50109 "Occupation"
{
    Caption = 'Occupation';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
            // Unique identifier for each occupation
            // Examples: TEA, NUR, FAR, ENG, ACC, LAW, DOC, ART, TRA, OTH
        }
        field(2; "Description"; Text[100])
        {
            Caption = 'Description';
            // Full name of the occupation (e.g., "Teacher", "Nurse")
        }
        field(3; "Active"; Boolean)
        {
            Caption = 'Active';
            InitValue = true;
            // Only active occupations show in member dropdowns
            // Set to false to hide old occupations
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
        key(SK1; "Active", "Description")
        {
            // Allows filtering: Show only active, sorted by description
        }
    }
}
