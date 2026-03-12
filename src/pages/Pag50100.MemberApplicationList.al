// ============================================================
// Page 50100 - Member Application List
// ============================================================
// PURPOSE: Shows ALL member applications in a scrollable list.
//          This is the main screen an admin sees to manage
//          who has applied to become a SACCO member.
//
// KEY CONCEPT - "PageType = List":
//   A List page shows MANY records in a table/grid format.
//   Think of it like an Excel spreadsheet — rows and columns.
//   Each row is one application.
//
// KEY CONCEPT - "SourceTable":
//   Tells BC which table provides the data for this page.
//   This page reads from the "Member Application" table (Tab50100).
//
// KEY CONCEPT - "UsageCategory = Lists":
//   This makes the page appear in BC's search bar and
//   navigation menu so users can find it easily.
//
// KEY CONCEPT - "Editable = false":
//   Users can VIEW data on this page but can't EDIT it here.
//   To edit, they must open the Card page (Pag50101).
//
// USER WORKFLOW:
//   1. Admin opens this list page
//   2. Sees all applications with their statuses
//   3. Can click "New Application" to create one
//   4. Can select an application and Approve/Reject it
//   5. Can click "View Details" to open the full Card page
// ============================================================

page 50100 "Member Application List"
{
    Caption = 'Member Applications';       // Title shown at the top of the page
    PageType = List;                       // Display as a list (grid/table format)
    SourceTable = "Member Application";    // Pull data from the Member Application table
    ApplicationArea = All;                 // Available to all users
    UsageCategory = Lists;                 // Appears in BC search/navigation under "Lists"
    Editable = false;                      // Read-only — can't edit directly on this page

    // -------------------------------------------------------
    // LAYOUT SECTION
    // Defines WHAT data columns appear in the list
    // -------------------------------------------------------
    layout
    {
        area(Content)
        {
            // KEY CONCEPT - "repeater":
            //   A repeater shows one row PER RECORD in the table.
            //   Think of it as: "repeat this group of fields for each application."
            //   This is how BC creates the rows in a list.
            repeater(General)
            {
                // Each field() below becomes a COLUMN in the list
                field("Application ID"; rec."Application ID")
                {
                    ToolTip = 'Specifies the value of the Application ID field';
                }
                field("First Name"; rec."First Name")
                {
                    ToolTip = 'Specifies the value of the First Name field';
                }
                field("Last Name"; rec."Last Name")
                {
                    ToolTip = 'Specifies the value of the Last Name field';
                }
                field("Email"; rec."Email")
                {
                    ToolTip = 'Specifies the value of the Email field';
                }
                field("Phone Number"; rec."Phone Number")
                {
                    ToolTip = 'Specifies the value of the Phone Number field';
                }
                field("Application Date"; rec."Application Date")
                {
                    ToolTip = 'Specifies the value of the Application Date field';
                }
                field("Status"; rec."Status")
                {
                    ToolTip = 'Specifies the value of the Status field';
                }
                field("Member Category"; rec."Member Category")
                {
                    ToolTip = 'Specifies the value of the Member Category field';
                }
            }
        }
    }

    // -------------------------------------------------------
    // ACTIONS SECTION
    // Defines the BUTTONS the user can click
    // -------------------------------------------------------
    actions
    {
        area(Processing)
        {
            // --- Action: New Application ---
            // Opens the Application Card page in "Create" mode
            // KEY CONCEPT - "RunObject":
            //   Tells BC to open another page when this button is clicked.
            // KEY CONCEPT - "RunPageMode = Create":
            //   Opens the page ready to create a NEW record (blank form).
            // KEY CONCEPT - "Promoted":
            //   When true, the button appears in the top action bar
            //   (not hidden in menus). Makes it easy to find.
            action("New Application")
            {
                Caption = 'New Application';
                Image = New;                               // Shows a "+" icon
                Promoted = true;                           // Show in top action bar
                PromotedCategory = New;                    // Groups under "New" category
                RunObject = page "Member Application Card"; // Opens the Card page
                RunPageMode = Create;                       // In create mode (blank form)
            }

            // --- Action: Member Setup ---
            // Opens the setup page where No. Series is configured
            // KEY CONCEPT - "Page.Run()":
            //   Opens another page programmatically (via code).
            //   Unlike RunObject (which is declarative/automatic),
            //   this lets you run code before/after opening the page.
            action("Member Setup")
            {
                Caption = 'Member Setup';
                Image = Setup;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    Page.Run(Page::"Member Setup");
                end;
            }

            // --- Action: View Details ---
            // Opens the Card page for the SELECTED application
            // KEY CONCEPT - "RunPageLink":
            //   Filters the target page to show only the record
            //   matching the current selection. Here it says:
            //   "Open the Card where Application ID = the one I selected"
            action("View Details")
            {
                Caption = 'View Details';
                RunObject = page "Member Application Card";
                RunPageLink = "Application ID" = field("Application ID");
                Image = Open;
                Promoted = true;
                PromotedCategory = Process;
            }

            // --- Action: Approve Application ---
            // Approves the selected application and creates a Member
            // KEY CONCEPT - "Confirm()":
            //   Shows a Yes/No dialog to the user. Returns true if
            //   they click Yes. This prevents accidental approvals.
            // KEY CONCEPT - "CurrPage.Update(false)":
            //   Refreshes the current page to show updated data.
            //   false = don't save pending changes first.
            action("Approve Application")
            {
                Caption = 'Approve Application';
                Image = Approve;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    MemberMgmt: Codeunit "Member Management";  // Business logic codeunit
                begin
                    if Confirm('Do you want to approve this application?', false) then
                        MemberMgmt.ApproveApplication(rec."Application ID");
                    CurrPage.Update(false);  // Refresh the list to show new status
                end;
            }

            // --- Action: Reject Application ---
            // Rejects the selected application with a reason
            action("Reject Application")
            {
                Caption = 'Reject Application';
                Image = Reject;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    MemberMgmt: Codeunit "Member Management";
                    RejectionReason: Text[250];
                begin
                    if Confirm('Do you want to reject this application?', false) then begin
                        RejectionReason := 'Application rejected by administrator';
                        MemberMgmt.RejectApplication(rec."Application ID", RejectionReason);
                        CurrPage.Update(false);  // Refresh the list
                    end;
                end;
            }

            // --- Action: Import Applications from CSV ---
            // Imports applicant data from a CSV file (Excel → Save As → CSV)
            // Each row becomes a new application with:
            //   - Auto-generated Application ID (APP-YYYYMMDD-#####)
            //   - Status = Pending (ready for admin approval)
            //   - Application Date = now
            action("Import Applications")
            {
                Caption = 'Import Applications';
                ApplicationArea = All;
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Import member applications from an Excel (.xlsx) or CSV (.csv) file. Each row creates a new Pending application.';

                trigger OnAction()
                var
                    ExcelMgt: Codeunit "Excel Import Export Mgt";
                    FormatChoice: Integer;
                begin
                    // StrMenu shows a dropdown with numbered options.
                    // Returns 1 for first option, 2 for second, 0 if cancelled.
                    FormatChoice := StrMenu(
                        'Excel (.xlsx),CSV (.csv)',
                        1,
                        'Choose import format');

                    case FormatChoice of
                        1:
                            ExcelMgt.ImportApplicationsFromExcel();
                        2:
                            ExcelMgt.ImportApplicationsFromCSV();
                    // 0 = user cancelled — do nothing
                    end;
                    CurrPage.Update(false);
                end;
            }

            // --- Action: Download Import Template ---
            // Downloads an empty .xlsx file with the correct 13-column
            // headers and a sample data row so users know exactly what
            // format to use when preparing import data.
            action("Download Import Template")
            {
                Caption = 'Download Import Template';
                ApplicationArea = All;
                Image = Template;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Download an Excel template with headers and sample data for importing member applications.';

                trigger OnAction()
                var
                    ExcelMgt: Codeunit "Excel Import Export Mgt";
                begin
                    ExcelMgt.DownloadImportTemplate();
                end;
            }
        }
    }
}
