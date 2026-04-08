# CORETEC SACCO Permission Sets - Security Testing Guide

**Version:** 1.0  
**Purpose:** Step-by-step guide for testing and validating least-privilege access control  
**Target Environment:** Business Central Sandbox  
**Date Prepared:** April 2026

---

## Quick Start: 5-Minute Setup

### Prerequisites
- Access to Business Central admin console
- Deployment of permission set files:
  - `PermSet50130.TellerRole.al`
  - `PermSet50131.ManagerRole.al`
- Test sandbox with sample data

### Deploy Permission Sets
```powershell
# In VS Code terminal
al_publish debug=false

# Expected output:
# ✅ Building...
# ✅ Publishing...
# ✅ Permission sets registered
```

### Create Test Users
1. Go to Business Central → **Users** (search bar)
2. Click **+ New**
3. Fill in:
   - **User Name:** `testuser.teller@coretec.local`
   - **Full Name:** Test Teller User
   - **User Role Memberships:** (leave empty for now)
4. Click **Create**
5. Repeat for:
   - `testuser.manager@coretec.local` → Manager
   - `testuser.baseline@coretec.local` → Admin (no restrictions)

---

## Module 1: Permission Set Assignment

### Objective
Verify permission sets are deployed and can be assigned to users

### Steps

**Step 1.1: Verify Permission Sets Exist**
1. Open Business Central → Search **Permission Sets**
2. Look for:
   - ✅ **CORETEC-TELLER** (ID: 50130)
   - ✅ **CORETEC-MANAGER** (ID: 50131)
3. Click each to verify:
   - Assignable = Yes
   - Caption and Description visible

**Expected Result:** Both permission sets listed

**Troubleshoot:**
- IF not found → Permission set .al files not deployed
  - Solution: Run `al_publish` in VS Code
- IF ID mismatch → Wrong object ID used
  - Solution: Check .al file IDs match (50130, 50131)

---

**Step 1.2: Assign Teller Permission Set**
1. Go to **Users**
2. Open `testuser.teller@coretec.local`
3. In **User Role Memberships** section, click **+ New**
4. Select **Role ID**: Type or search "CORETEC-TELLER"
5. Click **Next** → **Finish**
6. Click **Save**

**Expected Result:** Assignment saved without errors

**Verify Assignment:**
1. Still in user record, scroll to **User Permissions**
2. Click **Edit**
3. Verify permissions show:
   - ✅ Tables: 50100 (RIMD), 50101 (RIM), 50102 (R), 50103 (RIMD), etc.
   - ✅ Pages: 50100-50117 (partial list)
   - ❌ NOT table 50104 or page 50106

---

**Step 1.3: Assign Manager Permission Set**
1. Go to **Users**
2. Open `testuser.manager@coretec.local`
3. In **User Role Memberships**, click **+ New**
4. Select **Role ID**: "CORETEC-MANAGER"
5. Click **Finish** → **Save**

**Expected Result:** Manager has all table/page permissions + setup

**Verify in User Permissions:**
1. Click **Edit** permissions
2. Should see:
   - ✅ All tables: 50100 (X), 50101 (X), 50102 (X), 50104 (X), etc.
   - ✅ All pages including 50106 (Setup), 50111 (Email)

---

## Module 2: Teller Role - Functional Verification

### Objective
Confirm Teller can perform job duties but cannot approve/setup

### Test Data Preparation
Before running tests, create sample records:

**Create Member Applications (a few records to work with):**
1. Open **Member Application List** (page 50100)
2. Click **+ New**
3. Fill in:
   - Full Name: John Doe
   - Email: john@example.com
   - Phone: 0700000001
   - Status: Pending
4. Save, repeat for 2-3 more

**Create Members (reference data):**
1. Open **Member List** (page 50102)
2. Click **+ New**
3. Select application ID from previous step
4. Full Name auto-fills; adjust as needed
5. Save

