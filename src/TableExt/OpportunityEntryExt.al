tableextension 80102 "Opportunity Entry Ext" extends "Opportunity Entry"
{
    fields
    {
        field(80101; "Currency Code"; Code[10])
        {
            Caption = 'Cod. Divisa';
            ToolTip = 'Divisa en la que se negocia esta Oportunidad de Venta.';
            TableRelation = "Currency";
        }
        field(80102; "Estimated Value (ACY)"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Valor estimado ($)';
            ToolTip = 'Especifica el valor estimado del movimiento de la oportunidad.';
            trigger OnValidate()
            begin
                Validate("Estimated Value (LCY)", "Estimated Value (ACY)");
            end;
        }
        field(80103; "Calcd. Current Value (ACY)"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Valor actual calculado ($)';
            ToolTip = 'Especifica el valor actual calculado del movimiento de la oportunidad.';
            trigger OnValidate()
            begin
                Validate("Calcd. Current Value (LCY)", "Calcd. Current Value (ACY)");
            end;
        }
    }
}