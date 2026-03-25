// ============================================================
// Table 50101 - Member
// ============================================================
// PURPOSE: Stores active SACCO members (approved applicants).
//
// CHANGE LOG:
//   - Added field 20 "Occupation Code" Code[20] with
//     TableRelation = "Occupation".
//     This replaces free-text entry with a validated lookup.
//     The legacy field 16 "Occupation" (Text) is kept for
//     backward compatibility (populated from import/application
//     flow) but the Card page now shows "Occupation Code".
// ============================================================

table 50101 "Member"
{
    Caption = 'Member';
    DataClassification = ToBeClassified;

    fields
    {
        // ---------- IDENTIFICATION ----------
        field(1; "Member ID"; Code[20])
        {
            Caption = 'Member ID';
        }
        field(2; "Application ID"; Code[20])
        {
            Caption = 'Application ID';
            TableRelation = "Member Application"."Application ID";
        }

        // ---------- PERSONAL INFORMATION ----------
        field(3; "First Name"; Text[100])
        {
            Caption = 'First Name';
        }
        field(4; "Last Name"; Text[100])
        {
            Caption = 'Last Name';
        }
        field(5; "Full Name"; Text[200])
        {
            Caption = 'Full Name';
            Editable = false;
        }

        // ---------- CONTACT INFORMATION ----------
        field(6; "Email"; Text[100])
        {
            Caption = 'Email';
        }
        field(7; "Phone Number"; Text[20])
        {
            Caption = 'Phone Number';
        }
        field(8; "Date of Birth"; Date)
        {
            Caption = 'Date of Birth';

            trigger OnValidate()
            var
                MinimumAgeDate: Date;
            begin
                if "Date of Birth" = 0D then
                    exit;
                if "Date of Birth" >= Today then
                    Error('Date of Birth cannot be today or in the future. Please enter a valid past date.');
                MinimumAgeDate := CalcDate('-18Y', Today);
                if "Date of Birth" > MinimumAgeDate then
                    Error('Member must be at least 18 years old. Minimum Date of Birth allowed: %1', MinimumAgeDate);
            end;
        }

        // ---------- ADDRESS ----------
        field(9; "Address"; Text[150])
        {
            Caption = 'Address';
        }
        field(10; "City"; Text[50])
        {
            Caption = 'City';
        }
        field(11; "Postal Code"; Code[20])
        {
            Caption = 'Postal Code';
        }
        field(12; "Country"; Code[10])
        {
            Caption = 'Country';
            TableRelation = "Country/Region".Code;
        }
        field(13; "ID Number"; Text[20])
        {
            Caption = 'ID/Passport Number';
        }

        // ---------- STATUS & REGISTRATION ----------
        field(14; "Registration Date"; Date)
        {
            Caption = 'Registration Date';
            Editable = false;
        }
        field(15; "Status"; Enum "Member Status")
        {
            Caption = 'Status';
        }

        // ---------- EMPLOYMENT ----------
        field(16; "Occupation"; Text[100])
        {
            Caption = 'Occupation (Text)';
            // Legacy text field kept for backward compatibility.
            // Populated from Member Application "Occupation" text.
            // Use field 20 "Occupation Code" for validated lookups on the Card.
        }
        field(17; "Annual Income"; Decimal)
        {
            Caption = 'Annual Income';
        }
        field(18; "Member Category"; Code[20])
        {
            Caption = 'Member Category';
            TableRelation = "Member Category Master".Code;

            trigger OnValidate()
            var
                MemberCat: Record "Member Category Master";
            begin
                if "Member Category" = '' then
                    exit;
                if not MemberCat.Get("Member Category") then
                    Error('Member Category %1 does not exist.', "Member Category");
                if not MemberCat.Active then
                    Error('Member Category %1 is inactive.', "Member Category");
            end;
        }

        // ---------- FINANCIALS ----------
        field(19; "Account Balance"; Decimal)
        {
            Caption = 'Account Balance';
            Editable = false;
        }

        // ---------- OCCUPATION CODE (Task E – NEW) ----------
        field(20; "Occupation Code"; Code[20])
        {
            Caption = 'Occupation';
            // KEY CONCEPT - TableRelation with WHERE:
            //   Only active occupations appear in the dropdown.
            //   This prevents selecting retired/inactive occupations.
            TableRelation = "Occupation".Code where("Active" = const(true));

            trigger OnValidate()
            var
                Occ: Record "Occupation";
            begin
                if "Occupation Code" = '' then
                    exit;
                if not Occ.Get("Occupation Code") then
                    Error('Occupation code %1 does not exist.', "Occupation Code");
                if not Occ.Active then
                    Error('Occupation %1 is inactive.', "Occupation Code");
                // Mirror the description into the legacy text field for reports/queries
                // that still reference the old "Occupation" text field.
                "Occupation" := CopyStr(Occ.Description, 1, MaxStrLen("Occupation"));
            end;
        }
    }

    // -------------------------------------------------------
    // KEYS
    // -------------------------------------------------------
    keys
    {
        key(PK; "Member ID")
        {
            Clustered = true;
        }
        key(SK2; "Status")
        {
        }
        key(SK3; "Registration Date")
        {
        }
        key(SK4; "Occupation Code")
        {
            // Allows filtering/reporting by occupation category
        }
    }
}
