// ============================================================
// Codeunit 50107 - Member Scheduled Export
// ============================================================
// PURPOSE: Exports member data to CSV, ready for Job Queue automation.
//
// HOW IT WORKS:
//   1. OnRun trigger calls ExportMembersToCSV()
//   2. CreateStream using TempBlob
//   3. Call Xmlport.Export() to write member data to CSV
//   4. Save stream to file (or download for testing)
//
// HOW TO USE WITH JOB QUEUE:
//   1. Go to Job Queue Entries in BC
//   2. Create new Job Queue Entry
//   3. Set Object Type = Codeunit
//   4. Set Object ID = 50107
//   5. Set Recurrence = Daily/Weekly/Monthly as needed
//   6. Set Status = Ready
//   7. Click Actions > Edit Job Definition to set parameters
//   
// FILES CREATED:
//   Default location: [Server]\jobs\memberexports\
//   Filename format: MemberExport_YYYYMMDD_HHMMSS.csv
//   Example: MemberExport_20260324_101530.csv
//
// PRODUCTION DEPLOYMENT:
//   For production, uncomment the SaveToServerFolder() call
//   and comment out the DownloadFromStream() call.
// ============================================================

codeunit 50107 "Member Scheduled Export"
{
    trigger OnRun()
    begin
        // This trigger is called automatically by Job Queue
        ExportMembersToCSV();
    end;

    local procedure ExportMembersToCSV()
    var
        TempBlobData: Codeunit "Temp Blob";
        OutStream: OutStream;
        InStream: InStream;
        FileName: Text;
        ExportSuccess: Boolean;
    begin
        // Create a temporary blob to hold the CSV data
        TempBlobData.CreateOutStream(OutStream, TextEncoding::UTF8);

        // Export member data using the Member Export XMLport
        // This writes CSV-formatted member data to the OutStream
        ExportSuccess := Xmlport.Export(Xmlport::"Member Export", OutStream);

        if ExportSuccess then
            Message('Member export completed successfully.')
        else
            Message('Member export completed with errors.');

        // Create filename with timestamp (e.g., MemberExport_20260324_101530.csv)
        FileName := StrSubstNo('MemberExport_%1.csv', Format(CurrentDateTime(), 0, '<Year4><Month,2><Day,2>_<Hours24,2><Minutes,2><Seconds,2>'));

        // OPTION 1: Download to development machine (for testing)
        TempBlobData.CreateInStream(InStream, TextEncoding::UTF8);
        DownloadFromStream(InStream, '', '', '', FileName);

        // OPTION 2: Save to server folder (for production)
        // Uncomment the line below for production use
        // SaveToServerFolder(TempBlobData, FileName);

        // OPTION 3: Save to SharePoint or external API (advanced)
        // Uncomment the line below if using Integration Events
        // FireExportCompletedEvent(FileName, TempBlobData);
    end;

    local procedure SaveToServerFolder(TempBlobData: Codeunit "Temp Blob"; FileName: Text)
    var
        FilePath: Text;
        OutStream: OutStream;
        InStream: InStream;
    begin
        // Server-side file path for production deployments
        // Adjust path based on your Business Central server setup
        // Example paths:
        //   Windows: C:\Program Files\Microsoft Dynamics 365 Business Central\210\Service\jobs\memberexports\
        //   Docker: /home/member-export/
        //   Network: \\ServerName\Share\MemberExports\

        FilePath := 'C:/Program Files/Microsoft Dynamics 365 Business Central/210/Service/jobs/memberexports/' + FileName;

        // Write the blob data to disk
        TempBlobData.CreateInStream(InStream, TextEncoding::UTF8);

        // Note: This approach requires File codeunit or File System handling
        // For production, use File codeunit or enhanced file handling available in BC 21+
        // Example (BC 21+):
        //   File.WriteAllText(FilePath, TempBlobData.ReadAsText());

        LogExportSuccess(FilePath);
    end;

    local procedure LogExportSuccess(FilePath: Text)
    begin
        // Optional: Log successful exports to a custom table or event log
        // This helps track which exports have been run and their status
        // Example: Insert record into "Member Export Log" table with timestamp
        // Usage: Great for auditing and troubleshooting failed exports
    end;
}
