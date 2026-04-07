permissionset 50103 "Coretec Manager"
{
    Assignable = true;
    IncludedPermissionSets = "Coretec Teller";
    Permissions =
        tabledata "Member Setup" = RIMD,
        tabledata WelcomeEmailSetupTable = RIMD,
        tabledata RejectionEmailSetupTable = RIMD,
        page "Member Setup" = X,
        page WelcomeEmailSetupPage = X,
        page RejectionEmailSetupPage = X,
        tabledata "Loan Ledger Entry" = RIMD,
        page "MemberAPI" = X,
        page "Member Category List" = X,
        page "Loan Ledger Entries" = X,
        page "Loan Application List" = X,
        page "Loan Application Card" = X,
        codeunit "Member App No. Series Mgt" = X,
        codeunit "Loan No. Series Mgt" = X,
        codeunit "Approve Email" = X,
        codeunit "Member Management" = X,
        codeunit "Member Scheduled Export" = X,
        codeunit "Member Category Initialization" = X,
        XMLport "Export Member XMLport" = X,
        xmlport "Import Members XMLport" = X,
        Report "Member Report" = X,
        Report "Loan Summary by Member" = X;
}