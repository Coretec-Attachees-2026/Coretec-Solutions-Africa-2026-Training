page 50103 "Member Card"
{
    Caption = 'Member';
    PageType = Card;
    SourceTable = "Member";
    ApplicationArea = All;
    Editable = false;

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
        area(FactBoxes)
        {
            part(LoanInfo; "Member Loans Part")
            {
                Caption = 'Loan Details';
                ApplicationArea = all;
                SubPageLink = "Member ID" = field("Member ID"); // loan == member
            }
            part(LoanStats; "Member Loans Statistics") {
                Caption = 'Dues';
                ApplicationArea = all;
                SubPageLink = "Member ID" = field("Member ID");
            }
        }
    }
}

page 50138 "Member Loans Part"
{
    Caption = 'Member Loans';
    PageType = CardPart;
    SourceTable = "Loan Application";

    layout
    {
        area(Content)
        {
            repeater(Control1)
            {
                field("Loan Application No."; Rec."Loan Application No.")
                {
                    ApplicationArea = All;
                }
                field("application Date"; Rec."Application Date")
                {
                    ApplicationArea = All;
                }
            }

        }

    }

}

page 50139 "Member Loans Statistics"
{
    Caption = 'Integer Statistics';
    PageType = CardPart;
    SourceTable = "Loan Application";

    layout
    {
        area(Content)
        {
            cuegroup("Loan Stats")
            {
                field("LoanAmt"; Rec."Loan Amount")
                {
                    ApplicationArea = All;
                }
                field(ApprovalStatus; Rec.Status)
                {
                    ApplicationArea = All;
                }
            }

        }
    }
    var
    trigger OnAfterGetRecord()
    var
        DaysRemaining: Integer;
    begin
        // Get days remaining till due date
    end;
}