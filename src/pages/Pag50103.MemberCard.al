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
    }

    actions
    {
        area(Processing)
        {
            // ---- Suspend Member ----
            action(SuspendMember)
            {
                Caption = 'Suspend';
                ToolTip = 'Suspend this member. Suspended members cannot take new loans.';
                Image = Reject;
                Enabled = (Rec.Status = Enum::"Member Status"::Active);

                trigger OnAction()
                var
                    AuditLog: Record "Application Audit Log";
                begin
                    if not Confirm('Are you sure you want to suspend member %1 (%2)?',
                        false, Rec."Member ID", Rec."Full Name") then
                        exit;

                    Rec.Status := Enum::"Member Status"::Suspended;
                    Rec.Modify(true);

                    // Log audit trail for member suspension
                    AuditLog.Init();
                    AuditLog."Date-Time" := CurrentDateTime;
                    AuditLog."User ID" := CopyStr(UserId, 1, 50);
                    AuditLog."Action Type" := 'Suspended';
                    AuditLog."Document Type" := 'Member';
                    AuditLog."Document No." := Rec."Member ID";
                    AuditLog.Description := StrSubstNo('Member %1 (%2) suspended.', Rec."Member ID", Rec."Full Name");
                    AuditLog.Insert(true);

                    CurrPage.Update(false);
                    Message('Member %1 has been suspended.', Rec."Member ID");
                end;
            }

            // ---- Reactivate Member ----
            action(ReactivateMember)
            {
                Caption = 'Reactivate';
                ToolTip = 'Reactivate a suspended or inactive member.';
                Image = Approve;
                Enabled = (Rec.Status = Enum::"Member Status"::Suspended) or
                           (Rec.Status = Enum::"Member Status"::Inactive);

                trigger OnAction()
                var
                    AuditLog: Record "Application Audit Log";
                begin
                    if not Confirm('Are you sure you want to reactivate member %1 (%2)?',
                        false, Rec."Member ID", Rec."Full Name") then
                        exit;

                    Rec.Status := Enum::"Member Status"::Active;
                    Rec.Modify(true);

                    // Log audit trail for member reactivation
                    AuditLog.Init();
                    AuditLog."Date-Time" := CurrentDateTime;
                    AuditLog."User ID" := CopyStr(UserId, 1, 50);
                    AuditLog."Action Type" := 'Reactivated';
                    AuditLog."Document Type" := 'Member';
                    AuditLog."Document No." := Rec."Member ID";
                    AuditLog.Description := StrSubstNo('Member %1 (%2) reactivated.', Rec."Member ID", Rec."Full Name");
                    AuditLog.Insert(true);

                    CurrPage.Update(false);
                    Message('Member %1 has been reactivated.', Rec."Member ID");
                end;
            }

            // ---- Close Membership ----
            action(CloseMembership)
            {
                Caption = 'Close Membership';
                ToolTip = 'Permanently close this membership. This cannot be undone.';
                Image = Close;
                Enabled = (Rec.Status <> Enum::"Member Status"::Closed);

                trigger OnAction()
                var
                    AuditLog: Record "Application Audit Log";
                    LoanApp: Record "Loan Application";
                begin
                    // Check for outstanding loan balance
                    if Rec."Account Balance" < 0 then
                        Error('Cannot close membership while member has an outstanding loan balance of %1.', Rec."Account Balance");

                    // Check for any active loans (Disbursed or Partially Paid)
                    // A member might have a zero account balance but still have
                    // loans in progress that haven't been fully repaid.
                    LoanApp.SetRange("Member ID", Rec."Member ID");
                    LoanApp.SetFilter(Status, '%1|%2',
                        Enum::"Loan Application Status"::Disbursed,
                        Enum::"Loan Application Status"::"Partially Paid");
                    if LoanApp.FindFirst() then
                        Error('Cannot close membership — member has active loan %1 with status %2.',
                            LoanApp."Loan Application No.", LoanApp.Status);

                    if not Confirm('Are you sure you want to CLOSE membership for %1 (%2)?\\This action cannot be undone.',
                        false, Rec."Member ID", Rec."Full Name") then
                        exit;

                    Rec.Status := Enum::"Member Status"::Closed;
                    Rec.Modify(true);

                    // Log audit trail for membership closure
                    AuditLog.Init();
                    AuditLog."Date-Time" := CurrentDateTime;
                    AuditLog."User ID" := CopyStr(UserId, 1, 50);
                    AuditLog."Action Type" := 'Closed';
                    AuditLog."Document Type" := 'Member';
                    AuditLog."Document No." := Rec."Member ID";
                    AuditLog.Description := StrSubstNo('Membership closed for %1 (%2).', Rec."Member ID", Rec."Full Name");
                    AuditLog.Insert(true);

                    CurrPage.Update(false);
                    Message('Membership for %1 has been closed.', Rec."Member ID");
                end;
            }
        }

        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';
                actionref(SuspendMember_Promoted; SuspendMember) { }
                actionref(ReactivateMember_Promoted; ReactivateMember) { }
                actionref(CloseMembership_Promoted; CloseMembership) { }
            }
        }
    }
}
