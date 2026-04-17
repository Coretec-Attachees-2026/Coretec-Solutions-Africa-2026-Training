// ============================================================
// Table 50111 - Data Quality Issue (Temporary)
// ============================================================
// PURPOSE: Temporary table to hold data quality issues found
//          during analysis. Cleared before each analysis run.
//
// USAGE: The Data Quality Finder codeunit populates this table
//        with issues found across member and loan data.
//
// ISSUE TYPES:
//   - Duplicate Emails: Multiple members with same email
//   - Orphaned Lot Applications: Loan applications pointing to non-existent members
//   - Stuck Status: Applications stuck in a status for > 30 days
// ============================================================

table 50111 "Data Quality Issue"
{
    TableType = Temporary;
    Caption = 'Data Quality Issue';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            Editable = false;
            AutoIncrement = true;
        }

        field(2; "Issue Type"; Code[30])
        {
            Caption = 'Issue Type';
            // Values: "DUPLICATE_EMAIL", "ORPHANED_LOAN", "STUCK_STATUS"
        }

        field(3; "Severity"; Option)
        {
            Caption = 'Severity';
            OptionMembers = Critical,High,Medium,Low;
            OptionCaption = 'Critical,High,Medium,Low';
            // Critical = data integrity risk
            // High = could cause problems
            // Medium = should be reviewed
            // Low = informational
        }

        field(4; "Record Type"; Code[30])
        {
            Caption = 'Record Type';
            // Values: "Member", "Loan Application", "Member Application"
        }

        field(5; "Primary Record ID"; Code[50])
        {
            Caption = 'Primary Record ID';
            // For member: Member ID
            // For loan: Loan Application No.
            // For member app: Application ID
        }

        field(6; "Secondary Record ID"; Code[50])
        {
            Caption = 'Secondary Record ID';
            // For duplicate emails: the OTHER member's ID
            // For orphaned loans: the missing Member ID
            // For stuck status: empty
        }

        field(7; "Issue Description"; Text[250])
        {
            Caption = 'Issue Description';
            // Human-readable description of the issue
        }

        field(8; "Details"; Text[500])
        {
            Caption = 'Details';
            // Additional info (emails, dates, status, etc.)
        }

        field(9; "Recommendation"; Text[250])
        {
            Caption = 'Recommendation';
            // Steps to fix the issue
        }

        field(10; "Date Found"; DateTime)
        {
            Caption = 'Date Found';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(IssueType; "Issue Type")
        {
        }
        key(Severity; "Severity")
        {
        }
        key(RecordType; "Record Type")
        {
        }
    }
}