**Create Loan Applications:**
1. Open **Loan Application List** (page 50107)
2. Click **+ New**
3. Member ID: Select from member list
4. Loan Amount: 50,000.00
5. Business/Purpose: Small business
6. Status: Pending
7. Save, repeat for 2-3 more

---

### Test 2.1: Teller Can View Member Data

**Scenario:** Teller searches and views member information

**Steps:**
1. Sign in as: `testuser.teller@coretec.local`
2. Search → **Member List** (page 50102)
3. Observe: List of members loads ✅

**Verify:**
- Can see all member fields (ID, Name, Email, Phone, etc.)
- Can use filters and search ✅
- No "Permission Denied" error

**Pass Criteria:** ✅ Member list accessible and searchable

---

### Test 2.2: Teller Can Update Member Information

**Scenario:** Teller updates member contact info

**Steps:**
1. (Logged in as Teller)
2. From Member List, open a member card (page 50103)
3. Edit **Phone Number** field
4. Change email address
5. Click **Save**

**Expected Result:** ✅ Changes saved without error

**Verify in Database (Optional):**
- Open same member as Admin
- Confirm changes are persisted ✅

**Pass Criteria:** ✅ Teller can modify member records

**Failure Scenario:**
- If "Permission Denied" shown → Permission set has wrong flag
  - Debug: Check `table 50101 = RIM` (should have M flag)

---

### Test 2.3: Teller Cannot Delete Members

**Scenario:** Teller attempts to delete a member record

**Steps:**
1. (Logged in as Teller)
2. Open Member List (page 50102)
3. Select a member record
4. Press **Delete** key (or right-click → Delete)

**Expected Result:** ❌ Delete action blocked with error:
```
You do not have permission to delete from Member.
```

**Pass Criteria:** ✅ Record NOT deleted, error shown

**Failure Scenario - If delete succeeds:**
- Security breach! Permission set allow Delete (D flag)
- Debug: Check `table 50101` has RIM (NOT X or D flag)
- Fix: Redeploy permission set with corrected flag

---

### Test 2.4: Teller Can View Loan Applications

**Scenario:** Teller views pending loan applications

**Steps:**
1. (Logged in as Teller)
2. Search → **Loan Application List** (page 50107)
3. Observe: List of loan applications loads ✅

**Expected Result:** Applications visible, can filter by status

**Pass Criteria:** ✅ Loan Application list accessible

---

### Test 2.5: Teller Can Update Loan Application Details

**Scenario:** Teller updates loan request with additional info

**Steps:**
1. (Logged in as Teller)
2. Open a loan application (page 50108)
3. Edit **Loan Amount** or **Business Purpose** field
4. Add notes in description field
5. Click **Save**

**Expected Result:** ✅ Changes saved

**Pass Criteria:** ✅ Teller can modify loan applications

---

### Test 2.6: Teller CANNOT Approve Loans

**Scenario:** Teller attempts to approve a pending loan

**Steps:**
1. (Logged in as Teller)
2. Open Loan Application card (page 50108)
3. Try to change **Status** field from "Pending" to "Approved"
   OR
   Click **Approve** button/action (if available on page)

**Expected Result 1 (Field locked):**
```
Field is not editable
```

**Expected Result 2 (Action blocked):**
```
You do not have permission to execute this action
```

**Pass Criteria:** ✅ Approval action blocked/unavailable

**Verify via Codeunit (Advanced):**
- Even if Teller changed status directly in DB, approval codeunit should check permissions
- Codeunit should validate: `Approve` action only allowed for Managers

---

### Test 2.7: Teller Cannot Access Setup Pages

**Scenario:** Teller navigates to Member Category setup

**Steps:**
1. (Logged in as Teller)
2. Open breadcrumb/navigation
3. Try to open **Member Category List** (page 50104)
   OR
   Try direct URL: `https://localhost:7049/bc/run?page=50104`

**Expected Result:** ❌ Navigation blocked:
```
You do not have permission to access this page.
```

**Pass Criteria:** ✅ Page access denied

