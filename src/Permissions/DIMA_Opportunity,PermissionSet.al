permissionset 80103 "DIMA OPPORTUNITY"
{
    Assignable = true;
    Caption = 'DIMA Opportunity';

    Permissions =
        tabledata "DIMA Opportunity Broker" = RIMD,
        tabledata "DIMA Opportunity Delivery" = RIMD;
}