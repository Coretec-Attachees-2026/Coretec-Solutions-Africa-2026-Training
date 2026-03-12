// ============================================================
// Query 50117 - Member Statistics
// ============================================================
// PURPOSE: Provides aggregated member data for dashboards,
//          KPI analysis, and membership trends. Groups members
//          by status, category, and other dimensions.
//
// USE CASES:
//   - Monitor total active members and account balances
//   - Analyze member distribution by category or status
//   - Track membership growth over time
//   - Create dashboard widgets and visualizations
//   - Export data to Power BI for advanced analytics
//
// KEY COLUMNS:
//   - Status: Active/Inactive/Suspended/Closed member count
//   - Category: Members grouped by employment/type
//   - Registration Period: Cohort analysis
//
// NOTE: This query can be "Analyzed" in BC's Analysis Mode
//   to pivot and group data dynamically in the UI.
//
// ============================================================

query 50117 "Member Statistics"
{
    Caption = 'Member Statistics';
    QueryType = Normal;
    UsageCategory = ReportsAndAnalysis;

    elements
    {
        // ---------------------------------------------------------------
        // DATAITEM - Member (main source)
        // ---------------------------------------------------------------

        dataitem(Member; Member)
        {
            // ---------- COLUMNS from Member table ----------
            //
            // Include fields that can be grouped/filtered for analysis
            //
            // ----------

            column(MemberIDStat; "Member ID")
            {
                Caption = 'Member ID';
            }
            column(FullName_Stat; "Full Name")
            {
                Caption = 'Full Name';
            }
            column(Email_Stat; Email)
            {
                Caption = 'Email';
            }
            column(Status_Stat; Status)
            {
                Caption = 'Status';
            }
            column(RegistrationDate_Stat; "Registration Date")
            {
                Caption = 'Registration Date';
            }
            column(AccountBalance_Stat; "Account Balance")
            {
                Caption = 'Account Balance';
            }
            column(MemberCategory_Stat; "Member Category")
            {
                Caption = 'Member Category Code';
            }
            column(Occupation_Stat; Occupation)
            {
                Caption = 'Occupation';
            }
            column(AnnualIncome_Stat; "Annual Income")
            {
                Caption = 'Annual Income';
            }
            column(City_Stat; City)
            {
                Caption = 'City';
            }
            column(Country_Stat; Country)
            {
                Caption = 'Country';
            }

            // -----------------------------------------------------------
            // NESTED DATAITEM - Member Category Master
            // -----------------------------------------------------------
            //
            // Provides human-readable category names for grouping
            //
            // -----------------------------------------------------------

            dataitem(MemberCategoryMaster_Stat; "Member Category Master")
            {
                DataItemLink = Code = Member."Member Category";
                SqlJoinType = LeftOuterJoin;

                column(CategoryDescription_Stat; Description)
                {
                    Caption = 'Category Description';
                }
            }
        }
    }
}
