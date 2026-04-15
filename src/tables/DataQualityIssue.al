table 50110 "Data Quality Issue"
{
    Caption = 'Data Quality Issue';
    DataClassification = CustomerContent;
    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(2; "Rule Name"; Text[100])
        {
            Caption = 'Rule Name';
        }
        field(3; "Description"; Text[250])
        {
            Caption = 'Description';
        }
        field(4; "Table ID"; Integer)
        {
            Caption = 'Table ID';
        }
        field(5; "Record ID"; RecordId)
        {
            Caption = 'Record ID';
        }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
    }
}