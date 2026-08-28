tableextension 80100 "DIMA Marketing Setup Ext" extends "Marketing Setup"
{
    fields
    {
        field(80100; "Currency Code"; Code[10])
        {
            Caption = 'Cod. Divisa';
            ToolTip = 'Divisa predefinida para las oportunidades de venta (CRM)';
            TableRelation = "Currency";
        }
    }
}