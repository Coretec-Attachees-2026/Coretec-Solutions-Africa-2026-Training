permissionset 50101 "MEMBER API READ"
{
    Assignable = true;
    Caption = 'SACCO Member API Read';

    Permissions =
        tabledata "Member" = R;
}