**Repeat for:**
- Member Setup (page 50106) → Permission denied ✅
- Email Preview (page 50111) → Permission denied ✅
- Occupation (pages 50112-50113) → READ ONLY (can view, not edit)

---

## Module 3: Manager Role - Administrative Verification

### Objective
Confirm Manager can perform all Teller duties PLUS approval and setup

### Test 3.1: Manager Can Access Setup Pages

**Scenario:** Manager opens Member Category setup

**Steps:**
1. Sign in as: `testuser.manager@coretec.local`
2. Search → **Member Category List** (page 50104)

**Expected Result:** ✅ Page opens successfully

**Verify Functionality:**
1. Click **+ New**
2. Enter Category Name: "Premium"
3. Click **Create**

**Expected Result:** ✅ New category saved to table 50102

**Confirm as Teller:**
1. Sign out as Manager
2. Sign in as Teller
3. Open Member Application → Try to apply for Premium category
4. In dropdown: ✅ "Premium" now appears

**Pass Criteria:** ✅ Manager config visible to Teller (read-only access through dropdown)

---

### Test 3.2: Manager Can Approve Member Applications

**Scenario:** Manager approves a pending member application

**Setup:**
- Have a member application with Status = "Pending"

**Steps:**
1. (Logged in as Manager)
2. Open **Member Application Card** (page 50101)
3. Change **Status** to "Approved" (if field is editable)
   OR
   Click **Approve** button/action

**Expected Result:** ✅ Action executed without error

**Verify Side Effect:**
1. Check table 50101 (Members) → New member record created
2. New member ID should link to this application
3. Alert/notification sent (if email code is configured)

**Pass Criteria:** ✅ Member created in table 50101 post-approval

---

### Test 3.3: Manager Can Reject Member Applications

**Scenario:** Manager rejects an application

**Setup:**
- Have a member application with Status = "Pending"

**Steps:**
1. (Logged in as Manager)
2. Open **Member Application Card**
3. Change **Status** to "Rejected"
   OR
   Click **Reject** button/action
4. Enter rejection reason (if prompted)

**Expected Result:** ✅ Status updated to "Rejected"

**Verify Email:**
- Check applicant's email: Should receive rejection notice
- (If email integration active)

**Pass Criteria:** ✅ Rejection recorded and notification sent

---

### Test 3.4: Manager Can Delete Records

**Scenario:** Manager deletes a rejected application

**Steps:**
1. (Logged in as Manager)
2. Open **Member Application List**
3. Filter: Status = "Rejected"
4. Select rejected application
5. Press **Delete** OR right-click → Delete

**Expected Result:** ✅ Confirmation dialog shown

**Confirm Delete:**
1. Click **Yes/Confirm**
2. Record removed from list

**Verify Audit Trail:**
1. (Advanced: Check Activity Log or Audit Trail report)
2. Should show: `User: testuser.manager@coretec.local, Action: DELETE, Table: 50100, Time: [timestamp]`

**Pass Criteria:** ✅ Record deleted, audit logged

---

### Test 3.5: Manager Can Configure Occupations

**Scenario:** Manager adds new occupation

**Steps:**
1. (Logged in as Manager)
2. Search → **Occupation List** (page 50112)
3. Click **+ New**
4. Enter **Code:** "ENGINEER"
5. Enter **Description:** "Software Engineer"
6. Click **Create**

**Expected Result:** ✅ New occupation saved

**Verify Teller Can See:**
1. Sign out Manager
2. Sign in Teller
3. Open Member Application
4. In **Occupation** dropdown: Should see "ENGINEER" ✅

**Pass Criteria:** ✅ Occupation configured and visible to Teller

---

### Test 3.6: Manager Can Approve Loans

**Scenario:** Manager approves a loan application

**Setup:**
- Have a loan application with Status = "Pending"

**Steps:**
1. (Logged in as Manager)
2. Open **Loan Application Card** (page 50108)
3. Change **Status** to "Approved"
   OR
   Click **Approve** button/action
4. (Optionally) Set disbursement date

