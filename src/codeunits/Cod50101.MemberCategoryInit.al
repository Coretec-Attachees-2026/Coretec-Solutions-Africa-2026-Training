// ============================================================
// Codeunit 50101 - Member Category Initialization
// ============================================================
// PURPOSE: Pre-creates default member categories when the
//          extension is first installed.
//
// KEY CONCEPT - "SubType = Install":
//   This tells BC to run this codeunit AUTOMATICALLY when the
//   extension is installed. No one needs to click a button —
//   the categories just appear ready to use.
//
// KEY CONCEPT - "OnInstallAppPerCompany":
//   This trigger runs once PER COMPANY during installation.
//   (Business Central can have multiple companies in one database)
//
// WHY PRE-CREATE CATEGORIES?
//   Instead of making the admin type all categories manually,
//   we set up sensible defaults. They can add/edit more later.
//
// WHAT GETS CREATED:
//   REGULAR       = Employed Individual
//   STUDENT       = Full-time Student  
//   BUSINESS      = Self-employed/Entrepreneur
//   SENIOR        = Retired/Elderly
//   GROUP         = Small Group/Association
//   INSTITUTIONAL = Organization/Company
//   DORMANT       = Inactive Account
// ============================================================

codeunit 50101 "Member Category Initialization"
{
    SubType = Install;  // Runs automatically during installation

    // This trigger fires when the extension is installed per company
    trigger OnInstallAppPerCompany()
    begin
        InsertDefaultCategories();
    end;

    // -------------------------------------------------------
    // InsertDefaultCategories
    // -------------------------------------------------------
    // Creates 7 default member categories.
    // If categories already exist (re-install), it skips to avoid duplicates.
    //
    // PATTERN USED:
    //   1. Init() - prepare an empty record
    //   2. Set the fields
    //   3. Insert() - save to database
    //   Repeat for each category
    // -------------------------------------------------------
    local procedure InsertDefaultCategories()
    var
        MemberCategory: Record "Member Category Master";
    begin
        // Safety check: if categories already exist, don't create duplicates
        if MemberCategory.FindFirst() then
            exit;  // exit = stop here, don't run the rest

        // --- Category 1: Regular Member ---
        MemberCategory.Init();           // Prepare empty record
        MemberCategory."Code" := 'REGULAR';
        MemberCategory."Description" := 'Regular Member - Employed Individual';
        MemberCategory."Active" := true;
        MemberCategory.Insert();         // Save to database

        // --- Category 2: Student Member ---
        MemberCategory.Init();
        MemberCategory."Code" := 'STUDENT';
        MemberCategory."Description" := 'Student Member - Full-time Student';
        MemberCategory."Active" := true;
        MemberCategory.Insert();

        // --- Category 3: Business Member ---
        MemberCategory.Init();
        MemberCategory."Code" := 'BUSINESS';
        MemberCategory."Description" := 'Business Member - Self-employed/Entrepreneur';
        MemberCategory."Active" := true;
        MemberCategory.Insert();

        // --- Category 4: Senior Member ---
        MemberCategory.Init();
        MemberCategory."Code" := 'SENIOR';
        MemberCategory."Description" := 'Senior Member - Retired/Elderly';
        MemberCategory."Active" := true;
        MemberCategory.Insert();

        // --- Category 5: Group Member ---
        MemberCategory.Init();
        MemberCategory."Code" := 'GROUP';
        MemberCategory."Description" := 'Group Member - Small Group/Association';
        MemberCategory."Active" := true;
        MemberCategory.Insert();

        // --- Category 6: Institutional Member ---
        MemberCategory.Init();
        MemberCategory."Code" := 'INSTITUTIONAL';
        MemberCategory."Description" := 'Institutional Member - Organization/Company';
        MemberCategory."Active" := true;
        MemberCategory.Insert();

        // --- Category 7: Dormant Member ---
        MemberCategory.Init();
        MemberCategory."Code" := 'DORMANT';
        MemberCategory."Description" := 'Dormant Member - Inactive Account';
        MemberCategory."Active" := true;
        MemberCategory.Insert();

        // Let the admin know it worked (only if there's a GUI session)
        if GuiAllowed then
            Message('Member Categories initialized successfully');
    end;
}
