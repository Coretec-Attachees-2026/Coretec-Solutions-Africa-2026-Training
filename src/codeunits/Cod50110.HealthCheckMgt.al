// ============================================================
// Codeunit 50110 - Health Check Management
// ============================================================
// PURPOSE: Provides health check procedures to diagnose SACCO
//          system configuration. Checks for:
//          - Member Setup records and number series
//          - Member Categories
//          - Email Account configuration
//          - Loan-related accounts
//          - Email templates
//
// PATTERN: Each check returns a "Health Status" record with:
//          - Check Name (e.g., "Member Setup")
//          - Status (Red/Green/Amber)
//          - Description (detailed message)
// ============================================================

codeunit 50110 "Health Check Mgt"
{
    Access = Public;

    /// <summary>
    /// Health Status enum: Red (critical), Amber (warning), Green (ok)
    /// </summary>
    procedure GetHealthStatusRed(): Text
    begin
        exit('Red');
    end;

    procedure GetHealthStatusAmber(): Text
    begin
        exit('Amber');
    end;

    procedure GetHealthStatusGreen(): Text
    begin
        exit('Green');
    end;

    /// <summary>
    /// Check 1: Member Setup Record Exists
    /// </summary>
    procedure CheckMemberSetupExists(var Status: Text; var StatusCaption: Text; var Description: Text)
    var
        MemberSetup: Record "Member Setup";
    begin
        // Try to get the setup record
        if MemberSetup.Get('SETUP') then begin
            Status := GetHealthStatusGreen();
            StatusCaption := '✓';
            Description := 'Member Setup record exists.';
        end
        else begin
            Status := GetHealthStatusRed();
            StatusCaption := '✗';
            Description := 'CRITICAL: Member Setup record is MISSING. Click "Initialize Setup" to create it.';
        end;
    end;

    /// <summary>
    /// Check 2: Member Application No. Series
    /// </summary>
    procedure CheckMemberAppNoSeries(var Status: Text; var StatusCaption: Text; var Description: Text)
    var
        MemberSetup: Record "Member Setup";
        NoSeriesLine: Record "No. Series Line";
    begin
        MemberSetup.GetOrCreateSetup();

        if MemberSetup."Member Application Nos." = '' then begin
            Status := GetHealthStatusRed();
            StatusCaption := '✗';
            Description := 'CRITICAL: Member Application Number Series is NOT configured.';
            exit;
        end;

        // Check if the number series exists
        if NoSeriesLine.Get(MemberSetup."Member Application Nos.") then begin
            Status := GetHealthStatusGreen();
            StatusCaption := '✓';
            Description := 'Member Application No. Series [' + MemberSetup."Member Application Nos." + '] is configured.';
        end
        else begin
            Status := GetHealthStatusRed();
            StatusCaption := '✗';
            Description := 'Member Application No. Series [' + MemberSetup."Member Application Nos." + '] does NOT exist in the system.';
        end;
    end;

    /// <summary>
    /// Check 3: Member Categories Exist
    /// </summary>
    procedure CheckMemberCategoriesExist(var Status: Text; var StatusCaption: Text; var Description: Text)
    var
        MemberCategory: Record "Member Category Master";
        CategoryCount: Integer;
    begin
        CategoryCount := MemberCategory.Count();

        if CategoryCount = 0 then begin
            Status := GetHealthStatusRed();
            StatusCaption := '✗';
            Description := 'CRITICAL: No Member Categories are defined. Go to Member Categories and add at least one.';
        end
        else if CategoryCount < 3 then begin
            Status := GetHealthStatusAmber();
            StatusCaption := '⚠';
            Description := 'WARNING: Only ' + Format(CategoryCount) + ' category(ies) defined. Consider adding more.';
        end
        else begin
            Status := GetHealthStatusGreen();
            StatusCaption := '✓';
            Description := 'Member Categories: ' + Format(CategoryCount) + ' category(ies) configured.';
        end;
    end;

    /// <summary>
    /// Check 4: Loan Application No. Series
    /// </summary>
    procedure CheckLoanAppNoSeries(var Status: Text; var StatusCaption: Text; var Description: Text)
    var
        MemberSetup: Record "Member Setup";
        NoSeriesLine: Record "No. Series Line";
    begin
        MemberSetup.GetOrCreateSetup();

        if MemberSetup."Loan Application Nos." = '' then begin
            Status := GetHealthStatusAmber();
            StatusCaption := '⚠';
            Description := 'Loan Application Number Series is NOT configured. Loans feature will not work.';
            exit;
        end;

        // Check if the number series exists
        if NoSeriesLine.Get(MemberSetup."Loan Application Nos.") then begin
            Status := GetHealthStatusGreen();
            StatusCaption := '✓';
            Description := 'Loan Application No. Series [' + MemberSetup."Loan Application Nos." + '] is configured.';
        end
        else begin
            Status := GetHealthStatusRed();
            StatusCaption := '✗';
            Description := 'Loan Application No. Series [' + MemberSetup."Loan Application Nos." + '] does NOT exist.';
        end;
    end;

    /// <summary>
    /// Check 5: Loan Receivable Account
    /// </summary>
    procedure CheckLoanReceivableAccount(var Status: Text; var StatusCaption: Text; var Description: Text)
    var
        MemberSetup: Record "Member Setup";
        GLAccount: Record "G/L Account";
    begin
        MemberSetup.GetOrCreateSetup();

        if MemberSetup."Loans Receivable Account" = '' then begin
            Status := GetHealthStatusAmber();
            StatusCaption := '⚠';
            Description := 'Loan Receivable Account is NOT configured. Loan posting will fail.';
            exit;
        end;

        // Check if the G/L account exists
        if GLAccount.Get(MemberSetup."Loans Receivable Account") then begin
            Status := GetHealthStatusGreen();
            StatusCaption := '✓';
            Description := 'Loans Receivable Account [' + MemberSetup."Loans Receivable Account" + '] is configured.';
        end
        else begin
            Status := GetHealthStatusRed();
            StatusCaption := '✗';
            Description := 'Loans Receivable Account [' + MemberSetup."Loans Receivable Account" + '] does NOT exist.';
        end;
    end;

    /// <summary>
    /// Check 6: Loan Disbursement Account
    /// </summary>
    procedure CheckLoanDisbursementAccount(var Status: Text; var StatusCaption: Text; var Description: Text)
    var
        MemberSetup: Record "Member Setup";
        GLAccount: Record "G/L Account";
    begin
        MemberSetup.GetOrCreateSetup();

        if MemberSetup."Loan Disbursement Account" = '' then begin
            Status := GetHealthStatusAmber();
            StatusCaption := '⚠';
            Description := 'Loan Disbursement Account is NOT configured. Loan posting will fail.';
            exit;
        end;

        // Check if the G/L account exists
        if GLAccount.Get(MemberSetup."Loan Disbursement Account") then begin
            Status := GetHealthStatusGreen();
            StatusCaption := '✓';
            Description := 'Loan Disbursement Account [' + MemberSetup."Loan Disbursement Account" + '] is configured.';
        end
        else begin
            Status := GetHealthStatusRed();
            StatusCaption := '✗';
            Description := 'Loan Disbursement Account [' + MemberSetup."Loan Disbursement Account" + '] does NOT exist.';
        end;
    end;

    /// <summary>
    /// Check 7: Rejection Email Template
    /// </summary>
    procedure CheckRejectionEmailTemplate(var Status: Text; var StatusCaption: Text; var Description: Text)
    var
        MemberSetup: Record "Member Setup";
        TemplateBlob: Codeunit "Temp Blob";
        TemplateText: Text;
        TemplateLength: Integer;
    begin
        MemberSetup.GetOrCreateSetup();

        // Check if template blob is empty
        if not MemberSetup."Rejection Email Template".HasValue() then begin
            Status := GetHealthStatusAmber();
            StatusCaption := '⚠';
            Description := 'Rejection Email Template is NOT configured. Rejection emails will not contain personalized content.';
            exit;
        end;

        Status := GetHealthStatusGreen();
        StatusCaption := '✓';
        Description := 'Rejection Email Template is configured.';
    end;

    /// <summary>
    /// Check 8: Email Account Configuration (informational)
    /// Note: Email Accounts are system tables - cannot fully validate from code
    /// This check provides guidance to admins
    /// </summary>
    procedure CheckEmailAccountConfigured(var Status: Text; var StatusCaption: Text; var Description: Text)
    begin
        // Email Accounts are stored in "Email Account" table, but limited direct access
        // This is informational - user must manually verify in Email Accounts settings
        Status := GetHealthStatusAmber();
        StatusCaption := '⚠';
        Description := 'EMAIL ACCOUNT: Check manually in Settings > Email Accounts. Welcome emails require this to be configured.';
    end;

    /// <summary>
    /// Check 9: Loan Members Count (informational)
    /// </summary>
    procedure CheckLoanApplicationsExist(var Status: Text; var StatusCaption: Text; var Description: Text)
    var
        LoanApplication: Record "Loan Application";
        LoanCount: Integer;
    begin
        LoanCount := LoanApplication.Count();

        if LoanCount = 0 then begin
            Status := GetHealthStatusGreen();
            StatusCaption := '✓';
            Description := 'Loan System: Ready (no loans yet).';
        end
        else begin
            Status := GetHealthStatusGreen();
            StatusCaption := '✓';
            Description := 'Loan Applications: ' + Format(LoanCount) + ' loan(s) registered in system.';
        end;
    end;

    /// <summary>
    /// Check 10: Members Count (informational)
    /// </summary>
    procedure CheckMembersExist(var Status: Text; var StatusCaption: Text; var Description: Text)
    var
        Member: Record Member;
        MemberCount: Integer;
    begin
        MemberCount := Member.Count();

        if MemberCount = 0 then begin
            Status := GetHealthStatusGreen();
            StatusCaption := '✓';
            Description := 'Members: No members registered yet.';
        end
        else begin
            Status := GetHealthStatusGreen();
            StatusCaption := '✓';
            Description := 'Members: ' + Format(MemberCount) + ' active member(s) in system.';
        end;
    end;

    /// <summary>
    /// Get overall health status:
    /// - Critical (Red) if ANY critical check failed
    /// - Amber if warnings but no critical issues
    /// - Green if all checks pass
    /// </summary>
    procedure GetOverallHealthStatus(var OverallStatus: Text): Text
    var
        Status: Text;
        StatusCaption: Text;
        Description: Text;
    begin
        // Check for critical issues
        CheckMemberSetupExists(Status, StatusCaption, Description);
        if Status = GetHealthStatusRed() then begin
            OverallStatus := GetHealthStatusRed();
            exit('CRITICAL: Required configuration is missing.');
        end;

        CheckMemberAppNoSeries(Status, StatusCaption, Description);
        if Status = GetHealthStatusRed() then begin
            OverallStatus := GetHealthStatusRed();
            exit('CRITICAL: Member Application No. Series is not valid.');
        end;

        CheckMemberCategoriesExist(Status, StatusCaption, Description);
        if Status = GetHealthStatusRed() then begin
            OverallStatus := GetHealthStatusRed();
            exit('CRITICAL: No Member Categories defined.');
        end;

        // Check for warnings
        CheckLoanAppNoSeries(Status, StatusCaption, Description);
        if Status = GetHealthStatusAmber() then begin
            OverallStatus := GetHealthStatusAmber();
        end;

        CheckLoanReceivableAccount(Status, StatusCaption, Description);
        if Status = GetHealthStatusAmber() then begin
            OverallStatus := GetHealthStatusAmber();
        end;

        CheckLoanDisbursementAccount(Status, StatusCaption, Description);
        if Status = GetHealthStatusAmber() then begin
            OverallStatus := GetHealthStatusAmber();
        end;

        // If we get here and OverallStatus is empty, we're good
        if OverallStatus = '' then begin
            OverallStatus := GetHealthStatusGreen();
            exit('All critical systems configured correctly.');
        end;

        exit('Some warnings - review configuration.');
    end;
}
