query 50129 "Member Query"
{
    QueryType = Normal;
    Caption = 'Member query';
    AboutTitle = 'Analyze active members';
    AboutText = 'I do not know where about text goes';
    UsageCategory = ReportsAndAnalysis;
    
    elements
    {
        dataitem(Members; Member)
        {
            column(First_Name; "First Name")
            {
                
            }
            column(Last_Name;"Last Name") {

            }
            column(ID_Number;"ID Number") {

            }
            column(Member_Category;"Member Category") {

            }
            column(City;City) {

            }
            column(Status;Status) {

            }
        }
    }
    
    trigger OnBeforeOpen()
    begin
        
    end;
}