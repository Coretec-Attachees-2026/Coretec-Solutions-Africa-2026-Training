// ============================================================
// Page 50117 - Members API
// ============================================================
// PURPOSE: Read-only OData API for exposing Member data to 
//          external tools (Postman, Power BI, third-party apps).
//
// FIELD EXPOSURE STRATEGY:
// ✓ SAFE (exposed):    Member ID, Full Name, Email, Phone, Status, 
//                      Registration Date, Member Category
// ✗ SENSITIVE (hidden): Annual Income, Account Balance, Date of Birth, 
//                      ID Number, First/Last Names separately
//
// This is a read-only API (no modifications allowed).
// ============================================================

page 50117 "Members API"
{
    PageType = API;
    APIPublisher = 'coretec';
    APIGroup = 'members';
    APIVersion = 'v1.0';
    EntityName = 'member';
    EntitySetName = 'members';
    SourceTable = "Member";
    DelayedInsert = true;
    InsertAllowed = false;      // Read-only
    ModifyAllowed = false;      // Read-only
    DeleteAllowed = false;      // Read-only
    Permissions = tabledata "Member" = R;  // Read permission only

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(memberId; Rec."Member ID")
                {
                    Caption = 'Member ID';
                    Editable = false;
                }
                field(fullName; Rec."Full Name")
                {
                    Caption = 'Full Name';
                    Editable = false;
                }
                field(email; Rec.Email)
                {
                    Caption = 'Email';
                    Editable = false;
                }
                field(phoneNumber; Rec."Phone Number")
                {
                    Caption = 'Phone Number';
                    Editable = false;
                }
                field(status; Rec.Status)
                {
                    Caption = 'Member Status';
                    Editable = false;
                }
                field(registrationDate; Rec."Registration Date")
                {
                    Caption = 'Registration Date';
                    Editable = false;
                }
                field(memberCategory; Rec."Member Category")
                {
                    Caption = 'Member Category';
                    Editable = false;
                }
                field(occupationCode; Rec."Occupation Code")
                {
                    Caption = 'Occupation';
                    Editable = false;
                }
            }
        }
    }

    // ==============================================
    // API Filtering & Performance
    // ==============================================
    // The following fields are available for OData filtering:
    // - $filter=status eq 'Active'
    // - $filter=registrationDate gt 2026-01-01
    // - $filter=memberCategory eq 'REGULAR'
    //
    // Example OData Query:
    // GET /api/coretec/members/v1.0/members?$filter=status eq 'Active'&$top=10
    // ==============================================
}
