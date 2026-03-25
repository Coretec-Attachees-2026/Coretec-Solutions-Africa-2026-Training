// ============================================================
// Table 50108 - Occupation
// ============================================================
// PURPOSE: Stores the list of valid occupations for SACCO members.
//
// WHY A MASTER TABLE?
//   Instead of letting users type free-form text (which leads to
//   duplicates like "Software Engineer", "Software Eng", "SW Engineer"),
//   we maintain a controlled list they pick from.
//   This makes reporting, filtering, and analytics reliable.
//
// LINKED FROM:
//   - Member table (field "Occupation Code") via TableRelation
//   - Member Card page shows a lookup dropdown
//
// DEFAULT OCCUPATIONS:
//   Seeded by Cod50101 MemberCategoryInit during installation.
//   Admins can add more or mark existing ones inactive.
//
// KEY CONCEPT - "DrillDownPageId / LookupPageId":
//   These tell BC which page to open when the user clicks on
//   a field that has TableRelation = "Occupation". The lookup
//   page is the Occupation List.
// ============================================================

table 50108 "Occupation"
{
    Caption = 'Occupation';
    DataClassification = ToBeClassified;
    DrillDownPageId = "Occupation List";
    LookupPageId = "Occupation List";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            // Short uppercase code, e.g. TEACHER, ENGINEER, FARMER
            // Code[20] = uppercase, max 20 characters, no leading/trailing spaces
        }
        field(2; "Description"; Text[100])
        {
            Caption = 'Description';
            // Human-readable name, e.g. 'Secondary School Teacher'
        }
        field(3; "Active"; Boolean)
        {
            Caption = 'Active';
            InitValue = true;
            // InitValue = true → new occupations are Active by default.
            // Inactive occupations are hidden from member lookups.
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }

    // -------------------------------------------------------
    // OnDelete – prevent removing occupations still in use
    // -------------------------------------------------------
    trigger OnDelete()
    var
        Member: Record "Member";
    begin
        // Block deletion when members still reference this occupation
        Member.SetRange("Occupation Code", Code);
        if not Member.IsEmpty() then
            Error('Cannot delete occupation %1 because members are still assigned to it. ' +
                  'Mark it as Inactive instead.', Code);
    end;
}
