// ============================================================
// Codeunit 50111 - Data Quality Management
// ============================================================
// PURPOSE: Implements data quality checks to find problems:
//          1. Duplicate member emails
//          2. Loan applications with missing members (orphaned)
//          3. Loan applications stuck in "Pending Approval" too long
//
// HOW TO USE:
//   var
//       DataQual: Codeunit "Data Quality Management";
//       Issues: Record "Data Quality Issue";
//   begin
//       DataQual.RunDataQualityChecks(Issues);
//       // Issues now contains all found problems
//   end;
//
// DESIGN PATTERN:
//   - Each check is a separate procedure
//   - All results collected in a temporary table
//   - Returned to caller for display/action
//
// ============================================================

codeunit 50111 "Data Quality Management"
{
    // ================================================================
    // PUBLIC PROCEDURES
    // ================================================================

    // -------------------------------------------------------
    // RunDataQualityChecks
    // -------------------------------------------------------
    // PURPOSE: Master procedure that runs all data quality checks
    //          and returns findings in the Issues table.
    //
    // PARAMETERS:
    //   var Issues: Record "Data Quality Issue" - Output table with all issues
    //
    // RETURNS:
    //   Integer - Total number of issues found
    //
    // NOTES:
    //   - Clears the Issues table before running
    //   - Calls all three check procedures
    //   - Returns the count of issues
    // -------------------------------------------------------
    procedure RunDataQualityChecks(var Issues: Record "Data Quality Issue"): Integer
    var
        IssueID: Integer;
    begin
        Issues.DeleteAll();  // Clear any previous results
        IssueID := 1;  // Initialize counter for manual ID assignment

        CheckDuplicateEmails(Issues, IssueID);
        CheckOrphanedLoans(Issues, IssueID);
        CheckStalledApplications(Issues, IssueID);

        exit(Issues.Count);
    end;

    // ================================================================
    // CHECK 1: DUPLICATE EMAILS
    // ================================================================
    // RULE: A member email should be unique. If multiple members share
    //       the same email, they are likely duplicates or data entry errors.
    //
    // THRESHOLD: Any email appearing 2+ times is flagged
    // SEVERITY: Critical (could affect communications, security)
    // RECOMMENDATION: Merge duplicate records or correct email
    //
    // EXAMPLE ISSUE:
    //   Email "john@example.com" found in:
    //     - MEM-20260101-0001 (John Smith)
    //     - MEM-20260102-0050 (John Simth) ← typo in name
    //   This suggests someone entered the same person twice.
    // ================================================================

    local procedure CheckDuplicateEmails(var Issues: Record "Data Quality Issue"; var IssueID: Integer)
    var
        Member1: Record "Member";
        Member2: Record "Member";
        EmailsSeen: Dictionary of [Text, Integer];
        EmailAddress: Text;
        Count: Integer;
        Issue: Record "Data Quality Issue";
    begin
        // Step 1: Build a dictionary of email frequencies
        // GroupBy isn't available in AL, so we iterate and track manually
        Member1.SetFilter("Email", '<>%1', '');  // Only members with email
        if Member1.FindSet() then
            repeat
                EmailAddress := Member1."Email";
                if EmailsSeen.ContainsKey(EmailAddress) then
                    EmailsSeen.Set(EmailAddress, EmailsSeen.Get(EmailAddress) + 1)
                else
                    EmailsSeen.Add(EmailAddress, 1);
            until Member1.Next() = 0;

        // Step 2: For each email appearing 2+ times, create issue records
        foreach EmailAddress in EmailsSeen.Keys do begin
            Count := EmailsSeen.Get(EmailAddress);
            if Count >= 2 then begin
                // Found duplicate email—create an issue record for each affected member
                Member1.SetRange("Email", EmailAddress);
                if Member1.FindSet() then
                    repeat
                        Issue.Init();
                        Issue."Issue ID" := IssueID;
                        IssueID += 1;
                        Issue."Issue Type" := 'Duplicate Email';
                        Issue."Severity" := 'Critical';
                        Issue."Member ID" := Member1."Member ID";
                        Issue."Member Email" := EmailAddress;
                        Issue."Affected Count" := Count;
                        Issue."Description" := StrSubstNo(
                            'Email "%1" is used by %2 members. This may indicate duplicate records.',
                            EmailAddress,
                            Count
                        );
                        Issue."Recommendation" := 'Review and merge duplicate member records. Ensure email addresses are unique.';
                        Issue."Related Record ID" := Member1."Member ID";
                        Issue.Insert();
                    until Member1.Next() = 0;
            end;
        end;
    end;

    // ================================================================
    // CHECK 2: ORPHANED LOAN APPLICATIONS
    // ================================================================
    // RULE: Every Loan Application must reference a valid Member ID.
    //       If a loan points to a non-existent member, it's an orphan
    //       (data integrity violation—shouldn't happen if FK relations are enforced).
    //
    // THRESHOLD: Any loan with missing member is flagged
    // SEVERITY: Critical (breaks business logic)
    // RECOMMENDATION: Delete orphaned loan or correct Member ID
    //
    // EXAMPLE ISSUE:
    //   Loan Application LN-20260101-00050 references
    //   Member ID "MEM-DELETED-999" which doesn't exist in Member table.
    //   This could happen if a member was deleted but loans weren't cleaned up.
    // ================================================================

    local procedure CheckOrphanedLoans(var Issues: Record "Data Quality Issue"; var IssueID: Integer)
    var
        LoanApp: Record "Loan Application";
        Member: Record "Member";
        Issue: Record "Data Quality Issue";
    begin
        // Step 1: Get all loan applications
        if LoanApp.FindSet() then
            repeat
                // Step 2: Check if the referenced Member ID exists
                // Note: Normally the FK would prevent this, but we check anyway
                if not Member.Get(LoanApp."Member ID") then begin
                    // Member not found—this loan is orphaned
                    Issue.Init();
                    Issue."Issue ID" := IssueID;
                    IssueID += 1;
                    Issue."Issue Type" := 'Orphaned Loan';
                    Issue."Severity" := 'Critical';
                    Issue."Loan Application No." := LoanApp."Loan Application No.";
                    Issue."Referenced Member ID" := LoanApp."Member ID";
                    Issue."Description" := StrSubstNo(
                        'Loan Application %1 references non-existent Member ID "%2". ' +
                        'This is a data integrity issue.',
                        LoanApp."Loan Application No.",
                        LoanApp."Member ID"
                    );
                    Issue."Recommendation" :=
                        'Either delete the orphaned loan or correct its Member ID. ' +
                        'If member was deleted intentionally, clean up related loans.';
                    Issue."Related Record ID" := LoanApp."Loan Application No.";
                    Issue.Insert();
                end;
            until LoanApp.Next() = 0;
    end;

    // ================================================================
    // CHECK 3: STALLED LOAN APPLICATIONS
    // ================================================================
    // RULE: Loan applications in "Pending Approval" status should not
    //       stay in that state indefinitely. Applications stuck in
    //       approval for 30+ days indicate workflow issues.
    //
    // THRESHOLD: 30 days in "Pending Approval" status
    // SEVERITY: Warning (not data corruption, but process issue)
    // RECOMMENDATION: Follow up with loan officer for approval decision
    //
    // EXAMPLE ISSUE:
    //   Loan Application LN-20260101-00025 submitted 2026-02-10
    //   Still in "Pending Approval" as of 2026-04-15 (64 days!)
    //   Should have been approved/rejected by now.
    // ================================================================

    local procedure CheckStalledApplications(var Issues: Record "Data Quality Issue"; var IssueID: Integer)
    var
        LoanApp: Record "Loan Application";
        Issue: Record "Data Quality Issue";
        DaysInStatus: Integer;
        ThresholdDays: Integer;
        CurrentDate: Date;
        CheckDate: Date;
    begin
        CurrentDate := Today;
        ThresholdDays := 30;  // Flag if pending approval for 30+ days

        // Step 1: Get all loans in "Pending Approval" status
        LoanApp.SetRange("Status", Enum::"Loan Application Status"::"Pending Approval");
        if LoanApp.FindSet() then
            repeat
                // Step 2: Calculate how long it's been in pending approval
                // Use Application Date as baseline for when it entered the system
                if LoanApp."Application Date" <> 0D then
                    CheckDate := LoanApp."Application Date"
                else
                    CheckDate := Today;

                DaysInStatus := CurrentDate - CheckDate;

                // Step 3: Flag if exceeds threshold
                if DaysInStatus >= ThresholdDays then begin
                    Issue.Init();
                    Issue."Issue ID" := IssueID;
                    IssueID += 1;
                    Issue."Issue Type" := 'Stalled Application';
                    Issue."Severity" := 'Warning';
                    Issue."Loan Application No." := LoanApp."Loan Application No.";
                    Issue."Member ID" := LoanApp."Member ID";
                    Issue."Status Since Date" := CheckDate;
                    Issue."Days in Status" := DaysInStatus;
                    Issue."Description" := StrSubstNo(
                        'Loan Application %1 has been in "Pending Approval" status for %2 days ' +
                        '(since %3). This indicates a potential workflow bottleneck.',
                        LoanApp."Loan Application No.",
                        DaysInStatus,
                        CheckDate
                    );
                    Issue."Recommendation" := StrSubstNo(
                        'Contact loan officer to either approve or reject this application. ' +
                        'Set an SLA to resolve applications within %1 days.',
                        ThresholdDays
                    );
                    Issue."Related Record ID" := LoanApp."Loan Application No.";
                    Issue.Insert();
                end;
            until LoanApp.Next() = 0;
    end;
}
