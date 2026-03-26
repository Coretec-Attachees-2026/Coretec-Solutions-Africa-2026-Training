// ============================================================
// Codeunit 50101 - AT SMS Helper
// ============================================================
// PURPOSE: Sends an SMS via Python Flask server and logs
//          every attempt (success or failure) to the SMS Log
//          table for audit and debugging purposes.
//
// ARCHITECTURE:
//   AL (Business Central)
//     → HTTP POST to Python Server (192.168.8.57:5000)
//       → Python forwards to Africa's Talking API
//         → SMS delivered to member's phone
//         → Result logged to SMS Log table (Tab50102)
// ============================================================

codeunit 50108 "AT SMS Helper"
{
    // -------------------------------------------------------
    // SendSMS
    // -------------------------------------------------------
    // PURPOSE: Sends an SMS and logs the result
    //
    // PARAMETERS:
    //   PhoneNumber   → Member's phone number
    //   Message       → SMS text to send
    //   ApplicationID → Which application triggered this SMS
    //   MemberName    → Member's full name (for the log)
    //   TriggeredBy   → e.g. "Application Approved"
    //
    // RETURNS:
    //   Boolean → true if sent, false if failed
    // -------------------------------------------------------
    procedure SendSMS(PhoneNumber: Text; Message: Text; ApplicationID: Code[20]; MemberName: Text; TriggeredBy: Text): Boolean
    var
        HttpClient: HttpClient;
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
        HttpContent: HttpContent;
        ContentHeaders: HttpHeaders;
        JsonBody: Text;
        ResponseText: Text;
        Success: Boolean;
    begin
        // ── FORMAT PHONE NUMBER ───────────────────────────────────────
        PhoneNumber := DelChr(PhoneNumber, '=', ' ');

        if CopyStr(PhoneNumber, 1, 1) = '0' then
            PhoneNumber := '+254' + CopyStr(PhoneNumber, 2)
        else
            if CopyStr(PhoneNumber, 1, 3) = '254' then
                PhoneNumber := '+' + PhoneNumber
            else
                if CopyStr(PhoneNumber, 1, 1) <> '+' then
                    PhoneNumber := '+254' + PhoneNumber;
        // ─────────────────────────────────────────────────────────────

        // Build JSON body for Python server
        JsonBody := '{"phone":"' + PhoneNumber + '","message":"' + Message + '"}';

        HttpContent.WriteFrom(JsonBody);
        HttpContent.GetHeaders(ContentHeaders);
        ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'application/json');

        HttpRequest.Method := 'POST';

        // ⚠️ UPDATE THIS IP if your PC's IP changes
        HttpRequest.SetRequestUri('http://192.168.8.57:5000/send-sms');
        HttpRequest.Content := HttpContent;

        // Send request to Python server
        if not HttpClient.Send(HttpRequest, HttpResponse) then begin
            // Python server is unreachable — log as Failed
            LogSMS(PhoneNumber, Message, ApplicationID, MemberName, TriggeredBy, false,
                   'Could not reach Python SMS server. Make sure it is running.');
            exit(false);
        end;

        HttpResponse.Content.ReadAs(ResponseText);
        Success := HttpResponse.IsSuccessStatusCode();

        // Log the result — success or failure
        if Success then
            LogSMS(PhoneNumber, Message, ApplicationID, MemberName, TriggeredBy, true, '')
        else
            LogSMS(PhoneNumber, Message, ApplicationID, MemberName, TriggeredBy, false, ResponseText);

        exit(Success);
    end;

    // -------------------------------------------------------
    // LogSMS (local)
    // -------------------------------------------------------
    // PURPOSE: Writes a record to the SMS Log table.
    //          Called automatically after every SendSMS attempt.
    //
    // KEY CONCEPT - "local procedure":
    //   Only this codeunit can call LogSMS.
    //   External code always goes through SendSMS.
    // -------------------------------------------------------
    local procedure LogSMS(PhoneNumber: Text; Message: Text; ApplicationID: Code[20]; MemberName: Text; TriggeredBy: Text; Success: Boolean; ErrorMessage: Text)
    var
        SMSLog: Record "SMS Log";
    begin
        SMSLog.Init();
        SMSLog."Phone Number" := CopyStr(PhoneNumber, 1, 20);
        SMSLog."Message" := CopyStr(Message, 1, 250);
        SMSLog."Application ID" := ApplicationID;
        SMSLog."Member Name" := CopyStr(MemberName, 1, 100);
        SMSLog."Triggered By" := CopyStr(TriggeredBy, 1, 100);
        SMSLog."Sent DateTime" := CurrentDateTime;

        if Success then
            SMSLog.Status := SMSLog.Status::Sent
        else begin
            SMSLog.Status := SMSLog.Status::Failed;
            SMSLog."Error Message" := CopyStr(ErrorMessage, 1, 250);
        end;

        SMSLog.Insert();
    end;
}
