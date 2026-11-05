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
        field(80101; "Sales Order No. Series"; Code[20])
        {
            Caption = 'Serie Número Pedido de Venta';
            ToolTip = 'Serie de números para los pedidos de venta generados a partir de oportunidades';
            TableRelation = "No. Series";
        }
    }
}