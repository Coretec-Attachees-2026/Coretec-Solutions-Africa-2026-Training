page 50130 RejectionEmailSetupPage
{
    Caption = 'Rejection E-mail setup page';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Tasks;
    SourceTable = RejectionEmailSetupTable;
    InsertAllowed = false;
    DeleteAllowed = false;
    
    layout
    {
        area(Content)
        {
            group("Email format editor")
            {
                field("Email format"; EmailBodyVar)
                {
                    ExtendedDatatype = RichContent;
                    MultiLine = true;
                    
                    trigger OnValidate()
                    begin
                        Rec.SaveRichText(EmailBodyVar);
                    end;
                    
                }
            }
        }
    }
    
    actions
    {
        area(Processing)
        {
            action(Showmehow)
            {
                Image = AboutNav;
                Caption = 'Sample format';
                trigger OnAction()
                begin
                    Message('This is a sample email format to member with member ID {Member ID} and first Name {First Name} ');
                end;
            }
            action(AvailableFields) {
                Image = CreateForm;
                Caption = 'Available Fields';

                trigger OnAction()
                var
                begin
                    Message('Proceeds not to code available fields')
                end;

            }
            action(ApplicationID)
            {
                Caption = 'Application ID';
                ApplicationArea = All;
                Image = Link;
                trigger OnAction()
                var
                    Original: Text;
                begin
                    Original := Rec.GetRichText();
                    Original += '{Application ID}';
                    Rec.SaveRichText(Original);
                    CurrPage.Update();
                end;
            }
            action(FirstName)
            {
                Caption = 'First Name';
                ApplicationArea = All;
                Image = User;
                trigger OnAction()
                var
                    Original: Text;
                begin
                    Original := Rec.GetRichText();
                    Original += '{First Name}';
                    Rec.SaveRichText(Original);
                    CurrPage.Update();
                end;
            }
            action(LastName)
            {
                Caption = 'Last Name';
                ApplicationArea = All;
                Image = User;
                trigger OnAction()
                var
                    Original: Text;
                begin
                    Original := Rec.GetRichText();
                    Original += '{Last Name}';
                    Rec.SaveRichText(Original);
                    CurrPage.Update();
                end;
            }
            action(Email)
            {
                Caption = 'Email';
                ApplicationArea = All;
                Image = Email;
                trigger OnAction()
                var
                    Original: Text;
                begin
                    Original := Rec.GetRichText();
                    Original += '{Email}';
                    Rec.SaveRichText(Original);
                    CurrPage.Update();
                end;
            }
            action(PhoneNumber)
            {
                Caption = 'Phone Number';
                ApplicationArea = All;
                Image = Calls;
                trigger OnAction()
                var
                    Original: Text;
                begin
                    Original := Rec.GetRichText();
                    Original += '{Phone Number}';
                    Rec.SaveRichText(Original);
                    CurrPage.Update();
                end;
            }
            action(DateOfBirth)
            {
                Caption = 'Date of Birth';
                ApplicationArea = All;
                Image = DueDate;
                trigger OnAction()
                var
                    Original: Text;
                begin
                    Original := Rec.GetRichText();
                    Original += '{Date of Birth}';
                    Rec.SaveRichText(Original);
                    CurrPage.Update();
                end;
            }
            action(Address)
            {
                Caption = 'Address';
                ApplicationArea = All;
                Image = Home;
                trigger OnAction()
                var
                    Original: Text;
                begin
                    Original := Rec.GetRichText();
                    Original += '{Address}';
                    Rec.SaveRichText(Original);
                    CurrPage.Update();
                end;
            }
            action(City)
            {
                Caption = 'City';
                ApplicationArea = All;
                Image = Map;
                trigger OnAction()
                var
                    Original: Text;
                begin
                    Original := Rec.GetRichText();
                    Original += '{City}';
                    Rec.SaveRichText(Original);
                    CurrPage.Update();
                end;
            }
            action(PostalCode)
            {
                Caption = 'Postal Code';
                ApplicationArea = All;
                Image = Map;
                trigger OnAction()
                var
                    Original: Text;
                begin
                    Original := Rec.GetRichText();
                    Original += '{Postal Code}';
                    Rec.SaveRichText(Original);
                    CurrPage.Update();
                end;
            }
            action(Country)
            {
                Caption = 'Country';
                ApplicationArea = All;
                Image = Map;
                trigger OnAction()
                var
                    Original: Text;
                begin
                    Original := Rec.GetRichText();
                    Original += '{Country}';
                    Rec.SaveRichText(Original);
                    CurrPage.Update();
                end;
            }
            action(IDNumber)
            {
                Caption = 'ID Number';
                ApplicationArea = All;
                Image = Certificate;
                trigger OnAction()
                var
                    Original: Text;
                begin
                    Original := Rec.GetRichText();
                    Original += '{ID Number}';
                    Rec.SaveRichText(Original);
                    CurrPage.Update();
                end;
            }
            action(ApplicationDate)
            {
                Caption = 'Application Date';
                ApplicationArea = All;
                Image = DueDate;
                trigger OnAction()
                var
                    Original: Text;
                begin
                    Original := Rec.GetRichText();
                    Original += '{Application Date}';
                    Rec.SaveRichText(Original);
                    CurrPage.Update();
                end;
            }
            action(Status)
            {
                Caption = 'Status';
                ApplicationArea = All;
                Image = Status;
                trigger OnAction()
                var
                    Original: Text;
                begin
                    Original := Rec.GetRichText();
                    Original += '{Status}';
                    Rec.SaveRichText(Original);
                    CurrPage.Update();
                end;
            }
            action(ApprovalDate)
            {
                Caption = 'Approval Date';
                ApplicationArea = All;
                Image = DueDate;
                trigger OnAction()
                var
                    Original: Text;
                begin
                    Original := Rec.GetRichText();
                    Original += '{Approval Date}';
                    Rec.SaveRichText(Original);
                    CurrPage.Update();
                end;
            }
            action(RejectionReason)
            {
                Caption = 'Rejection Reason';
                ApplicationArea = All;
                Image = Note;
                trigger OnAction()
                var
                    Original: Text;
                begin
                    Original := Rec.GetRichText();
                    Original += '{Rejection Reason}';
                    Rec.SaveRichText(Original);
                    CurrPage.Update();
                end;
            }
            action(Occupation)
            {
                Caption = 'Occupation';
                ApplicationArea = All;
                Image = CalculateRemainingUsage;
                trigger OnAction()
                var
                    Original: Text;
                begin
                    Original := Rec.GetRichText();
                    Original += '{Occupation}';
                    Rec.SaveRichText(Original);
                    CurrPage.Update();
                end;
            }
            action(AnnualIncome)
            {
                Caption = 'Annual Income';
                ApplicationArea = All;
                Image = AccountingPeriods;
                trigger OnAction()
                var
                    Original: Text;
                begin
                    Original := Rec.GetRichText();
                    Original += '{Annual Income}';
                    Rec.SaveRichText(Original);
                    CurrPage.Update();
                end;
            }
            action(MemberCategory)
            {
                Caption = 'Member Category';
                ApplicationArea = All;
                Image = Group;
                trigger OnAction()
                var
                    Original: Text;
                begin
                    Original := Rec.GetRichText();
                    Original += '{Member Category}';
                    Rec.SaveRichText(Original);
                    CurrPage.Update();
                end;
            }

        }
        area(Promoted) {
            actionref("Show me how"; ShowMeHow) {

            }
            actionref("Available Fields"; AvailableFields) {

            }
            group(InsertField)
            {
                Image = Insert;
                Caption = 'Insert Field';

                actionref(ApplicationIDActionref; ApplicationID)
                {
                }
                actionref(FirstNameActionref; FirstName)
                {
                }
                actionref(LastNameActionref; LastName)
                {
                }
                actionref(EmailActionref; Email)
                {
                }
                actionref(PhoneNumberActionref; PhoneNumber)
                {
                }
                actionref(DateOfBirthActionref; DateOfBirth)
                {
                }
                actionref(AddressActionref; Address)
                {
                }
                actionref(CityActionref; City)
                {
                }
                actionref(PostalCodeActionref; PostalCode)
                {
                }
                actionref(CountryActionref; Country)
                {
                }
                actionref(IDNumberActionref; IDNumber)
                {
                }
                actionref(ApplicationDateActionref; ApplicationDate)
                {
                }
                actionref(StatusActionref; Status)
                {
                }
                actionref(ApprovalDateActionref; ApprovalDate)
                {
                }
                actionref(RejectionReasonActionref; RejectionReason)
                {
                }
                actionref(OccupationActionref; Occupation)
                {
                }
                actionref(AnnualIncomeActionref; AnnualIncome)
                {
                }
                actionref(MemberCategoryActionref; MemberCategory)
                {
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        EmailBodyVar := Rec.GetRichText();
    end;

    trigger OnOpenPage()
    begin
        if not Rec.get() then
        begin
            rec.Init();
            rec.Insert();
        end;
    end;
    
    var
        EmailBodyVar: Text;
}