// ============================================================
// FILE: SACCORoleCenter.al
// CONTAINS: All 4 objects in one file
//   1. table 50120 "SACCO Cue"
//   2. page 50124 "SACCO Cue CardPart"
//   3. page 50123 "SACCO Role Center"
//   4. profile "SACCO_OFFICER"
// ============================================================


// ============================================================
// OBJECT 1 - TABLE 50120: SACCO Cue
// ============================================================
table 50120 "SACCO Cue"
{
    Caption = 'SACCO Cue';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }

        // --- Member Application Cues ---
        field(10; "Pending Member Applications"; Integer)
        {
            Caption = 'Pending Member Applications';
            FieldClass = FlowField;
            CalcFormula = count("Member Application" where(Status = const(Pending)));
            Editable = false;
        }

        field(11; "Approved Member Applications"; Integer)
        {
            Caption = 'Approved Member Applications';
            FieldClass = FlowField;
            CalcFormula = count("Member Application" where(Status = const(Approved)));
            Editable = false;
        }

        field(12; "Rejected Member Applications"; Integer)
        {
            Caption = 'Rejected Member Applications';
            FieldClass = FlowField;
            CalcFormula = count("Member Application" where(Status = const(Rejected)));
            Editable = false;
        }

        // --- Member Status Cues ---
        field(20; "Active Members"; Integer)
        {
            Caption = 'Active Members';
            FieldClass = FlowField;
            CalcFormula = count(Member where(Status = const(Active)));
            Editable = false;
        }

        field(21; "Inactive Members"; Integer)
        {
            Caption = 'Inactive Members';
            FieldClass = FlowField;
            CalcFormula = count(Member where(Status = const(Inactive)));
            Editable = false;
        }

        field(22; "Suspended Members"; Integer)
        {
            Caption = 'Suspended Members';
            FieldClass = FlowField;
            CalcFormula = count(Member where(Status = const(Suspended)));
            Editable = false;
        }

        field(23; "Total Members"; Integer)
        {
            Caption = 'Total Members';
            FieldClass = FlowField;
            CalcFormula = count(Member);
            Editable = false;
        }

        // --- Loan Application Cues ---
        field(30; "Pending Loan Applications"; Integer)
        {
            Caption = 'Pending Loan Applications';
            FieldClass = FlowField;
            CalcFormula = count("Loan Application" where(Status = const("Pending Approval")));
            Editable = false;
        }

        field(31; "Approved Loan Applications"; Integer)
        {
            Caption = 'Approved Loan Applications';
            FieldClass = FlowField;
            CalcFormula = count("Loan Application" where(Status = const(Approved)));
            Editable = false;
        }

        field(32; "Disbursed Loans"; Integer)
        {
            Caption = 'Disbursed Loans';
            FieldClass = FlowField;
            CalcFormula = count("Loan Application" where(Status = const(Disbursed)));
            Editable = false;
        }

        field(33; "Rejected Loan Applications"; Integer)
        {
            Caption = 'Rejected Loan Applications';
            FieldClass = FlowField;
            CalcFormula = count("Loan Application" where(Status = const(Rejected)));
            Editable = false;
        }

        // --- Financial Cues ---
        field(40; "Total Account Balance"; Decimal)
        {
            Caption = 'Total Account Balance';
            FieldClass = FlowField;
            CalcFormula = sum(Member."Account Balance");
            Editable = false;
        }

        field(41; "Total Loans Outstanding"; Decimal)
        {
            Caption = 'Total Loans Outstanding';
            FieldClass = FlowField;
            CalcFormula = sum("Loan Application"."Loan Amount" where(Status = const(Disbursed)));
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Primary Key") { Clustered = true; }
    }
}


