# CORETEC SACCO Permission Sets - Security Testing Matrix

**Version:** 1.0  
**Date:** April 2026  
**Purpose:** Test matrix for least-privilege access control between Teller and Manager roles

---

## Overview

| Role | Object ID | Object Name | Scope | Created | Assignable |
|------|-----------|------------|-------|---------|-----------|
| **TELLER** | 50130 | CORETEC-TELLER | Read/Update Members & Loans | ✅ | ✅ Yes |
| **MANAGER** | 50131 | CORETEC-MANAGER | Full operational + Setup | ✅ | ✅ Yes |

---

## Access Control Matrix: ACTION × ROLE

### LEGEND
- ✅ **ALLOWED** - User can perform this action
- ❌ **BLOCKED** - User cannot perform this action, should see permission error
- (R) = Read-only access granted
- (RIM) = Read, Insert, Modify granted (no Delete)
- (X) = Full Execute permission (CRUD)

---

## TABLE PERMISSIONS - What Each Role Can Do

| Table ID | Table Name | Operation | Teller (RIM/R) | Manager (X) | Notes |
|----------|-----------|-----------|----------------|------------|-------|
| **50100** | **Member Application** | CREATE | ✅ | ✅ | Teller enters new applications |
| | | READ | ✅ | ✅ | Both can view |
| | | UPDATE | ✅ | ✅ | Both can modify status/info |
| | | DELETE | ❌ | ✅ | Manager only - audit trail |
| | | REJECT | ⚠️ (code-controlled) | ✅ | Approval flow in codeunit |
| **50101** | **Member** | CREATE | ✅ | ✅ | After application approved |
| | | READ | ✅ | ✅ | Both can view member records |
| | | UPDATE | ✅ | ✅ | Save member updates |
| | | DELETE | ❌ | ✅ | Manager only - data integrity |
| **50102** | **Member Category** | CREATE | ❌ | ✅ | Manager configures categories |
| | | READ | ✅ | ✅ | Teller uses for dropdowns |
| | | UPDATE | ❌ | ✅ | Manager-only setup |
| | | DELETE | ❌ | ✅ | Manager-only cleanup |
| **50103** | **Loan Application** | CREATE | ✅ | ✅ | Apply for new loan |
| | | READ | ✅ | ✅ | View application status |
| | | UPDATE | ✅ | ✅ | Update app details |
| | | DELETE | ❌ | ✅ | Manager only |
| | | APPROVE | ⚠️ (code-controlled) | ✅ | Approval flow in codeunit |
| | | REJECT | ⚠️ (code-controlled) | ✅ | Rejection flow in codeunit |
| **50104** | **Member Setup** | CREATE | ❌ | ✅ | Manager configures system |
| | | READ | ❌ | ✅ | Teller has NO access |
| | | UPDATE | ❌ | ✅ | Manager only |
| | | DELETE | ❌ | ✅ | Manager only |
| **50105** | **Loan Ledger Entry** | CREATE | ❌ | ✅ | Created by code only |
| | | READ | ✅ | ✅ | Both can view |
| | | UPDATE | ❌ | ✅ | Should be code-controlled |
| | | DELETE | ❌ | ✅ | Manager audit only |
| **50106** | **SMS Log** | CREATE | ❌ | ❌ | Automated via codeunit |
| | | READ | ✅ | ✅ | Both can view logs |
| | | UPDATE | ❌ | ✅ | Manager cleanup |
| | | DELETE | ❌ | ✅ | Manager cleanup |
| **50111** | **Occupation** | CREATE | ❌ | ✅ | Manager configures |
| | | READ | ✅ | ✅ | Teller uses for dropdowns |
| | | UPDATE | ❌ | ✅ | Manager setup |
| | | DELETE | ❌ | ✅ | Manager cleanup |

---

## PAGE PERMISSIONS - Can Access Page?

| Page ID | Page Name | Type | Teller | Manager | Expected Behavior |
|---------|-----------|------|--------|---------|-------------------|
| **50100** | Member Application List | List | ✅ | ✅ | Filter list, view records |
| **50101** | Member Application Card | Card | ✅ | ✅ | View/edit application data |
| **50102** | Member List | List | ✅ | ✅ | Search members |
| **50103** | Member Card | Card | ✅ | ✅ | View/edit member info |
| **50104** | Member Category List | Setup | ❌ | ✅ | **TELLER BLOCKED** |
| **50105** | Member Category Card | Setup | ❌ | ✅ | **TELLER BLOCKED** |
| **50106** | Member Setup Card | Setup | ❌ | ✅ | **TELLER BLOCKED** - Config only |
| **50107** | Loan Application List | List | ✅ | ✅ | View loan requests |
| **50108** | Loan Application Card | Card | ✅ | ✅ | View/update loan application |
| **50109** | Loan Ledger Entries | List | ✅ (ro) | ✅ | View transactions only |
| **50110** | Member Edit Card | Card | ✅ | ✅ | Targeted member edit |
| **50111** | Email Preview | Setup | ❌ | ✅ | **TELLER BLOCKED** - Email config |
| **50112** | Occupation List | Setup | ✅ (ro) | ✅ | Teller views, Manager edits |
| **50113** | Occupation Card | Setup | ✅ (ro) | ✅ | Teller views, Manager edits |
| **50114** | SMS Log List | List | ✅ | ✅ | View SMS history |
| **50115** | Member Dashboard | Dashboard | ✅ | ✅ | Analytics/metrics view |
| **50116** | Member Loans Part | FactBox | ✅ | ✅ | Loan summary widget |
| **50117** | Members API | API | ❌ | ✅ | **TELLER BLOCKED** - External access |

