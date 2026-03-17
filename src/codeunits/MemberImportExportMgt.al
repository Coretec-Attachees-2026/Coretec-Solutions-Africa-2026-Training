codeunit 50106 "Member Import/Export Mgt"
{

    // -------------------------------------------------------
    // EXPORT MEMBERS
    // -------------------------------------------------------
    procedure ExportMembers()
    var
        MemberExport: XMLport "Member Export";
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        InStr: InStream;
        FileName: Text;
    begin
        FileName := 'Members.csv';

        // Write XMLport output into memory stream
        TempBlob.CreateOutStream(OutStr);
        MemberExport.SetDestination(OutStr);
        MemberExport.Export();

        // Download with forced .csv filename
        TempBlob.CreateInStream(InStr);
        DownloadFromStream(InStr, 'Export Members', '', 'CSV Files (*.csv)|*.csv', FileName);
    end;

    // -------------------------------------------------------
    // IMPORT MEMBERS
    // -------------------------------------------------------
    procedure ImportMembers()
    var
        MemberImport: XMLport "Member Import";
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
        OutStr: OutStream;
        FileName: Text;
    begin
        FileName := '';

        // Open file picker — user selects their CSV file
        if not UploadIntoStream('Import Members', '', 'CSV Files (*.csv)|*.csv', FileName, InStr) then
            exit; // User cancelled

        // Feed the stream into the XMLport for import
        MemberImport.SetSource(InStr);
        MemberImport.Import();

        Message('Members imported successfully from %1', FileName);
    end;

}