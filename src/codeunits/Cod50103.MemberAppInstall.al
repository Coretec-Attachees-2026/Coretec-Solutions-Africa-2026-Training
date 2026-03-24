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
        // Seed default occupations
        InitializeDefaultOccupations();
    end;

    // ============================================================
    // PROCEDURE: InitializeDefaultOccupations
    // PURPOSE: Inserts default occupation values into the Occupation table
    //
    // WHY?
    //   Instead of each user having to manually add occupations,
    //   we pre-populate common job types. Users can add more as needed.
    //
    // OCCUPATIONS SEEDED:
    //   Teacher, Nurse, Farmer, Engineer, Accountant, Manager,
    //   Doctor, Lawyer, Shopkeeper, Student, Retired, Self-Employed,
    //   Unemployed, Government Official, Other
    // ============================================================
    local procedure InitializeDefaultOccupations()
    var
        Occupation: Record "Occupation";
    begin
        // Check if occupations already exist (to avoid duplicates on upgrades)
        if Occupation.IsEmpty() then begin
            // Teacher
            CreateOccupation('TEACHER', 'Teacher');

            // Nurse
            CreateOccupation('NURSE', 'Registered Nurse or Health Worker');

            // Farmer
            CreateOccupation('FARMER', 'Farmer');

            // Engineer
            CreateOccupation('ENGINEER', 'Engineer');

            // Accountant
            CreateOccupation('ACCOUNTANT', 'Accountant or Financial Professional');

            // Manager
            CreateOccupation('MANAGER', 'Manager or Supervisor');

            // Doctor
            CreateOccupation('DOCTOR', 'Doctor or Medical Professional');

            // Lawyer
            CreateOccupation('LAWYER', 'Lawyer or Legal Professional');

            // Shopkeeper
            CreateOccupation('SHOPKEEPER', 'Shopkeeper or Trader');

            // Mechanic
            CreateOccupation('MECHANIC', 'Mechanic or Technical Specialist');

            // Student
            CreateOccupation('STUDENT', 'Student');

            // Retired
            CreateOccupation('RETIRED', 'Retired');

            // Self-Employed
            CreateOccupation('SELFEMPLOYED', 'Self-Employed or Entrepreneur');

            // Unemployed
            CreateOccupation('UNEMPLOYED', 'Unemployed');

            // Government Official
            CreateOccupation('GOVT_OFFICIAL', 'Government Official or Civil Servant');

            // Other
            CreateOccupation('OTHER', 'Other Occupation');
        end;
    end;

    // ============================================================
    // PROCEDURE: CreateOccupation
    // PURPOSE: Inserts a single occupation record
    //
    // PARAMETERS:
    //   pCode - Short identifier (e.g., 'TEACHER', 'NURSE')
    //   pDescription - Full description (e.g., 'Teacher')
    // ============================================================
    local procedure CreateOccupation(pCode: Code[20]; pDescription: Text[100])
    var
        Occupation: Record "Occupation";
    begin
        // Create a new occupation record with the provided code and description
        Occupation.Init();
        Occupation.Code := pCode;
        Occupation.Description := pDescription;
        Occupation.Active := true;  // Set to active by default
        Occupation.Insert();
    end;
}

