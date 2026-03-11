// ============================================================
// Page 50110 - Member Edit Card
// ============================================================
// PURPOSE: Shows the FULL DETAILS of ONE member with the ability
//          to edit all member information. This is the editable
//          version of the Member Card (Pag50103).
//
// KEY CONCEPT - "Editable = true":
//   This page allows users to modify member details directly.
//   All fields are editable unless specifically marked as read-only.
//
// USE CASES:
//   1. Update contact information (phone, email, address)
//   2. Change member category
//   3. Update employment details
//   4. Maintain member records over time
//
// SECTIONS:
//   1. General Information — ID, name, status, registration date (ID is read-only)
//   2. Personal Information — name, DOB, ID number
//   3. Contact Information — phone, email, address, city
//   4. Employment Information — job title, income, category
//   5. Account Information — balance (read-only)
// ============================================================

page 50110 "Member Edit Card"
{
    Caption = 'Edit Member';               // Title shown at the top
    PageType = Card;                       // Shows ONE member in detail
    SourceTable = "Member";                // Data comes from the Member table
    ApplicationArea = All;
    Editable = true;                       // Page is editable
    UsageCategory = Documents;

    layout
    {
        area(Content)
        {
            // --- Section 1: General Information ---
            // Overview of the member (ID and key fields)
            group("General Information")
            {
                field("Member ID"; rec."Member ID")
                {
                    ToolTip = 'Specifies the unique member identifier';
                    Editable = false;      // Member ID cannot be changed
                }
                field("Full Name"; rec."Full Name")
                {
                    ToolTip = 'Specifies the member''s full name';
                }
                field("Status"; rec."Status")
                {
                    ToolTip = 'Specifies the member''s current status (Active/Closed)';
                }
                field("Registration Date"; rec."Registration Date")
                {
                    ToolTip = 'Specifies when the member was registered';
                    Editable = false;      // Registration date is auto-set
                }
                field("Application ID"; rec."Application ID")
                {
                    ToolTip = 'Specifies the original application ID for audit trail';
                    Editable = false;      // Link to original application
                }
            }

            // --- Section 2: Personal Information ---
            // Member demographics
            group("Personal Information")
            {
                field("First Name"; rec."First Name")
                {
                    ToolTip = 'Specifies the member''s first name';
                }
                field("Last Name"; rec."Last Name")
                {
                    ToolTip = 'Specifies the member''s last name';
                }
                field("Date of Birth"; rec."Date of Birth")
                {
                    ToolTip = 'Specifies the member''s date of birth';
                }
                field("ID Number"; rec."ID Number")
                {
                    ToolTip = 'Specifies the member''s national ID or passport number';
                }
            }

            // --- Section 3: Contact Information ---
            // How to reach the member
            group("Contact Information")
            {
                field("Phone Number"; rec."Phone Number")
                {
                    ToolTip = 'Specifies the member''s primary phone number';
                }
                field("Email"; rec."Email")
                {
                    ToolTip = 'Specifies the member''s email address';
                }
                field("City"; rec."City")
                {
                    ToolTip = 'Specifies the city where the member resides';
                }
                field("Address"; rec."Address")
                {
                    ToolTip = 'Specifies the member''s street address';
                    MultiLine = true;     // Allow multiple lines for longer addresses
                }
            }

            // --- Section 4: Employment Information ---
            // Member's job and income details
            group("Employment Information")
            {
                field("Occupation"; rec."Occupation")
                {
                    ToolTip = 'Specifies the member''s occupation';
                }
                field("Annual Income"; rec."Annual Income")
                {
                    ToolTip = 'Specifies the member''s annual income';
                }
                field("Member Category"; rec."Member Category")
                {
                    ToolTip = 'Specifies the category/classification of the member';
                }
            }

            // --- Section 5: Account Information ---
            // Member's account balance (read-only, managed by system)
            group("Account Information")
            {
                field("Account Balance"; rec."Account Balance")
                {
                    ToolTip = 'Specifies the member''s current account balance';
                    Editable = false;      // Balance is managed by loan/payment system
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Save and Close")
            {
                Caption = 'Save and Close';
                ToolTip = 'Save changes and close this page';
                Image = Close;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    CurrPage.SaveRecord();
                    CurrPage.Close();
                end;
            }

            action("Save")
            {
                Caption = 'Save';
                ToolTip = 'Save changes to this member record';
                Image = Save;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    CurrPage.SaveRecord();
                    Message('Member %1 has been updated successfully.', rec."Member ID");
                end;
            }
        }
    }
}
