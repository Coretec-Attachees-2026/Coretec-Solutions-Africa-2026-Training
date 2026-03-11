// ============================================================
// Codeunit 50106 - Member Import/Export Management
// ============================================================
// PURPOSE: Handle import and export of Member data
// NOTE: This codeunit is currently not used - the page buttons call XMLports directly
// Kept as stub for future enhancements
// ============================================================

codeunit 50106 "Member Import/Export Mgt"
{

    // -------------------------------------------------------
    // EXPORT MEMBERS
    // -------------------------------------------------------
    procedure ExportMembers()
    var
        MemberExportXMLport: Xmlport "Member Export";
    begin
        // Export members using XMLport 50112
        MemberExportXMLport.Run();
    end;

    // -------------------------------------------------------
    // IMPORT MEMBERS
    // -------------------------------------------------------
    procedure ImportMembers()
    var
        MemberImportXMLport: Xmlport "Member Import";
    begin
        // Import members using XMLport 50113
        MemberImportXMLport.Run();
    end;
}
