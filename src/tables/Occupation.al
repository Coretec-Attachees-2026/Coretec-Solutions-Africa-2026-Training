table 50140 Occupation
{
    Caption = 'Member occupation';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Occupation Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; Name; Text[30])
        {
        }
        field(3; Description; Text[100])
        {

        }
    }

    keys
    {
        key(OccupationCode; "Occupation Code")
        {
            Clustered = true;
        }
        key(Name; Name) {
            Unique = true;
        }
    }

    fieldgroups
    {
    }

    var
        myInt: Integer;

    trigger OnInsert()
    var
        NoSeriesHelper: Codeunit "No. Series";
        CodeToUse: Code[20];
        currentDate: Date;
        OccNoSeriesRecord: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        if not OccNoSeriesRecord.Get('OCC') then begin
            OccNoSeriesRecord.Init();
            OccNoSeriesRecord.Code := 'OCC';
            OccNoSeriesRecord.Description := 'Occupation';
            OccNoSeriesRecord.Insert(true);
        end;
        NoSeriesLine.SetRange("Series Code", 'OCC');
        if NoSeriesLine.IsEmpty() then begin
            NoSeriesLine.Init();
            NoSeriesLine."Series Code" := 'OCC';
            NoSeriesLine."Line No." := 10000;
            NoSeriesLine."Starting Date" := 0D;
            NoSeriesLine."Starting No." := 'OCC-0001';
            NoSeriesLine."Increment-by No." := 1;
            NoSeriesLine.Open := true;
            NoSeriesLine.Insert(true);
        end;
        currentDate := Today();
        if Rec."Occupation Code" = '' then begin
            Rec."Occupation Code" := NoSeriesHelper.GetNextNo('OCC', currentDate);
        end;
    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}