// ============================================================
// Query 50113 - Member Overview
// ============================================================
// PURPOSE: Retrieves Member data (and related Member Category) for
//          analysis, charts, and data exploration in Business Central.
//
// ============================================================
// PART 1: UNDERSTANDING HOW QUERIES WORK
// ============================================================
//
// A Query is different from a Report or XMLport:
//
//   REPORT: Loops through records, prints/renders output (PDF, Excel)
//   XMLPORT: Imports/exports data to/from files (XML, CSV)
//   QUERY:   Reads data into a dataset for DISPLAY or ANALYSIS
//
// QUERY USE CASES:
//   - Run from a page action → opens in "Analysis Mode" (slice/dice, group, filter)
//   - Use in code: Query.SetRange(), Query.Open(), Query.Read() for fast reads
//   - Power BI / OData: Expose as API for external tools
//   - Replace Record loops with Query for better performance
//
// QUERY STRUCTURE:
//   elements { dataitem → columns }
//   - dataitem: Which TABLE to read from
//   - column: Which FIELDS to include in the result
//   - Nested dataitems: JOIN tables (use DataItemLink, SqlJoinType)
//
// WHEN THE QUERY RUNS:
//   - From UI: Opens in Analysis Mode - users can group, filter, pivot
//   - From code: Query.Open() / Query.Read() - iterate through result set
//
// ============================================================
// PART 2: HOW THIS QUERY IS USED
// ============================================================
//
// 1) FROM THE MEMBERS PAGE:
//    Click "Analyze Members" action → Query opens in Analysis Mode.
//    Toggle "Analyze" switch to group by Status, Member Category, etc.
//
// 2) FROM TELL ME / SEARCH:
//    Search "Member Overview" (if UsageCategory is set).
//
// 3) FROM CODE (example):
//    var
//      MemberQuery: Query "Member Overview";
//    begin
//      MemberQuery.SetFilter(Status, '%1', MemberQuery.Status::Active);
//      MemberQuery.Open;
//      while MemberQuery.Read do
//        Message('Member: %1', MemberQuery.FullName);
//      MemberQuery.Close;
//    end;
//
// ============================================================
// PART 3: JOINING TABLES (Member + Member Category)
// ============================================================
//
// Member."Member Category" links to "Member Category Master".Code
// We nest the Member Category dataitem INSIDE the Member dataitem.
// DataItemLink = Code = Member."Member Category" connects them.
// SqlJoinType = LeftOuterJoin means: show Members even if they have
// no category (unlike InnerJoin which would hide them).
//
// ============================================================

query 50113 "Member Overview"
{
    Caption = 'Member Overview';
    QueryType = Normal;
    UsageCategory = ReportsAndAnalysis;

    elements
    {
        // ---------------------------------------------------------------
        // DATAITEM - Member table (main source)
        // ---------------------------------------------------------------
        //
        // dataitem(VariableName; "Table Name")
        //   VariableName: Use when referencing in nested dataitems (e.g. Member."Member Category")
        //   "Table Name": The BC table
        //
        // ---------------------------------------------------------------

        dataitem(Member; Member)
        {
            // ---------- COLUMNS from Member table ----------
            //
            // column(ColumnName; TableVariable.FieldName)
            //   ColumnName: Name in the query result (use underscores, no spaces)
            //   FieldName: The actual table field
            //
            // ----------

            column(MemberID; "Member ID")
            {
            }
            column(FullName; "Full Name")
            {
            }
            column(Email; Email)
            {
            }
            column(PhoneNumber; "Phone Number")
            {
            }
            column(Status; Status)
            {
            }
            column(RegistrationDate; "Registration Date")
            {
            }
            column(AccountBalance; "Account Balance")
            {
            }
            column(MemberCategory; "Member Category")
            {
            }
            column(Occupation; Occupation)
            {
            }
            column(AnnualIncome; "Annual Income")
            {
            }
            column(City; City)
            {
            }
            column(Country; Country)
            {
            }

            // -----------------------------------------------------------
            // NESTED DATAITEM - Member Category Master (joined table)
            // -----------------------------------------------------------
            //
            // Links Member."Member Category" to Member Category Master.Code
            // LeftOuterJoin = include Members even if category is blank
            //
            // -----------------------------------------------------------

            dataitem(MemberCategoryMaster; "Member Category Master")
            {
                DataItemLink = Code = Member."Member Category";
                SqlJoinType = LeftOuterJoin;

                column(CategoryDescription; Description)
                {
                    // Human-readable category name (e.g. "Employed Individual")
                }
            }
        }
    }
}
