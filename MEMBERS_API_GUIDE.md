# Members API (OData) - Documentation

## Overview
The Members API provides read-only access to SACCO member data via OData protocol. This API is designed for external tools like Postman, Power BI, or third-party applications to safely retrieve member information.

---

## API Details

### Endpoint Base URL
```
https://[YOUR_BC_SERVER]/api/coretec/members/v1.0/members
```

**Components:**
- `[YOUR_BC_SERVER]` = Your Business Central server hostname (e.g., `mycompany.onmicrosoft.com` for cloud)
- `coretec` = API Publisher
- `members` = API Group
- `v1.0` = API Version
- `members` = Entity Set (collection of Member records)

---

## Available Fields (Exposed via API)

The following fields are safe to expose and are available in the API response:

| Field Name (JSON) | Field Name (AL) | Type | Description |
|---|---|---|---|
| `memberId` | Member ID | Code[20] | Unique member identifier |
| `fullName` | Full Name | Text[200] | Member's full name |
| `email` | Email | Text[100] | Email address |
| `phoneNumber` | Phone Number | Text[20] | Contact phone number |
| `status` | Status | Enum | Member status (Active, Inactive, Suspended, Closed) |
| `registrationDate` | Registration Date | DateTime | When the member joined |
| `memberCategory` | Member Category | Code[20] | Category code (e.g., REGULAR, STUDENT, BUSINESS) |
| `occupationCode` | Occupation Code | Code[20] | Member's occupation classification |

---

## Example Requests

### 1. Get All Active Members
```http
GET https://[YOUR_BC_SERVER]/api/coretec/members/v1.0/members?$filter=status eq 'Active'&$top=10
Authorization: Basic [Base64EncodedCredentials]
```

**Example using curl:**
```bash
curl -X GET "https://[YOUR_BC_SERVER]/api/coretec/members/v1.0/members?$filter=status%20eq%20%27Active%27" \
  -H "Authorization: Basic [Base64EncodedCredentials]" \
  -H "Content-Type: application/json"
```

### 2. Get Single Member by ID
```http
GET https://[YOUR_BC_SERVER]/api/coretec/members/v1.0/members('MEM-20260303-0001')
Authorization: Basic [Base64EncodedCredentials]
```

### 3. Get Members with Pagination
```http
GET https://[YOUR_BC_SERVER]/api/coretec/members/v1.0/members?$skip=0&$top=50&$orderby=registrationDate desc
Authorization: Basic [Base64EncodedCredentials]
```

### 4. Filter by Registration Date Range
```http
GET https://[YOUR_BC_SERVER]/api/coretec/members/v1.0/members?$filter=registrationDate ge 2026-01-01 and registrationDate le 2026-12-31
Authorization: Basic [Base64EncodedCredentials]
```

---

## Sample JSON Response

### Single Member (GET /api/coretec/members/v1.0/members('MEM-20260303-0001'))
```json
{
  "@odata.context": "https://[YOUR_BC_SERVER]/api/coretec/members/v1.0/$metadata#members/$entity",
  "@odata.etag": "W/\"JzQ0OzE5NjczODI1MzswOzA7IjA=\"",
  "memberId": "MEM-20260303-0001",
  "fullName": "John Doe",
  "email": "john.doe@example.com",
  "phoneNumber": "+254712345678",
  "status": "Active",
  "registrationDate": "2026-03-15T10:30:00.000Z",
  "memberCategory": "REGULAR",
  "occupationCode": "ENG"
}
```

### Collection (GET /api/coretec/members/v1.0/members?$top=2)
```json
{
  "@odata.context": "https://[YOUR_BC_SERVER]/api/coretec/members/v1.0/$metadata#members",
  "value": [
    {
      "memberId": "MEM-20260303-0001",
      "fullName": "John Doe",
      "email": "john.doe@example.com",
      "phoneNumber": "+254712345678",
      "status": "Active",
      "registrationDate": "2026-03-15T10:30:00.000Z",
      "memberCategory": "REGULAR",
      "occupationCode": "ENG"
    },
    {
      "memberId": "MEM-20260303-0002",
      "fullName": "Jane Smith",
      "email": "jane.smith@example.com",
      "phoneNumber": "+254701234567",
      "status": "Active",
      "registrationDate": "2026-03-16T14:20:00.000Z",
      "memberCategory": "REGULAR",
      "occupationCode": "ACC"
    }
  ]
}
```

