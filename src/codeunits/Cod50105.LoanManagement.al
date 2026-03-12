// ============================================================
// Codeunit 50105 - Loan Management
// ============================================================
// PURPOSE: Contains all the business logic for the loan workflow.
//
// WORKFLOW STEPS (each is a procedure below):
//
//   1. SubmitForApproval()  →  Changes status from Open → Pending Approval
//                              Validates that all required fields are filled in
//
//   2. ApproveLoan()        →  Changes status from Pending Approval → Approved
//                              Records the approval date
//                              THEN AUTOMATICALLY calls PostLoan() to disburse!
//
//   3. RejectLoan()         →  Changes status from Pending Approval → Rejected
//                              Records the rejection reason
//
//   4. PostLoan()           →  (Called automatically by ApproveLoan)
//                              Changes status from Approved → Disbursed
//                              Creates General Ledger entries (the accounting part)
//                              Creates a Loan Ledger Entry (our audit log)
//
// KEY CONCEPT - "Automatic Disbursement":
//   When a loan officer clicks "Approve", the system:
//     a) Approves the loan (status → Approved)
//     b) Immediately posts it to the G/L (status → Disbursed)
//   This is done in ONE click instead of two.
//   The PostLoan procedure is still separate for clean code,
//   but ApproveLoan calls it automatically at the end.
//
// KEY CONCEPT - "Separation of Concerns":
//   We keep business logic in Codeunits (not in Pages or Tables).
//   This makes the code reusable, testable, and clean.
//   The Page just calls these procedures when user clicks a button.
// ============================================================

