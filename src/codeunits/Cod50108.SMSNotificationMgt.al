// ============================================================
// Codeunit 50108 - SMS Notification Mgt
// ============================================================
// PURPOSE: Sends SMS notifications to members by calling the
//          Python Flask webhook, which in turn calls Africa's
//          Talking to deliver the message.
//
// WHY DOES BC CALL A PYTHON SERVER INSTEAD OF AT DIRECTLY?
//   Business Central extensions CAN make outbound HTTP calls,
//   but storing the Africa's Talking API key inside BC is messy
//   and hard to rotate.  Using a Python middleware server means:
//     - Your AT API key stays on your own server in a .env file
//     - You can change SMS providers without touching BC code
//     - The Python server can add logging, queuing, and retries
//
// HOW THIS CODEUNIT WORKS:
//   1. Called by MemberManagement (approval) or LoanManagement (submit)
//   2. Builds a clean JSON body: { phone_number, message }
//   3. Sends HTTP POST to the webhook URL stored in Member Setup
//   4. Parses the JSON response and logs success/failure
//   5. NEVER blocks the business process — SMS failure is informational
//
// KEY CONCEPTS DEMONSTRATED:
//   HttpClient     — BC's built-in outbound HTTP object
//   JsonObject     — BC's built-in JSON builder (safer than string concat)
//   HttpContent    — wraps the JSON body for the HTTP request
//   MemberSetup    — where the webhook URL + secret are stored
//
// IMPORTANT NOTE ABOUT BC SAAS:
//   In Business Central SaaS, outbound HTTP calls MUST use HTTPS.
//   For local development/testing, use ngrok to get an HTTPS URL:
//     ngrok http 5000
//   The https://xxxx.ngrok-free.app URL is what you enter in Member Setup.
// ============================================================

