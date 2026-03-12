// ============================================================
// Table 50107 - Application Audit Log
// ============================================================
// PURPOSE: Records every significant action taken on Member
//          Applications and Loan Applications for audit purposes.
//
// WHAT IS AN AUDIT LOG?
//   An audit log records WHO did WHAT, WHEN, and to WHICH record.
//   This is important for compliance, accountability, and debugging.
//
// ENTRIES ARE CREATED BY:
//   - Cod50100 (Member Management) on approve/reject member applications
//   - Cod50105 (Loan Management) on submit/approve/reject/post/repayment of loans
// ============================================================

table 50107 "Application Audit Log"
{
    Caption = 'Application Audit Log';
    DataClassification = ToBeClassified;
    DrillDownPageId = "Application Audit Log";
    LookupPageId = "Application Audit Log";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "Date-Time"; DateTime)
        {
            Caption = 'Date-Time';
            // When the action was performed
        }
        field(3; "User ID"; Code[50])
        {
            Caption = 'User ID';
            // Who performed the action
        }
        field(4; "Action Type"; Text[50])
        {
            Caption = 'Action Type';
            // e.g., "Approved", "Rejected", "Submitted", "Disbursed", "Repayment"
        }
        field(5; "Document Type"; Text[50])
        {
            Caption = 'Document Type';
            // e.g., "Member Application", "Loan Application"
        }
        field(6; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            // The Application ID or Loan Application No.
        }
        field(7; "Description"; Text[250])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(SK1; "Document Type", "Document No.") { }
        key(SK2; "Date-Time") { }
    }
}
