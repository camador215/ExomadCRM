pageextension 80102 "DIMA Marketing Setup Ext" extends "Marketing Setup"
{
    layout
    {
        addFirst(Default)
        {
            group("DIMA Opportunity Setup")
            {
                ShowCaption = false;
                field("Currency Code"; Rec."Currency Code")
                {
                    Caption = 'Cod. Divisa Oportunidad';
                    Description = 'Código de moneda predeterminado al crear una nueva oportunidad.';
                    ApplicationArea = All;
                }
            }
        }
        addLast(Numbering)
        {
            group("DIMA Sales Order from Opportunity Setup")
            {
                ShowCaption = false;
                field("Sales Order No. Series"; Rec."Sales Order No. Series")
                {
                    Caption = 'Serie Número Pedido de Venta';
                    Description = 'Serie de números para los pedidos de venta generados a partir de oportunidades.';
                    ApplicationArea = All;
                }
            }
        }
    }
}