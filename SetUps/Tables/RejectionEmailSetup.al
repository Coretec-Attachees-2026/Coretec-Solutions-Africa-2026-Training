table 50131 RejectionEmailSetupTable
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; MyField; Text[29])
        {
            InitValue = 'Rejection Email Format Set up';
        }
        field(2; "Email Format Blob"; Blob)
        {
            Description = 'Contains Rich text for Email formatting';
        }
    }

    keys
    {
        key(Key1; MyField)
        {
            Clustered = true;
        }
    }
    procedure SaveRichText(EmailBodyVarWrite: Text)
    var
        OutStream: OutStream;
    begin
        Rec."Email Format Blob".CreateOutStream(OutStream);
        OutStream.Write(EmailBodyVarWrite);
        Rec.Modify();

    end;

    procedure GetRichText(): Text
    var
        Instream: InStream;
        TextValueToWriteTo: Text;
    begin
        Rec.CalcFields(Rec."Email Format Blob");
        Rec."Email format Blob".CreateInStream(Instream);
        Instream.Read(TextValueToWriteTo);
        exit(TextValueToWriteTo);
    end;

}