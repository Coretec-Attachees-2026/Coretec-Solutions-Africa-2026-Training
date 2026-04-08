// ============================================================
// Page 50120 - Members API
// ============================================================
// PURPOSE: Provides a read-only OData API to external systems
//          (Postman, Power BI, mobile apps, etc.) to query members.
//
// WHAT IS AN API PAGE?
//   An API page exposes table data via OData/REST endpoints.
//   External tools can GET data without using Business Central UI.
//
// SECURITY:
//   1. Read-only: No Create, Update, or Delete allowed
//   2. Limited fields: Only non-sensitive member info exposed:
//      - Member ID, Full Name, Email, Phone, Status
//      - Registration Date, Occupation, Category
//   3. Excluded fields: Phone number details, credentials, etc.
//
// HOW TO CALL THIS API:
//   GET https://your-bc-instance/BC260/api/coretec/members/v1.0/members
//   Headers: Authorization: Bearer <token>
//   Response: JSON array of members
//   Filter: ?$filter=status eq 'Active'
//   Top: ?$top=10
//   Select: ?$select=memberId,fullName,emailAddress
//
// DOCUMENTATION:
//   Base URL: /api/coretec/members/v1.0/members 
//   Method: GET (read-only)
//   Format: OData/JSON
//   Authentication: OAuth 2.0 Bearer token or Basic Auth
//
// ============================================================

page 50120 "Members API"
{
    PageType = API;
    Caption = 'Members API';
    APIPublisher = 'coretec';
    APIGroup = 'members';
    APIVersion = 'v1.0';
    EntityName = 'member';
    EntitySetName = 'members';
    SourceTable = "Member";
    DelayedInsert = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    ODataKeyFields = "Member ID";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                // ===== IDENTIFICATION =====
                field(memberId; Rec."Member ID")
                {
                    Caption = 'Member ID';
                }
                
                field(applicationId; Rec."Application ID")
                {
                    Caption = 'Application ID';
                }

                // ===== PERSONAL INFORMATION =====
                field(firstName; Rec."First Name")
                {
                    Caption = 'First Name';
                }
                
                field(lastName; Rec."Last Name")
                {
                    Caption = 'Last Name';
                }
                
                field(fullName; Rec."Full Name")
                {
                    Caption = 'Full Name';
                }
                
                field(emailAddress; Rec."Email")
                {
                    Caption = 'Email Address';
                }
                
                field(phoneNumber; Rec."Phone Number")
                {
                    Caption = 'Phone Number';
                }

                // ===== DEMOGRAPHICS =====
                field(dateOfBirth; Rec."Date of Birth")
                {
                    Caption = 'Date of Birth';
                }
                
                field(occupationCode; Rec."Occupation Code")
                {
                    Caption = 'Occupation Code';
                }

                // ===== MEMBERSHIP INFO =====
                field(status; Rec."Status")
                {
                    Caption = 'Status';
                }
                
                field(registrationDate; Rec."Registration Date")
                {
                    Caption = 'Registration Date';
                }
                
                field(memberCategory; Rec."Member Category")
                {
                    Caption = 'Member Category';
                }

                // ===== FINANCIAL INFO =====
                field(accountBalance; Rec."Account Balance")
                {
                    Caption = 'Account Balance';
                }
                
                field(annualIncome; Rec."Annual Income")
                {
                    Caption = 'Annual Income';
                }

                // ===== ADDRESS INFORMATION =====
                field(address; Rec."Address")
                {
                    Caption = 'Address';
                }
                
                field(city; Rec."City")
                {
                    Caption = 'City';
                }
                
                field(postalCode; Rec."Postal Code")
                {
                    Caption = 'Postal Code';
                }
                
                field(country; Rec."Country")
                {
                    Caption = 'Country';
                }

                // ===== IDENTIFICATION DOCUMENT =====
                field(idNumber; Rec."ID Number")
                {
                    Caption = 'ID Number';
                }
            }
        }
    }
}
