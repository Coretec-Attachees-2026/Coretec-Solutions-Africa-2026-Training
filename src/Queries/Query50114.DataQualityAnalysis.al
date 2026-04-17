// ============================================================
// Query 50114 - Data Quality Analysis Query
// ============================================================
// PURPOSE: Query to analyze data quality issues.
//          Can be used for reporting and trend analysis.
//
// USAGE: Use this query to generate data quality reports
//        in tools like Excel or Power BI. The query joins
//        tables to show related information.
// ============================================================

query 50114 "Data Quality Analysis"
{
    QueryType = Normal;
    Caption = 'Data Quality Analysis';

    elements
    {
        dataitem(Root; "Data Quality Issue")
        {
            column(Entry_No; "Entry No.")
            {
                Caption = 'Entry No.';
            }
            column(Issue_Type; "Issue Type")
            {
                Caption = 'Issue Type';
            }
            column(Severity; Severity)
            {
                Caption = 'Severity';
            }
            column(Record_Type; "Record Type")
            {
                Caption = 'Record Type';
            }
            column(Primary_Record_ID; "Primary Record ID")
            {
                Caption = 'Primary Record ID';
            }
            column(Secondary_Record_ID; "Secondary Record ID")
            {
                Caption = 'Secondary Record ID';
            }
            column(Issue_Description; "Issue Description")
            {
                Caption = 'Issue Description';
            }
            column(Details; Details)
            {
                Caption = 'Details';
            }
            column(Recommendation; Recommendation)
            {
                Caption = 'Recommendation';
            }
            column(Date_Found; "Date Found")
            {
                Caption = 'Date Found';
            }
        }
    }
}