codeunit 50105 "Loan Management"
{
    // -------------------------------------------------------
    // STEP 1: Submit for Approval
    // -------------------------------------------------------
    // The member has filled in their loan details.
    // This procedure validates everything and moves the loan
    // to "Pending Approval" status for a loan officer to review.
    // -------------------------------------------------------
    procedure SubmitForApproval(var LoanApp: Record "Loan Application")
    begin
        // --- VALIDATION: Make sure loan is in "Open" status ---
        // You can only submit a loan that hasn't been submitted yet
        if LoanApp.Status <> Enum::"Loan Application Status"::Open then
            Error('Only loans with status "Open" can be submitted for approval.\Current status: %1', LoanApp.Status);

        // --- VALIDATION: Required fields must be filled ---
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

        // --- All checks passed, change the status ---
        LoanApp.Status := Enum::"Loan Application Status"::"Pending Approval";
        LoanApp.Modify(true);

        LogAuditEntry('Submitted', 'Loan Application', LoanApp."Loan Application No.",
            StrSubstNo('Loan %1 submitted for approval. Amount: %2', LoanApp."Loan Application No.", LoanApp."Loan Amount"));

        Message('Loan %1 has been submitted for approval.', LoanApp."Loan Application No.");
    end;

    // -------------------------------------------------------
    // STEP 2: Approve Loan (+ Automatic Disbursement)
    // -------------------------------------------------------
    // A loan officer reviews and approves the loan.
    // After approval, PostLoan() is called AUTOMATICALLY
    // so the loan is disbursed in the same action.
    //
    // BEFORE (2 clicks):  Approve → Post Loan
    // NOW    (1 click):   Approve (posting happens automatically)
    // -------------------------------------------------------
    procedure ApproveLoan(var LoanApp: Record "Loan Application")
    var
        Member: Record "Member";
    begin
        // Can only approve loans that are "Pending Approval"
        if LoanApp.Status <> Enum::"Loan Application Status"::"Pending Approval" then
            Error('Only loans with status "Pending Approval" can be approved.\Current status: %1', LoanApp.Status);

        // Verify the member is still Active before approving the loan.
        // A member could have been suspended/closed after submitting.
        Member.Get(LoanApp."Member ID");
        if Member.Status <> Enum::"Member Status"::Active then
            Error('Cannot approve loan — member %1 is not Active.\Current member status: %2',
                LoanApp."Member ID", Member.Status);

        // Step A: Mark the loan as Approved
        LoanApp.Status := Enum::"Loan Application Status"::Approved;
        LoanApp."Approval Date" := Today;
        LoanApp.Modify(true);

        // Step B: Automatically post/disburse the loan
        // This calls PostLoan() which creates the G/L entries,
        // Loan Ledger Entry, and sets status to Disbursed.
        PostLoan(LoanApp);

        // NOTE: We don't show a separate "approved" message here
        // because PostLoan() already shows a success message
        // that confirms everything was done.
    end;

    // -------------------------------------------------------
    // STEP 3: Reject Loan
    // -------------------------------------------------------
    // A loan officer rejects the loan with a reason.
    // The loan cannot proceed further after rejection.
    // -------------------------------------------------------
    procedure RejectLoan(var LoanApp: Record "Loan Application"; RejectionReason: Text[250])
    begin
        // Can only reject loans that are "Pending Approval"
        if LoanApp.Status <> Enum::"Loan Application Status"::"Pending Approval" then
            Error('Only loans with status "Pending Approval" can be rejected.\Current status: %1', LoanApp.Status);

        if RejectionReason = '' then
            Error('Please provide a reason for rejection.');

        LoanApp.Status := Enum::"Loan Application Status"::Rejected;
        LoanApp."Rejection Reason" := RejectionReason;
        LoanApp.Modify(true);

        LogAuditEntry('Rejected', 'Loan Application', LoanApp."Loan Application No.",
            StrSubstNo('Loan %1 rejected. Reason: %2', LoanApp."Loan Application No.", RejectionReason));

        Message('Loan %1 has been rejected.\Reason: %2', LoanApp."Loan Application No.", RejectionReason);
    end;

    // -------------------------------------------------------
    // STEP 4: Post (Disburse) Loan
    // -------------------------------------------------------
    // This is the big one! It does THREE things:
    //   a) Posts to the General Ledger (accounting entries)
    //   b) Creates a Loan Ledger Entry (our audit log)
    //   c) Updates the loan status to "Disbursed"
    //
    // WHAT IS POSTING?
    //   "Posting" in BC means creating permanent accounting entries.
    //   Once posted, it cannot be undone (only reversed with a new entry).
    //
    // DOUBLE-ENTRY BOOKKEEPING:
    //   Every financial transaction has TWO sides:
    //     DEBIT  = Loans Receivable (member now owes us money → asset goes UP)
    //     CREDIT = Bank Account     (money left our bank → asset goes DOWN)
    //   Debits ALWAYS equal Credits. This keeps the books balanced.
    // -------------------------------------------------------
    procedure PostLoan(var LoanApp: Record "Loan Application")
    var
        MemberSetup: Record "Member Setup";
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        LoanLedgerEntry: Record "Loan Ledger Entry";
        Member: Record "Member";
        DocumentNo: Code[20];
    begin
        // --- VALIDATION ---
        if LoanApp.Status <> Enum::"Loan Application Status"::Approved then
            Error('Only approved loans can be posted.\Current status: %1', LoanApp.Status);

        if LoanApp.Posted then
            Error('This loan has already been posted.');

        // --- GET SETUP (G/L Accounts) ---
        MemberSetup.GetOrCreateSetup();

        if MemberSetup."Loans Receivable Account" = '' then
            Error('Please configure "Loans Receivable Account" in Member Setup before posting.');

        if MemberSetup."Loan Disbursement Account" = '' then
            Error('Please configure "Loan Disbursement Account" in Member Setup before posting.');

        // --- GENERATE DOCUMENT NUMBER ---
        // The Document No. groups related G/L entries together
        DocumentNo := LoanApp."Loan Application No.";

        // =============================================
        // POST ENTRY 1: DEBIT - Loans Receivable
        // =============================================
        // This increases the "Loans Receivable" asset account
        // because the member now owes us money.
        //
        // GenJnlLine is a "General Journal Line" - it's the
        // standard way to create G/L entries in Business Central.
        // We fill in the fields and then call GenJnlPostLine.RunWithCheck()
        // which validates and posts it to the G/L.
        // =============================================
        GenJnlLine.Init();
        GenJnlLine."Posting Date" := Today;
        GenJnlLine."Document No." := DocumentNo;
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
        GenJnlLine."Account No." := MemberSetup."Loans Receivable Account";
        GenJnlLine.Description := StrSubstNo('Loan disbursement - %1', LoanApp."Member Name");
        // Positive amount in "Debit Amount" = money coming IN to this account
        GenJnlLine.Validate(Amount, LoanApp."Loan Amount");
        GenJnlLine."Source Code" := 'GENJNL';
        GenJnlLine."System-Created Entry" := true;
        GenJnlPostLine.RunWithCheck(GenJnlLine);

        // =============================================
        // POST ENTRY 2: CREDIT - Loan Disbursement (Bank)
        // =============================================
        // This decreases the bank account because money is going out.
        // Notice the NEGATIVE amount - that's what makes it a credit.
        // =============================================
        GenJnlLine.Init();
        GenJnlLine."Posting Date" := Today;
        GenJnlLine."Document No." := DocumentNo;
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
        GenJnlLine."Account No." := MemberSetup."Loan Disbursement Account";
        GenJnlLine.Description := StrSubstNo('Loan disbursement - %1', LoanApp."Member Name");
        // Negative amount = CREDIT (money going OUT of this account)
        GenJnlLine.Validate(Amount, -LoanApp."Loan Amount");
        GenJnlLine."Source Code" := 'GENJNL';
        GenJnlLine."System-Created Entry" := true;
        GenJnlPostLine.RunWithCheck(GenJnlLine);

        // =============================================
        // CREATE LOAN LEDGER ENTRY (our audit log)
        // =============================================
        LoanLedgerEntry.Init();
        LoanLedgerEntry."Loan Application No." := LoanApp."Loan Application No.";
        LoanLedgerEntry."Member ID" := LoanApp."Member ID";
        LoanLedgerEntry."Member Name" := LoanApp."Member Name";
        LoanLedgerEntry."Posting Date" := Today;
        LoanLedgerEntry."Document No." := DocumentNo;
        LoanLedgerEntry."Loan Amount" := LoanApp."Loan Amount";
        LoanLedgerEntry."Interest Rate (%)" := LoanApp."Interest Rate (%)";
        LoanLedgerEntry."Loan Term (Months)" := LoanApp."Loan Term (Months)";
        LoanLedgerEntry."Total Interest" := LoanApp."Total Interest";
        LoanLedgerEntry."Total Repayment" := LoanApp."Total Repayment";
        LoanLedgerEntry.Description := StrSubstNo('Loan disbursed to %1', LoanApp."Member Name");
        LoanLedgerEntry.Insert(true);

        // =============================================
        // UPDATE LOAN APPLICATION STATUS
        // =============================================
        LoanApp.Status := Enum::"Loan Application Status"::Disbursed;
        LoanApp."Disbursement Date" := Today;
        LoanApp.Posted := true;
        LoanApp."Document No." := DocumentNo;
        LoanApp.Modify(true);

        // =============================================
        // UPDATE MEMBER ACCOUNT BALANCE
        // =============================================
        // Disbursing a loan decreases the member's account balance
        // (they now owe money to the SACCO)
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
    end;

    // -------------------------------------------------------
    // STEP 5: Record Repayment
    // -------------------------------------------------------
    // PURPOSE: Records a loan repayment from a member.
    //
    // WHAT HAPPENS:
    //   1. Validates the loan is in a repayable state (Disbursed or Partially Paid)
    //   2. Calculates how much goes to interest vs principal
    //   3. Posts G/L entries (reverse of disbursement)
    //   4. Creates a Loan Repayment record
    //   5. Updates member Account Balance
    //   6. Updates loan status (Partially Paid or Fully Paid)
    //
    // SIMPLE INTEREST ALLOCATION:
    //   Interest portion = (Payment / Total Repayment) × Total Interest
    //   Principal portion = Payment - Interest portion
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
        // --- VALIDATION ---
        if not (LoanApp.Status in [Enum::"Loan Application Status"::Disbursed,
                                    Enum::"Loan Application Status"::"Partially Paid"]) then
            Error('Only disbursed or partially paid loans can receive repayments.\Current status: %1', LoanApp.Status);

        if PaymentAmount <= 0 then
            Error('Payment amount must be greater than zero.');

        // Calculate how much has been paid so far
        TotalPaid := GetTotalRepayments(LoanApp."Loan Application No.");
        RemainingBefore := LoanApp."Total Repayment" - TotalPaid;

        if RemainingBefore <= 0 then
            Error('This loan has already been fully repaid.');

        // Don't allow overpayment
        if PaymentAmount > RemainingBefore then
            Error('Payment amount (%1) exceeds outstanding balance (%2).', PaymentAmount, RemainingBefore);

        // --- GET SETUP (G/L Accounts) ---
        MemberSetup.GetOrCreateSetup();

        // --- CALCULATE INTEREST vs PRINCIPAL SPLIT ---
        if LoanApp."Total Repayment" > 0 then
            InterestPortion := Round(PaymentAmount * (LoanApp."Total Interest" / LoanApp."Total Repayment"), 0.01)
        else
            InterestPortion := 0;
        PrincipalPortion := PaymentAmount - InterestPortion;

        RemainingAfter := RemainingBefore - PaymentAmount;

        // --- GENERATE DOCUMENT NUMBER ---
        // Append a unique repayment counter (e.g., '-R001', '-R002')
        // to avoid duplicate G/L document numbers across repayments
        DocumentNo := CopyStr(
            LoanApp."Loan Application No." + '-R' + Format(GetRepaymentCount(LoanApp."Loan Application No.") + 1, 0, '<Integer,3>'),
            1, MaxStrLen(DocumentNo));

        // =============================================
        // POST ENTRY 1: DEBIT - Bank (money coming in)
        // =============================================
        GenJnlLine.Init();
        GenJnlLine."Posting Date" := Today;
        GenJnlLine."Document No." := DocumentNo;
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
        GenJnlLine."Account No." := MemberSetup."Loan Disbursement Account";
        GenJnlLine.Description := StrSubstNo('Loan repayment - %1', LoanApp."Member Name");
        GenJnlLine.Validate(Amount, PaymentAmount);
        GenJnlLine."Source Code" := 'GENJNL';
        GenJnlLine."System-Created Entry" := true;
        GenJnlPostLine.RunWithCheck(GenJnlLine);

        // =============================================
        // POST ENTRY 2: CREDIT - Loans Receivable (debt decreasing)
        // =============================================
        GenJnlLine.Init();
        GenJnlLine."Posting Date" := Today;
        GenJnlLine."Document No." := DocumentNo;
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
        GenJnlLine."Account No." := MemberSetup."Loans Receivable Account";
        GenJnlLine.Description := StrSubstNo('Loan repayment - %1', LoanApp."Member Name");
        GenJnlLine.Validate(Amount, -PaymentAmount);
        GenJnlLine."Source Code" := 'GENJNL';
        GenJnlLine."System-Created Entry" := true;
        GenJnlPostLine.RunWithCheck(GenJnlLine);

        // =============================================
        // CREATE LOAN REPAYMENT RECORD
        // =============================================
        LoanRepayment.Init();
        LoanRepayment."Loan Application No." := LoanApp."Loan Application No.";
        LoanRepayment."Member ID" := LoanApp."Member ID";
        LoanRepayment."Member Name" := LoanApp."Member Name";
        LoanRepayment."Payment Date" := Today;
        LoanRepayment."Amount Paid" := PaymentAmount;
        LoanRepayment."Principal Applied" := PrincipalPortion;
        LoanRepayment."Interest Applied" := InterestPortion;
        LoanRepayment."Remaining Balance" := RemainingAfter;
        LoanRepayment."Document No." := DocumentNo;
        LoanRepayment.Description := StrSubstNo('Loan repayment for %1', LoanApp."Loan Application No.");
        LoanRepayment.Insert(true);

        // =============================================
        // UPDATE MEMBER ACCOUNT BALANCE
        // =============================================
        Member.Get(LoanApp."Member ID");
        Member."Account Balance" += PaymentAmount;
        Member.Modify(true);

        // =============================================
        // UPDATE LOAN STATUS
        // =============================================
        if RemainingAfter <= 0 then
            LoanApp.Status := Enum::"Loan Application Status"::"Fully Paid"
        else
            LoanApp.Status := Enum::"Loan Application Status"::"Partially Paid";
        LoanApp.Modify(true);

        LogAuditEntry('Repayment', 'Loan Application', LoanApp."Loan Application No.",
            StrSubstNo('Repayment of %1 recorded for loan %2. Remaining: %3',
                PaymentAmount, LoanApp."Loan Application No.", RemainingAfter));

        Message('Payment of %1 recorded for loan %2.\Remaining balance: %3',
            PaymentAmount,
            LoanApp."Loan Application No.",
            RemainingAfter);
    end;

    // -------------------------------------------------------
    // GetTotalRepayments (local helper)
    // -------------------------------------------------------
    // PURPOSE: Calculates the sum of all repayments made against a loan.
    // Uses CalcSums for efficient server-side aggregation
    // instead of looping through records manually.
    // -------------------------------------------------------
    local procedure GetTotalRepayments(LoanApplicationNo: Code[20]): Decimal
    var
        LoanRepayment: Record "Loan Repayment";
    begin
        LoanRepayment.SetRange("Loan Application No.", LoanApplicationNo);
        LoanRepayment.CalcSums("Amount Paid");
        exit(LoanRepayment."Amount Paid");
    end;

    // -------------------------------------------------------
    // GetRepaymentCount (local helper)
    // -------------------------------------------------------
    // PURPOSE: Counts how many repayment records exist for a loan.
    // Used to generate unique Document No. suffixes (e.g., '-R001').
    // -------------------------------------------------------
    local procedure GetRepaymentCount(LoanApplicationNo: Code[20]): Integer
    var
        LoanRepayment: Record "Loan Repayment";
    begin
        LoanRepayment.SetRange("Loan Application No.", LoanApplicationNo);
        exit(LoanRepayment.Count);
    end;

    // -------------------------------------------------------
    // LogAuditEntry (local helper)
    // -------------------------------------------------------
    // PURPOSE: Creates an audit log record for tracking actions
    //          taken on loan applications.
    // -------------------------------------------------------
    local procedure LogAuditEntry(ActionType: Text[50]; DocumentType: Text[50]; DocumentNo: Code[20]; Description: Text[250])
    var
        AuditLog: Record "Application Audit Log";
    begin
        AuditLog.Init();
        AuditLog."Date-Time" := CurrentDateTime;
        AuditLog."User ID" := CopyStr(UserId, 1, 50);
        AuditLog."Action Type" := ActionType;
        AuditLog."Document Type" := DocumentType;
        AuditLog."Document No." := DocumentNo;
        AuditLog.Description := Description;
        AuditLog.Insert(true);
    end;
}
