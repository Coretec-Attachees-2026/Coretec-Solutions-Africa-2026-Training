// ============================================================
// Codeunit 50105 - Loan Management (UPDATED with SMS)
// ============================================================
// PURPOSE: All business logic for the loan workflow.
//
// SMS INTEGRATION CHANGE LOG:
//   Three points in the loan lifecycle now trigger an SMS:
//
//   1. SubmitForApproval()  → "Your loan has been submitted for review"
//      WHY HERE? The member submitted the loan, not a staff member.
//      They need immediate confirmation that the system received it.
//
//   2. PostLoan()           → "Your loan has been approved and disbursed"
//      WHY HERE? Disbursement is the most important event in the
//      member's experience — they need to know money is coming.
//
//   3. RejectLoan()         → "Your loan application was not approved"
//      WHY HERE? Fairness — if they get an SMS when approved,
//      they should also get one when rejected so they can plan.
//
// PATTERN USED (same in all three places):
//   1. Complete the business logic (status change, G/L posting, etc.)
//   2. Look up the Member record to get Phone Number + First Name
//   3. Call the appropriate SMSMgt.Send*SMS() procedure
//   All SMS calls are placed AFTER Message() so the staff member
//   sees confirmation even if SMS is temporarily misconfigured.
// ============================================================

