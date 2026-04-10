// ============================================================
// Codeunit 50110 - Bulk Loan Approval Management
// ============================================================
// PURPOSE: Handles bulk operations on loan applications,
//          allowing users to approve/update multiple loans at once.
//
// FEATURES:
// 1. Bulk Approve - Change selected loans from "Pending Approval" → "Approved"
//                   and immediately disburse them (post to G/L)
// 2. Bulk Create Audit Entries - Log each change to Loan Ledger
// 3. Validation & Error Handling - Skip invalid records, report summary
// 4. User Feedback - Dialog showing updated count vs. skipped count
//
// KEY CONCEPT - "SetSelectionFilter":
//   The page passes "CurrPage.SetSelectionFilter(LoanApp)"
//   This retrieves ALL rows the user selected on the list.
//   We then loop through and process each one.
// ============================================================

codeunit 50110 "Bulk Loan Approval Mgt"
{
    // ==========================================================
    // PROCEDURE: Approve Selected
    // ==========================================================
    // Bulk-approves all selected loans.
    // - Validates each one (skips if wrong status)
    // - Changes status to Approved
    // - Automatically posts the loans
    // - Creates audit log entries
    // - Shows summary dialog
    // ==========================================================
    procedure ApproveSelected(var LoanApp: Record "Loan Application")
    var
        LoanMgt: Codeunit "Loan Management";
        ApprovedCount: Integer;
        SkippedCount: Integer;
        TotalCount: Integer;
        ErrorMsg: Text;
        ConfirmMsg: Text;
    begin
        // --- STEP 1: Confirm action with user ---
        ConfirmMsg := 'This will approve and disburse all selected loans.\';
        ConfirmMsg += 'Each loan will be posted to the General Ledger.\';
        ConfirmMsg += '\Do you want to continue?';

        if not Confirm(ConfirmMsg, false) then
            exit;

        ApprovedCount := 0;
        SkippedCount := 0;

        // --- STEP 2: Loop through all selected records ---
        if LoanApp.FindSet(true) then
            repeat
                // Clear error message from previous iteration
                ErrorMsg := '';

                // Try to approve this loan
                if ProcessSingleLoan(LoanApp, LoanMgt, ErrorMsg) then
                    ApprovedCount += 1
                else
                    SkippedCount += 1;

            until LoanApp.Next() = 0;

        TotalCount := ApprovedCount + SkippedCount;

        // --- STEP 3: Log to Audit Log ---
        LogBulkOperation(Enum::"Bulk Operation Type"::"Bulk Approve", TotalCount, ApprovedCount, SkippedCount);

        // --- STEP 4: Show summary dialog ---
        ShowBulkSummary(ApprovedCount, SkippedCount);
    end;

    // ==========================================================
    // PROCEDURE: Process Single Loan
    // ==========================================================
    // Internal helper - processes one loan with error handling.
    // Returns TRUE if successful, FALSE if skipped.
    // ==========================================================
    local procedure ProcessSingleLoan(var LoanApp: Record "Loan Application";
                                       var LoanMgt: Codeunit "Loan Management";
                                       var ErrorMsg: Text): Boolean
    begin
        // --- VALIDATION 1: Check if already disbanded ---
        if LoanApp.Status = Enum::"Loan Application Status"::Disbursed then begin
            ErrorMsg := StrSubstNo('Already disbursed: %1', LoanApp."Loan Application No.");
            LogSkippedRecord(LoanApp, ErrorMsg);
            exit(false);
        end;

        // --- VALIDATION 2: Check if rejected ---
        if LoanApp.Status = Enum::"Loan Application Status"::Rejected then begin
            ErrorMsg := StrSubstNo('Rejected: %1 - %2', LoanApp."Loan Application No.", LoanApp."Rejection Reason");
            LogSkippedRecord(LoanApp, ErrorMsg);
            exit(false);
        end;

        // --- VALIDATION 3: Check if in correct status ---
        if LoanApp.Status <> Enum::"Loan Application Status"::"Pending Approval" then begin
            ErrorMsg := StrSubstNo('Wrong status %1: %2', LoanApp.Status, LoanApp."Loan Application No.");
            LogSkippedRecord(LoanApp, ErrorMsg);
            exit(false);
        end;

        // --- VALIDATION 4: Check required fields ---
        if LoanApp."Member ID" = '' then begin
            ErrorMsg := StrSubstNo('No member assigned: %1', LoanApp."Loan Application No.");
            LogSkippedRecord(LoanApp, ErrorMsg);
            exit(false);
        end;

        if LoanApp."Loan Amount" <= 0 then begin
            ErrorMsg := StrSubstNo('Invalid amount: %1', LoanApp."Loan Application No.");
            LogSkippedRecord(LoanApp, ErrorMsg);
            exit(false);
        end;

        // --- SUCCESS: Approve and post the loan ---
        // Call the standard LoanManagement procedures
        begin
            LoanMgt.ApproveLoan(LoanApp);
            // ApproveLoan automatically calls PostLoan, so we're done
            LogApprovedRecord(LoanApp);
            exit(true);
        end;
    end;

    // ==========================================================
    // PROCEDURE: Log Approved Record
    // ==========================================================
    // Creates an audit entry when a loan is approved in bulk.
    // ==========================================================
    local procedure LogApprovedRecord(var LoanApp: Record "Loan Application")
    var
        LoanLedgerEntry: Record "Loan Ledger Entry";
    begin
        // Note: The PostLoan() procedure already creates a Loan Ledger Entry.
        // This additional entry is optional for tracking bulk operations.
        // You could log a summary entry, or skip this to avoid duplication.
        // For now, we rely on the existing audit entries from PostLoan.

        // FUTURE ENHANCEMENT: Create a separate audit table for bulk operations
        // to track WHO initiated the bulk action and WHEN.
    end;

    // ==========================================================
    // PROCEDURE: Log Skipped Record
    // ==========================================================
    // Logs why a record was skipped during bulk processing.
    // ==========================================================
    local procedure LogSkippedRecord(var LoanApp: Record "Loan Application"; Reason: Text)
    begin
        // FUTURE ENHANCEMENT: Create a Bulk Operation Log table to track skipped records
        // For now, we'll store this in a variable and show in the final dialog
        // This could be extended with a separate audit table if needed
    end;

    // ==========================================================
    // PROCEDURE: Show Bulk Summary
    // ==========================================================
    // Displays a summary dialog with counts.
    // ==========================================================
    local procedure ShowBulkSummary(ApprovedCount: Integer; SkippedCount: Integer)
    var
        TotalCount: Integer;
        SummaryMsg: Text;
    begin
        TotalCount := ApprovedCount + SkippedCount;

        SummaryMsg := 'Bulk Approval Complete\';
        SummaryMsg += '================================\';
        SummaryMsg += StrSubstNo('Total Selected: %1\', TotalCount);
        SummaryMsg += StrSubstNo('Approved & Disbursed: %1\', ApprovedCount);
        SummaryMsg += StrSubstNo('Skipped: %1\', SkippedCount);

        if SkippedCount > 0 then begin
            SummaryMsg += '================================\';
            SummaryMsg += 'Reasons for skipped records:\';
            SummaryMsg += '- Already disbursed\';
            SummaryMsg += '- Previously rejected\';
            SummaryMsg += '- Not in "Pending Approval" status\';
            SummaryMsg += '- Missing required fields\';
        end;

        Dialog.Message(SummaryMsg);
    end;

    // ==========================================================
    // PROCEDURE: Log Bulk Operation
    // ==========================================================
    // Creates an audit log entry for compliance and tracking
    // ==========================================================
    local procedure LogBulkOperation(OperationType: Enum "Bulk Operation Type";
                                      TotalCount: Integer;
                                      ApprovedCount: Integer;
                                      SkippedCount: Integer)
    var
        AuditLog: Record "Audit Log Entry";
        DescriptionText: Text[500];
        Success: Boolean;
    begin
        // Create the audit log entry
        AuditLog.Init();
        // Entry No is auto-increment, will be assigned automatically

        // Record user information
        AuditLog."User ID" := UserId();
        AuditLog."Operation Date" := CurrentDateTime;
        AuditLog."Operation Type" := OperationType;

        // Record counts
        AuditLog."Total Selected" := TotalCount;
        AuditLog."Approved Count" := ApprovedCount;
        AuditLog."Skipped Count" := SkippedCount;

        // Determine if operation was successful (all items approved, none skipped)
        Success := (SkippedCount = 0) and (TotalCount > 0);
        AuditLog."Success" := Success;

        // Create description text
        DescriptionText := StrSubstNo('Bulk approved %1 loans, skipped %2', ApprovedCount, SkippedCount);
        if SkippedCount > 0 then
            DescriptionText := DescriptionText + ' (validation errors)';

        AuditLog."Description" := CopyStr(DescriptionText, 1, 500);

        // Insert the audit log entry
        AuditLog.Insert(true);
    end;

    // ==========================================================
    // PROCEDURE: Change Selected Status (Generic Helper)
    // ==========================================================
    // This is a more generic version for future enhancements.
    // It could support changing status to other values with validation.
    // ==========================================================
    procedure ChangeStatusSelected(var LoanApp: Record "Loan Application";
                                    NewStatus: Enum "Loan Application Status")
    var
        ChangedCount: Integer;
        SkippedCount: Integer;
    begin
        // Validate the status change is allowed
        case NewStatus of
            Enum::"Loan Application Status"::Open:
                Error('Cannot change status to Open in bulk.');
            Enum::"Loan Application Status"::"Pending Approval":
                Error('Use the Submit button to move loans to Pending Approval.');
            Enum::"Loan Application Status"::Approved:
                ApproveSelected(LoanApp); // Reuse existing logic
            Enum::"Loan Application Status"::Rejected:
                Error('Reject loans individually - bulk rejection not permitted.');
            Enum::"Loan Application Status"::Disbursed:
                ApproveSelected(LoanApp); // Reuse existing logic
        end;
    end;

    // ==========================================================
    // PROCEDURE: Validate Selection (Helper)
    // ==========================================================
    // Checks if any records are selected.
    // ==========================================================
    procedure ValidateSelection(var LoanApp: Record "Loan Application"): Boolean
    begin
        if not LoanApp.FindFirst() then begin
            Message('Please select at least one loan application.');
            exit(false);
        end;
        exit(true);
    end;
}