// ============================================================
// OBJECT 2 - PAGE 50124: SACCO Cue CardPart
// ============================================================
page 50124 "SACCO Cue CardPart"
{
    Caption = 'SACCO Activities';
    PageType = CardPart;
    SourceTable = "SACCO Cue";
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            // --- Member Applications Tiles ---
            cuegroup("Member Applications")
            {
                Caption = 'Member Applications';

                field("Pending Member Applications"; Rec."Pending Member Applications")
                {
                    Caption = 'Pending Applications';
                    ToolTip = 'Number of member applications awaiting approval';
                    StyleExpr = PendingAppStyle;
                    ApplicationArea = All;

                    trigger OnDrillDown()
                    var
                        MemberApp: Record "Member Application";
                    begin
                        MemberApp.SetRange(Status, MemberApp.Status::Pending);
                        Page.Run(Page::"Member Application List", MemberApp);
                    end;
                }

                field("Approved Member Applications"; Rec."Approved Member Applications")
                {
                    Caption = 'Approved Applications';
                    ToolTip = 'Number of approved member applications';
                    StyleExpr = 'Favorable';
                    ApplicationArea = All;

                    trigger OnDrillDown()
                    var
                        MemberApp: Record "Member Application";
                    begin
                        MemberApp.SetRange(Status, MemberApp.Status::Approved);
                        Page.Run(Page::"Member Application List", MemberApp);
                    end;
                }

                field("Rejected Member Applications"; Rec."Rejected Member Applications")
                {
                    Caption = 'Rejected Applications';
                    ToolTip = 'Number of rejected member applications';
                    StyleExpr = 'Unfavorable';
                    ApplicationArea = All;

                    trigger OnDrillDown()
                    var
                        MemberApp: Record "Member Application";
                    begin
                        MemberApp.SetRange(Status, MemberApp.Status::Rejected);
                        Page.Run(Page::"Member Application List", MemberApp);
                    end;
                }
            }

            // --- Member Overview Tiles ---
            cuegroup("Member Overview")
            {
                Caption = 'Member Overview';

                field("Active Members"; Rec."Active Members")
                {
                    Caption = 'Active Members';
                    ToolTip = 'Total number of active members';
                    StyleExpr = 'Favorable';
                    ApplicationArea = All;

                    trigger OnDrillDown()
                    var
                        Member: Record Member;
                    begin
                        Member.SetRange(Status, Member.Status::Active);
                        Page.Run(Page::"Member List", Member);
                    end;
                }

                field("Inactive Members"; Rec."Inactive Members")
                {
                    Caption = 'Inactive Members';
                    ToolTip = 'Total number of inactive members';
                    StyleExpr = 'Attention';
                    ApplicationArea = All;

                    trigger OnDrillDown()
                    var
                        Member: Record Member;
                    begin
                        Member.SetRange(Status, Member.Status::Inactive);
                        Page.Run(Page::"Member List", Member);
                    end;
                }

                field("Suspended Members"; Rec."Suspended Members")
                {
                    Caption = 'Suspended Members';
                    ToolTip = 'Total number of suspended members';
                    StyleExpr = 'Unfavorable';
                    ApplicationArea = All;

                    trigger OnDrillDown()
                    var
                        Member: Record Member;
                    begin
                        Member.SetRange(Status, Member.Status::Suspended);
                        Page.Run(Page::"Member List", Member);
                    end;
                }

                field("Total Members"; Rec."Total Members")
                {
                    Caption = 'Total Members';
                    ToolTip = 'Total number of members in the system';
                    StyleExpr = 'Strong';
                    ApplicationArea = All;

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"Member List");
                    end;
                }
            }

            // --- Loan Application Tiles ---
            cuegroup("Loan Applications")
            {
                Caption = 'Loan Applications';

                field("Pending Loan Applications"; Rec."Pending Loan Applications")
                {
                    Caption = 'Pending Approval';
                    ToolTip = 'Number of loan applications awaiting approval';
                    StyleExpr = PendingLoanStyle;
                    ApplicationArea = All;

                    trigger OnDrillDown()
                    var
                        LoanApp: Record "Loan Application";
                    begin
                        LoanApp.SetRange(Status, LoanApp.Status::"Pending Approval");
                        Page.Run(Page::"Loan Application List", LoanApp);
                    end;
                }

                field("Approved Loan Applications"; Rec."Approved Loan Applications")
                {
                    Caption = 'Approved Loans';
                    ToolTip = 'Number of approved loan applications';
                    StyleExpr = 'Favorable';
                    ApplicationArea = All;

                    trigger OnDrillDown()
                    var
                        LoanApp: Record "Loan Application";
                    begin
                        LoanApp.SetRange(Status, LoanApp.Status::Approved);
                        Page.Run(Page::"Loan Application List", LoanApp);
                    end;
                }

                field("Disbursed Loans"; Rec."Disbursed Loans")
                {
                    Caption = 'Disbursed Loans';
                    ToolTip = 'Number of loans that have been disbursed';
                    StyleExpr = 'Favorable';
                    ApplicationArea = All;

                    trigger OnDrillDown()
                    var
                        LoanApp: Record "Loan Application";
                    begin
                        LoanApp.SetRange(Status, LoanApp.Status::Disbursed);
                        Page.Run(Page::"Loan Application List", LoanApp);
                    end;
                }

                field("Rejected Loan Applications"; Rec."Rejected Loan Applications")
                {
                    Caption = 'Rejected Loans';
                    ToolTip = 'Number of rejected loan applications';
                    StyleExpr = 'Unfavorable';
                    ApplicationArea = All;

                    trigger OnDrillDown()
                    var
                        LoanApp: Record "Loan Application";
                    begin
                        LoanApp.SetRange(Status, LoanApp.Status::Rejected);
                        Page.Run(Page::"Loan Application List", LoanApp);
                    end;
                }
            }

            // --- Financial Summary Tiles ---
            cuegroup("Financial Summary")
            {
                Caption = 'Financial Summary';

                field("Total Account Balance"; Rec."Total Account Balance")
                {
                    Caption = 'Total Member Balance';
                    ToolTip = 'Sum of all member savings/account balances';
                    StyleExpr = 'Strong';
                    ApplicationArea = All;
                }

                field("Total Loans Outstanding"; Rec."Total Loans Outstanding")
                {
                    Caption = 'Loans Outstanding';
                    ToolTip = 'Sum of all outstanding disbursed loan amounts';
                    StyleExpr = 'Attention';
                    ApplicationArea = All;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        // Create the singleton record if it doesn't exist yet
        if not Rec.Get('') then begin
            Rec.Init();
            Rec."Primary Key" := '';
            Rec.Insert();
        end;

        // Trigger all FlowField calculations
        Rec.CalcFields(
            "Pending Member Applications",
            "Approved Member Applications",
            "Rejected Member Applications",
            "Active Members",
            "Inactive Members",
            "Suspended Members",
            "Total Members",
            "Pending Loan Applications",
            "Approved Loan Applications",
            "Disbursed Loans",
            "Rejected Loan Applications",
            "Total Account Balance",
            "Total Loans Outstanding"
        );

        // Apply conditional color styling
        SetStyleExpressions();
    end;

    local procedure SetStyleExpressions()
    begin
        if Rec."Pending Member Applications" > 5 then
            PendingAppStyle := 'Unfavorable'
        else
            PendingAppStyle := 'Ambiguous';

        if Rec."Pending Loan Applications" > 3 then
            PendingLoanStyle := 'Unfavorable'
        else
            PendingLoanStyle := 'Ambiguous';
    end;

    var
        PendingAppStyle: Text;
        PendingLoanStyle: Text;
}


// ============================================================
// OBJECT 3 - PAGE 50123: SACCO Role Center
// ============================================================
page 50123 "SACCO Role Center"
{
    Caption = 'SACCO Role Center';
    PageType = RoleCenter;
    ApplicationArea = All;

    layout
    {
        area(RoleCenter)
        {
            // Embed the CardPart — this is where the tiles appear
            part(SACCOCuePart; "SACCO Cue CardPart")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(Sections)
        {
            group(MembersGroup)
            {
                Caption = 'Members';

                action(MemberApplicationList)
                {
                    Caption = 'Member Applications';
                    RunObject = page "Member Application List";
                    ApplicationArea = All;
                    ToolTip = 'View and manage member applications';
                }

                action(MemberList)
                {
                    Caption = 'Members';
                    RunObject = page "Member List";
                    ApplicationArea = All;
                    ToolTip = 'View and manage all members';
                }
            }

            group(LoansGroup)
            {
                Caption = 'Loans';
                Image = Bank;

                action(LoanApplicationList)
                {
                    Caption = 'Loan Applications';
                    RunObject = page "Loan Application List";
                    ApplicationArea = All;
                    ToolTip = 'View and manage loan applications';
                }

                action(LoanLedgerEntries)
                {
                    Caption = 'Loan Ledger';
                    RunObject = page "Loan Ledger Entries";
                    ApplicationArea = All;
                    ToolTip = 'View loan ledger entries';
                }
            }
        }

        area(Embedding)
        {
            action(QuickMembers)
            {
                Caption = 'Members';
                RunObject = page "Member List";
                ApplicationArea = All;
            }

            action(QuickLoanApps)
            {
                Caption = 'Loan Applications';
                RunObject = page "Loan Application List";
                ApplicationArea = All;
            }

            action(QuickMemberApps)
            {
                Caption = 'Member Applications';
                RunObject = page "Member Application List";
                ApplicationArea = All;
            }
        }
    }
}


// ============================================================
// OBJECT 4 - PROFILE: SACCO Officer
// ============================================================
profile "SACCO_OFFICER"
{
    Caption = 'SACCO Officer';
    RoleCenter = "SACCO Role Center";
    Enabled = true;
    promoted = true;
}
