pageextension 80105 "DIMA Opportunity List Ext" extends "Opportunity List"
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

        modify("Estimated Value (LCY)")
        {
            Visible = false;
        }
    }
}