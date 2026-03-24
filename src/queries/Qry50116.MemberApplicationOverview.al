// ============================================================
// Query 50116 - Member Application Overview
// ============================================================
// PURPOSE: Retrieves Member Application data for monitoring
//          the membership signup process. Tracks applications
//          from submitted → approved → rejected states.
//
// USE CASES:
//   - Monitor pending membership applications
//   - Track approval rates and processing times
//   - Analyze member demographics by application
//   - Generate approval/rejection reports
//   - Follow up on applications by status
//
// JOINS:
//   - Member Application → Member Category Master (shows applicant category)
//
// ============================================================

query 50116 "Member Application Overview"
{
    Caption = 'Member Application Overview';
    QueryType = Normal;
    UsageCategory = ReportsAndAnalysis;

    elements
    {
        // ---------------------------------------------------------------
        // DATAITEM - Member Application (main source)
        // ---------------------------------------------------------------

        dataitem(MemberApplication; "Member Application")
        {
            // ---------- COLUMNS from Member Application table ----------

            column(ApplicationID; "Application ID")
            {
                Caption = 'Application ID';
            }
            column(FirstName; "First Name")
            {
                Caption = 'First Name';
            }
            column(LastName; "Last Name")
            {
                Caption = 'Last Name';
            }
            column(Email_App; Email)
            {
                Caption = 'Email';
            }
            column(PhoneNumber_App; "Phone Number")
            {
                Caption = 'Phone Number';
            }
            column(ApplicationDate; "Application Date")
            {
                Caption = 'Application Date';
            }
            column(DateOfBirth; "Date of Birth")
            {
                Caption = 'Date of Birth';
            }
            column(IDNumber; "ID Number")
            {
                Caption = 'ID/Passport Number';
            }
            column(Address; Address)
            {
                Caption = 'Address';
            }
            column(City_App; City)
            {
                Caption = 'City';
            }
            column(Country_App; Country)
            {
                Caption = 'Country';
            }
            column(Status_App; Status)
            {
                Caption = 'Status';
            }
            column(ApprovalDate; "Approval Date")
            {
                Caption = 'Approval Date';
            }
            column(RejectionReason_App; "Rejection Reason")
            {
                Caption = 'Rejection Reason';
            }
            column(OccupationCode_App; "Occupation Code")
            {
                Caption = 'Occupation Code';
            }
            column(AnnualIncome_App; "Annual Income")
            {
                Caption = 'Annual Income';
            }
            column(MemberCategoryCode_App; "Member Category")
            {
                Caption = 'Member Category Code';
            }

            // -----------------------------------------------------------
            // NESTED DATAITEM - Member Category Master
            // -----------------------------------------------------------
            //
            // Shows category description for applicants
            //
            // -----------------------------------------------------------

            dataitem(MemberCategoryMaster_App; "Member Category Master")
            {
                DataItemLink = Code = MemberApplication."Member Category";
                SqlJoinType = LeftOuterJoin;

                column(CategoryDescription_App; Description)
                {
                    Caption = 'Category';
                }
            }
        }
    }
}
