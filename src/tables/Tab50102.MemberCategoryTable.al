// ============================================================
// Table 50102 - Member Category Master
// ============================================================
// PURPOSE: Stores the different types/categories of SACCO members.
//
// Examples:
//   REGULAR       = Employed Individual
//   STUDENT       = Full-time Student
//   BUSINESS      = Self-employed/Entrepreneur
//   SENIOR        = Retired/Elderly
//   GROUP         = Small Group/Association
//   INSTITUTIONAL = Organization/Company
//   DORMANT       = Inactive Account
//
// These categories are pre-created when the extension is installed
// (see Codeunit 50101 - Member Category Initialization).
//
// WHY HAVE CATEGORIES?
//   - Different loan limits per category
//   - Different interest rates per category
//   - Reporting: how many members per category
//   - Different services for different member types
//
// KEY CONCEPT - "InitValue":
//   InitValue = true on the "Active" field means new categories
//   are automatically set to Active when created.
// ============================================================

table 50102 "Member Category Master"
{
    Caption = 'Member Category Master';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            // Short identifier like REGULAR, STUDENT, BUSINESS
            // Code[20] = uppercase, max 20 characters
        }
        field(2; "Description"; Text[100])
        {
            Caption = 'Description';
            // Longer description explaining the category
        }
        field(3; "Active"; Boolean)
        {
            Caption = 'Active';
            InitValue = true;
            // Boolean = true/false (yes/no)
            // InitValue = true means new categories are active by default
            // Inactive categories won't appear in dropdown selections
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
            // Each category has a unique Code as its primary key
        }
    }

    // -------------------------------------------------------
    // OnDelete Trigger - Prevent deletion if category is in use
    // -------------------------------------------------------
    trigger OnDelete()
    var
        Member: Record "Member";
        MemberApp: Record "Member Application";
    begin
        Member.SetRange("Member Category", Code);
        if not Member.IsEmpty() then
            Error('Cannot delete category %1. Members are still assigned to it.', Code);

        MemberApp.SetRange("Member Category", Code);
        if not MemberApp.IsEmpty() then
            Error('Cannot delete category %1. Applications are still using it.', Code);
    end;
}
