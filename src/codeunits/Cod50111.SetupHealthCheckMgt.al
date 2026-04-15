// ============================================================
// Codeunit 50111 - Setup Health Check Manager
// ============================================================
// PURPOSE: Performs comprehensive health checks of SACCO system
//          configuration and returns results for display on the
//          Setup Health Check page.
//
// KEY FUNCTIONS:
//   - PerformAllHealthChecks()    → Runs all 9 checks and populates temp table
//   - Individual check functions  → Return True if check passes
//
// DEFENSIVE CODING:
//   - Gracefully handles missing setup record
//   - Checks for empty GL account numbers
//   - Safely converts Blob to string
//   - Uses FILTER instead of assuming data structure
// ============================================================

codeunit 50111 "Setup Health Check Manager"
{
    Access = Public;

    /// <summary>
    /// Performs all health checks and populates the provided Setup Health Check record.
    /// Called from Setup Health Check page OnOpenPage trigger.
    /// </summary>
    procedure PerformAllHealthChecks(var HealthCheckTable: Record "Setup Health Check")
    begin
        HealthCheckTable.DeleteAll(false); // Clear previous results

        // 1. Member Application No. Series
        PerformCheckMemberAppNoSeries(HealthCheckTable);

        // 2. Loan Application No. Series
        PerformCheckLoanAppNoSeries(HealthCheckTable);

        // 3. Loans Receivable Account
        PerformCheckLoansReceivableAccount(HealthCheckTable);

        // 4. Loan Disbursement Account
        PerformCheckLoanDisbursementAccount(HealthCheckTable);

        // 5. Member Categories
        PerformCheckMemberCategories(HealthCheckTable);

        // 6. Email Account
        PerformCheckEmailAccount(HealthCheckTable);

        // 7. Rejection Email Subject
        PerformCheckRejectionEmailSubject(HealthCheckTable);

        // 8. Rejection Email Body
        PerformCheckRejectionEmailBody(HealthCheckTable);

        // 9. AfricasTalking SMS Configuration
        PerformCheckAfricasTalking(HealthCheckTable);
    end;

    // ===== CHECK 1: Member Application No. Series =====
    local procedure PerformCheckMemberAppNoSeries(var HealthCheckTable: Record "Setup Health Check")
    var
        MemberSetup: Record "Member Setup";
    begin
        InitializeCheck(HealthCheckTable, 'Member Application No. Series');

        if not MemberSetup.Get('SETUP') then begin
            HealthCheckTable.Status := HealthCheckTable.Status::Red;
            HealthCheckTable.Details := 'Member Setup record not found.';
            HealthCheckTable.Recommendation := 'System error: Member Setup must exist. Contact support.';
            HealthCheckTable.Modify(false);
            exit;
        end;

        if MemberSetup."Member Application Nos." = '' then begin
            HealthCheckTable.Status := HealthCheckTable.Status::Red;
            HealthCheckTable.Details := 'No number series assigned for Member Applications.';
            HealthCheckTable.Recommendation := 'Open Member Setup → assign "Member Application Nos." value';
            HealthCheckTable."Link Page ID" := 50106;
            HealthCheckTable.Modify(false);
        end else begin
            HealthCheckTable.Status := HealthCheckTable.Status::Green;
            HealthCheckTable.Details := 'Member Application No. Series "' + MemberSetup."Member Application Nos." + '" is configured.';
            HealthCheckTable.Recommendation := '';
            HealthCheckTable.Modify(false);
        end;
    end;

    // ===== CHECK 2: Loan Application No. Series =====
    local procedure PerformCheckLoanAppNoSeries(var HealthCheckTable: Record "Setup Health Check")
    var
        MemberSetup: Record "Member Setup";
    begin
        InitializeCheck(HealthCheckTable, 'Loan Application No. Series');

        if not MemberSetup.Get('SETUP') then begin
            HealthCheckTable.Status := HealthCheckTable.Status::Red;
            HealthCheckTable.Details := 'Member Setup record not found.';
            HealthCheckTable.Recommendation := 'System error: Member Setup must exist. Contact support.';
            HealthCheckTable.Modify(false);
            exit;
        end;

        if MemberSetup."Loan Application Nos." = '' then begin
            HealthCheckTable.Status := HealthCheckTable.Status::Red;
            HealthCheckTable.Details := 'No number series assigned for Loan Applications.';
            HealthCheckTable.Recommendation := 'Open Member Setup → Loan Settings → assign "Loan Application Nos."';
            HealthCheckTable."Link Page ID" := 50106;
            HealthCheckTable.Modify(false);
        end else begin
            HealthCheckTable.Status := HealthCheckTable.Status::Green;
            HealthCheckTable.Details := 'Loan Application No. Series "' + MemberSetup."Loan Application Nos." + '" is configured.';
            HealthCheckTable.Recommendation := '';
            HealthCheckTable.Modify(false);
        end;
    end;

    // ===== CHECK 3: Loans Receivable GL Account =====
    local procedure PerformCheckLoansReceivableAccount(var HealthCheckTable: Record "Setup Health Check")
    var
        MemberSetup: Record "Member Setup";
        GLAccount: Record "G/L Account";
    begin
        InitializeCheck(HealthCheckTable, 'Loans Receivable GL Account');

        if not MemberSetup.Get('SETUP') then begin
            HealthCheckTable.Status := HealthCheckTable.Status::Red;
            HealthCheckTable.Details := 'Member Setup record not found.';
            HealthCheckTable.Recommendation := 'System error: Member Setup must exist. Contact support.';
            HealthCheckTable.Modify(false);
            exit;
        end;

        if MemberSetup."Loans Receivable Account" = '' then begin
            HealthCheckTable.Status := HealthCheckTable.Status::Red;
            HealthCheckTable.Details := 'No GL Account assigned for Loans Receivable.';
            HealthCheckTable.Recommendation := 'Open Member Setup → Loan Settings → assign "Loans Receivable Account" (Asset account like 1200)';
            HealthCheckTable."Link Page ID" := 50106;
            HealthCheckTable.Modify(false);
        end else if not GLAccount.Get(MemberSetup."Loans Receivable Account") then begin
            HealthCheckTable.Status := HealthCheckTable.Status::Amber;
            HealthCheckTable.Details := 'GL Account "' + MemberSetup."Loans Receivable Account" + '" does not exist.';
            HealthCheckTable.Recommendation := 'Create the GL Account "' + MemberSetup."Loans Receivable Account" + '" or choose a different existing account.';
            HealthCheckTable."Link Page ID" := 50106;
            HealthCheckTable.Modify(false);
        end else begin
            HealthCheckTable.Status := HealthCheckTable.Status::Green;
            HealthCheckTable.Details := 'Loans Receivable Account "' + MemberSetup."Loans Receivable Account" + '" (' + GLAccount.Name + ') is configured.';
            HealthCheckTable.Recommendation := '';
            HealthCheckTable.Modify(false);
        end;
    end;

    // ===== CHECK 4: Loan Disbursement GL Account =====
    local procedure PerformCheckLoanDisbursementAccount(var HealthCheckTable: Record "Setup Health Check")
    var
        MemberSetup: Record "Member Setup";
        GLAccount: Record "G/L Account";
    begin
        InitializeCheck(HealthCheckTable, 'Loan Disbursement GL Account');

        if not MemberSetup.Get('SETUP') then begin
            HealthCheckTable.Status := HealthCheckTable.Status::Red;
            HealthCheckTable.Details := 'Member Setup record not found.';
            HealthCheckTable.Recommendation := 'System error: Member Setup must exist. Contact support.';
            HealthCheckTable.Modify(false);
            exit;
        end;

        if MemberSetup."Loan Disbursement Account" = '' then begin
            HealthCheckTable.Status := HealthCheckTable.Status::Red;
            HealthCheckTable.Details := 'No GL Account assigned for Loan Disbursement.';
            HealthCheckTable.Recommendation := 'Open Member Setup → Loan Settings → assign "Loan Disbursement Account" (typically bank account)';
            HealthCheckTable."Link Page ID" := 50106;
            HealthCheckTable.Modify(false);
        end else if not GLAccount.Get(MemberSetup."Loan Disbursement Account") then begin
            HealthCheckTable.Status := HealthCheckTable.Status::Amber;
            HealthCheckTable.Details := 'GL Account "' + MemberSetup."Loan Disbursement Account" + '" does not exist.';
            HealthCheckTable.Recommendation := 'Create the GL Account "' + MemberSetup."Loan Disbursement Account" + '" or choose a different existing account.';
            HealthCheckTable."Link Page ID" := 50106;
            HealthCheckTable.Modify(false);
        end else begin
            HealthCheckTable.Status := HealthCheckTable.Status::Green;
            HealthCheckTable.Details := 'Loan Disbursement Account "' + MemberSetup."Loan Disbursement Account" + '" (' + GLAccount.Name + ') is configured.';
            HealthCheckTable.Recommendation := '';
            HealthCheckTable.Modify(false);
        end;
    end;

    // ===== CHECK 5: Member Categories =====
    local procedure PerformCheckMemberCategories(var HealthCheckTable: Record "Setup Health Check")
    var
        MemberCategory: Record "Member Category Master";
    begin
        InitializeCheck(HealthCheckTable, 'Member Categories');

        MemberCategory.SetRange(Active, true);

        if MemberCategory.IsEmpty then begin
            HealthCheckTable.Status := HealthCheckTable.Status::Red;
            HealthCheckTable.Details := 'No active member categories defined.';
            HealthCheckTable.Recommendation := 'Open Member Category Master → create active categories (e.g., REGULAR, BUSINESS, STUDENT)';
            HealthCheckTable."Link Page ID" := 50104;
            HealthCheckTable.Modify(false);
        end else begin
            HealthCheckTable.Status := HealthCheckTable.Status::Green;
            HealthCheckTable.Details := 'Member categories are defined. Count: ' + Format(MemberCategory.Count) + ' active categories.';
            HealthCheckTable.Recommendation := '';
            HealthCheckTable.Modify(false);
        end;
    end;

    // ===== CHECK 6: Email Account =====
    local procedure PerformCheckEmailAccount(var HealthCheckTable: Record "Setup Health Check")
    var
        EmailAccount: Record "Email Account";
    begin
        InitializeCheck(HealthCheckTable, 'Email Account (Default)');

        // In BC, check if any email account exists
        if EmailAccount.FindFirst() then begin
            HealthCheckTable.Status := HealthCheckTable.Status::Green;
            HealthCheckTable.Details := 'Email account "' + EmailAccount.Name + '" is configured and ready for sending notifications.';
            HealthCheckTable.Recommendation := '';
            HealthCheckTable.Modify(false);
        end else begin
            HealthCheckTable.Status := HealthCheckTable.Status::Red;
            HealthCheckTable.Details := 'No email account configured in Business Central.';
            HealthCheckTable.Recommendation := 'Search "Email Accounts" in Business Central → create account (Microsoft 365 recommended) → activate it';
            HealthCheckTable."Link Page ID" := 0; // No direct link available
            HealthCheckTable.Modify(false);
        end;
    end;

    // ===== CHECK 7: Rejection Email Subject =====
    local procedure PerformCheckRejectionEmailSubject(var HealthCheckTable: Record "Setup Health Check")
    var
        MemberSetup: Record "Member Setup";
    begin
        InitializeCheck(HealthCheckTable, 'Rejection Email Subject');

        if not MemberSetup.Get('SETUP') then begin
            HealthCheckTable.Status := HealthCheckTable.Status::Amber;
            HealthCheckTable.Details := 'Member Setup record not found.';
            HealthCheckTable.Recommendation := 'System will use default rejection email template if subject not specified.';
            HealthCheckTable.Modify(false);
            exit;
        end;

        if MemberSetup."Rejection Email Subject" = '' then begin
            HealthCheckTable.Status := HealthCheckTable.Status::Amber;
            HealthCheckTable.Details := 'No rejection email subject template defined.';
            HealthCheckTable.Recommendation := 'Optional: Open Member Setup → fill "Rejection Email Subject" for custom rejection emails (e.g., "Your Application Status")';
            HealthCheckTable."Link Page ID" := 50106;
            HealthCheckTable.Modify(false);
        end else begin
            HealthCheckTable.Status := HealthCheckTable.Status::Green;
            HealthCheckTable.Details := 'Rejection email subject: "' + MemberSetup."Rejection Email Subject" + '"';
            HealthCheckTable.Recommendation := '';
            HealthCheckTable.Modify(false);
        end;
    end;

    // ===== CHECK 8: Rejection Email Body =====
    local procedure PerformCheckRejectionEmailBody(var HealthCheckTable: Record "Setup Health Check")
    var
        MemberSetup: Record "Member Setup";
        EmailBodyText: Text;
        InStream: InStream;
    begin
        InitializeCheck(HealthCheckTable, 'Rejection Email Body Template');

        if not MemberSetup.Get('SETUP') then begin
            HealthCheckTable.Status := HealthCheckTable.Status::Amber;
            HealthCheckTable.Details := 'Member Setup record not found.';
            HealthCheckTable.Recommendation := 'System will use default email template if body not specified.';
            HealthCheckTable.Modify(false);
            exit;
        end;

        // Try to read the Blob field
        if MemberSetup."Rejection Email Body".HasValue then begin
            MemberSetup."Rejection Email Body".CreateInStream(InStream);
            InStream.ReadText(EmailBodyText);

            if EmailBodyText = '' then begin
                HealthCheckTable.Status := HealthCheckTable.Status::Amber;
                HealthCheckTable.Details := 'Rejection email body template is empty.';
                HealthCheckTable.Recommendation := 'Optional: Fill email template with variables {First Name}, {Application ID}, {Rejection Reason}';
                HealthCheckTable."Link Page ID" := 50106;
                HealthCheckTable.Modify(false);
            end else begin
                HealthCheckTable.Status := HealthCheckTable.Status::Green;
                HealthCheckTable.Details := 'Rejection email body template is configured (' + Format(StrLen(EmailBodyText)) + ' characters).';
                HealthCheckTable.Recommendation := '';
                HealthCheckTable.Modify(false);
            end;
        end else begin
            HealthCheckTable.Status := HealthCheckTable.Status::Amber;
            HealthCheckTable.Details := 'No rejection email body template defined.';
            HealthCheckTable.Recommendation := 'Optional: Open Member Setup → fill "Rejection Email Body" with HTML template';
            HealthCheckTable."Link Page ID" := 50106;
            HealthCheckTable.Modify(false);
        end;
    end;

    // ===== CHECK 9: AfricasTalking SMS Configuration =====
    local procedure PerformCheckAfricasTalking(var HealthCheckTable: Record "Setup Health Check")
    var
        MemberSetup: Record "Member Setup";
    begin
        InitializeCheck(HealthCheckTable, 'AfricasTalking SMS Integration');

        if not MemberSetup.Get('SETUP') then begin
            HealthCheckTable.Status := HealthCheckTable.Status::Amber;
            HealthCheckTable.Details := 'Member Setup record not found.';
            HealthCheckTable.Recommendation := 'Optional: Configure Africa''s Talking API if SMS notifications are needed.';
            HealthCheckTable.Modify(false);
            exit;
        end;

        if (MemberSetup."AfricasTalking API Key" = '') or (MemberSetup."AfricasTalking Username" = '') then begin
            HealthCheckTable.Status := HealthCheckTable.Status::Amber;
            HealthCheckTable.Details := 'AfricasTalking API credentials not configured.';
            HealthCheckTable.Recommendation := 'Optional: If SMS is needed, open Member Setup → fill "AfricasTalking API Key" and "Username"';
            HealthCheckTable."Link Page ID" := 50106;
            HealthCheckTable.Modify(false);
        end else begin
            HealthCheckTable.Status := HealthCheckTable.Status::Green;
            HealthCheckTable.Details := 'AfricasTalking SMS API is configured and ready for sending SMS notifications.';
            HealthCheckTable.Recommendation := '';
            HealthCheckTable.Modify(false);
        end;
    end;

    // ===== HELPER: Initialize a new check record =====
    local procedure InitializeCheck(var HealthCheckTable: Record "Setup Health Check"; CheckName: Text[100])
    begin
        HealthCheckTable.Init();
        HealthCheckTable."Entry No." := 0; // Auto-increment will handle this
        HealthCheckTable."Check Name" := CheckName;
        HealthCheckTable.Insert(false);
    end;

    // ===== PUBLIC ACCESS: Individual check functions (for use by other code) =====

    /// <summary>
    /// Returns true if Member Application No. Series is configured.
    /// </summary>
    procedure IsMemberAppNoSeriesConfigured(): Boolean
    var
        MemberSetup: Record "Member Setup";
    begin
        if MemberSetup.Get('SETUP') then
            exit(MemberSetup."Member Application Nos." <> '');
        exit(false);
    end;

    /// <summary>
    /// Returns true if Loan Application No. Series is configured.
    /// </summary>
    procedure IsLoanAppNoSeriesConfigured(): Boolean
    var
        MemberSetup: Record "Member Setup";
    begin
        if MemberSetup.Get('SETUP') then
            exit(MemberSetup."Loan Application Nos." <> '');
        exit(false);
    end;

    /// <summary>
    /// Returns true if Loans Receivable GL Account exists and is configured.
    /// </summary>
    procedure IsLoansReceivableAccountConfigured(): Boolean
    var
        MemberSetup: Record "Member Setup";
        GLAccount: Record "G/L Account";
    begin
        if not MemberSetup.Get('SETUP') then
            exit(false);

        if MemberSetup."Loans Receivable Account" = '' then
            exit(false);

        exit(GLAccount.Get(MemberSetup."Loans Receivable Account"));
    end;

    /// <summary>
    /// Returns true if Loan Disbursement GL Account exists and is configured.
    /// </summary>
    procedure IsLoanDisbursementAccountConfigured(): Boolean
    var
        MemberSetup: Record "Member Setup";
        GLAccount: Record "G/L Account";
    begin
        if not MemberSetup.Get('SETUP') then
            exit(false);

        if MemberSetup."Loan Disbursement Account" = '' then
            exit(false);

        exit(GLAccount.Get(MemberSetup."Loan Disbursement Account"));
    end;

    /// <summary>
    /// Returns true if at least one active Member Category exists.
    /// </summary>
    procedure AreMemberCategoriesConfigured(): Boolean
    var
        MemberCategory: Record "Member Category Master";
    begin
        MemberCategory.SetRange(Active, true);
        exit(not MemberCategory.IsEmpty);
    end;

    /// <summary>
    /// Returns true if any email account is configured in BC.
    /// </summary>
    procedure IsEmailAccountConfigured(): Boolean
    var
        EmailAccount: Record "Email Account";
    begin
        exit(not EmailAccount.IsEmpty);
    end;

    /// <summary>
    /// Returns true if rejection email subject is configured.
    /// </summary>
    procedure IsRejectionEmailSubjectConfigured(): Boolean
    var
        MemberSetup: Record "Member Setup";
    begin
        if MemberSetup.Get('SETUP') then
            exit(MemberSetup."Rejection Email Subject" <> '');
        exit(false);
    end;

    /// <summary>
    /// Returns true if rejection email body template is configured.
    /// </summary>
    procedure IsRejectionEmailBodyConfigured(): Boolean
    var
        MemberSetup: Record "Member Setup";
    begin
        if MemberSetup.Get('SETUP') then
            exit(MemberSetup."Rejection Email Body".HasValue);
        exit(false);
    end;

    /// <summary>
    /// Returns true if AfricasTalking API is configured.
    /// </summary>
    procedure IsAfricasTalkingConfigured(): Boolean
    var
        MemberSetup: Record "Member Setup";
    begin
        if MemberSetup.Get('SETUP') then
            exit((MemberSetup."AfricasTalking API Key" <> '') and (MemberSetup."AfricasTalking Username" <> ''));
        exit(false);
    end;

    /// <summary>
    /// Returns overall system health status text based on all checks.
    /// Returns: "Healthy", "At Risk", or "Critical"
    /// </summary>
    procedure GetOverallSystemStatusText(HealthCheckTable: Record "Setup Health Check"): Text
    var
        CriticalFailCount: Integer;
        WarningCount: Integer;
    begin
        if HealthCheckTable.FindSet() then begin
            repeat
                if HealthCheckTable.Status = HealthCheckTable.Status::Red then
                    CriticalFailCount += 1
                else if HealthCheckTable.Status = HealthCheckTable.Status::Amber then
                    WarningCount += 1;
            until HealthCheckTable.Next() = 0;
        end;

        if CriticalFailCount > 0 then
            exit('CRITICAL - Action Required')
        else if WarningCount > 0 then
            exit('AT RISK - Check Warnings')
        else
            exit('HEALTHY - System Ready');
    end;

    /// <summary>
    /// Returns styling appropriate to the overall status.
    /// Green for Healthy, Attention for At Risk, Unfavorable for Critical.
    /// </summary>
    procedure GetOverallSystemStyle(HealthCheckTable: Record "Setup Health Check"): Text
    var
        CriticalFailCount: Integer;
        WarningCount: Integer;
    begin
        if HealthCheckTable.FindSet() then begin
            repeat
                if HealthCheckTable.Status = HealthCheckTable.Status::Red then
                    CriticalFailCount += 1
                else if HealthCheckTable.Status = HealthCheckTable.Status::Amber then
                    WarningCount += 1;
            until HealthCheckTable.Next() = 0;
        end;

        if CriticalFailCount > 0 then
            exit('Unfavorable')
        else if WarningCount > 0 then
            exit('Attention')
        else
            exit('Favorable');
    end;
}
