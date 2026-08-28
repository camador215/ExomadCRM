pageextension 80106 "Opportunity Entries Ext" extends "Opportunity Entries"
{
    layout
    {
        addbefore("Estimated Value (LCY)")
        {
            field("Cod. Divisa"; Rec."Currency Code")
            {
                ApplicationArea = All;
                ToolTip = 'Divisa en la que se negocia esta Oportunidad de Venta.';
            }
            field("Estimated Value (ACY)"; Rec."Estimated Value (ACY)")
            {
                ApplicationArea = All;
                ToolTip = 'Especifica el valor estimado de la oportunidad.';
            }
        }
        addbefore("Calcd. Current Value (LCY)")
        {
            field("Calcd. Current Value (ACY)"; Rec."Calcd. Current Value (ACY)")
            {
                ApplicationArea = All;
                ToolTip = 'Especifica el valor calculado actual de la oportunidad.';
            }
        }

        modify("Estimated Value (LCY)")
        {
            Visible = false;
        }
        modify("Calcd. Current Value (LCY)")
        {
            Visible = false;
        }
    }
}