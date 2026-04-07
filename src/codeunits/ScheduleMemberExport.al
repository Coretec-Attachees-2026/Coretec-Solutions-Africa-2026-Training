codeunit 50106 "Member Scheduled Export"
{
    trigger OnRun()
    var
        WriteToBlob: Codeunit "Temp Blob";
        OutStream: OutStream;
        InStream: InStream;
        DialogueText: Text;
        FileName: Text;
    begin
        WriteToBlob.CreateOutStream(OutStream);
        // writetoblob - container
        // outstream - pipe
        // outstream has .write() to write to the stream, like a pipe, so .write() pours data into the pipe
        Xmlport.Export(Xmlport::"Export Member XMLport", OutStream);
        //  or pass the outstream to Export and it does the pouring, it calls outstream.write() itself
        // after that now writetoblob has the csv data which we need to read
        // writetoblob has .createinstream to read data from it
        WriteToBlob.CreateInStream(InStream);
        // create an opening to read data, or we can download the file directly to the browser using the instream
        DialogueText := 'Downloading Member data';
        FileName := 'Members.csv';
        DownloadFromStream(InStream, DialogueText, '', 'All Files (*.*)|*.*', FileName);
        // InStream.read() is called by downloadfromstream 
    end;

}