---

## OPERATIONAL WORKFLOWS - Can Perform Process?

### Member Application Workflow

| Step | Action | Teller | Manager | Notes |
|------|--------|---------|---------|-------|
| 1 | **Enter new member application** | ✅ | ✅ | Fill form on page 50101 (Member Application Card) |
| 2 | **View pending applications** | ✅ | ✅ | List page 50100 |
| 3 | **Request clarification** (Update Status) | ✅ | ✅ | Change status field |
| 4 | **Approve application** | ❌ BLOCKED | ✅ | Codeunit 50100 runs business logic |
| 5 | **Reject application** | ❌ BLOCKED | ✅ | Manager action, sends email |
| 6 | **Delete rejected app** | ❌ BLOCKED | ✅ | Cleanup historical data |
| 7 | **Transfer approved app to Member table** | ⚠️ Auto | ⚠️ Auto | Codeunit 50100 (no permission needed) |

**Test Cases:**
- ✅ **TC-M-001:** Teller creates member app, Manager approves → New member created in table 50101
- ✅ **TC-T-001:** Teller approves app → Permission error displayed
- ✅ **TC-M-002:** Manager deletes rejected app → Record removed, audit trail preserved

---

### Loan Application Workflow

| Step | Action | Teller | Manager | Notes |
|------|--------|---------|---------|-------|
| 1 | **Member applies for loan** | ✅ | ✅ | Create record on page 50108 |
| 2 | **View pending loans** | ✅ | ✅ | List page 50107 |
| 3 | **Update loan details** (amount, term) | ✅ | ✅ | Modify card fields |
| 4 | **Approve loan** | ❌ BLOCKED | ✅ | Creates entries in Loan Ledger |
| 5 | **Reject loan request** | ❌ BLOCKED | ✅ | Update status, send notification |
| 6 | **Delete rejected loan app** | ❌ BLOCKED | ✅ | Cleanup |
| 7 | **Disburse loan** | ❌ BLOCKED | ✅ | Create ledger entry (code calls) |

**Test Cases:**
- ✅ **TC-M-003:** Manager approves loan → Ledger entries created in table 50105
- ✅ **TC-T-002:** Teller clicks "Approve" button → Action greyed out OR permission error
- ✅ **TC-M-004:** Manager rejects loan → Status set to "Rejected", email notification sent

---

### Setup & Configuration Workflow

| Step | Action | Teller | Manager | Notes |
|------|--------|---------|---------|-------|
| 1 | **Create new occupation** | ❌ BLOCKED | ✅ | Page 50113 (Occupation Card) |
| 2 | **View occupations** | ✅ (ro) | ✅ | Dropdown in member form |
| 3 | **Edit occupation description** | ❌ BLOCKED | ✅ | Manager-only setup |
| 4 | **Create member category** | ❌ BLOCKED | ✅ | Page 50105 (Category Card) |
| 5 | **View categories** | ✅ (ro) | ✅ | Dropdown in member form |
| 6 | **Edit welcome email template** | ❌ BLOCKED | ✅ | Page 50111 (Email Preview) |
| 7 | **Configure SMS sender ID** | ❌ BLOCKED | ✅ | Member Setup page 50106 |

**Test Cases:**
- ✅ **TC-T-003:** Teller opens page 50106 (Setup) → "Page not found" or permission error
- ✅ **TC-M-005:** Manager creates new occupation → Record added to table 50111
- ✅ **TC-T-004:** Teller navigates to Occupation dropdown → Values populated (read access OK)

---

## SECURITY TEST SCENARIOS

### Scenario 1: Teller Attempts Unauthorized Approval
**Precondition:** Teller user assigned CORETEC-TELLER permission set

**Steps:**
1. Open Loan Application page 50108 with pending loan
2. Click "Approve" button/action
3. Attempt to change loan status to "Approved"

**Expected Results:**
- ❌ Button should be greyed out OR show permission error
- ❌ Status field cannot be changed (code should validate)
- ❌ No ledger entries created (codeunit blocked from execution)
- ✅ Log entry: "User [TELLER-USER] attempted unauthorized approval"

**Pass Criteria:** User receives clear permission error, no state changed.

---

### Scenario 2: Manager Creates Setup Entry
**Precondition:** Manager user assigned CORETEC-MANAGER permission set

**Steps:**
1. Open Member Setup page 50106
2. Create new setup record (e.g., welcome email template)
3. Save changes

**Expected Results:**
- ✅ Page accessible
- ✅ New record created in table 50104
- ✅ Changes applied to system configuration
- ✅ Audit log records action

**Pass Criteria:** Setup changes propagate correctly, tellers see new config in dropdowns.

