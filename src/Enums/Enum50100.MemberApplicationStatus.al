// ============================================================
// Enum 50100 - Member Application Status
// ============================================================
// PURPOSE: Defines the possible states a member application can be in.
//
// WHAT IS AN ENUM?
//   An Enum (short for "Enumeration") is a list of named choices.
//   Instead of using numbers (0, 1, 2) or text ('Pending', 'Approved'),
//   we define a fixed set of options that the system can use.
//   This prevents typos and makes code easy to read.
//
// WORKFLOW:  Pending  →  Approved
//                     ↘  Rejected
//
// "Pending"   = Application just submitted, waiting for review
// "Approved"  = Application accepted, member will be created
// "Rejected"  = Application denied
//
// KEY CONCEPT - "Extensible = true":
//   This allows other extensions to add MORE values to this enum.
//   For example, another extension could add "On Hold" without
//   modifying our code.
//
// KEY CONCEPT - "value(0; Pending)":
//   The number (0, 1, 2) is the internal ID stored in the database.
//   The name (Pending, Approved, Rejected) is what appears in code.
//   Caption is what the USER sees on screen.
// ============================================================

enum 50100 "Member Application Status"
{
    Extensible = true;

    value(0; Pending)
    {
        Caption = 'Pending';    // What the user sees on screen
    }
    value(1; Approved)
    {
        Caption = 'Approved';
    }
    value(2; Rejected)
    {
        Caption = 'Rejected';
    }
}
