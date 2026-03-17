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
    end;
}
