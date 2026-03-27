// ============================================================
// Codeunit 50108 - Africa's Talking SMS
// ============================================================
// PURPOSE: Handles SMS sending through the Python middleware.
//          The middleware (SMS_api.py) integrates with Africa's Talking API.
//
// ARCHITECTURE:
//   Business Central (AL) → HTTP → Python Flask Service → Africa's Talking API
//
// WHAT THIS CODEUNIT DOES:
//   1. SendApprovalSMS()  - Sends welcome SMS when application is approved
//   2. SendRejectionSMS() - Sends rejection SMS when application is rejected
//   3. SendSMS()          - Core procedure that calls the Python middleware
//   4. FormatPhoneNumber()- Converts phone numbers to +254 format (Kenya)
//
// MESSAGE FORMAT:
//   - Phone numbers: Must be in format +254xxxxxxxxx
//   - HTTP Endpoint: POST http://localhost:5000/send-sms
//   - Request: {"phone": "+254...", "message": "..."}
//   - Response: {"success": true/false, "message": "...", "error": "..."}
//
// ============================================================

codeunit 50108 "Africa's Talking SMS"
{
    /// <summary>
    /// SendApprovalSMS
    /// Sends a welcome SMS to the member when their application is approved.
    /// </summary>
    procedure SendApprovalSMS(PhoneNumber: Text; MemberName: Text; MemberID: Code[20])
    var
        Message: Text;
    begin
        if PhoneNumber = '' then
            exit;

        Message := 'Dear ' + MemberName + ', your SACCO membership has been approved. Your Member ID is: ' + MemberID + '. Welcome!';
        SendSMS(PhoneNumber, Message, MemberID);
    end;

    /// <summary>
    /// SendRejectionSMS
    /// Sends a rejection notification SMS when application is rejected.
    /// </summary>
    procedure SendRejectionSMS(PhoneNumber: Text; MemberName: Text; ApplicationID: Code[20]; RejectionReason: Text[250])
    var
        Message: Text;
    begin
        if PhoneNumber = '' then
            exit;

        Message := 'Dear ' + MemberName + ', your SACCO application (' + ApplicationID + ') has been rejected. Reason: ' + RejectionReason;
        SendSMS(PhoneNumber, Message, ApplicationID);
    end;

    /// <summary>
    /// SendSMS (Local)
    /// Core procedure that communicates with the Python middleware API.
    /// Makes HTTP POST request to localhost:5000/send-sms
    /// </summary>
    local procedure SendSMS(PhoneNumber: Text; MessageText: Text; ReferenceID: Code[20])
    var
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpHeaders: HttpHeaders;
        HttpResponseMessage: HttpResponseMessage;
        RequestPayload: Text;
        ResponseText: Text;
        JsonToken: JsonToken;
        ServiceURL: Text;
        FormattedPhone: Text;
    begin
        // Format phone number to +254 format
        FormattedPhone := FormatPhoneNumber(PhoneNumber);

        if FormattedPhone = '' then begin
            Message('Invalid phone number format for SMS: %1', PhoneNumber);
            exit;
        end;

        // Build JSON payload for Python middleware
        RequestPayload := '{"phone":"' + FormattedPhone + '","message":"' + MessageText + '"}';

        // Create HTTP content
        HttpContent.WriteFrom(RequestPayload);
        HttpContent.GetHeaders(HttpHeaders);
        HttpHeaders.Add('Content-Type', 'application/json');

        // Set the service URL (default to localhost:5000)
        ServiceURL := 'http://localhost:5000/send-sms';

        // Make HTTP POST request to Python middleware
        if not HttpClient.Post(ServiceURL, HttpContent, HttpResponseMessage) then begin
            Message('Failed to connect to SMS service at %1', ServiceURL);
            exit;
        end;

        // Get response text
        HttpResponseMessage.Content().ReadAs(ResponseText);

        // Parse JSON response
        if JsonToken.ReadFrom(ResponseText) then begin
            // Check if success field is true
            if JsonToken.AsObject().Get('success', JsonToken) then begin
                if JsonToken.AsValue().AsBoolean() then
                    Message('SMS sent successfully to %1', FormattedPhone)
                else begin
                    // Extract error message if available
                    if JsonToken.AsObject().Get('error', JsonToken) then
                        Message('SMS sending failed: %1', JsonToken.AsValue().AsText())
                    else
                        Message('SMS sending failed');
                end;
            end;
        end else
            Message('Unexpected response from SMS service');
    end;

    /// <summary>
    /// FormatPhoneNumber
    /// Converts various phone number formats to +254xxxxxxxxx format (Kenya)
    /// Supports: 0712..., 254712..., +254712...
    /// </summary>
    local procedure FormatPhoneNumber(PhoneNumber: Text): Text
    var
        TrimmedPhone: Text;
    begin
        TrimmedPhone := PhoneNumber.Trim();
        TrimmedPhone := TrimmedPhone.Replace(' ', '');
        TrimmedPhone := TrimmedPhone.Replace('-', '');
        TrimmedPhone := TrimmedPhone.Replace('(', '');
        TrimmedPhone := TrimmedPhone.Replace(')', '');

        // If already in +254 format, return as-is
        if TrimmedPhone.StartsWith('+254') then
            exit(TrimmedPhone);

        // If starts with 0, replace with +254
        if TrimmedPhone.StartsWith('0') then
            exit('+254' + TrimmedPhone.Substring(2));

        // If starts with 254 (without +), add +
        if TrimmedPhone.StartsWith('254') then
            exit('+' + TrimmedPhone);

        // Invalid format
        exit('');
    end;
}
