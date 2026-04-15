// ============================================================
// Table 50108 - Data Quality Issue
// ============================================================
// PURPOSE: Temporary table to store data quality findings.
//          Used by Data Quality Codeunit (50111) to report
//          duplicate emails, orphaned loans, and stalled apps.
//
// DESIGN:
//   - Temporary table (not persisted to database)
//   - Populated by Codeunit 50111.RunDataQualityChecks()
//   - Displayed via Page 50121 (Data Quality Findings)
//   - Each record = one data quality issue
//
// ISSUE TYPES:
//   1. "Duplicate Email"       - Multiple members with same email
//   2. "Orphaned Loan"         - Loan references non-existent member
//   3. "Stalled Application"   - Loan stuck in Pending Approval too long
//
// ============================================================

table 50108 "Data Quality Issue"
{
    Caption = 'Data Quality Issue';
    DataClassification = ToBeClassified;
    TableType = Temporary;  // NOT persisted to database

    fields
    {
        field(1; "Issue ID"; Integer)
        {
            Caption = 'Issue ID';
            // NOTE: AutoIncrement removed for temporary table.
            // Manually managed in Cod50111.RunDataQualityChecks()
        }

        field(2; "Issue Type"; Text[50])
        {
            Caption = 'Issue Type';
            // Values: "Duplicate Email", "Orphaned Loan", "Stalled Application"
        }

        field(3; "Severity"; Text[20])
        {
            Caption = 'Severity';
            // Values: "Critical", "Warning", "Info"
        }

        field(4; "Description"; Text[250])
        {
            Caption = 'Description';
            // Human-readable explanation of the issue
        }

        field(5; "Member ID"; Code[20])
        {
            Caption = 'Member ID';
            // Links to Member table (for Duplicate Email issues)
            TableRelation = "Member"."Member ID";
        }

        field(6; "Member Email"; Text[100])
        {
            Caption = 'Member Email';
            // The problematic email address
        }

        field(7; "Affected Count"; Integer)
        {
            Caption = 'Affected Count';
            // For duplicate emails: how many members share this email
            // For related records: count of affected items
        }

        field(8; "Loan Application No."; Code[20])
        {
            Caption = 'Loan Application No.';
            // Links to Loan Application (for Orphaned/Stalled issues)
            TableRelation = "Loan Application"."Loan Application No.";
        }

        field(9; "Referenced Member ID"; Code[20])
        {
            Caption = 'Referenced Member ID';
            // For Orphaned Loan: the Member ID that doesn't exist
        }

        field(10; "Days in Status"; Integer)
        {
            Caption = 'Days in Status';
            // For Stalled Application: how long in Pending Approval
        }

        field(11; "Status Since Date"; Date)
        {
            Caption = 'Status Since Date';
            // When did it enter the current status
        }

        field(12; "Recommendation"; Text[250])
        {
            Caption = 'Recommendation';
            // Suggested action to fix the issue
        }

        field(13; "Related Record ID"; Code[20])
        {
            Caption = 'Related Record ID';
            // Primary key of the affected record (for drill-down)
        }
    }

    keys
    {
        key(PK; "Issue ID")
        {
            Clustered = true;
        }
        key(KeyIssueType; "Issue Type")
        {
        }
        key(KeySeverity; "Severity")
        {
        }
    }
}
