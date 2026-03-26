codeunit 50146 FieldValidator
{
    procedure CheckPhone(PhoneNumber: Text): Boolean
    var
        Regex: Codeunit Regex;
        pattern: Text;
    begin
        pattern := '^07[0-9]{8}$';
        if Regex.IsMatch(PhoneNumber, pattern) then
            exit(true)
        else
            exit(false)
    end;

    procedure CheckKRAPin(KRAPin: Text): Boolean
    var
        Regex: Codeunit Regex;
        pattern: Text;
    begin
        pattern := '^[A-Z]{1}[0-9]{9}[A-Z]{1}$';
        if Regex.IsMatch(KRAPin, pattern) then
            exit(true)
        else
            exit(false)
    end;

    procedure CheckID(ID: Text): Boolean
    var
        Regex: Codeunit Regex;
        pattern: Text;
    begin
        pattern := '^\d{8}';
        if Regex.IsMatch(ID, pattern) then
            exit(true)
        else
            exit(false)
    end;
}