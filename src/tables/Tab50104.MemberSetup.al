
// ============================================================
// Table 50104 - Member Setup
// ============================================================
// PURPOSE: Stores configuration settings for the SACCO system.
//
// This is a "single-record" table - there's only ever ONE row
// with Primary Key = 'SETUP'. This pattern is common in BC for
// storing global settings.
//
// WHAT'S NEW FOR LOANS:
// - "Loan Application Nos."    → No. Series for generating loan IDs
// - "Loans Receivable Account" → G/L Account where we DEBIT (loan given out)
// - "Loan Disbursement Account"→ G/L Account where we CREDIT (money leaves bank)
//
// WHY TWO G/L ACCOUNTS?
//   Double-entry bookkeeping: every transaction must have equal debits and credits.
//   When we give a loan:
//     DEBIT  "Loans Receivable"    (asset goes UP - member owes us money)
//     CREDIT "Bank/Disbursement"   (asset goes DOWN - money left our bank)
// ============================================================

table 50104 "Member Setup"
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
