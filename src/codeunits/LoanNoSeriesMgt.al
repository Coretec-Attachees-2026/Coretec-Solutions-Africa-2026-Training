// ============================================================
// Codeunit 50104 - Loan No. Series Mgt
// ============================================================
// PURPOSE: Automatically creates the No. Series for Loan Applications.
//
// WHAT IS A NO. SERIES?
//   In Business Central, a "No. Series" is a system for generating
//   sequential numbers automatically. Instead of typing "LN-00001",
//   "LN-00002" manually, the system does it for you.
//
// HOW THIS WORKS:
//   1. Creates a No. Series record called 'LOANAPPSEQ'
//   2. Creates a No. Series Line that starts at '00001' and increments by 1
//   3. Links it to the Member Setup table
//
// This runs automatically when the extension is installed (see Cod50103).
// ============================================================

codeunit 50104 "Loan No. Series Mgt"
{
    // Permissions tell BC which tables this codeunit needs to read/write
    Permissions = tabledata "No. Series" = rimd,        // r=read, i=insert, m=modify, d=delete
                  tabledata "No. Series Line" = rimd,
                  tabledata "Member Setup" = rimd;

    /// <summary>
    /// Main procedure: makes sure the No. Series and Setup are configured.
    /// Called from the install codeunit and from the Loan Application table.
    /// </summary>
    procedure EnsureLoanNoSeriesAndSetup()
    var
        MemberSetup: Record "Member Setup";
    begin
        // Step 1: Create the No. Series if it doesn't exist
        EnsureNoSeries();

        // Step 2: Link it to Member Setup
        MemberSetup.GetOrCreateSetup();
        if MemberSetup."Loan Application Nos." = '' then begin
            MemberSetup."Loan Application Nos." := 'LOANAPPSEQ';
            MemberSetup.Modify(true);
        end;
    end;

    /// <summary>
    /// Creates the 'LOANAPPSEQ' No. Series and its line if they don't exist.
    /// </summary>
    local procedure EnsureNoSeries()
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        // Create the No. Series header
        if not NoSeries.Get('LOANAPPSEQ') then begin
            NoSeries.Init();
            NoSeries.Code := 'LOANAPPSEQ';
            NoSeries.Description := 'Loan Application Sequence';
            NoSeries."Default Nos." := true;    // Auto-assign numbers
            NoSeries."Manual Nos." := false;    // Don't allow manual entry
            NoSeries.Insert(true);
        end;

        // Create the No. Series line (defines starting number and increment)
        NoSeriesLine.SetRange("Series Code", 'LOANAPPSEQ');
        if NoSeriesLine.IsEmpty() then begin
            NoSeriesLine.Init();
            NoSeriesLine."Series Code" := 'LOANAPPSEQ';
            NoSeriesLine."Line No." := 10000;
            NoSeriesLine."Starting Date" := 0D;         // No start date restriction
            NoSeriesLine."Starting No." := '00001';      // First number
            NoSeriesLine."Increment-by No." := 1;        // Go up by 1 each time
            NoSeriesLine.Open := true;                   // Series is active
            NoSeriesLine.Insert(true);
        end;
    end;
}
