# Members API - Quick Testing & Setup Guide

## Overview
This guide walks you through testing the read-only Members API (OData) using your local Business Central server.

---

## Your Local Environment Setup

**BC Server Details (from launch.json):**
- **Server URL:** `http://localhost:8080/BC260`
- **Server Instance:** `BC260`
- **Authentication Type:** Windows
- **Port:** 7049
- **Tenant:** `default`

---

## Quick Start Testing Steps

### Step 1: Deploy the API Page
Before testing, the API page needs to be published to your BC server:

```powershell
# In VS Code Terminal:
# Option 1: Publish with Debugging
al_publish debug=true

# Option 2: Publish without Debugging  
al_publish skipbuild=false debug=false
```

This deploys the Members API page (Pag50117) to your local BC instance.

---

### Step 2: Test the API Metadata

The simplest way to verify the API exists is to check the OData metadata:

**URL:**
```
http://localhost:8080/BC260/api/coretec/members/v1.0/$metadata
```

Open this in your browser (or Postman). If successful, you should see an XML document describing the API structure.

---

### Step 3: Test with Postman

#### Import the Collection:
1. Open **Postman**
2. Click **Import** (top left)
3. Select **File** tab
4. Navigate to: `Members_API_Postman_Collection.json` (in your workspace root)
5. Click **Import**

#### Configure Postman Variables:
1. In Postman, click the **Members API** collection
2. Go to **Variables** tab
3. Set your local environment variables:
   - `base_url` = `http://localhost:8080/BC260`
   - `username` = Your Windows username (or BC admin user)
   - `password` = Your Windows password (or BC admin password)
4. Click **Save**

#### Run Your First Request:
1. Select the request: **"Get All Members (First 10)"**
2. Click **Send**
3. Check the response in the **Body** tab

**Expected Response Format:**
```json
{
  "@odata.context": "http://localhost:8080/BC260/api/coretec/members/v1.0/$metadata#members",
  "value": [
    {
      "memberId": "MEM-20260303-0001",
      "fullName": "John Doe",
      "email": "john.doe@example.com",
      "phoneNumber": "+254712345678",
      "status": "Active",
      "registrationDate": "2026-03-15T10:30:00Z",
      "memberCategory": "REGULAR",
      "occupationCode": "ENG"
    }
    // ... more records
  ]
}
```

---

### Step 4: Test Various Queries

#### Test 1: Get Active Members Only
```
Request: GET All Active Members
Expected: Returns only members with status = 'Active'
```

#### Test 2: Filter by Member Category
```
Request: Get Members by Category
Expected: Returns only 'REGULAR' category members
```

#### Test 3: Single Member Lookup
```
Request: Get Single Member by ID
Expected: Returns one member record matching the ID
```

#### Test 4: Pagination
```
Request: Get Members with Pagination
Expected: Returns 50 records, sorted by registration date
```

---

## Access the API Metadata URL

To verify the API is registered and explore its structure:

```
http://localhost:8080/BC260/api/coretec/members/v1.0/$metadata
```

This returns XML describing:
- Available entity sets (`members`)
- Fields and their types
- Navigation properties
- Constraints

---

## Troubleshooting

### Error: "404 Not Found"
**Cause:** API page not deployed or URL is incorrect  
**Fix:** 
1. Run `al_publish` to deploy the page
2. Wait 10-15 seconds for the service to refresh
3. Verify URL matches exactly: `http://localhost:8080/BC260/api/coretec/members/v1.0/members`

### Error: "401 Unauthorized"
**Cause:** Authentication failed  
**Fix:**
1. In Postman, verify your Windows credentials in the **Auth** tab
2. Ensure the user has API access permissions in BC
3. Try Windows Authentication instead of Basic

### Error: "400 Bad Request"
**Cause:** Invalid OData query syntax  
**Fix:**
1. Check the `$filter` syntax (should be: `status eq 'Active'`)
2. Verify date format: `2026-03-01`
3. Check for URL encoding issues

### No Data Returned
**Cause:** Members table might be empty  
**Fix:**
1. First create some member test records in BC:
   - Go to **Coretec Solutions → Members**
   - Manually add a few test members
   - Or use the Member Application approval workflow

### API Not Appearing in Metadata
**Cause:** Rebuild hasn't completed yet  
**Fix:**
1. Run `al_build` to recompile
2. Run `al_publish` to redeploy
3. Wait 30 seconds and try again
4. Check BC server logs for deployment errors

---

## Using curl (Command Line)

If you prefer testing via PowerShell/cmd instead of Postman:

```powershell
$url = "http://localhost:8080/BC260/api/coretec/members/v1.0/members?`$top=10"
$headers = @{
    "Content-Type" = "application/json"
}
$auth = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("$($env:USERNAME):$($env:USERDOMAIN)"))

$response = Invoke-RestMethod -Uri $url -Method Get -Headers $headers -Authentication Basic -Credential (Get-Credential)
$response | ConvertTo-Json | Write-Host
```

---

## PowerBi Integration

To connect Power BI to the Members API:

1. **Open Power BI Desktop**
2. Go to **Home → Get Data → Web**
3. **Enter URL:**
   ```
   http://localhost:8080/BC260/api/coretec/members/v1.0/members?$top=10000
   ```
4. **Click OK**
5. **Select Authentication:** Windows or Basic (with your BC credentials)
6. **Click Connect**
7. **Load** the data and start building reports

---

## Important Notes

📌 **Read-Only API**
- This API does NOT allow create, update, or delete operations
- All requests are GET only
- Modifications must be done in BC directly

📌 **Performance Optimization**
- Maximum records per request: 10,000
- For large exports, use pagination (`$skip` and `$top`)
- Recommended batch size: 1,000-2,000 records

📌 **Security**
- Sensitive fields are deliberately hidden
- Only "safe to share" member data is exposed
- Use dedicated read-only API users for integrations

📌 **Field Exposure**
- **Exposed:** Member ID, Full Name, Email, Phone, Status, Registration Date, Category
- **Hidden:** Date of Birth, ID Number, Annual Income, Account Balance

---

## Next Steps

1. ✅ Deploy API to BC (run `al_publish`)
2. ✅ Test with Postman collection provided
3. ✅ Verify OData metadata URL works
4. ✅ Test filtering and sorting queries
5. ✅ Document API responses (check screenshot below)
6. ✅ Share API base URL with external consumers

---

## API Endpoint Summary

| Operation | Method | URL Pattern |
|---|---|---|
| List all members | GET | `/api/coretec/members/v1.0/members` |
| Get by ID | GET | `/api/coretec/members/v1.0/members('MEMBER_ID')` |
| Filter active | GET | `/api/coretec/members/v1.0/members?$filter=status eq 'Active'` |
| Pagination | GET | `/api/coretec/members/v1.0/members?$skip=100&$top=50` |
| Sort | GET | `/api/coretec/members/v1.0/members?$orderby=registrationDate desc` |
| Count | GET | `/api/coretec/members/v1.0/members?$count=true` |
| Metadata | GET | `/api/coretec/members/v1.0/$metadata` |

---

## Files Created

- **Pag50117.MembersAPI.al** — API page source code
- **MEMBERS_API_GUIDE.md** — Full API documentation
- **Members_API_Postman_Collection.json** — Ready-to-import Postman collection
- **MEMBERS_API_TESTING_GUIDE.md** — This file

---

**Status:** ✅ API created, built successfully, ready for deployment and testing  
**Last Updated:** March 31, 2026
