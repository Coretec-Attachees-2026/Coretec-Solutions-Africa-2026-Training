page 50130 "Data Quality Issues"
{
    Caption = 'Data Quality Issues';
    PageType = List;
    SourceTable = "Data Quality Issue";
    SourceTableTemporary = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Rule Name"; Rec."Rule Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'The data quality rule that was violated.';
                    Style = Attention;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Details about the specific issue.';
                }
                field("Table ID"; Rec."Table ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'The ID of the table containing the bad data.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(OpenRecord)
            {
                Caption = 'Open Record';
                Image = ViewDetails;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Open the card for the record that has this data quality issue.';

                trigger OnAction()
                var
                    RecRef: RecordRef;
                    PageManagement: Codeunit "Page Management";
                begin
                    if RecRef.Get(Rec."Record ID") then begin
                        PageManagement.PageRun(RecRef);
                    end else
                        Message('Record could not be found. It may have been deleted since the scan ran.');
                end;
            }
        }
    }

    procedure SetTempRecords(var TempIssues: Record "Data Quality Issue" temporary)
    begin
        Rec.Copy(TempIssues, true);
    end;
}