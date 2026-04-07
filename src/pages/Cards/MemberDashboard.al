page 50116 "Member Dashboard"
// flowfields are better for performace
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'Member Dashboard';


    layout
    {
        area(Content)
        {
            cuegroup(Data)
            {

                CuegroupLayout = Wide;

                
                field(TotalAssets; ActiveMembersCount)
                {
                    Caption = 'Total Active Members';
                    DrillDownPageId="Member List";
                    ColumnSpan = 2;

                }
                field(PendingApplicationsCount; PendingApplicationsCount)
                {
                    RowSpan = 2;
                    Caption = 'Total Pending Applications';
                    DrillDownPageId="Member Application List";
                }
                field(TotalAccountBalance; TotalAccountBalance)
                {
                    Caption = 'Total Account Balance';
                    DrillDownPageId="Member List";

                }
                field(TotalMembersCount; TotalMembersCount)
                {
                    Caption = 'Total Members';
                    DrillDownPageId="Member List";

                }
            }
            cuegroup(MemberActions) {

                // CuegroupLayout = Wide;
                Caption = 'Action on Members';
                actions {
                    action(AddMember) {
                        Caption= 'Add a Member';
                        Image = TileNew;
                        RunObject = page "Member Application Card";
                        RunPageMode = Create; // runs the page to create a new application
                    }
                    action(ApproveMembers) {
                        Caption = 'Approve members';
                        Image = TilePeople;
                        RunObject = page "Member Application List";
                    }
                    action(Members) {
                        Caption = 'View Members';
                        Image = TileBrickCustomer;
                        RunObject = page "Member List";
                    }

                }

            }

        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {

                trigger OnAction()
                begin

                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        MemberAccBal: Record Member;
        PendingApplications: Record "Member Application";
        ActiveMembers: Record Member;
        TotalMembers: Record Member;
    begin
        if MemberAccBal.FindSet() then begin
            MemberAccBal.CalcSums("Account Balance");
            TotalAccountBalance := MemberAccBal."Account Balance";
        end;
        PendingApplications.SetFilter(Status, '=%1', "Member Application Status"::Pending);
        if PendingApplications.FindSet() then begin
            PendingApplicationsCount := PendingApplications.Count();
        end;

        ActiveMembers.SetFilter(Status, '=%1', "Member Status"::Active);
        if ActiveMembers.FindSet() then begin
            ActiveMembersCount := ActiveMembers.Count();
        end;
        
        TotalMembersCount := PendingApplicationsCount + ActiveMembersCount;
    end;

    var
        TotalMembersCount: Integer; // correct
        ActiveMembersCount: Integer;
        TotalAccountBalance: Integer;
        PendingApplicationsCount: Integer; // correct
}