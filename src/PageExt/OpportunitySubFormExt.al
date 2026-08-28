pageextension 80109 "Opportunity SubForm Ext" extends "Opportunity SubForm"
{
    layout
    {
        addafter("Estimated Value (LCY)")
        {
            field("Estimated Value (ACY)"; Rec."Estimated Value (ACY)")
            {
                ApplicationArea = All;
                Caption = 'Valor de ventas estimado ($)';
                ToolTip = 'Especifica el valor estimado del movimiento de la oportunidad.';
            }
        }
        modify("Estimated Value (LCY)")
        {
            Visible = false;
        }
        addafter("Calcd. Current Value (LCY)")
        {
            field("Calcd. Current Value (ACY)"; Rec."Calcd. Current Value (ACY)")
            {
                ApplicationArea = All;
                Caption = 'Valor actual calculado ($)';
                ToolTip = 'Especifica el valor actual calculado del movimiento de la oportunidad.';
            }
        }
        modify("Calcd. Current Value (LCY)")
        {
            Visible = false;
        }
    }
}