---

## Security & Permissions

✅ **What This API Allows:**
- Read-only access to safe member data
- Filtering by Status, Category, and Date
- Sorting and pagination

❌ **What This API Prevents:**
- No modifications (Insert, Update, Delete)
- No access to sensitive fields:
  - Date of Birth
  - ID/Passport Number  
  - Annual Income
  - Account Balance (removed for privacy)
  - First/Last Names separately (only Full Name exposed)

**Authentication:**
- Use your Business Central API user credentials
- Encode as Base64 for HTTP Basic Authentication
- Recommended: Create a dedicated read-only API user in BC

---

## Testing with Postman

### Setup Steps:
1. **Create New Collection** in Postman
2. **Add Collection Variables:**
   - `bc_server` = https://[YOUR_BC_SERVER]
   - `api_user` = [Your BC API username]
   - `api_password` = [Your BC API password]

3. **Create Collection Auth** (Postman):
   - Go to Collection → Authorization tab
   - Type: Basic Auth
   - Username: `{{api_user}}`
   - Password: `{{api_password}}`

### Sample Postman Requests:

**Request 1: Get All Active Members**
```
Method: GET
URL: {{bc_server}}/api/coretec/members/v1.0/members?$filter=status eq 'Active'&$top=10
Headers:
  Content-Type: application/json
  Accept: application/json
```

**Request 2: Get Member by ID**
```
Method: GET
URL: {{bc_server}}/api/coretec/members/v1.0/members('MEM-20260303-0001')
Headers:
  Content-Type: application/json
```

---

## Common OData Query Parameters

| Parameter | Example | Purpose |
|---|---|---|
| `$filter` | `$filter=status eq 'Active'` | Filter records |
| `$top` | `$top=50` | Limit results (max 10,000) |
| `$skip` | `$skip=100` | Skip N records for pagination |
| `$orderby` | `$orderby=fullName asc` | Sort results |
| `$select` | `$select=memberId,fullName` | Select specific fields only |
| `$count` | `$count=true` | Include total record count |

---

## Error Responses

### 401 Unauthorized
```json
{
  "error": {
    "code": "AADSTS700016",
    "message": "Application with identifier 'xyz' was not found in the directory"
  }
}
```
**Fix:** Check credentials and ensure the API user is active.

### 404 Not Found
```json
{
  "error": {
    "code": "NotFound",
    "message": "No records found"
  }
}
```
**Fix:** Verify the member ID exists.

### 429 Too Many Requests
```json
{
  "error": {
    "code": "Throttled",
    "message": "Request rate limit exceeded"
  }
}
```
**Fix:** Implement request throttling (max recommended: 100 req/sec).

---

## Integration Examples

### Power BI
1. In Power BI Desktop: **Get Data → Web**
2. Enter URL: `https://[YOUR_BC_SERVER]/api/coretec/members/v1.0/members`
3. Click **Basic authentication**, enter BC credentials
4. Select the returned data and Load

### Excel
Use **Data → Get & Transform → From Web** with the API URL

### Third-Party Apps
Typically require:
- Base URL
- Username/Password
- (Optional) Custom headers or API key

---

## Page Object Details

**Page ID:** 50117  
**Page Name:** Members API  
**Type:** API  
**Publisher:** coretec  
**Group:** members  
**Version:** v1.0  
**Source Table:** Member (50101)  
**Permissions:** Read-only (No Insert/Update/Delete)  

---

## Support & Limitation Notes

- API responses limited to 10,000 records per call (use `$top` and `$skip` for pagination)
- Concurrent connection limit: 50 per user
- Recommended batch size: 500 records for ETL operations
- For large data pulls, consider off-peak hours
- API is read-only and cannot create/modify member records

---

**Last Updated:** March 31, 2026  
**API Version:** 1.0  
**Status:** Ready for Testing
