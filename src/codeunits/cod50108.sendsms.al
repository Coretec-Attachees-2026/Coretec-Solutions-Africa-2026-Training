codeunit 50108 "AT SMS Helper"
{
    procedure SendSMS(PhoneNumber: Text; Message: Text): Boolean
    var
        HttpClient: HttpClient;
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
        HttpContent: HttpContent;
        ContentHeaders: HttpHeaders;
        JsonBody: Text;
        ResponseText: Text;
    begin
        // Format phone number to +254XXXXXXXXX
        PhoneNumber := DelChr(PhoneNumber, '=', ' ');
        if CopyStr(PhoneNumber, 1, 1) = '0' then
            PhoneNumber := '+254' + CopyStr(PhoneNumber, 2)
        else
            if CopyStr(PhoneNumber, 1, 3) = '254' then
                PhoneNumber := '+' + PhoneNumber
            else
                if CopyStr(PhoneNumber, 1, 1) <> '+' then
                    PhoneNumber := '+254' + PhoneNumber;

        // Build JSON body to send to Python API
        JsonBody := '{"phone":"' + PhoneNumber + '","message":"' + Message + '"}';

        HttpContent.WriteFrom(JsonBody);
        HttpContent.GetHeaders(ContentHeaders);
        ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'application/json');

        HttpRequest.Method := 'POST';

        // ← Point this to your Python server IP and port
        HttpRequest.SetRequestUri('http://192.168.8.57:5000/send-sms');
        HttpRequest.Content := HttpContent;

        if not HttpClient.Send(HttpRequest, HttpResponse) then
            exit(false);

        HttpResponse.Content.ReadAs(ResponseText);
        exit(HttpResponse.IsSuccessStatusCode());
    end;
}