codeunit 50108 "SMS Notification Mgt"
{
    // -------------------------------------------------------
    // PUBLIC: Send Member Approval SMS
    // -------------------------------------------------------
    // Called by MemberManagement.ApproveApplication() after the
    // member record has been successfully created.
    // -------------------------------------------------------
    procedure SendMemberApprovalSMS(
        PhoneNumber: Text;
        MemberFirstName: Text;
        MemberID: Code[20])
    var
        Message: Text;
    begin
        // Do nothing if no phone number is available
        if PhoneNumber = '' then
            exit;

        // Compose a warm, informative welcome message.
        // Keep it under 160 characters to fit a single SMS segment.
        // This message is 158 characters at its longest substitution.
        Message := StrSubstNo(
            'Dear %1, your SACCO membership application has been APPROVED! ' +
            'Your Member ID is %2. Welcome to the family. ' +
            'Call us on 0800-SACCO for any help.',
            MemberFirstName,
            MemberID);

        // Delegate the actual HTTP call to the shared procedure below
        PostSMSToWebhook(PhoneNumber, Message);
    end;

    // -------------------------------------------------------
    // PUBLIC: Send Loan Submitted SMS
    // -------------------------------------------------------
    // Called by LoanManagement.SubmitForApproval() after the
    // loan status is changed to "Pending Approval".
    // -------------------------------------------------------
    procedure SendLoanSubmittedSMS(
        PhoneNumber: Text;
        MemberFirstName: Text;
        LoanApplicationNo: Code[20];
        LoanAmount: Decimal)
    var
        Message: Text;
    begin
        if PhoneNumber = '' then
            exit;

        // Example message (adjust wording to match your SACCO's tone):
        // "Dear James, your loan application LN-20260325-00001 for KES 100,000.00
        //  has been submitted for review. We will notify you of the outcome
        //  within 2 business days."
        Message := StrSubstNo(
            'Dear %1, your loan application %2 for %3 has been submitted ' +
            'for review. You will be notified within 2 business days. ' +
            'Ref: %2',
            MemberFirstName,
            LoanApplicationNo,
            Format(LoanAmount, 0, '<Precision,2:2><Standard Format,0>'));

        PostSMSToWebhook(PhoneNumber, Message);
    end;

    // -------------------------------------------------------
    // PUBLIC: Send Loan Approved / Disbursed SMS
    // -------------------------------------------------------
    // Called by LoanManagement.PostLoan() after the G/L entries
    // are created and the loan is marked Disbursed.
    // -------------------------------------------------------
    procedure SendLoanDisbursedSMS(
        PhoneNumber: Text;
        MemberFirstName: Text;
        LoanApplicationNo: Code[20];
        LoanAmount: Decimal)
    var
        Message: Text;
    begin
        if PhoneNumber = '' then
            exit;

        Message := StrSubstNo(
            'Dear %1, GREAT NEWS! Your loan %2 of %3 has been approved ' +
            'and disbursed to your account. Please check your balance. ' +
            'Remember: repayments begin next month.',
            MemberFirstName,
            LoanApplicationNo,
            Format(LoanAmount, 0, '<Precision,2:2><Standard Format,0>'));

        PostSMSToWebhook(PhoneNumber, Message);
    end;

    // -------------------------------------------------------
    // PUBLIC: Send Loan Rejected SMS
    // -------------------------------------------------------
    procedure SendLoanRejectedSMS(
        PhoneNumber: Text;
        MemberFirstName: Text;
        LoanApplicationNo: Code[20];
        RejectionReason: Text[250])
    var
        Message: Text;
    begin
        if PhoneNumber = '' then
            exit;

        // Keep the reason concise — the full reason is in BC for staff to see
        Message := StrSubstNo(
            'Dear %1, your loan application %2 was not approved at this time. ' +
            'Reason: %3. Please visit a branch or call 0800-SACCO to discuss.',
            MemberFirstName,
            LoanApplicationNo,
            CopyStr(RejectionReason, 1, 80));   // Trim to keep SMS short

        PostSMSToWebhook(PhoneNumber, Message);
    end;

    // -------------------------------------------------------
    // PUBLIC: SendTestSMS
    // -------------------------------------------------------
    // Called by the "Send Test SMS" action on the Member Setup page.
    // Identical internally to the other Send* procedures but accepts
    // any arbitrary message so an admin can confirm the full pipeline
    // works before a real member approval triggers a live SMS.
    // -------------------------------------------------------
    procedure SendTestSMS(PhoneNumber: Text; TestMessage: Text)
    begin
        if PhoneNumber = '' then begin
            LogSMSFailure('Test SMS: no phone number was provided.');
            exit;
        end;
        PostSMSToWebhook(PhoneNumber, TestMessage);
    end;

    // -------------------------------------------------------
    // PRIVATE: PostSMSToWebhook
    // -------------------------------------------------------
    // The single procedure responsible for all HTTP communication.
    // Keeping all HttpClient code here means:
    //   - There is only ONE place to change if the API changes
    //   - The public procedures above stay clean and readable
    //   - Error handling is centralised
    //
    // KEY CONCEPT — HttpClient in AL:
    //   HttpClient is stateless in AL. You create it, use it, and let
    //   it go out of scope. You do NOT declare it as a class-level
    //   variable — create it fresh for each call.
    //
    // KEY CONCEPT — JsonObject:
    //   DO NOT build JSON by string concatenation.  If MemberFirstName
    //   contains a double-quote or backslash the JSON will be malformed.
    //   JsonObject.WriteTo() handles all escaping automatically.
    // -------------------------------------------------------
    local procedure PostSMSToWebhook(PhoneNumber: Text; Message: Text)
    var
        MemberSetup: Record "Member Setup";
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        HttpContent: HttpContent;
        HttpHeaders: HttpHeaders;
        JsonBody: JsonObject;     // Builds properly-escaped JSON
        JsonText: Text;           // The serialised JSON string
        WebhookURL: Text;
        WebhookSecret: Text;
        ResponseBody: Text;
        ResponseJson: JsonObject;
        SuccessToken: JsonToken;
        ErrorToken: JsonToken;
        StatusCode: Integer;
    begin
        // ── Step 1: Read the webhook URL from Member Setup ──────────────────
        // The admin enters this URL when they deploy the Python server.
        // If it's blank, SMS is not configured — skip silently.
        MemberSetup.GetOrCreateSetup();
        WebhookURL    := MemberSetup."SMS Webhook URL";
        WebhookSecret := MemberSetup."SMS Webhook Secret";

        if WebhookURL = '' then begin
            // Log a warning but DON'T Error() — SMS failure must never
            // roll back the member creation or loan submission.
            LogSMSFailure('SMS Webhook URL is not configured. ' +
                          'Set it in Member Setup → SMS Settings.');
            exit;
        end;

        // ── Step 2: Build the JSON body ──────────────────────────────────────
        // Example output: {"phone_number":"+254712345678","message":"Dear James..."}
        JsonBody.Add('phone_number', PhoneNumber);
        JsonBody.Add('message', Message);
        JsonBody.WriteTo(JsonText);

        // ── Step 3: Set up HTTP content with Content-Type: application/json ──
        HttpContent.WriteFrom(JsonText);
        HttpContent.GetHeaders(HttpHeaders);
        // HttpHeaders is always pre-populated with default headers.
        // Remove the existing Content-Type and add the correct one.
        HttpHeaders.Remove('Content-Type');
        HttpHeaders.Add('Content-Type', 'application/json');

        // ── Step 4: Add the optional security header ─────────────────────────
        // The Python server checks X-Webhook-Secret against its own copy.
        // If they match, the request is accepted.  This prevents anyone
        // who discovers your webhook URL from triggering SMS blasts.
        if WebhookSecret <> '' then begin
            HttpRequestMessage.GetHeaders(HttpHeaders);
            HttpHeaders.Add('X-Webhook-Secret', WebhookSecret);
        end;

        // ── Step 5: Build and send the HTTP POST request ──────────────────────
        HttpRequestMessage.Method  := 'POST';
        HttpRequestMessage.SetRequestUri(WebhookURL + '/sms/send');
        HttpRequestMessage.Content := HttpContent;

        // HttpClient.Send() returns FALSE if a network-level error occurs
        // (e.g. the Python server is down).  It does NOT throw an exception.
        if not HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then begin
            LogSMSFailure(StrSubstNo(
                'Could not reach SMS webhook at %1. ' +
                'Check that the Python server is running.',
                WebhookURL));
            exit;
        end;

        // ── Step 6: Check the HTTP status code ───────────────────────────────
        StatusCode := HttpResponseMessage.HttpStatusCode();
        if StatusCode <> 200 then begin
            HttpResponseMessage.Content.ReadAs(ResponseBody);
            LogSMSFailure(StrSubstNo(
                'SMS webhook returned HTTP %1. Response: %2',
                StatusCode, CopyStr(ResponseBody, 1, 200)));
            exit;
        end;

        // ── Step 7: Parse the success response from Python ───────────────────
        HttpResponseMessage.Content.ReadAs(ResponseBody);
        if ResponseJson.ReadFrom(ResponseBody) then begin
            if ResponseJson.Get('success', SuccessToken) then
                if not SuccessToken.AsValue().AsBoolean() then begin
                    // Python returned {"success": false, "error": "..."}
                    if ResponseJson.Get('error', ErrorToken) then
                        LogSMSFailure(StrSubstNo('AT API error: %1',
                            ErrorToken.AsValue().AsText()));
                end;
            // If success = true, everything is fine — no action needed
        end;
    end;

    // -------------------------------------------------------
    // PRIVATE: LogSMSFailure
    // -------------------------------------------------------
    // Records SMS failures in the Application Audit Log.
    // Does NOT show a Message() or Error() — SMS is always
    // non-blocking.  Admins can check the Audit Log to see
    // what happened.
    // -------------------------------------------------------
    local procedure LogSMSFailure(FailureDetail: Text)
    var
        AuditLog: Record "Application Audit Log";
    begin
        AuditLog.Init();
        AuditLog."Date-Time"     := CurrentDateTime;
        AuditLog."User ID"       := CopyStr(UserId, 1, 50);
        AuditLog."Action Type"   := 'SMS Failure';
        AuditLog."Document Type" := 'SMS';
        AuditLog."Document No."  := '';
        AuditLog.Description     := CopyStr(FailureDetail, 1, 250);
        AuditLog.Insert(true);
    end;
}
