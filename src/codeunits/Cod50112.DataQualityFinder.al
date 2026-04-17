// ============================================================
// Codeunit 50112 - Data Quality Finder
// ============================================================
// PURPOSE: Analyzes SACCO data to identify quality issues:
//   1. Duplicate emails in member table
//   2. Orphaned loan applications (Member ID doesn't exist)
//   3. Applications stuck in a status for > 30 days
//
// PUBLIC PROCEDURES:
//   - PerformAllDataQualityChecks(): Find all issues
//   - GetIssueCount(): Return total issues found
//   - GetCriticalIssueCount(): Return critical severity issues
// ============================================================

codeunit 50112 "Data Quality Finder"
{
    Access = Public;

    // ===== PUBLIC PROCEDURES =====

    /// <summary>
    /// Populate the Data Quality Issue table with all issues found.
    /// Clears existing issues before running new analysis.
    /// </summary>
    /// <param name="IssueTable">Temporary table to populate with issues</param>
    procedure PerformAllDataQualityChecks(var IssueTable: Record "Data Quality Issue")
    begin
        // Clear previous results
        IssueTable.DeleteAll(false);

        // Run each check
        FindDuplicateEmails(IssueTable);
        FindOrphanedLoanApplications(IssueTable);
        FindStuckStatusApplications(IssueTable);

        // Mark timestamp
        Message('Data quality analysis complete. %1 issues found.', IssueTable.Count());
    end;

    /// <summary>
    /// Return the total count of issues found
    /// </summary>
    procedure GetIssueCount(IssueTbl: Record "Data Quality Issue"): Integer
    begin
        exit(IssueTbl.Count());
    end;

    /// <summary>
    /// Return count of critical severity issues only
    /// </summary>
    procedure GetCriticalIssueCount(IssueTbl: Record "Data Quality Issue"): Integer
    var
        FilteredIssue: Record "Data Quality Issue";
    begin
        FilteredIssue.Copy(IssueTbl);
        FilteredIssue.SetRange(Severity, FilteredIssue.Severity::Critical);
        exit(FilteredIssue.Count());
    end;

    // ===== PRIVATE PROCEDURES =====

    /// <summary>
    /// RULE 1: Find members with duplicate email addresses.
    /// Duplicates violate data integrity and can cause MIS issues.
    /// 
    /// LOGIC:
    ///   1. Loop through all members with non-empty email
    ///   2. For each email, count how many members have it
    ///   3. If count > 1, record each member ID as an issue
    ///   4. Link the two duplicate email members together
    /// 
    /// SEVERITY: Critical (data integrity risk)
    /// RECOMMENDATION: Consolidate members or fix email addresses
    /// </summary>
    local procedure FindDuplicateEmails(var IssueTable: Record "Data Quality Issue")
    var
        Member: Record "Member";
        MemberDupe: Record "Member";
        EmailCount: Integer;
    begin
        // Find all members with emails
        Member.SetFilter(Email, '<>%1', '');
        if not Member.FindSet() then
            exit; // No members with emails

        repeat
            // For this email, count how many members have it
            MemberDupe.SetRange(Email, Member.Email);
            EmailCount := MemberDupe.Count();

            // If more than one member has this email, it's a duplicate
            if EmailCount > 1 then begin
                // Find the OTHER member(s) with the same email
                MemberDupe.FindSet();
                repeat
                    // Don't report the same duplicate pair twice
                    if MemberDupe."Member ID" <> Member."Member ID" then begin
                        // Check if we already reported this pair (avoid duplicates in our report)
                        if not IssueAlreadyExists(IssueTable, 'DUPLICATE_EMAIL', Member."Member ID") then
                            AddIssue(
                                IssueTable,
                                'DUPLICATE_EMAIL',
                                IssueTable.Severity::Critical,
                                'Member',
                                Member."Member ID",
                                MemberDupe."Member ID",
                                'Member ' + Member."Member ID" + ' has duplicate email: ' + Member.Email,
                                'Member ' + Member."Member ID" + ': ' + Member."Full Name" + ' | Email: ' + Member.Email + ' | Also used by: ' + MemberDupe."Member ID",
                                'Change one of the email addresses or consolidate member records'
                            );
                    end;
                until MemberDupe.Next() = 0;
            end;
        until Member.Next() = 0;
    end;

    /// <summary>
    /// RULE 2: Find loan applications pointing to non-existent members.
    /// These are "orphaned" records - should not occur if referential
    /// integrity is enforced, but can happen if data was deleted.
    /// 
    /// LOGIC:
    ///   1. Loop through all loan applications
    ///   2. For each, try to find the associated member
    ///   3. If member doesn't exist, it's an orphaned loan application
    ///   4. Record the loan no. and missing member ID
    /// 
    /// SEVERITY: Critical (blocks loan processing)
    /// RECOMMENDATION: Delete the orphaned loan or re-link to correct member
    /// </summary>
    local procedure FindOrphanedLoanApplications(var IssueTable: Record "Data Quality Issue")
    var
        LoanApp: Record "Loan Application";
        Member: Record "Member";
    begin
        if not LoanApp.FindSet() then
            exit; // No loan applications

        repeat
            // Try to find the member referenced by this loan
            if not Member.Get(LoanApp."Member ID") then begin
                // Member doesn't exist - this is an orphaned loan
                AddIssue(
                    IssueTable,
                    'ORPHANED_LOAN',
                    IssueTable.Severity::Critical,
                    'Loan Application',
                    LoanApp."Loan Application No.",
                    LoanApp."Member ID",
                    'Loan application references non-existent member',
                    'Loan ' + LoanApp."Loan Application No." + ' | Status: ' + Format(LoanApp.Status) +
                    ' | Amount: ' + Format(LoanApp."Loan Amount") + ' | Missing Member ID: ' + LoanApp."Member ID",
                    'Delete this loan application or create the missing member record'
                );
            end;
        until LoanApp.Next() = 0;
    end;

    /// <summary>
    /// RULE 3: Find applications stuck in a status for > 30 days.
    /// Applications should move through the workflow - long delays
    /// indicate bottlenecks, forgotten approvals, or stuck processes.
    /// 
    /// LOGIC:
    ///   1. For Member Applications: Find records in Pending status > 30 days old
    ///   2. For Loan Applications: Find records in Pending Approval > 30 days old
    ///   3. Calculate days since application was created
    ///   4. If > 30 days, record as an issue
    /// 
    /// SEVERITY: Medium (workflow issue, not data integrity)
    /// RECOMMENDATION: Review and either approve, reject, or update status
    /// 
    /// THRESHOLD: 30 days (STALE_THRESHOLD constant)
    /// </summary>
    local procedure FindStuckStatusApplications(var IssueTable: Record "Data Quality Issue")
    var
        MemberApp: Record "Member Application";
        LoanApp: Record "Loan Application";
        DaysOld: Integer;
        StaleThreshold: Integer;
        AppDate: Date;
    begin
        StaleThreshold := 30; // Applications older than 30 days in same status

        // ===== CHECK MEMBER APPLICATIONS =====
        // Member apps should move out of Pending within 30 days
        MemberApp.SetRange(Status, MemberApp.Status::Pending);
        if MemberApp.FindSet() then
            repeat
                AppDate := DT2Date(MemberApp."Application Date");
                DaysOld := Today() - AppDate;
                if DaysOld < 0 then
                    DaysOld := Abs(DaysOld);

                if DaysOld > StaleThreshold then
                    AddIssue(
                        IssueTable,
                        'STUCK_STATUS',
                        IssueTable.Severity::Medium,
                        'Member Application',
                        MemberApp."Application ID",
                        '',
                        'Member application pending review for ' + Format(DaysOld) + ' days',
                        'Application ' + MemberApp."Application ID" + ' | Applicant: ' + MemberApp."First Name" + ' ' +
                        MemberApp."Last Name" + ' | Email: ' + MemberApp.Email + ' | Age: ' + Format(DaysOld) + ' days',
                        'Review the application and either approve, reject, or update status'
                    );
            until MemberApp.Next() = 0;

        // ===== CHECK LOAN APPLICATIONS =====
        // Loans in "Pending Approval" should move out within 30 days
        LoanApp.SetRange(Status, LoanApp.Status::"Pending Approval");
        if LoanApp.FindSet() then
            repeat
                DaysOld := Today() - LoanApp."Application Date";
                if DaysOld < 0 then
                    DaysOld := Abs(DaysOld);

                if DaysOld > StaleThreshold then
                    AddIssue(
                        IssueTable,
                        'STUCK_STATUS',
                        IssueTable.Severity::High,
                        'Loan Application',
                        LoanApp."Loan Application No.",
                        '',
                        'Loan application pending approval for ' + Format(DaysOld) + ' days',
                        'Loan ' + LoanApp."Loan Application No." + ' | Member: ' + LoanApp."Member Name" +
                        ' | Amount: ' + Format(LoanApp."Loan Amount") + ' | Age: ' + Format(DaysOld) + ' days',
                        'Review the loan and either approve, reject, or update status'
                    );
            until LoanApp.Next() = 0;
    end;

    /// <summary>
    /// Helper procedure to add an issue to the temporary table.
    /// Centralizes issue creation for consistency.
    /// </summary>
    local procedure AddIssue(
        var IssueTable: Record "Data Quality Issue";
        IssueType: Code[30];
        Severity: Option Critical,High,Medium,Low;
        RecordType: Code[30];
        PrimaryID: Code[50];
        SecondaryID: Code[50];
        Description: Text[250];
        Details: Text[500];
        Recommendation: Text[250]
    ): Integer
    begin
        IssueTable."Issue Type" := IssueType;
        IssueTable.Severity := Severity;
        IssueTable."Record Type" := RecordType;
        IssueTable."Primary Record ID" := PrimaryID;
        IssueTable."Secondary Record ID" := SecondaryID;
        IssueTable."Issue Description" := Description;
        IssueTable.Details := Details;
        IssueTable.Recommendation := Recommendation;
        IssueTable."Date Found" := CurrentDateTime;

        IssueTable.Insert();
        exit(IssueTable."Entry No.");
    end;

    /// <summary>
    /// Helper to check if an issue ID was already reported
    /// (avoids reporting the same duplicate pair twice)
    /// </summary>
    local procedure IssueAlreadyExists(
        var IssueTable: Record "Data Quality Issue";
        IssueType: Code[30];
        PrimaryID: Code[50]
    ): Boolean
    var
        TempIssue: Record "Data Quality Issue";
    begin
        TempIssue.Copy(IssueTable);
        TempIssue.SetRange("Issue Type", IssueType);
        TempIssue.SetRange("Primary Record ID", PrimaryID);

        if TempIssue.FindFirst() then
            exit(true);

        exit(false);
    end;
}
