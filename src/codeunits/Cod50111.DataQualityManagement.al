codeunit 50111 "Data Quality Management"
{
    procedure RunDataQualityChecks(var Issues: Record "Data Quality Issue"): Integer
    var
        IssueID: Integer;
    begin
        Issues.DeleteAll();
        IssueID := 1;

        CheckDuplicateEmails(Issues, IssueID);
        CheckOrphanedLoans(Issues, IssueID);
        CheckStalledApplications(Issues, IssueID);

        exit(Issues.Count);
    end;

    local procedure CheckDuplicateEmails(var Issues: Record "Data Quality Issue"; var IssueID: Integer)
    var
        Member1: Record "Member";
        Member2: Record "Member";
        EmailsSeen: Dictionary of [Text, Integer];
        EmailAddress: Text;
        Count: Integer;
    begin
        Member1.SetFilter("Email", '<>%1', '');
        if Member1.FindSet() then
            repeat
                EmailAddress := Member1."Email";
                if EmailsSeen.ContainsKey(EmailAddress) then
                    EmailsSeen.Set(EmailAddress, EmailsSeen.Get(EmailAddress) + 1)
                else
                    EmailsSeen.Add(EmailAddress, 1);
            until Member1.Next() = 0;

        foreach EmailAddress in EmailsSeen.Keys do begin
            Count := EmailsSeen.Get(EmailAddress);
            if Count >= 2 then begin
                Member2.SetRange("Email", EmailAddress);
                if Member2.FindSet() then
                    repeat
                        Issues.Init();
                        issues."Issue ID" := IssueID;
                        IssueID += 1;
                        Issues."Issue Type" := 'Duplicate Email';
                        Issues."Severity" := 'Critical';
                        Issues."Member ID" := Member2."Member ID";
                        Issues."Member Email" := EmailAddress;
                        Issues."Affected Count" := Count;
                        Issues."Description" := StrSubstNo(
                            'Email "%1" is used by %2 members. This may indicate duplicate records.',
                            EmailAddress,
                            Count
                        );
                        Issues."Recommendation" := 'Review and merge duplicate member records. Ensure email addresses are unique.';
                        Issues."Related Record ID" := Member2."Member ID";
                        Issues.Insert();
                    until Member2.Next() = 0;
            end;
        end;
    end;

    local procedure CheckOrphanedLoans(var Issues: Record "Data Quality Issue"; var IssueID: Integer)
    var
        LoanApp: Record "Loan Application";
        Member: Record "Member";
    begin
        if LoanApp.FindSet() then
            repeat
                if not Member.Get(LoanApp."Member ID") then begin
                    Issues.Init();
                    Issues."Issue ID" := IssueID;
                    IssueID += 1;
                    Issues."Issue Type" := 'Orphaned Loan';
                    Issues."Severity" := 'Critical';
                    Issues."Loan Application No." := LoanApp."Loan Application No.";
                    Issues."Referenced Member ID" := LoanApp."Member ID";
                    Issues."Description" := StrSubstNo(
                        'Loan Application %1 references non-existent Member ID "%2". ' +
                        'This is a data integrity issue.',
                        LoanApp."Loan Application No.",
                        LoanApp."Member ID"
                    );
                    Issues."Recommendation" :=
                        'Either delete the orphaned loan or correct its Member ID. ' +
                        'If member was deleted intentionally, clean up related loans.';
                    Issues."Related Record ID" := LoanApp."Loan Application No.";
                    Issues.Insert();
                end;
            until LoanApp.Next() = 0;
    end;

    local procedure CheckStalledApplications(var Issues: Record "Data Quality Issue"; var IssueID: Integer)
    var
        LoanApp: Record "Loan Application";
        DaysInStatus: Integer;
        ThresholdDays: Integer;
        CurrentDate: Date;
        CheckDate: Date;
    begin
        CurrentDate := Today;
        ThresholdDays := 30;

        LoanApp.SetRange("Status", Enum::"Loan Application Status"::"Pending Approval");
        if LoanApp.FindSet() then
            repeat
                if LoanApp."Application Date" <> 0D then
                    CheckDate := LoanApp."Application Date"
                else
                    CheckDate := Today;

                DaysInStatus := CurrentDate - CheckDate;

                if DaysInStatus >= ThresholdDays then begin
                    Issues.Init();
                    Issues."Issue ID" := IssueID;
                    IssueID += 1;
                    Issues."Issue Type" := 'Stalled Application';
                    Issues."Severity" := 'Warning';
                    Issues."Loan Application No." := LoanApp."Loan Application No.";
                    Issues."Member ID" := LoanApp."Member ID";
                    Issues."Status Since Date" := CheckDate;
                    Issues."Days in Status" := DaysInStatus;
                    Issues."Description" := StrSubstNo(
                        'Loan Application %1 has been in "Pending Approval" status for %2 days ' +
                        '(since %3). This indicates a potential workflow bottleneck.',
                        LoanApp."Loan Application No.",
                        DaysInStatus,
                        CheckDate
                    );
                    Issues."Recommendation" := StrSubstNo(
                        'Contact loan officer to either approve or reject this application. ' +
                        'Set an SLA to resolve applications within %1 days.',
                        ThresholdDays
                    );
                    Issues."Related Record ID" := LoanApp."Loan Application No.";
                    Issues.Insert();
                end;
            until LoanApp.Next() = 0;
    end;
}