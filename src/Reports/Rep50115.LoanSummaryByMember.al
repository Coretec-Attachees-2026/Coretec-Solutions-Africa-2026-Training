// ============================================================
// Report 50115 - Loan Summary by Member
// ============================================================
// PURPOSE: Shows each member with their loans listed underneath.
//          This is a multi-level report with parent-child structure.
//
// HOW IT WORKS:
// 1. DataItem 1 (Member) - Lists all members
// 2. DataItem 2 (Loan Application) - For each member, lists their loans
// 3. DataItemLink connects Loan Application to Member via Member ID
// 4. Request page allows filtering by Member ID, Status, etc.
//
// KEY CONCEPT - "DataItemLink":
//   Creates a parent-child relationship between the two DataItems.
//   For each member row, it shows all matching loan applications.
//
// EXAMPLE OUTPUT:
// ============================================================
// Member ID: MEM-20260303-0001  |  Full Name: John Doe
//   Loan No: LN-20260303-00001  |  Amount: 50,000  |  Status: Approved
//   Loan No: LN-20260303-00002  |  Amount: 75,000  |  Status: Pending
//
// Member ID: MEM-20260303-0002  |  Full Name: Jane Smith
//   Loan No: LN-20260303-00003  |  Amount: 100,000  |  Status: Approved
// ============================================================

report 50115 "Loan Summary by Member"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    Caption = 'Loan Summary by Member';
    DefaultRenderingLayout = LoanSummaryLayout;

    dataset
    {
        // ============================================================
        // DataItem 1: Member (Parent)
        // ============================================================
        // This is the top-level data source.
        // For each member, we'll show all their loans underneath.
        dataitem(Member; Member)
        {
            // Allow users to filter by these fields on the Request Page
            RequestFilterFields = "Member ID", Status, "Member Category";

            // Columns for Member data
            column(MemberId; "Member ID")
            {
            }
            column(FullName; "Full Name")
            {
            }
            column(MemberStatus; Status)
            {
            }
            column(MemberCategory; "Member Category")
            {
            }
            column(RegistrationDate; "Registration Date")
            {
            }
            column(Email; Email)
            {
            }
            column(PhoneNumber; "Phone Number")
            {
            }

            // ============================================================
            // DataItem 2: Loan Application (Child)
            // ============================================================
            // This DataItem is NESTED under Member.
            // It will repeat for each member, showing all their loans.
            //
            // KEY CONCEPT - "DataItemLink":
            //   Links Loan Application to Member by matching Member IDs.
            //   Syntax: "Field in Loan Application" = "Field in Parent Member"
            dataitem("Loan Application"; "Loan Application")
            {
                // Link this table to Member
                // "Loan Application"."Member ID" = "Member"."Member ID"
                DataItemLink = "Member ID" = field("Member ID");

                // By default, data is grouped by the parent.
                // This shows a proper parent-child structure.
                DataItemTableView = sorting("Member ID", "Loan Application No.");

                // Columns for Loan Application data
                column(LoanApplicationNo; "Loan Application No.")
                {
                }
                column(LoanAmount; "Loan Amount")
                {
                }
                column(LoanStatus; Status)
                {
                }
                column(ApplicationDate; "Application Date")
                {
                }
                column(LoanTerm; "Loan Term (Months)")
                {
                }
                column(InterestRate; "Interest Rate (%)")
                {
                }
                column(MonthlyPayment; "Monthly Payment")
                {
                }
                column(TotalRepayment; "Total Repayment")
                {
                }
                column(ApprovalDate; "Approval Date")
                {
                }
            }
        }
    }

    requestpage
    {
        AboutTitle = 'Loan Summary by Member Report';
        AboutText = 'This report displays each member with their loans listed underneath. You can filter by Member ID, Member Status, or Category.';

        layout
        {
            area(Content)
            {
                group("Report Options")
                {
                    Caption = 'Report Options';
                    field(ShowAllMembers; ShowAllMembers)
                    {
                        ApplicationArea = All;
                        Caption = 'Show All Members (including those without loans)';
                        ToolTip = 'Check to include members even if they have no loan applications.';
                    }
                }
            }
        }

        actions
        {
            area(processing)
            {
                action(SelectLayout)
                {
                    ApplicationArea = All;
                    Caption = 'Select Layout';
                    ToolTip = 'Choose the report layout';
                }
            }
        }
    }

    rendering
    {
        layout(LoanSummaryLayout)
        {
            Type = RDLC;
            LayoutFile = 'LoanSummaryByMember.rdl';
        }
    }

    var
        ShowAllMembers: Boolean;
}
