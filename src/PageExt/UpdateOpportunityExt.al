pageextension 80107 "Update Opportunity Ext" extends "Update Opportunity"
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
    }
}