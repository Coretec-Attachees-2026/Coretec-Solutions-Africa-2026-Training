table 50101 "Member Setup"
{
    Caption = 'Member Setup';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            Editable = false;
        }
        field(2; "Member Application Nos."; Code[20])
        {
            Caption = 'Member Application Nos.';
            TableRelation = "No. Series";
        }

        // ----- NEW: Loan Settings -----

        field(3; "Loan Application Nos."; Code[20])
        {
            Caption = 'Loan Application Nos.';
            TableRelation = "No. Series";
            // Links to the No. Series table so user picks a valid series
        }
        field(4; "Loans Receivable Account"; Code[20])
        {
            Caption = 'Loans Receivable Account';
            TableRelation = "G/L Account"."No." where("Direct Posting" = const(true));
            // TableRelation with WHERE clause:
            // Only shows G/L Accounts that allow direct posting
            // This is the DEBIT side (asset - money owed to SACCO)
        }
        field(5; "Loan Disbursement Account"; Code[20])
        {
            Caption = 'Loan Disbursement Account';
            TableRelation = "G/L Account"."No." where("Direct Posting" = const(true));
            // This is the CREDIT side (bank account - money going out)
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        if "Primary Key" = '' then
            "Primary Key" := 'SETUP';
    end;

    /// <summary>
    /// Gets the single setup record, or creates it if it doesn't exist.
    /// This is called before reading any setup values to make sure the record is there.
    /// </summary>
    procedure GetOrCreateSetup()
    begin
        if not Get('SETUP') then begin
            Init();
            "Primary Key" := 'SETUP';
            Insert(true);
        end;
    end;
}
