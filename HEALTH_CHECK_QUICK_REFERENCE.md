# SACCO Health Check - Admin Quick Reference Guide

## How to Access the Health Check

### **Option 1: From Member Setup Page** (Recommended)
1. Search "Member Setup" in Business Central
2. Open the card
3. Click "SACCO Health Check" button in the toolbar
4. Health check page opens and automatically runs all checks

### **Option 2: Direct Search**
1. Search "SACCO Health Check" in Business Central
2. Page opens and runs all checks

---

## Understanding the Status Display

### **Status Symbols**
```
✓ PASS      ← Configuration is correct (Green)
⚠ WARNING   ← Optional config missing or needs attention (Amber)  
✗ CRITICAL  ← Blocking issue - system won't work (Red)
```

### **Overall System Status**
```
HEALTHY - System Ready
├─ All critical checks: PASS
├─ All operational checks: PASS
└─ Action: Ready to deploy and use

AT RISK - Check Warnings
├─ Critical checks: PASS
├─ Some warnings present: 1+ AMBER
└─ Action: Fix warnings for best performance

CRITICAL - Action Required
├─ Critical checks: 1+ CRITICAL failures
├─ System cannot function properly
└─ Action: Fix all RED items immediately
```

---

## Quick Fix Guide: By Check Type

### 🔴 RED CHECK - Requires Immediate Action

**If you see RED status**:

1. Read the "Recommendation" text - it tells you exactly what to fix
2. Click "Open Member Setup" button
3. Go to the recommended field
4. Fill in the missing value
5. Save the page
6. Return to Health Check page
7. Click "Refresh Health Checks" button
8. Status should change to GREEN

**Example**: "Member Application No. Series" is RED
```
Recommendation: "Open Member Setup → assign 'Member Application Nos.' value"

Steps:
1. Click "Open Member Setup"
2. Find the "Member Application" group
3. In "Member Application Nos." field, type or select: MEM-APP
4. Click Save
5. Go back to Health Check
6. Click Refresh
7. Check now shows ✓ PASS in green
```

---

### 🟡 AMBER CHECK - Optional or Recommended

**If you see AMBER status**:

- This is NOT blocking - system will still work
- But functionality is limited or degraded
- Configuration is optional but recommended

**Example**: "Rejection Email Subject" is AMBER
```
Recommendation: "Optional: Fill 'Rejection Email Subject' for custom emails"

This means:
- System will still WORK without this
- But rejection emails won't be personalized
- You can skip if rejections aren't needed
- Or fill it if you want branded emails
```

---

### ✅ GREEN CHECK - All Good

**If you see GREEN status**:
- This configuration is complete and correct
- No action needed
- Keep monitoring during maintenance

---

## The 9 Checks Explained Simply

### Check 1: Member Application No. Series
**What**: Is there a numbering pattern for member applications?  
**Why**: So app IDs are like MEM-APP-001, MEM-APP-002, etc.  
**If Missing**: Members can't apply (system can't assign IDs)  
**Fix Location**: Member Setup → "Member Application Nos."  
**Status**: 🔴 CRITICAL

### Check 2: Loan Application No. Series
**What**: Is there a numbering pattern for loan applications?  
**Why**: So loan IDs are like LOAN-001, LOAN-002, etc.  
**If Missing**: Loans can't be created (system can't assign IDs)  
**Fix Location**: Member Setup → Loan Settings → "Loan Application Nos."  
**Status**: 🔴 CRITICAL

