page 50109 "Loan Application Audit Log"
{
    PageType = List;
    Caption = 'Loan Application Audit Log';
    Editable = false;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Loan Application Audit Log";
    
    layout
    {
        area(Content)
        {
            repeater("Loan Application Audit Log")
            {
                field("Audit ID"; Rec."Audit ID")
                {                    
                }
                field("Loan Application ID"; Rec."Loan Application ID") {

                }
                field("Auditor"; Rec.Auditor) {

                }
                field("Status From"; Rec.StatusFrom) {

                }
                field("Status To"; Rec.StatusTo) {

                }
                field("Audited at";Rec.SystemCreatedAt) {

                }
            }
        }
        area(Factboxes)
        {
            
        }
    }
    
    actions
    {
        area(Processing)
        {
            action("Loan Applications")
            {
                
                trigger OnAction()
                begin
                    
                end;
            }
        }
    }
}