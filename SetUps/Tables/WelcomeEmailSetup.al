table 50128 WelcomeEmailSetupTable
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; MyField; Text[27])
        {
            InitValue = 'Welcome Email Format Set up';
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