---

### Scenario 3: Teller Cannot Delete Member Records
**Precondition:** Teller user assigned CORETEC-TELLER permission set

**Steps:**
1. Open Member List page 50102
2. Select a member record
3. Attempt to delete (via Delete key or action)

**Expected Results:**
- ❌ Delete action/button not available
- ❌ Delete key (press Delete) shows permission error
- ❌ Record NOT deleted
- ✅ Error message: "You do not have permission to delete from Member"

**Pass Criteria:** Record preserved, teller blocked from delete.

---

### Scenario 4: Manager Deletes Rejected Application
**Precondition:** Manager user assigned CORETEC-MANAGER permission set

**Steps:**
1. Open Member Application List page 50100
2. Find rejected application (Status = "Rejected")
3. Delete the record

**Expected Results:**
- ✅ Delete action available
- ✅ Confirmation dialog shown (optional)
- ✅ Record deleted from table 50100
- ✅ Audit log records action + timestamp + manager name

**Pass Criteria:** Record successfully removed, audit trail maintained.

---

### Scenario 5: Cross-Page Boundary Test
**Precondition:** Teller user assigned CORETEC-TELLER permission set

**Steps:**
1. Open any page accessible to Teller (e.g., Member List 50102)
2. Try to navigate to Member Category page 50104 (Setup page)
3. Try to access directly via URL: `https://localhost:7049/bc/run?page=50104`

**Expected Results:**
- ❌ Navigation blocked
- ❌ Direct URL access shows "Access Denied"
- ❌ No permission escalation possible through URL tricks

**Pass Criteria:** All navigation paths blocked for unauthorized pages.

---

## TEST EXECUTION PLAN

### Phase 1: Setup (Preparation)
- [ ] Create test users in Business Central sandbox:
  - `testuser.teller@coretec.local` → Assign CORETEC-TELLER
  - `testuser.manager@coretec.local` → Assign CORETEC-MANAGER
  - `testuser.admin@coretec.local` → Assign SUPER (baseline)
- [ ] Build and deploy AL code (permission sets)
- [ ] Prepare test data (mock member, application, loan records)

### Phase 2: Functional Testing (Per Role)
- [ ] Teller smoke tests: Can access pages 50102, 50107, 50110
- [ ] Manager smoke tests: Can access all setup pages
- [ ] Test create/read/update/delete per table (matrix above)

### Phase 3: Security Testing (Boundary Scenarios)
- [ ] Run Scenario 1-5 (see above)
- [ ] Attempt privilege escalation (URL manipulation, direct table access)
- [ ] Test concurrent operations (two users, overlapping records)

### Phase 4: Audit/Logging
- [ ] Verify failed permission attempts are logged
- [ ] Confirm approval actions logged with actor info
- [ ] Check audit trail timestamps accuracy

### Phase 5: Sign-Off
- [ ] Document findings
- [ ] Get Manager/Admin approval
- [ ] Archive test evidence

---

## PERMISSION SET ASSIGNMENT INSTRUCTIONS

### In Business Central (Admin Console)

1. **Assign TELLER role:**
   ```
   Users → Select user → Role Memberships
   + Add → Select CORETEC-TELLER
   → Next → Finish
   ```

2. **Assign MANAGER role:**
   ```
   Users → Select user → Role Memberships
   + Add → Select CORETEC-MANAGER
   → Next → Finish
   ```

3. **Verify assignment:**
   ```
   Users → Select user → View Permissions
   → Should show tables/pages accessible
   ```

---

## TROUBLESHOOTING PERMISSION ISSUES

| Issue | Cause | Solution |
|-------|-------|----------|
| Pages not visible after assignment | Permission set not deployed | Run `al_publish` to deploy .al files |
| Teller can delete | RIMD includes Delete (D) | Fix: Change to RIM (remove D) |
| Manager cannot access Setup | Page not in permission set | Add page to permissionset object |
| Permission error on read | Table access = R not granted | Add READ to permission (R flag) |
| Dropdown empty (no values) | Child table permission denied | Grant READ on child table |

---

## DELIVERABLES CHECKLIST

- ✅ Two permission set objects created:
  - `PermSet50130.TellerRole.al` (50130 - CORETEC-TELLER)
  - `PermSet50131.ManagerRole.al` (50131 - CORETEC-MANAGER)
- ✅ Test matrix (this document) with:
  - Action × Role access grid
  - 5 security test scenarios
  - Test execution plan
  - Troubleshooting guide
- 📋 Ready for:
  - Deployment via `al_publish`
  - User assignment in Business Central
  - Test execution in sandbox
  - Security compliance review

---

## GOVERNANCE NOTES

- **Least Privilege Principle:** Tellers have minimum permissions for job function
- **Separation of Duties:** Tellers cannot approve their own applications
- **Audit Trail:** All manager actions (deletes, approvals) logged
- **Configuration Control:** Only managers can modify setup
- **API Access:** Limited to Manager role (external system integration)

---

**Document Version:** 1.0  
**Last Updated:** April 2026  
**Prepared By:** CORETEC Training System  
**Status:** Ready for Testing
