// ============================================================
// Page 50103 - Member Card
// ============================================================
// PURPOSE: Shows the FULL DETAILS of ONE member.
//          This is a READ-ONLY view — member data was copied
//          from the approved application and can't be changed here.
//
// HOW MEMBERS GET CREATED:
//   1. Someone fills out a Member Application (Pag50101)
//   2. An admin clicks "Approve" on the application
//   3. The system copies all data into a Member record
//   4. That member appears here — fully read-only
//
// KEY CONCEPT - "Editable = false" on the whole page:
//   This makes EVERY field on the page read-only.
//   Unlike the Application Card (where only some fields are
//   read-only), the entire Member Card prevents editing.
//   This is because member data should only change through
//   proper business processes, not manual edits.
//
// SECTIONS:
//   1. General Information — ID, name, status, registration date
//   2. Personal Information — name, DOB, ID number
//   3. Contact Information — phone, email, address
//   4. Employment Information — job, income, category
//   5. Account Information — current balance
// ============================================================

page 50103 "Member Card"
{
    Caption = 'Member';                    // Title shown at the top
    PageType = Card;                       // Shows ONE member in detail
    SourceTable = "Member";                // Data comes from the Member table
    ApplicationArea = All;
    Editable = false;                      // Entire page is read-only

    layout
    {
        area(Content)
        {
            // --- Section 1: General Information ---
            // Quick overview of the member
            group("General Information")
            {
                field("Member ID"; rec."Member ID")
                {
                    ToolTip = 'Specifies the unique member identifier';
                }
                field("Full Name"; rec."Full Name")
                {
                    ToolTip = 'Specifies the member''s full name';
                }
                field("Status"; rec."Status")
                {
                    ToolTip = 'Specifies the member''s current status';
                }
                field("Registration Date"; rec."Registration Date")
                {
                    ToolTip = 'Specifies when the member was registered';
                }
                // Links back to the original application for audit trail
                field("Application ID"; rec."Application ID")
                {
                    ToolTip = 'Specifies the original application ID';
                }
            }

            // --- Section 2: Personal Information ---
            // Copied from the approved application
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
                    ToolTip = 'Specifies the member''s ID or passport number';
                }
            }

            // --- Section 3: Contact Information ---
            group("Contact Information")
            {
                field("Phone Number"; rec."Phone Number")
                {
                    ToolTip = 'Specifies the member''s phone number';
                }
                field("Email"; rec."Email")
                {
                    ToolTip = 'Specifies the member''s email address';
                }
                field("Address"; rec."Address")
                {
                    ToolTip = 'Specifies the member''s street address';
                }
                field("City"; rec."City")
                {
                    ToolTip = 'Specifies the member''s city';
                }
                field("Postal Code"; rec."Postal Code")
                {
                    ToolTip = 'Specifies the member''s postal code';
                }
                field("Country"; rec."Country")
                {
                    ToolTip = 'Specifies the member''s country';
                }
            }

            // --- Section 4: Employment Information ---
            group("Employment Information")
            {
                field("Occupation Code"; rec."Occupation Code")
                {
                    ToolTip = 'Specifies the member''s occupation (linked to occupation master)';
                }
                field("Annual Income"; rec."Annual Income")
                {
                    ToolTip = 'Specifies the member''s annual income';
                }
                field("Member Category"; rec."Member Category")
                {
                    ToolTip = 'Specifies the member category';
                }
            }

            // --- Section 5: Account Information ---
            // Shows the member's current financial balance
            group("Account Information")
            {
                field("Account Balance"; rec."Account Balance")
                {
                    ToolTip = 'Specifies the member''s current account balance';
                }
            }
        }

        // --- FactBoxes Area ---
        // Shows related information and details panels on the right side
        area(FactBoxes)
        {
            // Member Loans FactBox
            // Lists all loans for the current member, filtered by Member ID
            part(MemberLoansPart; "Member Loans Part")
            {
                Caption = 'Member Loans';
                SubPageLink = "Member ID" = field("Member ID");
            }
        }
    }
}
