// ============================================================
// Codeunit 50103 - Member Application Install
// ============================================================
// PURPOSE: Runs automatically when the extension is first installed.
//
// KEY CONCEPT - "SubType = Install":
//   This tells BC to run this codeunit automatically when
//   someone installs or upgrades the extension.
//
// WHY?
//   We need to make sure No. Series exist before anyone tries
//   to create a Member Application or Loan Application.
//   This auto-setup saves the admin from doing manual configuration.
// ============================================================

codeunit 50103 "Member Application Install"
{
    SubType = Install;

    trigger OnInstallAppPerCompany()
    var
        MemberAppNoSeriesMgt: Codeunit "Member App No. Series Mgt";
        LoanNoSeriesMgt: Codeunit "Loan No. Series Mgt";
    begin
        // Set up the Member Application No. Series
        MemberAppNoSeriesMgt.EnsureMemberApplicationNoSeriesAndSetup();
        // Set up the Loan Application No. Series (NEW)
        LoanNoSeriesMgt.EnsureLoanNoSeriesAndSetup();
        // Set up default occupations
        SeedDefaultOccupations();
    end;

    // ============================================================
    // Seed Default Occupations
    // ============================================================
    // PURPOSE: Inserts 10 common occupations into the Occupation table
    //          when the extension is first installed.
    //
    // OCCUPATIONS SEEDED:
    //   TEA - Teacher
    //   NUR - Nurse
    //   FAR - Farmer
    //   ENG - Engineer
    //   ACC - Accountant
    //   LAW - Lawyer
    //   DOC - Doctor
    //   ART - Artist
    //   TRA - Trader
    //   OTH - Other
    //
    // KEY CONCEPT - Duplicate Check:
    //   Before inserting, checks if occupation already exists.
    //   This prevents errors if the install runs multiple times.
    // ============================================================
    local procedure SeedDefaultOccupations()
    var
        OccupationTable: Record "Occupation";
    begin
        // Define the default occupations to seed
        InsertOccupation('TEA', 'Teacher', true);
        InsertOccupation('NUR', 'Nurse', true);
        InsertOccupation('FAR', 'Farmer', true);
        InsertOccupation('ENG', 'Engineer', true);
        InsertOccupation('ACC', 'Accountant', true);
        InsertOccupation('LAW', 'Lawyer', true);
        InsertOccupation('DOC', 'Doctor', true);
        InsertOccupation('ART', 'Artist', true);
        InsertOccupation('TRA', 'Trader', true);
        InsertOccupation('OTH', 'Other', true);
    end;

    local procedure InsertOccupation(Code: Code[20]; Description: Text[100]; Active: Boolean)
    var
        OccupationTable: Record "Occupation";
    begin
        // Check if occupation already exists
        if OccupationTable.Get(Code) then
            exit; // Already exists, skip insert

        // Create and insert the new occupation
        OccupationTable.Init();
        OccupationTable.Code := Code;
        OccupationTable.Description := Description;
        OccupationTable.Active := Active;
        OccupationTable.Insert(true);
    end;
}
