table 50100 "Member Application"
{
    Caption = 'Member Application';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Application ID"; Code[20])
        {
            Caption = 'Application ID';
            Editable = false;
        }
        field(2; "First Name"; Text[100])
        {
            Caption = 'First Name';
        }
        field(3; "Last Name"; Text[100])
        {
            Caption = 'Last Name';
        }

        // ---------- CONTACT INFORMATION ----------
        field(4; "Email"; Text[100])
        {
            Caption = 'Email';
        }
        field(5; "Phone Number"; Text[10])
        {
            Caption = 'Phone Number';
            NotBlank = true;
            trigger onValidate()
            var
                FieldValidator: Codeunit FieldValidator;
            begin
                if not FieldValidator.CheckPhone(Rec."Phone Number") then
                    Error('Incorrect Phone number format: Use 07XXXXXXXX');
            end;

        }
        field(6; "Date of Birth"; Date)
        {
            Caption = 'Date of Birth';

            trigger OnValidate()
            var
                MinimumAgeDate: Date;  // Variable to hold the cutoff date
            begin
                if "Date of Birth" = 0D then
                    exit;

                if "Date of Birth" >= Today then
                    Error('Date of Birth cannot be today or in the future. Please enter a valid past date.');

                MinimumAgeDate := CalcDate('-35Y', Today);

                if "Date of Birth" > MinimumAgeDate then
                    Error('Applicant must be at least 35 years old. Minimum Date of Birth allowed: %1', MinimumAgeDate);
            end;
        }
        field(7; "Address"; Text[150])
        {
            Caption = 'Address';
        }
        field(8; "City"; Text[50])
        {
            Caption = 'City';
        }
        field(9; "Postal Code"; Code[20])
        {
            Caption = 'Postal Code';
        }
        field(10; "Country"; Code[10])
        {
            Caption = 'Country';
            TableRelation = "Country/Region".Code;
        }
        field(11; "ID Number"; Text[20])
        {
            Caption = 'ID/Passport Number';
        }
        field(12; "Application Date"; DateTime)
        {
            Caption = 'Application Date';
            Editable = false;
        }
        field(13; "Status"; Enum "Member Application Status")
        {
            Caption = 'Status';
        }
        field(14; "Approval Date"; DateTime)
        {
            Caption = 'Approval Date';
        }
        field(15; "Rejection Reason"; Text[250])
        {
            Caption = 'Rejection Reason';
        }
        field(16; "Occupation"; Text[30])
        {
            Caption = 'Occupation';
            TableRelation = Occupation.Name;
        }
        field(17; "Annual Income"; Decimal)
        {
            Caption = 'Annual Income';
        }
        field(18; "Member Category"; Code[20])
        {
            Caption = 'Member Category';
            TableRelation = "Member Category Master".Code;
        }
    }

    keys
    {
        key(PK; "Application ID")
        {
            Clustered = true;
        }
        key(SK; "Application Date")
        {
        }
        key(SK2; "Status")
        {
        }
    }
    trigger OnInsert()
    begin
        if "Application ID" = '' then
            AssignApplicationID();

        "Application Date" := CurrentDateTime;

        "Status" := Enum::"Member Application Status"::Pending;
    end;
    local procedure AssignApplicationID()
    var
        MemberSetup: Record "Member Setup";
        MemberAppNoSeriesMgt: Codeunit "Member App No. Series Mgt";
        NoSeries: Codeunit "No. Series";
        RawSequenceNo: Code[20];
        SequenceNoInteger: Integer;
        SequenceNoText: Text[20];
        SequencePart: Text[5];
        ApplicationIDText: Text[30];
    begin
        MemberAppNoSeriesMgt.EnsureMemberApplicationNoSeriesAndSetup();

        MemberSetup.GetOrCreateSetup();

        if MemberSetup."Member Application Nos." = '' then
            Error(
              'Member Application Nos. is not configured. Open Member Application List, choose Member Setup, and set a No. Series (for example MEMAPPSEQ).');

        RawSequenceNo := NoSeries.GetNextNo(MemberSetup."Member Application Nos.", WorkDate());
        SequenceNoText := Format(RawSequenceNo);
        if not Evaluate(SequenceNoInteger, SequenceNoText) then
            Error(
              'Invalid value %1 returned from No. Series %2. Configure the series to return numeric values only for Application ID format APP-YYYYMMDD-#####.',
              SequenceNoText,
              MemberSetup."Member Application Nos.");
        if StrLen(SequenceNoText) > MaxStrLen(SequencePart) then
            Error(
              'No. Series %1 returned %2, which exceeds %3 digits required for Application ID format APP-YYYYMMDD-#####.',
              MemberSetup."Member Application Nos.",
              SequenceNoText,
              MaxStrLen(SequencePart));
        SequencePart := CopyStr(PadStr('', MaxStrLen(SequencePart) - StrLen(SequenceNoText), '0') + SequenceNoText, 1, MaxStrLen(SequencePart));
        ApplicationIDText := 'APP-' + Format(WorkDate(), 0, '<Year4><Month,2><Day,2>') + '-' + SequencePart;

        // Step 9: Safety check - make sure it fits in the field
        if StrLen(ApplicationIDText) > MaxStrLen("Application ID") then
            Error(
              'Generated Application ID %1 exceeds maximum length %2. Review No. Series setup.',
              ApplicationIDText,
              MaxStrLen("Application ID"));

        // Step 10: Assign the generated ID to the record
        "Application ID" := CopyStr(ApplicationIDText, 1, MaxStrLen("Application ID"));
    end;
}
