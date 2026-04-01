codeunit 50106 "Approve Email"
// this is the actual codeunit that will run the email
{
    TableNo = "Job Queue Entry";
    trigger OnRun()
    var
        Member: Record Member;
        RecID: RecordId;
        EmailMessenger: Codeunit "Member Management";
    begin
        RecID := Rec."Record ID to Process";
        if Member.Get(RecID) then begin
            EmailMessenger.SendWelcomeEmailToMember(Member);
        end;
    end;
    
    var
        myInt: Integer;
}