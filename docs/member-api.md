# Member API

This extension exposes a read-only Business Central API page for members:

- Publisher: `coretec`
- Group: `membership`
- Version: `v1.0`
- Entity set: `members`
- OData key: `SystemId`

## Safe fields exposed

The API currently exposes only these fields from the `Member` table:

- `id`
- `memberId`
- `applicationId`
- `fullName`
- `status`
- `registrationDate`
- `memberCategory`
- `city`
- `country`
- `occupationCode`

It intentionally does not expose email, phone number, date of birth, address, ID/passport number, income, or account balance.

## Base URL

Using the local launch profile in `.vscode/launch.json`, the base API URL pattern is:

`http://localhost:8080/BC260/api/coretec/membership/v1.0/companies({companyId})/members`

You can inspect metadata here:

`http://localhost:8080/BC260/api/coretec/membership/v1.0/$metadata`

## Sample GET

Replace `{companyId}` with the company GUID from your Business Central environment:

`GET http://localhost:8080/BC260/api/coretec/membership/v1.0/companies({companyId})/members`

Example with a select clause:

`GET http://localhost:8080/BC260/api/coretec/membership/v1.0/companies({companyId})/members?$select=id,memberId,fullName,status,registrationDate`

## How to test

1. Publish the extension.
2. Assign the `SACCO MEMBER API READ` permission set, or otherwise make sure the caller has read access to `Member` data.
3. Open the metadata URL in a browser or Postman.
4. Find the company ID:
   `GET http://localhost:8080/BC260/api/coretec/membership/v1.0/companies`
5. Call the members endpoint with that company ID.
6. Capture a screenshot of the successful JSON response for your deliverable.

## Authentication note

Your current launch profile uses `Windows` authentication on an on-prem environment. In Postman, use the same auth method your BC server is configured for, or test first in a browser that can already access the BC web client.
