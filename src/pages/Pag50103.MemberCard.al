// ============================================================
// Page 50103 - Member Card
// ============================================================
// PURPOSE: Full detail view of ONE member.
//
// CHANGE LOG:
//   Task D – FactBox: "Member Loans Part" (Pag50116) added in
//            area(FactBoxes), filtered by current Member ID.
//            Shows all loans for the member on the right panel.
//
//   Task E – Employment group now shows "Occupation Code" (lookup
//            dropdown from the Occupation master table) instead
//            of the free-text "Occupation" field.
//
// NOTE: The page is still Editable = false overall.
//       Occupation Code + Status changes happen through the
//       dedicated Member Detail Update report or through the
//       Suspend / Reactivate / Close actions.
// ============================================================

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
            group("General Information")
            {
                field("Member ID"; rec."Member ID")
                {
                    ToolTip = 'Specifies the unique member identifier.';
                }
                field("Full Name"; rec."Full Name")
                {
                    ToolTip = 'Specifies the member''s full name.';
                }
                field("Status"; rec."Status")
                {
                    ToolTip = 'Specifies the member''s current status.';
                }
                field("Registration Date"; rec."Registration Date")
                {
                    ToolTip = 'Specifies when the member was registered.';
                }
                field("Application ID"; rec."Application ID")
                {
                    ToolTip = 'Specifies the original application that created this member.';
                }
            }

            // --- Section 2: Personal Information ---
            group("Personal Information")
            {
                field("First Name"; rec."First Name")
                {
                    ToolTip = 'Specifies the member''s first name.';
                }
                field("Last Name"; rec."Last Name")
                {
                    ToolTip = 'Specifies the member''s last name.';
                }
                field("Date of Birth"; rec."Date of Birth")
                {
                    ToolTip = 'Specifies the member''s date of birth.';
                }
                field("ID Number"; rec."ID Number")
                {
                    ToolTip = 'Specifies the member''s national ID or passport number.';
                }
            }

            // --- Section 3: Contact Information ---
            group("Contact Information")
            {
                field("Phone Number"; rec."Phone Number")
                {
                    ToolTip = 'Specifies the member''s phone number.';
                }
                field("Email"; rec."Email")
                {
                    ToolTip = 'Specifies the member''s email address.';
                }
                field("Address"; rec."Address")
                {
                    ToolTip = 'Specifies the member''s street address.';
                }
                field("City"; rec."City")
                {
                    ToolTip = 'Specifies the member''s city.';
                }
                field("Postal Code"; rec."Postal Code")
                {
                    ToolTip = 'Specifies the member''s postal code.';
                }
                field("Country"; rec."Country")
                {
                    ToolTip = 'Specifies the member''s country.';
                }
            }

            // --- Section 4: Employment Information ---
            group("Employment Information")
            {
                // Task E: show validated Occupation Code (dropdown) instead
                // of the free-text Occupation field.
                field("Occupation Code"; rec."Occupation Code")
                {
                    ToolTip = 'Specifies the member''s occupation from the Occupation master list.';
                }
                field("Annual Income"; rec."Annual Income")
                {
                    ToolTip = 'Specifies the member''s annual income.';
                }
                field("Member Category"; rec."Member Category")
                {
                    ToolTip = 'Specifies the member category (e.g. REGULAR, STUDENT).';
                }
            }

            // --- Section 5: Account Information ---
            group("Account Information")
            {
                field("Account Balance"; rec."Account Balance")
                {
                    ToolTip = 'Specifies the member''s current account balance.';
                }
            }
        }

        // -------------------------------------------------------
        // Task D: FactBox – Member Loans Part
        // -------------------------------------------------------
        // SubPageLink filters the ListPart to show ONLY loans
        // belonging to the member currently open on this Card.
        // KEY CONCEPT - "part()":
        //   Embeds another page (Pag50116) in the FactBox area.
        //   SubPageLink = "Member ID" = field("Member ID") is the
        //   equivalent of "WHERE Loan Application."Member ID" =
        //   Member."Member ID"" — it keeps the sub-page in sync.
        // -------------------------------------------------------
        area(FactBoxes)
        {
            part(MemberLoansPart; "Member Loans Part")
            {
                ApplicationArea = All;
                Caption = 'Loans';
                SubPageLink = "Member ID" = field("Member ID");
            }
        }
    }

    // -------------------------------------------------------
    // ACTIONS
    // -------------------------------------------------------
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

                    AuditLog.Init();
                    AuditLog."Date-Time"     := CurrentDateTime;
                    AuditLog."User ID"       := CopyStr(UserId, 1, 50);
                    AuditLog."Action Type"   := 'Suspended';
                    AuditLog."Document Type" := 'Member';
                    AuditLog."Document No."  := Rec."Member ID";
                    AuditLog.Description     :=
                        StrSubstNo('Member %1 (%2) suspended.', Rec."Member ID", Rec."Full Name");
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

                    AuditLog.Init();
                    AuditLog."Date-Time"     := CurrentDateTime;
                    AuditLog."User ID"       := CopyStr(UserId, 1, 50);
                    AuditLog."Action Type"   := 'Reactivated';
                    AuditLog."Document Type" := 'Member';
                    AuditLog."Document No."  := Rec."Member ID";
                    AuditLog.Description     :=
                        StrSubstNo('Member %1 (%2) reactivated.', Rec."Member ID", Rec."Full Name");
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
                    if Rec."Account Balance" < 0 then
                        Error('Cannot close membership while member has an outstanding loan balance of %1.',
                            Rec."Account Balance");

                    LoanApp.SetRange("Member ID", Rec."Member ID");
                    LoanApp.SetFilter(Status, '%1|%2',
                        Enum::"Loan Application Status"::Disbursed,
                        Enum::"Loan Application Status"::"Partially Paid");
                    if LoanApp.FindFirst() then
                        Error('Cannot close membership — member has active loan %1 with status %2.',
                            LoanApp."Loan Application No.", LoanApp.Status);

                    if not Confirm(
                        'Are you sure you want to CLOSE membership for %1 (%2)?\This cannot be undone.',
                        false, Rec."Member ID", Rec."Full Name") then
                        exit;

                    Rec.Status := Enum::"Member Status"::Closed;
                    Rec.Modify(true);

                    AuditLog.Init();
                    AuditLog."Date-Time"     := CurrentDateTime;
                    AuditLog."User ID"       := CopyStr(UserId, 1, 50);
                    AuditLog."Action Type"   := 'Closed';
                    AuditLog."Document Type" := 'Member';
                    AuditLog."Document No."  := Rec."Member ID";
                    AuditLog.Description     :=
                        StrSubstNo('Membership closed for %1 (%2).', Rec."Member ID", Rec."Full Name");
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