### Check 3: Loans Receivable GL Account
**What**: Is there an accounting entry for money members owe?  
**Why**: Bookkeeping: Track "member debt" asset account  
**If Missing**: Loan ledger can't be posted (accounting broken)  
**Examples**: Account 1200 (Asset), 1210 (Member Loans)  
**Fix Location**: Member Setup → Loan Settings → "Loans Receivable Account"  
**Status**: 🔴 CRITICAL (or 🟡 AMBER if account doesn't exist)

### Check 4: Loan Disbursement GL Account
**What**: Is there an accounting entry for money going out?  
**Why**: Bookkeeping: Track disbursement from bank account  
**If Missing**: Loan disbursement can't be posted (accounting broken)  
**Examples**: Account 1000 (Bank), 1010 (Checking), 2000 (Cash)  
**Fix Location**: Member Setup → Loan Settings → "Loan Disbursement Account"  
**Status**: 🔴 CRITICAL (or 🟡 AMBER if account doesn't exist)

### Check 5: Member Categories
**What**: Is at least one member type defined?  
**Why**: Group members (REGULAR, BUSINESS, STUDENT, etc.)  
**If Missing**: Can't classify new members (signup fails)  
**Categories Needed**: At least 1 active category  
**Fix Location**: Search "Member Category Master" → Create categories  
**Status**: 🔴 CRITICAL

### Check 6: Email Account
**What**: Is an email configured to send member notifications?  
**Why**: Send welcome emails, rejection notices, loan approvals  
**If Missing**: Members won't get notifications (no communication)  
**Setup**: Search "Email Accounts" → New → Microsoft 365 recommended  
**Fix Location**: Business Central → Search "Email Accounts"  
**Status**: 🔴 CRITICAL

### Check 7: Rejection Email Subject
**What**: Custom subject line for rejection emails?  
**Why**: Personalize rejection notifications (optional)  
**If Missing**: Will use default generic subject  
**Example**: "Your SACCO Application Status" or "Application Decision"  
**Fix Location**: Member Setup → "Rejection Email Subject"  
**Status**: 🟡 OPTIONAL

### Check 8: Rejection Email Body
**What**: Custom HTML template for rejection emails?  
**Why**: Personalized rejection messages (optional)  
**If Missing**: Will use default template  
**Variables**: Can use {First Name}, {Application ID}, {Rejection Reason}  
**Fix Location**: Member Setup → "Rejection Email Body"  
**Status**: 🟡 OPTIONAL

### Check 9: AfricasTalking SMS API
**What**: Is SMS gateway configured for notifications?  
**Why**: Send SMS alerts to members (optional feature)  
**If Missing**: SMS won't work (but system still functions)  
**Setup Needed**: API Key + Username from Africa's Talking  
**Fix Location**: Member Setup → "AfricasTalking API Key" + "Username"  
**Status**: 🟡 OPTIONAL

---

## Flowchart: What to Do at Each Status

```
┌─ System Health Check Opened
│
├─ RED Items Present? ──→ YES ──→ SYSTEM BROKEN
│  │                              Go fix each RED item immediately
│  │                              Click "Refresh" after each fix
│  │                              Repeat until NO RED items
│  │
│  └─ NO
│      │
│      ├─ AMBER Items Present? ──→ YES ──→ SYSTEM AT RISK
│      │  │                             Optional features degraded
│      │  │                             Fix if possible for best UX
│      │  │                             Can continue if needed urgently
│      │  │
│      │  └─ NO
│      │      │
│      │      └─ ALL GREEN ──→ SYSTEM HEALTHY ✓
│                               Ready for production!
│                               Users can now use the system
```

---

## Common Questions (FAQ)

### Q: Can I use the system if I have RED checks?
**A**: NO. The system will not work properly with RED checks. You must fix all RED items first.

### Q: Can I ignore AMBER checks?
**A**: AMBER checks are optional. The system will work, but some features (emails, personalization) won't work. Fix them when you have time.

### Q: I fixed something but health check still shows RED
**A**: Click "Refresh Health Checks" button to re-run the checks. The check reads fresh data each time.

### Q: What if I don't have the GL accounts mentioned?
**A**: You need to create them in the Chart of Accounts first. Ask your accountant or finance person to add:
- One "Asset" account for Loans Receivable (e.g., 1200)
- One "Bank" or "Asset" account for Loan Disbursement (e.g., 1000)

Then enter those account numbers in Member Setup.

### Q: Why do I need 9 different checks?
**A**: Each check validates a critical piece of setup:
- No. Series ensure ID generation works
- GL accounts enable accounting
- Categories enable member classification  
- Email enables communication
- SMS enables notifications

### Q: Can I skip email setup if I'm not sending emails?
**A**: NO. Email is marked CRITICAL because member notifications are essential. Even if you don't need emails immediately, it must be configured to mark the check GREEN.

### Q: What about the optional checks (7, 8, 9)?
**A**: These are truly optional:
- #7-8: Email personalization (nice-to-have)
- #9: SMS (only if you use SMS feature)

System works fine with these AMBER. But it's better to configure them for full functionality.

---

## Quick Setup Checklist (First Time)

Use this checklist to get from RED to GREEN:

```
□ STEP 1: Go to Member Setup
  □ Assign Member Application Nos. (e.g., "MEM-APP")
  □ Assign Loan Application Nos. (e.g., "LOAN")
  
□ STEP 2: Go to Member Setup → Loan Settings
  □ Select Loans Receivable Account (e.g., 1200)
  □ Select Loan Disbursement Account (e.g., 1000)
  
□ STEP 3: Go to Member Category Master
  □ Create category: REGULAR
  □ Create category: BUSINESS
  □ Create category: STUDENT
  □ (Set all as Active = YES)
  
□ STEP 4: Search "Email Accounts"
  □ New → Microsoft 365
  □ Enter your email address
  □ Click Authenticate
  □ Sign in to your Microsoft account
  □ Save
  
□ STEP 5: Go to SACCO Health Check
  □ Click Refresh Health Checks
  □ All critical checks should now be GREEN
  □ Status: HEALTHY ✓
  
□ STEP 6: You're ready!
  □ Users can now access Member Application
  □ Loans functionality is ready
  □ Email notifications are active
```

---

## Support & Escalation

### **I'm stuck on a RED check**

**Ask yourself**:
- Did I follow the exact field name in the Recommendation?
- Did I enter the value correctly (e.g., account numbers exist)?
- Did I save the page?
- Did I click Refresh?

**If still stuck**:
- Note which check is RED
- Take a screenshot
- Contact your system administrator or developer
- Share the details

### **Multiple RED checks**

**Don't panic**! Work through them ONE AT A TIME:
1. Fix #1 first
2. Refresh
3. Then move to #2
4. Etc.

Each fix compounds, so status improves quickly from CRITICAL → AT RISK → HEALTHY

---

## Maintenance Schedule

### **First Time Setup** (Day 1)
- Run health check
- Fix all RED items
- Verify HEALTHY status
- Deploy to users

### **Weekly Maintenance** (Mondays)
- Run health check
- Verify status hasn't degraded
- If AMBER or RED appeared, investigate

### **Before Major Updates**
- Run health check
- Document current status
- Run after update
- Compare to pre-update

### **If System Issues**
- First thing: Run health check
- Check if any RED items appeared
- Often reveals the root cause!

---

## Visual Layout of Health Check Page

```
╔════════════════════════════════════════════════════════════════╗
║                  SACCO Health Check                            ║
╠════════════════════════════════════════════════════════════════╣
║                                                                ║
║  System Health Status                                          ║
║  ─────────────────────                                         ║
║  Overall Status:  AT RISK - Check Warnings                    ║ (Amber)
║  Last Check:      2026-04-15 14:22:10                         ║
║                                                                ║
╠════════════════════════════════════════════════════════════════╣
║
║  Configuration Checks
║  ───────────────────────────────────────────────────────────────
║  Check Name          │ Status    │ Details      │ Recommendation
║  ───────────────────────────────────────────────────────────────
║  Member App Series   │ ✓ PASS    │ MEM-APP      │ (none)
║  Loan App Series     │ ✓ PASS    │ LOAN         │ (none)
║  Receivable Account  │ ✓ PASS    │ 1200 (Assets)│ (none)
║  Disbursement Acct   │ ✓ PASS    │ 1000 (Bank)  │ (none)
║  Member Categories   │ ✓ PASS    │ 5 categories │ (none)
║  Email Account       │ ✓ PASS    │ sacco@xyz.com│ (none)
║  Reject Subject      │ ⚠ WARNING │ (empty)      │ Fill if needed
║  Reject Body         │ ⚠ WARNING │ (empty)      │ Fill if needed
║  SMS API             │ ⚠ WARNING │ (not config.)│ Fill if SMS used
║
╠════════════════════════════════════════════════════════════════╣
║
║  [Refresh] [Member Setup] [Categories] [Email Accounts]
║
╚════════════════════════════════════════════════════════════════╝
```

---

## Success Indicators

### ✅ You Know Setup is Complete When:
- Health Check page shows "HEALTHY - System Ready"
- All critical checks (1-6) are GREEN
- Overall status is GREEN (not AMBER)
- You can approve a member application
- Email is sent to the new member
- No error messages during key workflows

### ⚠ Warning Signs:
- Health Check shows CRITICAL
- Any RED checks visible
- Can't approve applications
- Emails aren't sending
- Error messages with "not configured"

---

## Related Pages & Information

**To Configure**: Open these pages to fix issues
- Member Setup (Page 50106)
- Member Category Master (Search "Member Categories")
- Email Accounts (Search "Email Accounts")
- Chart of Accounts (Search "G/L Account" - for GL numbers)

**For Help With**:
- No. Series: Search "No. Series"
- GL Accounts: Work with your accountant
- Email: IT department or Microsoft 365 admin

---

*Quick Reference Document*  
*Created: 2026-04-15*  
*For: SACCO System Administrators*  
