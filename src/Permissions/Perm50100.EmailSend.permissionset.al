permissionset 50100 "SACCO EMAIL SEND"
{
    Assignable = true;
    Caption = 'SACCO Email Send';

    Permissions =
        tabledata "Sent Email" = RIMD,
        tabledata "Email Outbox" = RIMD,
        tabledata "Email Related Record" = RIMD,
        tabledata "Email Account" = R;
}
