report 50102 "Find Data Quality Issues"
{
    Caption = 'Find Data Quality Issues';
    ProcessingOnly = true;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;

    trigger OnPreReport()
    var
        DataQualityPage: Page "Data Quality Issues";
    begin
        TempIssues.DeleteAll();
        NextEntryNo := 0;

        CheckRule1_DuplicateEmails();
        CheckRule2_StaleApplications();
        CheckRule3_MissingVitalContactInfo();

        if TempIssues.IsEmpty() then
            Message('Data scan complete: No data quality issues found! Excellent.')
        else begin
            DataQualityPage.SetTempRecords(TempIssues);
            DataQualityPage.Run();
        end;
    end;

    var
        TempIssues: Record "Data Quality Issue" temporary;
        NextEntryNo: Integer;

    local procedure InsertIssue(RuleName: Text[100]; Desc: Text[250]; RecId: RecordId; TableID: Integer)
    begin
        NextEntryNo += 1;
        TempIssues.Init();
        TempIssues."Entry No." := NextEntryNo;
        TempIssues."Rule Name" := RuleName;
        TempIssues.Description := Desc;
        TempIssues."Record ID" := RecId;
        TempIssues."Table ID" := TableID;
        TempIssues.Insert();
    end;

    local procedure CheckRule1_DuplicateEmails()
    var
        Member: Record Member;
        DuplicateCheck: Record Member;
        MemberApp: Record "Member Application";
        AppDuplicateCheck: Record "Member Application";
        ProcessedEmails: List of [Text];
        ProcessedAppEmails: List of [Text];
        LowerEmail: Text;
    begin
        Member.SetFilter(Email, '<>%1', '');
        if Member.FindSet() then
            repeat
                LowerEmail := LowerCase(Member.Email);
                if not ProcessedEmails.Contains(LowerEmail) then begin
                    DuplicateCheck.SetRange(Email, Member.Email);
                    if DuplicateCheck.Count > 1 then begin
                        ProcessedEmails.Add(LowerEmail);

                        if DuplicateCheck.FindSet() then
                            repeat
                                InsertIssue('Duplicate Email', 'Email "' + DuplicateCheck.Email + '" is used by multiple members.', DuplicateCheck.RecordId, Database::Member);
                            until DuplicateCheck.Next() = 0;
                    end;
                end;
            until Member.Next() = 0;

        MemberApp.SetFilter(Email, '<>%1', '');
        if MemberApp.FindSet() then
            repeat
                LowerEmail := LowerCase(MemberApp.Email);
                if not ProcessedAppEmails.Contains(LowerEmail) then begin
                    AppDuplicateCheck.SetRange(Email, MemberApp.Email);
                    if AppDuplicateCheck.Count > 1 then begin
                        ProcessedAppEmails.Add(LowerEmail);

                        if AppDuplicateCheck.FindSet() then
                            repeat
                                InsertIssue('Duplicate Email', 'Email "' + AppDuplicateCheck.Email + '" is used by multiple applications.', AppDuplicateCheck.RecordId, Database::"Member Application");
                            until AppDuplicateCheck.Next() = 0;
                    end;
                end;
            until MemberApp.Next() = 0;
    end;

    local procedure CheckRule2_StaleApplications()
    var
        MemberApp: Record "Member Application";
        ThirtyDaysAgo: Date;
    begin
        ThirtyDaysAgo := CalcDate('<-30D>', Today);
        MemberApp.SetRange(Status, Enum::"Member Application Status"::Pending);
        MemberApp.SetFilter("Application Date", '<%1', CreateDateTime(ThirtyDaysAgo, 0T));

        if MemberApp.FindSet() then
            repeat
                InsertIssue('Stale Application', 'App ' + MemberApp."Application ID" + ' has been pending for over 30 days.', MemberApp.RecordId, Database::"Member Application");
            until MemberApp.Next() = 0;
    end;

    local procedure CheckRule3_MissingVitalContactInfo()
    var
        Member: Record Member;
    begin
        if Member.FindSet() then
            repeat
                if (Member.Email = '') or (Member."Phone Number" = '') then
                    InsertIssue('Missing Contact Info', 'Member ' + Member."Member ID" + ' is missing an Email or Phone Number.', Member.RecordId, Database::Member);
            until Member.Next() = 0;
    end;
}