**Expected Result:** ✅ Status updated

**Verify Side Effect:**
1. Open **Loan Ledger Entries** (page 50109)
2. New ledger entry created with:
   - Member ID: From loan application
   - Loan Amount: From application
   - Entry Type: "Loan" or "Disbursement"
   - Status: Active

**Pass Criteria:** ✅ Ledger entry auto-created on approval

---

## Module 4: Cross-Role Boundary Tests

### Objective
Verify permission boundaries cannot be bypassed

### Test 4.1: Privilege Escalation via URL

**Scenario:** Teller attempts direct page access via URL manipulation

**Steps:**
1. (Logged in as Teller)
2. Open Member List (page 50102) - this works ✅
3. In browser address bar, manually change page ID:
   - Current: `https://localhost:7049/bc/run?page=50102`
   - Change to: `https://localhost:7049/bc/run?page=50106` (Member Setup)
4. Press **Enter**

**Expected Result:** ❌ Navigation blocked:
```
You do not have permission to access this page. 
Contact your administrator.
```

**Pass Criteria:** ✅ Direct URL access blocked

---

### Test 4.2: Privilege Escalation via Form Actions

**Scenario:** Teller tries to trigger admin action via form

**Steps:**
1. (Logged in as Teller)
2. Open Loan Application Card (page 50108)
3. If page has custom actions (e.g., "Monthly Batch Process"):
   - Click action → Try to execute

**Expected Result:** ❌ Action disabled or shows:
```
You do not have sufficient permissions to run this action.
```

**Pass Criteria:** ✅ Custom actions enforced at code level

---

### Test 4.3: Concurrent Operations - No Perm Escalation

**Scenario:** Two users, one Teller and one Manager, both edit same record

**Precondition:**
- Two machines or two browser sessions
- Session A: Logged in as Teller
- Session B: Logged in as Manager

**Steps:**
1. Session A: Open Member record (page 50103)
2. Session B: Open same Member record
3. Session B (Manager): Edit an approval-only field
4. Session B: Click Save ✅
5. Session A (Teller): Try to make edit
6. Session A: Try to Save

**Expected Result:**
- Session A shows: "Record has been modified. Do you want to reload?"
- Click Yes/Reload
- Session A cannot see Manager's approval field (if hidden in Teller view)
- Any attempt to change Manager-only fields: Permission denied

**Pass Criteria:** ✅ No permission escalation via concurrency

---

## Module 5: Permission Verification Reports

### Objective
Generate reports to confirm permission set structure

### Verify Using Security Audit Trail

**In Business Central:**
1. Search → **User Security Activities**
2. Filter: User = `testuser.teller@coretec.local`
3. Look for failed permission attempts:
   - "Delete from Member" - BLOCKED
   - "Execute Approve action" - BLOCKED
   - "Access page 50106" - BLOCKED

**Expected Result:** Several FAILED operations logged ✅

---

### Generate Permission Report

**Manual Report (Advanced):**
1. Search → **Users**
2. Select `testuser.teller@coretec.local`
3. Click **User Permissions** → Export to Excel
4. Verify:
   - Table 50104 (Member Setup): NOT listed
   - Page 50106 (Member Setup Card): NOT listed
   - Table 50101: Listed with RIM permission ✅

**Pass Criteria:** ✅ Permission report matches design

---

## Module 6: Regression Testing Checklist

After any changes to permission sets, run this checklist:

- [ ] **Teller Role**
  - [ ] Can create member applications
  - [ ] Can update member records
  - [ ] Cannot delete members
  - [ ] Cannot approve applications
  - [ ] Cannot access page 50106 (Setup)
  - [ ] Cannot access page 50111 (Email)
  - [ ] Can view but not edit occupations

- [ ] **Manager Role**
  - [ ] Can perform all Teller tasks
  - [ ] Can approve member applications
  - [ ] Can reject member applications
  - [ ] Can delete records
  - [ ] Can access page 50106 (Setup)
  - [ ] Can modify occupations
  - [ ] Can approve loans
  - [ ] Can access page 50117 (Members API)

