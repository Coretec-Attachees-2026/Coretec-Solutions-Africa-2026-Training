// ============================================================
// Codeunit 50109 - Loan Bulk Processing
// ============================================================
// PURPOSE: Handles bulk status updates on multiple loan applications
//          with validation, audit logging, and user feedback.
//
// HOW IT WORKS:
// 1. Receives selected records from list page via SetSelectionFilter
// 2. Validates each record (only updates if in correct current status)
// 3. Skips invalid records and shows summary feedback
// 4. Logs all changes to Audit Log table with batch ID
// 5. Shows Dialog with results: Updated count, Skipped count
//
// EDGE CASES HANDLED:
//   - Empty selection: Shows error message
//   - Mixed statuses: Skips records not in expected status
//   - Duplicate processing: Uses batch ID to track changes
// ============================================================

codeunit 50109 "Loan Bulk Processing"
{
    Permissions = tabledata "Loan Application" = m,
                  tabledata "Loan Application Audit Log" = i;

    /// <summary>
    /// Updates a batch of loan applications from one status to another.
    /// Called from Loan Application List page action.
    /// </summary>
    /// <param name="SourceLoanApp">Loan Application record with filters already applied</param>
    /// <param name="CurrentStatus">The status records must be in to be updated</param>
    /// <param name="NewStatus">The target status to set</param>
    /// <param name="Notes">Optional reason/notes for the audit log</param>
    procedure BulkUpdateLoanStatus(
        var SourceLoanApp: Record "Loan Application";
        CurrentStatus: Enum "Loan Application Status";
        NewStatus: Enum "Loan Application Status";
        Notes: Text[250])
    var
        LoanApp: Record "Loan Application";
        AuditLog: Record "Loan Application Audit Log";
        BatchID: Code[20];
        UpdatedCount: Integer;
        SkippedCount: Integer;
        DialogMsg: Text;
    begin
        // Check if any records are selected
        if not SourceLoanApp.FindSet() then begin
            Message('No records selected. Please select at least one loan application.');
            exit;
        end;

        // Generate unique batch ID for this bulk operation
        BatchID := CreateBatchID();

        // Initialize counters
        UpdatedCount := 0;
        SkippedCount := 0;

        // Loop through all selected records
        repeat
            LoanApp := SourceLoanApp;
            LoanApp.Find('=');

            // VALIDATION: Check if record is in the expected status
            if LoanApp.Status <> CurrentStatus then begin
                SkippedCount += 1;
                // Record reason for skipping
                LogAuditEntry(
                    LoanApp."Loan Application No.",
                    LoanApp.Status,
                    LoanApp.Status,
                    BatchID,
                    'SKIPPED: Current status is ' + Format(LoanApp.Status) + ', expected ' + Format(CurrentStatus)
                );
            end else begin
                // Update the status
                LoanApp.Status := NewStatus;
                LoanApp.Modify(false);

                // Log the change
                LogAuditEntry(
                    LoanApp."Loan Application No.",
                    CurrentStatus,
                    NewStatus,
                    BatchID,
                    Notes
                );

                UpdatedCount += 1;

                // If transitioning to Approved, we might set approval date
                if NewStatus = Enum::"Loan Application Status"::Approved then begin
                    if LoanApp."Approval Date" = 0D then begin
                        LoanApp."Approval Date" := Today();
                        LoanApp.Modify(false);
                    end;
                end;
            end;
        until SourceLoanApp.Next() = 0;

        // Build and show summary message
        DialogMsg := StrSubstNo(
            'Bulk Update Complete\' +
            '\Updated: %1 records\' +
            'Skipped: %2 records\' +
            '\Batch ID: %3',
            UpdatedCount,
            SkippedCount,
            BatchID
        );

        Message(DialogMsg);
    end;

    /// <summary>
    /// Logs an audit entry for a loan application status change.
    /// </summary>
    local procedure LogAuditEntry(
        LoanAppNo: Code[20];
        OldStatus: Enum "Loan Application Status";
        NewStatus: Enum "Loan Application Status";
        BatchID: Code[20];
        Notes: Text[250])
    var
        AuditLog: Record "Loan Application Audit Log";
    begin
        AuditLog.Init();
        AuditLog."Loan Application No." := LoanAppNo;
        AuditLog."Old Status" := OldStatus;
        AuditLog."New Status" := NewStatus;
        AuditLog."Change Date & Time" := CurrentDateTime();
        AuditLog."User ID" := UserId();
        AuditLog."Action Type" := AuditLog."Action Type"::"Bulk Update";
        AuditLog."Batch ID" := BatchID;
        AuditLog."Notes" := Notes;
        AuditLog.Insert(true);
    end;

    /// <summary>
    /// Creates a unique batch ID for grouping bulk changes.
    /// Format: "BULK-YYYYMMDD-HHMMSS"
    /// </summary>
    local procedure CreateBatchID(): Code[20]
    begin
        exit(
            'BULK-' +
            Format(Today(), 0, '<Year4><Month,2><Day,2>') + '-' +
            Format(Time(), 0, '<Hours24,2><Minutes,2><Seconds,2>')
        );
    end;
}
