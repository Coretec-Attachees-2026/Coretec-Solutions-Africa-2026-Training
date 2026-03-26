codeunit 50105 "Loan Management"
{
    procedure SubmitForApproval(var LoanApp: Record "Loan Application")
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
        sendLoanRequestSubmittedSMS(LoanApp); // Set this as a background task

        Message('Loan %1 has been submitted for approval.', LoanApp."Loan Application No.");
    end;

    procedure ApproveLoan(var LoanApp: Record "Loan Application")
    begin
        if LoanApp.Status <> Enum::"Loan Application Status"::"Pending Approval" then
            Error('Only loans with status "Pending Approval" can be approved.\Current status: %1', LoanApp.Status);

        LoanApp.Status := Enum::"Loan Application Status"::Approved;
        LoanApp."Approval Date" := Today;
        LoanApp.Modify(true);
        PostLoan(LoanApp);
        sendloanapprovedSMS(LoanApp);

    end;

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

        Message('Loan %1 has been rejected.\Reason: %2', LoanApp."Loan Application No.", RejectionReason);
    end;

    procedure PostLoan(var LoanApp: Record "Loan Application")
    var
        MemberSetup: Record "Member Setup";
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        LoanLedgerEntry: Record "Loan Ledger Entry";
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

        DocumentNo := LoanApp."Loan Application No.";

        GenJnlLine.Init();
        GenJnlLine."Posting Date" := Today;
        GenJnlLine."Document No." := DocumentNo;
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
        GenJnlLine."Account No." := MemberSetup."Loans Receivable Account";
        GenJnlLine.Description := StrSubstNo('Loan disbursement - %1', LoanApp."Member Name");
        GenJnlLine.Validate(Amount, LoanApp."Loan Amount");
        GenJnlLine."Source Code" := 'GENJNL';
        GenJnlLine."System-Created Entry" := true;
        GenJnlPostLine.RunWithCheck(GenJnlLine);

        GenJnlLine.Init();
        GenJnlLine."Posting Date" := Today;
        GenJnlLine."Document No." := DocumentNo;
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
        GenJnlLine."Account No." := MemberSetup."Loan Disbursement Account";
        GenJnlLine.Description := StrSubstNo('Loan disbursement - %1', LoanApp."Member Name");
        GenJnlLine.Validate(Amount, -LoanApp."Loan Amount");
        GenJnlLine."Source Code" := 'GENJNL';
        GenJnlLine."System-Created Entry" := true;
        GenJnlPostLine.RunWithCheck(GenJnlLine);

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

        LoanApp.Status := Enum::"Loan Application Status"::Disbursed;
        LoanApp."Disbursement Date" := Today;
        LoanApp.Posted := true;
        LoanApp."Document No." := DocumentNo;
        LoanApp.Modify(true);

        Message('Loan %1 has been posted successfully!\Amount: %2\Document No.: %3',
            LoanApp."Loan Application No.",
            LoanApp."Loan Amount",
            DocumentNo);
    end;

    procedure sendLoanRequestSubmittedSMS(var LoanApp: Record "Loan Application"): Boolean
    var
        Client: HttpClient;
        Messenger: HttpRequestMessage;
        Headers: HttpHeaders;
        ContentHeaders: HttpHeaders;
        Body: HttpContent;
        IsSuccessful: Boolean;
        response: HttpResponseMessage;
        json: JsonObject;
        Payload: Text;
        Member: Record Member;
    begin
        Member.Get(LoanApp."Member ID");
        json.Add('phone', Member."Phone Number".Replace('0', '+254'));
        json.WriteTo(Payload);
        Body.WriteFrom(Payload);

        Body.GetHeaders(ContentHeaders);
        if ContentHeaders.Contains('Content-Type') then begin
            ContentHeaders.Remove('Content-Type');
            ContentHeaders.Add('Content-Type', 'application/json');
        end;

        Messenger.Content := Body;

        Messenger.SetRequestUri('http://localhost:5009/loanapprovalsubmitted');
        Messenger.Method('POST');

        IsSuccessful := client.Send(Messenger, response);

        if IsSuccessful then begin
            exit(true);
        end;
        exit(false);
    end;

    procedure sendloanapprovedSMS(var LoanApp: Record "Loan Application"): Boolean
    var
        Client: HttpClient;
        Messenger: HttpRequestMessage;
        Headers: HttpHeaders;
        ContentHeaders: HttpHeaders;
        Body: HttpContent;
        IsSuccessful: Boolean;
        response: HttpResponseMessage;
        json: JsonObject;
        Payload: Text;
        Member: Record Member;
    begin
        Member.Get(LoanApp."Member ID");
        json.Add('phone', Member."Phone Number".Replace('0', '+254'));
        json.WriteTo(Payload);
        Body.WriteFrom(Payload);

        Body.GetHeaders(ContentHeaders);
        if ContentHeaders.Contains('Content-Type') then begin
            ContentHeaders.Remove('Content-Type');
            ContentHeaders.Add('Content-Type', 'application/json');
        end;

        Messenger.Content := Body;

        Messenger.SetRequestUri('http://localhost:5009/loanapproved');
        Messenger.Method('POST');

        IsSuccessful := client.Send(Messenger, response);

        if IsSuccessful then begin
            exit(true);
        end;
        exit(false);
    end;
}
