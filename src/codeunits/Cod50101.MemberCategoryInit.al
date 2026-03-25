// ============================================================
// Codeunit 50101 - Member Category Initialization
// ============================================================
// PURPOSE: Pre-creates default member categories AND default
//          occupations when the extension is first installed.
//
// CHANGE LOG:
//   - Added InsertDefaultOccupations() called from
//     OnInstallAppPerCompany so occupation data is ready
//     alongside member categories.
//
// DEFAULT OCCUPATIONS SEEDED:
//   TEACHER, NURSE, DOCTOR, ENGINEER, FARMER, BUSINESS,
//   DRIVER, ACCOUNTANT, LAWYER, STUDENT, RETIRED, OTHER
// ============================================================

codeunit 50101 "Member Category Initialization"
{
    SubType = Install;

    trigger OnInstallAppPerCompany()
    begin
        InsertDefaultCategories();
        InsertDefaultOccupations();  // ← NEW
    end;

    // -------------------------------------------------------
    // InsertDefaultCategories
    // -------------------------------------------------------
    local procedure InsertDefaultCategories()
    var
        MemberCategory: Record "Member Category Master";
    begin
        if MemberCategory.FindFirst() then
            exit;

        InsertCategory('REGULAR',       'Regular Member - Employed Individual');
        InsertCategory('STUDENT',       'Student Member - Full-time Student');
        InsertCategory('BUSINESS',      'Business Member - Self-employed/Entrepreneur');
        InsertCategory('SENIOR',        'Senior Member - Retired/Elderly');
        InsertCategory('GROUP',         'Group Member - Small Group/Association');
        InsertCategory('INSTITUTIONAL', 'Institutional Member - Organization/Company');
        InsertCategory('DORMANT',       'Dormant Member - Inactive Account');

        if GuiAllowed then
            Message('Member Categories initialized successfully.');
    end;

    local procedure InsertCategory(CategoryCode: Code[20]; CategoryDesc: Text[100])
    var
        MemberCategory: Record "Member Category Master";
    begin
        // KEY FIX: Insert() is VOID in AL — it cannot be used in an if-condition.
        // Correct pattern: check with Get() first; only Insert() if the record is absent.
        if MemberCategory.Get(CategoryCode) then
            exit;

        MemberCategory.Init();
        MemberCategory."Code"        := CategoryCode;
        MemberCategory."Description" := CategoryDesc;
        MemberCategory."Active"      := true;
        MemberCategory.Insert();   // void procedure — no return value
    end;

    // -------------------------------------------------------
    // InsertDefaultOccupations  (NEW – Task E)
    // -------------------------------------------------------
    // Creates 12 common occupations to seed the Occupation table.
    // Admins can add more or deactivate any of these from the
    // Occupation List page.
    // -------------------------------------------------------
    local procedure InsertDefaultOccupations()
    var
        Occupation: Record "Occupation";
    begin
        // If occupations already exist (e.g. re-install), skip
        if Occupation.FindFirst() then
            exit;

        InsertOccupation('TEACHER',     'Teacher / Educator');
        InsertOccupation('NURSE',       'Nurse / Clinical Officer');
        InsertOccupation('DOCTOR',      'Medical Doctor / Physician');
        InsertOccupation('ENGINEER',    'Engineer / Technician');
        InsertOccupation('FARMER',      'Farmer / Agriculturalist');
        InsertOccupation('BUSINESS',    'Business Owner / Entrepreneur');
        InsertOccupation('DRIVER',      'Driver / Transport Operator');
        InsertOccupation('ACCOUNTANT',  'Accountant / Finance Officer');
        InsertOccupation('LAWYER',      'Lawyer / Legal Practitioner');
        InsertOccupation('STUDENT',     'Student / Intern');
        InsertOccupation('RETIRED',     'Retired / Pensioner');
        InsertOccupation('OTHER',       'Other / Not Listed');

        if GuiAllowed then
            Message('Default Occupations initialized successfully.');
    end;

    local procedure InsertOccupation(OccCode: Code[20]; OccDesc: Text[100])
    var
        Occupation: Record "Occupation";
    begin
        // KEY FIX: Insert() is VOID in AL — cannot be used in an if-condition.
        // Check with Get() first; only Insert() if the record is absent.
        if Occupation.Get(OccCode) then
            exit;

        Occupation.Init();
        Occupation."Code"        := OccCode;
        Occupation."Description" := OccDesc;
        Occupation."Active"      := true;
        Occupation.Insert();   // void procedure — no return value
    end;
}
