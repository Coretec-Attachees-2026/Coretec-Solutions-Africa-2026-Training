# Email Setup Guide - SACCO Member Management System

## Overview
The SACCO Member Management system sends welcome emails to members when their application is approved. This guide explains how to configure Email Accounts in Business Central so these emails are sent successfully.

---

## Email Workflow

When an administrator approves a member application, the system automatically:
1. ✅ Creates the member record
2. ✅ Generates a Member ID
3. 📧 **Attempts to send a welcome email** (if Email Account is configured)

---

## Step 1: Access Email Accounts in Business Central

1. **Open Business Central** and login with administrator credentials
2. **Search for "Email Accounts"** (use the search bar at the top)
3. You'll see the Email Accounts page

---

## Step 2: Add an Email Account

Click **"New"** to create a new email account. You have **THREE OPTIONS**:

### Option 1: SMTP (Recommended for Most Organizations)
- **Use when**: You have a corporate email server or want to use services like Gmail, SendGrid, etc.
- **Setup Steps**:
  1. Account Type: Select **"SMTP"**
  2. Name: Give it a descriptive name (e.g., "SACCO Default Account")
  3. Server Address: Enter your SMTP server (e.g., `smtp.gmail.com`, `smtp.sendgrid.net`)
  4. Port: Enter the port number:
     - **587** for TLS (most common)
     - **465** for SSL
  5. Username: Your email address
  6. Password: Your email password (or app-specific password for Gmail/Office 365)
  7. Sender Email: The email address to send from
  8. Sender Name: Display name (e.g., "SACCO Member Services")

**Example for Gmail:**
- Server: `smtp.gmail.com`
- Port: `587`
- Username: `your-email@gmail.com`
- Password: Use an [App Password](https://support.google.com/accounts/answer/185833) (NOT your regular password)

### Option 2: Microsoft 365 (Best if using Office 365)
- **Use when**: Your organization uses Office 365/Microsoft 365
- **Setup Steps**:
  1. Account Type: Select **"Microsoft 365"**
  2. Name: Give it a descriptive name
  3. Click **"Sign In"** and authenticate with your Microsoft account
  4. Grant permission for the application to send emails
  5. Done! BC will automatically use your Microsoft 365 email

### Option 3: Current User
- **Use when**: You want to use the Windows user's email account
- **Setup Steps**:
  1. Account Type: Select **"Current User"**
  2. Name: Give it a descriptive name
  3. Configure Windows authentication (consult your IT department)

---

## Step 3: Test Your Email Account

After entering credentials:

1. Click **"Test"** button to verify the setup
2. You'll receive a test email at your registered email address
3. If successful, you'll see a confirmation message
4. If it fails, check:
   - Email address is correct
   - Password is correct (or app password for Gmail)
   - Port number is correct
   - Server address is accessible from your network
   - Firewall isn't blocking the SMTP port

---

## Step 4: Make it the Default Account (Optional)

If you create multiple email accounts, you can set one as the default:

1. Select the account you want as default
2. Check the **"Default"** checkbox
3. Click **"OK"**

The system will use this account for all emails (including member welcome emails).

---

## What Happens During Member Approval

### With Email Account Configured ✅
When an admin approves a member application:
1. **Member is created** with the application data
2. **Welcome email is sent** to the member's email address
3. **Success message** confirms both member creation and email sending

**Welcome Email Contains:**
- Member's name
- Unique Member ID (e.g., MEM-20260303-0001)
- Instructions to access account and apply for loans
- Professional greeting from SACCO Team

### Without Email Account Configured ⚠️
When an admin approves a member application:
1. **Member is still created** ✅ (this is NOT blocked)
2. **Email is NOT sent** ❌
3. **Friendly message** appears: 
   > "Member created successfully, but the welcome email could not be sent. 
   > Please ensure an Email Account is configured."

---

## Troubleshooting Common Issues

| Issue | Solution |
|-------|----------|
| **"Test email failed"** | Check SMTP credentials, server address, and port number. Verify firewall isn't blocking the port. |
| **"Email not sent after member approval"** | Go back to Email Accounts and verify at least one account is configured. Test it again. |
| **"Gmail says 'insecure app blocked'"** | Use an [App Password](https://support.google.com/accounts/answer/185833) instead of your regular password. |
| **"Office 365 authentication failed"** | Try signing in again using the "Sign In" button. You may need to use an admin account. |
| **"Port 587 doesn't work"** | Some networks block this port. Try **Port 25** or **Port 465** instead. Contact your IT department. |
| **"Email sends but member doesn't receive it"** | Check spam folder. Verify sender email address is correct. |
| **"Want to change which email sends the emails"** | Go to Email Accounts, mark a different account as "Default". |

---

## User Workflow - Member Application to Welcome Email

### Step 1: Create a New Member Application
1. Open **Member Application List**
2. Click **"New"**
3. Fill in applicant details (Name, Email, Phone, Address, etc.)
4. Click **"OK"** to save
5. Application is now in **"Pending"** status

### Step 2: Approve the Application
1. Open the pending application
2. Click the **"Approve"** action button
3. System processes:
   - ✅ Changes status to "Approved"
   - ✅ Creates member record with unique Member ID
   - 📧 Sends welcome email (if configured)
4. Success message appears

### Step 3: Member Receives Welcome Email (if configured)
1. Member receives email with:
   - Welcome greeting
   - Assigned Member ID
   - Instructions to access account
2. Member can now:
   - Access the Member portal
   - Apply for loans
   - View their account balance

---

## Best Practices

✅ **DO:**
- Test your email account regularly
- Use a dedicated email account (don't use personal email if possible)
- Keep email credentials secure
- Monitor email for bounce-backs or delivery failures
- Use Microsoft 365 if your org uses Office 365 (better integration)

❌ **DON'T:**
- Share email account credentials
- Use temporary/disposable email accounts
- Store passwords in plain text
- Configure firewall to block SMTP ports without reason
- Ignore failed email notifications

---

## Email Account Security

- **Credentials are encrypted** in Business Central's secure storage
- **Only admins** can configure email accounts
- **Each user's sent emails** are logged for audit purposes
- **Never share** email account passwords via email or chat

---

## Advanced: Using Email.Enqueue() vs Email.Send()

The system currently uses **Email.Send()** which sends emails immediately. For high-volume scenarios, you can request Email.Enqueue() which:

- **Sends in background** (doesn't block the approval)
- **Better for batch imports** of multiple members
- **Automatic retry** if email fails initially

Contact your developer to make this change if needed.

---

## Reference

- **Email Setup Location**: Search "Email Accounts" in Business Central
- **Affected Feature**: Member Application Approval
- **Email Template**: Defined in `Codeunit 50100 - Member Management`
- **Documentation**: See `SendWelcomeEmailToMember` procedure in the Member Management codeunit

---

**Still having issues?** Contact your Business Central Administrator or check your email provider's SMTP documentation.
