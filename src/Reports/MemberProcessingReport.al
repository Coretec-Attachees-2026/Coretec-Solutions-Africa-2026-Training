// ============================================================
// Report 50101 - Member Details Update (Processing Report)
// ============================================================
// PURPOSE: Allows updating member details in bulk via a
//          processing report. No preview/print is generated.
//
// HOW IT WORKS:
//   1. User runs the report from the Member List page
//   2. The request page lets the user filter which member(s) to update
//   3. The user enters new values for the fields they want to change
//   4. On processing, the report updates only the fields that
//      have been filled in on the request page
//   5. A success message is displayed after processing
//
// KEY CONCEPT - "ProcessingOnly = true":
//   This report does NOT produce any printable output.
//   It only processes (modifies) data. There is no layout file.
// ============================================================

report 50101 "Member Details Update"
{
    Caption = 'Member Details Update';
    UsageCategory = Administration;
    ApplicationArea = All;
    ProcessingOnly = true;

    // -------------------------------------------------------
    // DATASET - defines which records to process
    // -------------------------------------------------------
    dataset
    {
        dataitem(Member; "Member")
        {
            // Filters on the request page to select which member(s) to update
            RequestFilterFields = "Member ID";

            trigger OnPreDataItem()
            begin
                // Ensure at least one new value has been entered
                if (NewPostalCode = '') and (NewPhoneNumber = '') and (NewEmail = '') and (NewAddress = '') and
                   (NewCity = '') and (NewOccupation = '') and (not UpdateStatus)
                then
                    Error('Please enter at least one new value to update.');
            end;

            trigger OnAfterGetRecord()
            begin
                // Update only the fields where the user entered a new value
                if NewPostalCode <> '' then
                    Member."Postal Code" := NewPostalCode;

                if NewPhoneNumber <> '' then
                    Member."Phone Number" := NewPhoneNumber;

                if NewEmail <> '' then
                    Member."Email" := NewEmail;

                if NewAddress <> '' then
                    Member."Address" := NewAddress;

                if NewCity <> '' then
                    Member."City" := NewCity;

                if NewOccupation <> '' then
                    Member."Occupation" := NewOccupation;

                if UpdateStatus then
                    Member."Status" := NewStatus;

                Member.Modify(true);
                RecordsUpdated += 1;
            end;

            trigger OnPostDataItem()
            begin
                Message('Successful change of Member details. %1 record(s) updated.', RecordsUpdated);
            end;
        }
    }

    // -------------------------------------------------------
    // REQUEST PAGE - user enters the new values here
    // -------------------------------------------------------
    requestpage
    {
        layout
        {
            area(Content)
            {
                group(NewValues)
                {
                    Caption = 'New Member Details';

                    field(NewPhoneNumberField; NewPhoneNumber)
                    {
                        Caption = 'New Phone Number';
                        ApplicationArea = All;
                        ToolTip = 'Enter a new phone number. Leave blank to keep the current value.';
                    }
                    field(NewEmailField; NewEmail)
                    {
                        Caption = 'New Email';
                        ApplicationArea = All;
                        ToolTip = 'Enter a new email address. Leave blank to keep the current value.';
                    }
                    field(NewPostalCodeField; NewPostalCode)
                    {
                        Caption = 'New Postal Code';
                        ApplicationArea = All;
                        ToolTip = 'Enter a new postal code. Leave blank to keep the current value.';
                    }
                    field(NewAddressField; NewAddress)
                    {
                        Caption = 'New Address';
                        ApplicationArea = All;
                        ToolTip = 'Enter a new address. Leave blank to keep the current value.';
                    }
                    field(NewCityField; NewCity)
                    {
                        Caption = 'New City';
                        ApplicationArea = All;
                        ToolTip = 'Enter a new city. Leave blank to keep the current value.';
                    }
                    field(NewOccupationField; NewOccupation)
                    {
                        Caption = 'New Occupation';
                        ApplicationArea = All;
                        ToolTip = 'Enter a new occupation. Leave blank to keep the current value.';
                    }
                    field(UpdateStatusField; UpdateStatus)
                    {
                        Caption = 'Update Status';
                        ApplicationArea = All;
                        ToolTip = 'Enable this to update the member status to the value below.';
                    }
                    field(NewStatusField; NewStatus)
                    {
                        Caption = 'New Status';
                        ApplicationArea = All;
                        ToolTip = 'Select the new status. Only applied if "Update Status" is enabled.';
                    }
                }
            }
        }
    }

    // -------------------------------------------------------
    // VARIABLES
    // -------------------------------------------------------
    var
        NewPhoneNumber: Text[20];
        NewEmail: Text[100];
        NewAddress: Text[150];
        NewPostalCode: Text[20];
        NewCity: Text[50];
        NewOccupation: Text[100];
        NewStatus: Enum "Member Status";
        UpdateStatus: Boolean;
        RecordsUpdated: Integer;
}
