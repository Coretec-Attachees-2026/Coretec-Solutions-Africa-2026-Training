// ============================================================
// Codeunit 50100 - Member App No. Series Mgt
// ============================================================
// PURPOSE: Automatically creates the No. Series for Member Applications.
//
// WHAT IS A NO. SERIES?
//   A No. Series is BC's system for auto-generating sequential numbers.
//   Instead of manually typing IDs, the system generates them:
//   00001, 00002, 00003, etc.
//
// THIS CODEUNIT CREATES:
//   - A No. Series called 'MEMAPPSEQ' (Member Application Sequence)
//   - Starting at '00001', incrementing by 1
//   - Links it to the Member Setup table
//
// KEY CONCEPT - "Permissions":
//   The "Permissions" property tells BC which tables this codeunit
//   needs access to. Without these, BC might block the operations.
//   r = read, i = insert, m = modify, d = delete
//   "rimd" = full access (read, insert, modify, delete)
//
// WHEN IS THIS CALLED?
//   - During extension installation (by Cod50103)
//   - When creating a Member Application (by Tab50100)
//   It's safe to call multiple times — it checks first and only
//   creates the series if it doesn't exist.
// ============================================================

codeunit 50100 "Member App No. Series Mgt"
{
    // Grant this codeunit permission to read/write these tables
    Permissions = tabledata "No. Series" = rimd,
                  tabledata "No. Series Line" = rimd,
                  tabledata "Member Setup" = rimd;

    // -------------------------------------------------------
    // EnsureMemberApplicationNoSeriesAndSetup
    // -------------------------------------------------------
    // Main entry point. Does two things:
    //   1. Creates the MEMAPPSEQ No. Series (if it doesn't exist)
    //   2. Links it to Member Setup (if not already linked)
    // -------------------------------------------------------
    procedure EnsureMemberApplicationNoSeriesAndSetup()
    var
        MemberSetup: Record "Member Setup";
    begin
        // Step 1: Create No. Series if needed
        EnsureNoSeries();

        // Step 2: Link to Member Setup
        MemberSetup.GetOrCreateSetup();
        if MemberSetup."Member Application Nos." = '' then begin
            MemberSetup."Member Application Nos." := 'MEMAPPSEQ';
            MemberSetup.Modify(true);  // Save the change
        end;
    end;

    // -------------------------------------------------------
    // EnsureNoSeries (local)
    // -------------------------------------------------------
    // Creates the 'MEMAPPSEQ' No. Series and its line.
    //
    // No. Series has TWO parts:
    //   1. Header ("No. Series" table) - name, settings
    //   2. Line ("No. Series Line" table) - start number, increment
    //
    // "Default Nos." = true means numbers are auto-assigned
    // "Manual Nos." = false means user can't type their own number
    // -------------------------------------------------------
    local procedure EnsureNoSeries()
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        // Create the header (only if it doesn't exist)
        if not NoSeries.Get('MEMAPPSEQ') then begin
            NoSeries.Init();
            NoSeries.Code := 'MEMAPPSEQ';
            NoSeries.Description := 'Member Application Sequence';
            NoSeries."Default Nos." := true;    // Auto-assign numbers
            NoSeries."Manual Nos." := false;    // Don't allow manual entry
            NoSeries.Insert(true);
        end;

        // Create the line (defines the actual numbering)
        // SetRange filters to only look for lines in this series
        NoSeriesLine.SetRange("Series Code", 'MEMAPPSEQ');
        if NoSeriesLine.IsEmpty() then begin
            NoSeriesLine.Init();
            NoSeriesLine."Series Code" := 'MEMAPPSEQ';
            NoSeriesLine."Line No." := 10000;        // Standard line number
            NoSeriesLine."Starting Date" := 0D;       // No date restriction
            NoSeriesLine."Starting No." := '00001';    // First number
            NoSeriesLine."Increment-by No." := 1;      // Go up by 1
            NoSeriesLine.Open := true;                 // Series is active
            NoSeriesLine.Insert(true);
        end;
    end;
}