- [ ] **Security Boundaries**
  - [ ] URL-based bypass blocked
  - [ ] Action-based privilege escalation blocked
  - [ ] Failed attempts logged
  - [ ] No Silent Failures (errors shown to user)

---

## Troubleshooting

### Problem: "Permission Denied" but should have access

**Debug Steps:**
1. Check user role assignment:
   - Go to **Users** → Select user → View **User Role Memberships**
   - Is correct role assigned?
2. Check permission set deployed:
   - Search **Permission Sets**
   - Does role exist with correct ID (50130 or 50131)?
3. Check for conflicting permissions:
   - If user has SUPER role + Teller role
   - SUPER overrides everything → Remove SUPER for testing
4. Clear browser cache:
   - Ctrl+Shift+Del → Clear all → Retry login

**Command to redeploy:**
```powershell
al_build  # Verify no errors
al_publish debug=false
# Wait 30 seconds for permissions to propagate
# Then test again
```

---

### Problem: Teller CAN delete records (security breach)

**Immediate Action:**
1. Revoke Teller role from all users:
   - Go to **Users**
   - Find users with CORETEC-TELLER role
   - Remove role membership
2. Fix permission set:
   - Open `PermSet50130.TellerRole.al`
   - Check table 50101 line:
     - Current: `table 50101 "Member" = X,` ← WRONG (X = full access)
     - Should be: `table 50101 "Member" = RIM,` ← RIGHT (no Delete)
   - Deploy fix: `al_publish debug=false`
3. Re-assign Teller role:
   - Test with one user first
   - Verify delete blocked ✅
   - Then assign to remaining staff

---

### Problem: Teller cannot see dropdown values

**Cause:** Child table permission is read: Child table not granted READ permission

**Debug:**
- Teller trying to access Member Category dropdown in form
- Dropdown empty (no values)
- Check permission set: `table 50102 "Member Category" = R`
- Verify permission flag includes R (read) ✅

**If still broken:**
- Check if page has data-access control
- Check filter on Member Category list (maybe filtering out accessible categories)
- Test: Open Member Category List directly as Teller
  - Should see values ✅
  - If empty → Category table is empty OR permission wrong

---

## Sign-Off Checklist

- [ ] Permission sets deployed successfully
- [ ] Test users created (Teller, Manager, baseline)
- [ ] All Module 1-4 tests passed
- [ ] No permission escalation vulnerabilities found
- [ ] Audit trail logging confirmed
- [ ] Documentation updated
- [ ] Team trained on roles:
  - [ ] Teller staff understand their access
  - [ ] Manager staff understand their additional permissions
  - [ ] Admin staff aware of least-privilege design
- [ ] Approved by: _________________ Date: _________

---

## Appendix: Test Data Setup Script

If you need to quickly populate test data:

```al
// Codeunit to create test member applications
codeunit 50199 "Create Test Data"
{
    trigger OnRun()
    begin
        CreateTestMemberApplications();
        CreateTestMembers();
        CreateTestLoans();
        CreateTestOccupations();
    end;

    local procedure CreateTestMemberApplications()
    var
        MemberApp: Record "Member Application";
    begin
        IntializeMemberApp(MemberApp, 'APP001', 'Alice Johnson', 'alice@test.com');
        MemberApp.Status := Enum::"Member Application Status"::Pending;
        MemberApp.Insert();

        InitializeMemberApp(MemberApp, 'APP002', 'Bob Smith', 'bob@test.com');
        MemberApp.Status := Enum::"Member Application Status"::Pending;
        MemberApp.Insert();
    end;

    // ... More test data procedures

end;
```

To run:
1. Create codeunit in src/codeunits/
2. Deploy via `al_publish`
3. Run from Business Central → Search "Create Test Data" → Click **Run**

---

**Document Version:** 1.0  
**Last Updated:** April 2026  
**Prepared By:** CORETEC Security Team  
**Status:** Ready for Execution
