// ============================================================
// Report 50102 - Member Edit Report
// ============================================================
// PURPOSE: Allows administrators to view and edit member details
//          in a report format, then process/save changes back to
//          the Member table.
//
// KEY DIFFERENCES FROM MEMBER REPORT (Rpt50101):
//   Rpt50101 = Read-only report (view only, for printing/analysis)
//   Rpt50102 = Editable report (view + edit, saves changes to table)
//
// HOW IT WORKS:
//   1. Admin runs the report
//   2. Request page shows: Member ID dropdown to select which member
//   3. Report displays current member details
//   4. Admin can type new values for editable fields
//   5. Admin clicks "Process" button to save changes
//   6. Code automatically updates the Member table
//   7. Success message confirms the update
//
// EDITABLE FIELDS:
//   - Email
//   - Phone Number
//   - City
//   - Status
//   - Occupation
//   - Annual Income
//   - Member Category
//
// PROTECTED/READ-ONLY FIELDS:
//   - Member ID (cannot change)
//   - Full Name (managed by first/last name)
//   - Registration Date (system-set)
//   - Account Balance (managed by loans/payments)
// ============================================================

report 50102 "Member Edit Report"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    Caption = 'Member Edit Report';
    ProcessingOnly = true;  // This report doesn't print, just processes data

    dataset
    {
        dataitem(Member; "Member")
        {
            DataItemTableView = sorting("Member ID");
            RequestFilterFields = "Member ID";

            trigger OnPreDataItem()
            begin
                // Validate that a member was selected
                if GetFilter("Member ID") = '' then begin
                    if not ConfirmMemberSelection() then
                        CurrReport.Quit();
                end;
            end;

            trigger OnAfterGetRecord()
            begin
                // Populate the edited variables with current values when report first loads
                if FirstRecord then begin
                    EditedEmail := Email;
                    EditedPhone := "Phone Number";
                    EditedCity := City;
                    EditedStatus := Status;
                    EditedOccupation := Occupation;
                    EditedAnnualIncome := "Annual Income";
                    EditedMemberCategory := "Member Category";
                    FirstRecord := false;
                end;

                // UPDATE THE MEMBER RECORD with edited values
                Email := EditedEmail;
                "Phone Number" := EditedPhone;
                City := EditedCity;
                Status := EditedStatus;
                Occupation := EditedOccupation;
                "Annual Income" := EditedAnnualIncome;
                "Member Category" := EditedMemberCategory;

                // Save the changes to the database
                Modify(true);

                // Show success message after update
                Message('Member %1 (%2) has been updated successfully with the following changes:\' +
                    'Email: %3\Phone: %4\City: %5\Status: %6\Occupation: %7\Annual Income: %8\Member Category: %9',
                    "Member ID",
                    "Full Name",
                    EditedEmail,
                    EditedPhone,
                    EditedCity,
                    EditedStatus,
                    EditedOccupation,
                    EditedAnnualIncome,
                    EditedMemberCategory);
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group("Member to Edit")
                {
                    Caption = 'Select Member to Edit';

                    field(MemberIDFilter; SelectedMemberID)
                    {
                        Caption = 'Member ID';
                        ToolTip = 'Select which member to edit';
                        TableRelation = "Member"."Member ID";

                        trigger OnValidate()
                        begin
                            // When user selects a member, load their current data
                            if SelectedMemberID <> '' then begin
                                if MemberRec.Get(SelectedMemberID) then begin
                                    // Load current values into edit variables
                                    EditedEmail := MemberRec.Email;
                                    EditedPhone := MemberRec."Phone Number";
                                    EditedCity := MemberRec.City;
                                    EditedStatus := MemberRec.Status;
                                    EditedOccupation := MemberRec.Occupation;
                                    EditedAnnualIncome := MemberRec."Annual Income";
                                    EditedMemberCategory := MemberRec."Member Category";
                                    CurrentMemberName := MemberRec."Full Name";
                                end else
                                    Error('Member %1 not found.', SelectedMemberID);
                            end;
                        end;
                    }

                    field(CurrentName; CurrentMemberName)
                    {
                        Caption = 'Current Member Name';
                        ToolTip = 'Shows the full name of the selected member (read-only)';
                        Editable = false;
                    }
                }

                group("Editable Details")
                {
                    Caption = 'Edit Member Information';
                    Visible = (SelectedMemberID <> '');

                    // Contact Information Section
                    group("Contact Information")
                    {
                        field(EditEmail; EditedEmail)
                        {
                            Caption = 'Email';
                            ToolTip = 'Edit the member''s email address';
                        }
                        field(EditPhone; EditedPhone)
                        {
                            Caption = 'Phone Number';
                            ToolTip = 'Edit the member''s phone number';
                        }
                        field(EditCity; EditedCity)
                        {
                            Caption = 'City';
                            ToolTip = 'Edit the city where member lives';
                        }
                    }

                    // Status Section
                    group("Status")
                    {
                        field(EditStatus; EditedStatus)
                        {
                            Caption = 'Member Status';
                            ToolTip = 'Change member status (Active/Inactive/Suspended/Closed)';
                        }
                    }

                    // Employment Information Section
                    group("Employment Information")
                    {
                        field(EditOccupation; EditedOccupation)
                        {
                            Caption = 'Occupation';
                            ToolTip = 'Edit the member''s occupation';
                        }
                        field(EditIncome; EditedAnnualIncome)
                        {
                            Caption = 'Annual Income';
                            ToolTip = 'Edit the member''s annual income';
                        }
                        field(EditCategory; EditedMemberCategory)
                        {
                            Caption = 'Member Category';
                            ToolTip = 'Edit the member''s category (e.g., REGULAR, STUDENT, BUSINESS)';
                            TableRelation = "Member Category Master".Code;
                        }
                    }
                }
            }
        }

        actions
        {
            area(Processing)
            {
                action("Save Changes")
                {
                    Caption = 'Save Changes';
                    ToolTip = 'Save all edits to the member record';
                    Image = Save;

                    trigger OnAction()
                    begin
                        if SelectedMemberID = '' then begin
                            Error('Please select a member first.');
                        end;

                        // Run the report dataset which will update the member
                        CurrReport.Run();
                    end;
                }
            }
        }
    }

    var
        SelectedMemberID: Code[20];
        CurrentMemberName: Text[200];
        MemberRec: Record "Member";

        // Variables to hold edited values from request page
        EditedEmail: Text[100];
        EditedPhone: Text[20];
        EditedCity: Text[50];
        EditedStatus: Enum "Member Status";
        EditedOccupation: Text[100];
        EditedAnnualIncome: Decimal;
        EditedMemberCategory: Code[20];

        FirstRecord: Boolean;

    // -----------------------------------------------
    // Helper procedure to allow user to select member
    // -----------------------------------------------
    local procedure ConfirmMemberSelection(): Boolean
    var
        MemberList: Page "Member List";
    begin
        // Open the member list to let user select one
        MemberList.SetTableView(MemberRec);
        if MemberList.RunModal() = Action::LookupOK then begin
            MemberList.GetRecord(MemberRec);
            SelectedMemberID := MemberRec."Member ID";
            exit(true);
        end;
        exit(false);
    end;
}