codeunit 50105 "Loan Management"
{
    // -------------------------------------------------------
    // STEP 1: Submit for Approval  (+SMS)
    // -------------------------------------------------------
    procedure SubmitForApproval(var LoanApp: Record "Loan Application")
    var
        Member: Record "Member";
        SMSMgt: Codeunit "SMS Notification Mgt";   // ← SMS integration
    begin
        if LoanApp.Status <> Enum::"Loan Application Status"::Open then
            Error('Only loans with status "Open" can be submitted for approval.\Current status: %1', LoanApp.Status);

        if LoanApp."Member ID" = '' then
            Error('Please select a Member before submitting.');
        if LoanApp."Loan Amount" <= 0 then
            Error('Loan Amount must be greater than zero.');
        if LoanApp."Loan Term (Months)" <= 0 then
            Error('Loan Term must be at least 1 month.');
        if LoanApp."Interest Rate (%)" < 0 then
            Error('Interest Rate cannot be negative.');
        if LoanApp."Loan Purpose" = '' then
            Error('Please enter the Loan Purpose before submitting.');

        LoanApp.Status := Enum::"Loan Application Status"::"Pending Approval";
        LoanApp.Modify(true);

        LogAuditEntry('Submitted', 'Loan Application', LoanApp."Loan Application No.",
            StrSubstNo('Loan %1 submitted for approval. Amount: %2',
                LoanApp."Loan Application No.", LoanApp."Loan Amount"));

        Message('Loan %1 has been submitted for approval.', LoanApp."Loan Application No.");

        // ── SMS: Tell the member their application is under review ───────────
        // We look up the member here rather than carrying their phone number
        // on the Loan Application record, so we always get the current number
        // even if it was updated after the loan was created.
        if Member.Get(LoanApp."Member ID") then
            SMSMgt.SendLoanSubmittedSMS(
                Member."Phone Number",
                Member."First Name",
                LoanApp."Loan Application No.",
                LoanApp."Loan Amount");
    end;

    // -------------------------------------------------------
    // STEP 2: Approve Loan (triggers automatic disbursement)
    // -------------------------------------------------------
    // SMS is sent from PostLoan() (called below), not here,
    // because PostLoan() is where the money actually moves.
    // Sending the SMS after G/L posting is the correct moment —
    // "disbursed" means the accounting has been recorded.
    // -------------------------------------------------------
    procedure ApproveLoan(var LoanApp: Record "Loan Application")
    var
        Member: Record "Member";
    begin
        if LoanApp.Status <> Enum::"Loan Application Status"::"Pending Approval" then
            Error('Only loans with status "Pending Approval" can be approved.\Current status: %1', LoanApp.Status);

        Member.Get(LoanApp."Member ID");
        if Member.Status <> Enum::"Member Status"::Active then
            Error('Cannot approve loan — member %1 is not Active.\Current member status: %2',
                LoanApp."Member ID", Member.Status);

        LoanApp.Status          := Enum::"Loan Application Status"::Approved;
        LoanApp."Approval Date" := Today;
        LoanApp.Modify(true);

        // PostLoan() handles the G/L entries, Loan Ledger Entry, status →
        // Disbursed, AND the SMS notification for the member.
        PostLoan(LoanApp);
    end;

    // -------------------------------------------------------
    // STEP 3: Reject Loan  (+SMS)
    // -------------------------------------------------------
    procedure RejectLoan(var LoanApp: Record "Loan Application"; RejectionReason: Text[250])
    var
        Member: Record "Member";
        SMSMgt: Codeunit "SMS Notification Mgt";   // ← SMS integration
    begin
        if LoanApp.Status <> Enum::"Loan Application Status"::"Pending Approval" then
            Error('Only loans with status "Pending Approval" can be rejected.\Current status: %1', LoanApp.Status);
        if RejectionReason = '' then
            Error('Please provide a reason for rejection.');

        LoanApp.Status             := Enum::"Loan Application Status"::Rejected;
        LoanApp."Rejection Reason" := RejectionReason;
        LoanApp.Modify(true);

        LogAuditEntry('Rejected', 'Loan Application', LoanApp."Loan Application No.",
            StrSubstNo('Loan %1 rejected. Reason: %2',
                LoanApp."Loan Application No.", RejectionReason));

        Message('Loan %1 has been rejected.\Reason: %2',
            LoanApp."Loan Application No.", RejectionReason);

        // ── SMS: Inform member their application was unsuccessful ─────────────
        if Member.Get(LoanApp."Member ID") then
            SMSMgt.SendLoanRejectedSMS(
                Member."Phone Number",
                Member."First Name",
                LoanApp."Loan Application No.",
                RejectionReason);
    end;

    // -------------------------------------------------------
    // STEP 4: Post (Disburse) Loan  (+SMS)
    // -------------------------------------------------------
    procedure PostLoan(var LoanApp: Record "Loan Application")
    var
        MemberSetup: Record "Member Setup";
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        LoanLedgerEntry: Record "Loan Ledger Entry";
        Member: Record "Member";
        SMSMgt: Codeunit "SMS Notification Mgt";   // ← SMS integration
        DocumentNo: Code[20];
    begin
        if LoanApp.Status <> Enum::"Loan Application Status"::Approved then
            Error('Only approved loans can be posted.\Current status: %1', LoanApp.Status);
        if LoanApp.Posted then
            Error('This loan has already been posted.');

        MemberSetup.GetOrCreateSetup();
        if MemberSetup."Loans Receivable Account" = '' then
            Error('Please configure "Loans Receivable Account" in Member Setup before posting.');
        if MemberSetup."Loan Disbursement Account" = '' then
            Error('Please configure "Loan Disbursement Account" in Member Setup before posting.');

        DocumentNo := LoanApp."Loan Application No.";

        // DEBIT: Loans Receivable (member now owes us money)
        GenJnlLine.Init();
        GenJnlLine."Posting Date"          := Today;
        GenJnlLine."Document No."          := DocumentNo;
        GenJnlLine."Account Type"          := GenJnlLine."Account Type"::"G/L Account";
        GenJnlLine."Account No."           := MemberSetup."Loans Receivable Account";
        GenJnlLine.Description             := StrSubstNo('Loan disbursement - %1', LoanApp."Member Name");
        GenJnlLine.Validate(Amount, LoanApp."Loan Amount");
        GenJnlLine."Source Code"           := 'GENJNL';
        GenJnlLine."System-Created Entry"  := true;
        GenJnlPostLine.RunWithCheck(GenJnlLine);

        // CREDIT: Loan Disbursement / Bank (money leaves our account)
        GenJnlLine.Init();
        GenJnlLine."Posting Date"          := Today;
        GenJnlLine."Document No."          := DocumentNo;
        GenJnlLine."Account Type"          := GenJnlLine."Account Type"::"G/L Account";
        GenJnlLine."Account No."           := MemberSetup."Loan Disbursement Account";
        GenJnlLine.Description             := StrSubstNo('Loan disbursement - %1', LoanApp."Member Name");
        GenJnlLine.Validate(Amount, -LoanApp."Loan Amount");
        GenJnlLine."Source Code"           := 'GENJNL';
        GenJnlLine."System-Created Entry"  := true;
        GenJnlPostLine.RunWithCheck(GenJnlLine);

        // Loan Ledger Entry (our audit trail)
        LoanLedgerEntry.Init();
        LoanLedgerEntry."Loan Application No." := LoanApp."Loan Application No.";
        LoanLedgerEntry."Member ID"            := LoanApp."Member ID";
        LoanLedgerEntry."Member Name"          := LoanApp."Member Name";
        LoanLedgerEntry."Posting Date"         := Today;
        LoanLedgerEntry."Document No."         := DocumentNo;
        LoanLedgerEntry."Loan Amount"          := LoanApp."Loan Amount";
        LoanLedgerEntry."Interest Rate (%)"    := LoanApp."Interest Rate (%)";
        LoanLedgerEntry."Loan Term (Months)"   := LoanApp."Loan Term (Months)";
        LoanLedgerEntry."Total Interest"       := LoanApp."Total Interest";
        LoanLedgerEntry."Total Repayment"      := LoanApp."Total Repayment";
        LoanLedgerEntry.Description            := StrSubstNo('Loan disbursed to %1', LoanApp."Member Name");
        LoanLedgerEntry.Insert(true);

        // Update loan status to Disbursed
        LoanApp.Status              := Enum::"Loan Application Status"::Disbursed;
        LoanApp."Disbursement Date" := Today;
        LoanApp.Posted              := true;
        LoanApp."Document No."      := DocumentNo;
        LoanApp.Modify(true);

        // Update member account balance (balance decreases — they owe us)
        Member.Get(LoanApp."Member ID");
        Member."Account Balance" -= LoanApp."Loan Amount";
        Member.Modify(true);

        LogAuditEntry('Disbursed', 'Loan Application', LoanApp."Loan Application No.",
            StrSubstNo('Loan %1 disbursed. Amount: %2, Document No.: %3',
                LoanApp."Loan Application No.", LoanApp."Loan Amount", DocumentNo));

        Message('Loan %1 has been posted successfully!\Amount: %2\Document No.: %3',
            LoanApp."Loan Application No.",
            LoanApp."Loan Amount",
            DocumentNo);

        // ── SMS: Notify member that their money is disbursed ─────────────────
        // This is sent AFTER the G/L posting succeeds and AFTER Message().
        // If posting fails (e.g. G/L account not found) an Error() is thrown
        // above and we never reach this line — so SMS is only sent when
        // the accounting is actually committed.
        SMSMgt.SendLoanDisbursedSMS(
            Member."Phone Number",
            Member."First Name",
            LoanApp."Loan Application No.",
            LoanApp."Loan Amount");
    end;

    // -------------------------------------------------------
    // STEP 5: Record Repayment (no SMS — repayments are frequent,
    // an SMS on every payment would be annoying.  Add one here
    // if your SACCO wants a payment-received confirmation.)
    // -------------------------------------------------------
    procedure RecordRepayment(var LoanApp: Record "Loan Application"; PaymentAmount: Decimal)
    var
        MemberSetup: Record "Member Setup";
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        LoanRepayment: Record "Loan Repayment";
        Member: Record "Member";
        DocumentNo: Code[20];
        TotalPaid: Decimal;
        RemainingBefore: Decimal;
        RemainingAfter: Decimal;
        InterestPortion: Decimal;
        PrincipalPortion: Decimal;
    begin
        if not (LoanApp.Status in [Enum::"Loan Application Status"::Disbursed,
                                    Enum::"Loan Application Status"::"Partially Paid"]) then
            Error('Only disbursed or partially paid loans can receive repayments.\Current status: %1', LoanApp.Status);
        if PaymentAmount <= 0 then
            Error('Payment amount must be greater than zero.');

        TotalPaid       := GetTotalRepayments(LoanApp."Loan Application No.");
        RemainingBefore := LoanApp."Total Repayment" - TotalPaid;

        if RemainingBefore <= 0 then
            Error('This loan has already been fully repaid.');
        if PaymentAmount > RemainingBefore then
            Error('Payment amount (%1) exceeds outstanding balance (%2).', PaymentAmount, RemainingBefore);

        MemberSetup.GetOrCreateSetup();

        if LoanApp."Total Repayment" > 0 then
            InterestPortion := Round(PaymentAmount * (LoanApp."Total Interest" / LoanApp."Total Repayment"), 0.01)
        else
            InterestPortion := 0;
        PrincipalPortion := PaymentAmount - InterestPortion;
        RemainingAfter   := RemainingBefore - PaymentAmount;

        DocumentNo := CopyStr(
            LoanApp."Loan Application No." + '-R' +
            Format(GetRepaymentCount(LoanApp."Loan Application No.") + 1, 0, '<Integer,3>'),
            1, MaxStrLen(DocumentNo));

        // DEBIT: Bank (money coming in from the member)
        GenJnlLine.Init();
        GenJnlLine."Posting Date"         := Today;
        GenJnlLine."Document No."         := DocumentNo;
        GenJnlLine."Account Type"         := GenJnlLine."Account Type"::"G/L Account";
        GenJnlLine."Account No."          := MemberSetup."Loan Disbursement Account";
        GenJnlLine.Description            := StrSubstNo('Loan repayment - %1', LoanApp."Member Name");
        GenJnlLine.Validate(Amount, PaymentAmount);
        GenJnlLine."Source Code"          := 'GENJNL';
        GenJnlLine."System-Created Entry" := true;
        GenJnlPostLine.RunWithCheck(GenJnlLine);

        // CREDIT: Loans Receivable (debt is decreasing)
        GenJnlLine.Init();
        GenJnlLine."Posting Date"         := Today;
        GenJnlLine."Document No."         := DocumentNo;
        GenJnlLine."Account Type"         := GenJnlLine."Account Type"::"G/L Account";
        GenJnlLine."Account No."          := MemberSetup."Loans Receivable Account";
        GenJnlLine.Description            := StrSubstNo('Loan repayment - %1', LoanApp."Member Name");
        GenJnlLine.Validate(Amount, -PaymentAmount);
        GenJnlLine."Source Code"          := 'GENJNL';
        GenJnlLine."System-Created Entry" := true;
        GenJnlPostLine.RunWithCheck(GenJnlLine);

        LoanRepayment.Init();
        LoanRepayment."Loan Application No." := LoanApp."Loan Application No.";
        LoanRepayment."Member ID"            := LoanApp."Member ID";
        LoanRepayment."Member Name"          := LoanApp."Member Name";
        LoanRepayment."Payment Date"         := Today;
        LoanRepayment."Amount Paid"          := PaymentAmount;
        LoanRepayment."Principal Applied"    := PrincipalPortion;
        LoanRepayment."Interest Applied"     := InterestPortion;
        LoanRepayment."Remaining Balance"    := RemainingAfter;
        LoanRepayment."Document No."         := DocumentNo;
        LoanRepayment.Description            := StrSubstNo('Loan repayment for %1', LoanApp."Loan Application No.");
        LoanRepayment.Insert(true);

        Member.Get(LoanApp."Member ID");
        Member."Account Balance" += PaymentAmount;
        Member.Modify(true);

        if RemainingAfter <= 0 then
            LoanApp.Status := Enum::"Loan Application Status"::"Fully Paid"
        else
            LoanApp.Status := Enum::"Loan Application Status"::"Partially Paid";
        LoanApp.Modify(true);

        LogAuditEntry('Repayment', 'Loan Application', LoanApp."Loan Application No.",
            StrSubstNo('Repayment of %1 recorded for loan %2. Remaining: %3',
                PaymentAmount, LoanApp."Loan Application No.", RemainingAfter));

        Message('Payment of %1 recorded for loan %2.\Remaining balance: %3',
            PaymentAmount, LoanApp."Loan Application No.", RemainingAfter);
    end;

    // -------------------------------------------------------
    // Local helpers
    // -------------------------------------------------------
    local procedure GetTotalRepayments(LoanApplicationNo: Code[20]): Decimal
    var
        LoanRepayment: Record "Loan Repayment";
    begin
        LoanRepayment.SetRange("Loan Application No.", LoanApplicationNo);
        LoanRepayment.CalcSums("Amount Paid");
        exit(LoanRepayment."Amount Paid");
    end;

    local procedure GetRepaymentCount(LoanApplicationNo: Code[20]): Integer
    var
        LoanRepayment: Record "Loan Repayment";
    begin
        LoanRepayment.SetRange("Loan Application No.", LoanApplicationNo);
        exit(LoanRepayment.Count);
    end;

    local procedure LogAuditEntry(
        ActionType: Text[50];
        DocumentType: Text[50];
        DocumentNo: Code[20];
        Description: Text[250])
    var
        AuditLog: Record "Application Audit Log";
    begin
        AuditLog.Init();
        AuditLog."Date-Time"     := CurrentDateTime;
        AuditLog."User ID"       := CopyStr(UserId, 1, 50);
        AuditLog."Action Type"   := ActionType;
        AuditLog."Document Type" := DocumentType;
        AuditLog."Document No."  := DocumentNo;
        AuditLog.Description     := Description;
        AuditLog.Insert(true);
    end;
}
