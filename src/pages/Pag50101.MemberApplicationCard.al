// ============================================================
// Page 50101 - Member Application Card
// ============================================================
// PURPOSE: Shows the FULL DETAILS of ONE member application.
//          This is where you fill out a new application or
//          review an existing one.
//
// KEY CONCEPT - "PageType = Card":
//   A Card page shows ONE record with all its details.
//   Think of it like a paper form — all fields visible at once.
//   This is the opposite of a List page (which shows many records).
//
// KEY CONCEPT - List vs Card Pattern:
//   In BC, data entry follows a common pattern:
//   LIST page = overview (see all records in a grid)
//   CARD page = detail (see/edit one record's full details)
//   Users click a row in the List → opens the Card for that record.
//
// KEY CONCEPT - "DelayedInsert = true":
//   Don't save the record to the database until the user
//   has entered some data. Without this, an empty record
//   would be created as soon as the page opens.
//
// KEY CONCEPT - "DeleteAllowed = false":
//   Users can't delete applications — we want to keep
//   a history of all applications for audit purposes.
//
// FORM SECTIONS (Groups):
//   1. General Information — ID, status, date (auto-filled, read-only)
//   2. Personal Information — name, DOB, ID number (user fills in)
//   3. Contact Information — phone, email, address (user fills in)
//   4. Employment Information — job, income, category (user fills in)
//   5. Approval Information — approval date, rejection reason (read-only)
// ============================================================

page 50101 "Member Application Card"
{
    Caption = 'Member Application';        // Title shown at the top
    PageType = Card;                       // Shows ONE record in detail
    SourceTable = "Member Application";    // Reads from Member Application table
    ApplicationArea = All;
    DelayedInsert = true;                  // Don't save until user enters data
    InsertAllowed = true;                  // Users CAN create new applications
    DeleteAllowed = false;                 // Users CANNOT delete applications

    // -------------------------------------------------------
    // LAYOUT SECTION
    // Organizes fields into logical groups (like sections on a form)
    // -------------------------------------------------------
    layout
    {
        area(Content)
        {
            // --- Section 1: General Information ---
            // These fields are auto-generated (read-only)
            // KEY CONCEPT - "group()":
            //   Groups visually organize fields on the page.
            //   They create collapsible sections with a header.
            group("General Information")
            {
                field("Application ID"; rec."Application ID")
                {
                    ToolTip = 'Specifies the unique identifier for this application';
                    Editable = false;  // Auto-generated, user can't change
                }
                field("Status"; rec."Status")
                {
                    ToolTip = 'Specifies the current status of the application';
                    Editable = false;  // Changed by Approve/Reject actions only
                }
                field("Application Date"; rec."Application Date")
                {
                    ToolTip = 'Specifies when the application was submitted';
                    Editable = false;  // Set automatically on creation
                }
            }

            // --- Section 2: Personal Information ---
            // User fills in the applicant's personal details
            group("Personal Information")
            {
                field("First Name"; rec."First Name")
                {
                    ToolTip = 'Specifies the applicant''s first name';
                }
                field("Last Name"; rec."Last Name")
                {
                    ToolTip = 'Specifies the applicant''s last name';
                }
                field("Date of Birth"; rec."Date of Birth")
                {
                    ToolTip = 'Specifies the applicant''s date of birth';
                }
                field("ID Number"; rec."ID Number")
                {
                    ToolTip = 'Specifies the applicant''s ID or passport number';
                }
            }

            // --- Section 3: Contact Information ---
            // How to reach the applicant
            group("Contact Information")
            {
                field("Phone Number"; rec."Phone Number")
                {
                    ToolTip = 'Specifies the applicant''s phone number';
                }
                field("Email"; rec."Email")
                {
                    ToolTip = 'Specifies the applicant''s email address';
                }
                field("Address"; rec."Address")
                {
                    ToolTip = 'Specifies the applicant''s street address';
                }
                field("City"; rec."City")
                {
                    ToolTip = 'Specifies the applicant''s city';
                }
                field("Postal Code"; rec."Postal Code")
                {
                    ToolTip = 'Specifies the applicant''s postal code';
                }
                field("Country"; rec."Country")
                {
                    ToolTip = 'Specifies the applicant''s country';
                }
            }

            // --- Section 4: Employment Information ---
            // Financial details for the application
            group("Employment Information")
            {
                field("Occupation"; rec."Occupation")
                {
                    ToolTip = 'Specifies the applicant''s occupation';
                }
                field("Annual Income"; rec."Annual Income")
                {
                    ToolTip = 'Specifies the applicant''s annual income';
                }
                field("Member Category"; rec."Member Category")
                {
                    ToolTip = 'Specifies the member category';
                }
            }

            // --- Section 5: Approval Information ---
            // Read-only section showing approval/rejection details
            // "Editable = false" on the GROUP makes ALL fields in it read-only
            group("Approval Information")
            {
                Editable = false;  // Entire group is read-only
                field("Approval Date"; rec."Approval Date")
                {
                    ToolTip = 'Specifies when the application was approved or rejected';
                }
                field("Rejection Reason"; rec."Rejection Reason")
                {
                    ToolTip = 'Specifies the reason for rejection, if applicable';
                }
            }
        }
    }

    // -------------------------------------------------------
    // ACTIONS SECTION
    // Approve and Reject buttons for processing applications
    // -------------------------------------------------------
    actions
    {
        area(Processing)
        {
            // --- Approve Button ---
            // Calls the ApproveApplication procedure in the Member Management codeunit
            action("Approve")
            {
                Caption = 'Approve';
                Image = Approve;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    MemberMgmt: Codeunit "Member Management";
                begin
                    // Ask "Are you sure?" before approving
                    if Confirm('Do you want to approve this application?', false) then begin
                        MemberMgmt.ApproveApplication(rec."Application ID");
                        CurrPage.Update(false);  // Refresh to show new status
                    end;
                end;
            }

            // --- Reject Button ---
            // Calls the RejectApplication procedure with a reason
            action("Reject")
            {
                Caption = 'Reject';
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
                        CurrPage.Update(false);  // Refresh to show new status
                    end;
                end;
            }
        }
    }
}
