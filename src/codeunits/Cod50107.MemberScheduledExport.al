// ============================================================
// Codeunit 50107 - Member Scheduled Export
// ============================================================
// PURPOSE: Exports all members to a CSV file.
//          Designed to be run on a schedule via BC's Job Queue.
//
// HOW TO SCHEDULE WITH JOB QUEUE:
//   1. Search "Job Queue Entries" in BC
//   2. Click "New"
//   3. Set: Object Type to Run = Codeunit
//           Object ID to Run   = 50107
//           Description        = 'Nightly Member CSV Export'
//   4. In the "Recurrence" FastTab set your schedule
//      (e.g. Daily at 02:00)
//   5. Set Status = Ready → job runs automatically
//
// HOW IT WORKS WHEN CALLED INTERACTIVELY:
//   - The OnRun trigger fires (via CODEUNIT.Run or Job Queue)
//   - It calls ExportToFile() which streams the CSV via XMLport
//   - In an interactive session, DownloadFromStream() triggers a
//     browser download. In Job Queue (no GUI), the message is
//     suppressed by the GuiAllowed check.
//
// KEY CONCEPT - "TempBlob":
//   We can't write to disk directly in SaaS/cloud BC.
//   TempBlob holds data in memory as a stream, which we can
//   then download to the browser or pass to another service.
//
// KEY CONCEPT - "Xmlport.Export(XmlportId, OutStream)":
//   Runs an XMLport programmatically (no UI) and writes its
//   output into the provided OutStream. Used here to produce
//   the same CSV that the manual "Export Members" button does.
//
// KEY CONCEPT - "GuiAllowed":
//   Returns TRUE when running in an interactive session (user
//   is at a browser). Returns FALSE in Job Queue or background
//   sessions. Always check before calling UI functions like
//   DownloadFromStream() or Message().
// ============================================================

codeunit 50107 "Member Scheduled Export"
{
    // -------------------------------------------------------
    // OnRun – entry point for Job Queue and CODEUNIT.Run()
    // -------------------------------------------------------
    trigger OnRun()
    begin
        ExportToFile();
    end;

    // -------------------------------------------------------
    // ExportToFile
    // -------------------------------------------------------
    // Streams the Member table through XMLport 50100 ("Member Export")
    // and offers the result as a CSV download.
    //
    // NOTE FOR JOB QUEUE USE:
    //   When running headlessly, DownloadFromStream() is a no-op.
    //   In production you would replace it with:
    //     - Saving to a SharePoint/FTP via HttpClient
    //     - Emailing the file as an attachment
    //     - Writing to Azure Blob Storage
    //   For the training project, the download approach is sufficient.
    // -------------------------------------------------------
    procedure ExportToFile()
    var
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        InStr: InStream;
        FileName: Text;
    begin
        // Build the output filename: Members_YYYYMMDD.csv
        FileName := 'Members_' + Format(Today, 0, '<Year4><Month,2><Day,2>') + '.csv';

        // Create an in-memory output stream and run the XMLport into it
        TempBlob.CreateOutStream(OutStr);
        Xmlport.Export(Xmlport::"Member Export", OutStr);

        // Flip the TempBlob to an InStream for downloading
        TempBlob.CreateInStream(InStr);

        // Download to the browser if running interactively;
        // skip silently if running as a background Job Queue task.
        if GuiAllowed then begin
            DownloadFromStream(InStr, 'Export Members', '', 'CSV Files (*.csv)|*.csv', FileName);
            Message('Member export complete: %1', FileName);
        end;
        // When scheduled (no GUI): log completion via OnAfterExport
        // or extend this procedure to write to an external location.
    end;

    // -------------------------------------------------------
    // ExportWithEmailDelivery  (EXTENSION POINT — not wired up)
    // -------------------------------------------------------
    // In a real deployment you might want to email the CSV instead
    // of relying on a browser download.  Skeleton shown here for
    // reference; wire up with the Email API as needed.
    //
    // procedure ExportWithEmailDelivery(RecipientEmail: Text[100])
    // var
    //     TempBlob   : Codeunit "Temp Blob";
    //     OutStr     : OutStream;
    //     InStr      : InStream;
    //     EmailMsg   : Codeunit "Email Message";
    //     Email      : Codeunit Email;
    //     ToList     : List of [Text];
    //     FileName   : Text;
    // begin
    //     FileName := 'Members_' + Format(Today, 0, '<Year4><Month,2><Day,2>') + '.csv';
    //     TempBlob.CreateOutStream(OutStr);
    //     Xmlport.Export(Xmlport::"Member Export", OutStr);
    //     TempBlob.CreateInStream(InStr);
    //     ToList.Add(RecipientEmail);
    //     EmailMsg.Create(ToList, 'SACCO Member Export – ' + Format(Today), 'Please find the member export attached.', false);
    //     EmailMsg.AddAttachmentStream(InStr, FileName);
    //     Email.Send(EmailMsg, Enum::"Email Scenario"::Default);
    // end;
    //============================================================
    // LOG SCHEDULED EXPORT
    // ============================================================
    // Writes a success entry to the Activity Log.
    // Admins can view this under: Search → "Activity Log"
    // ============================================================
    local procedure LogScheduledExport(FileName: Text)
    var
        ActivityLog: Record "Activity Log";
    begin
        ActivityLog.LogActivity(
            ActivityLog,
            ActivityLog.Status::Success,
            'Member Export',
            StrSubstNo('Scheduled export completed. File: %1', FileName),
            ''
        );
    end;

}
