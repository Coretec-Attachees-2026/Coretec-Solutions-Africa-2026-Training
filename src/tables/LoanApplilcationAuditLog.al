table 50109 "Loan Application Audit Log"
{
    DataClassification = ToBeClassified;
    
    fields
    {
        field(1; "Audit ID"; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }
        field(2; "Loan Application ID"; Code[20]) {
            TableRelation = "Loan Application"."Loan Application No.";
        }
        field(3; "Auditor"; Text[2048]) {
        }
        field(4; StatusFrom; Enum "Loan Application Status") {

        }
        field(5; StatusTo; Enum "Loan Application Status") {

        }
    }
    
    keys
    {
        key(AuditID; "Audit ID")
        {
            Clustered = true;
        }
    }

    // trigger OnInsert()
    // var
    //     NoSeriesMgt: Codeunit "No. Series";
    // begin
    //     if Rec."Audit ID" = '' then begin
    //         Rec."Audit ID" := NoSeriesMgt.GetNextNo('LAL', WorkDate())
    //     end;

    // end;
}