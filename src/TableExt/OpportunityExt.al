tableextension 80103 "DIMA Opportunity Ext" extends Opportunity
{
    fields
    {
        field(80100; "Currency Code"; Code[10])
        {
            Caption = 'Cod. Divisa';
            ToolTip = 'Divisa en la que se negocia esta Oportunidad de Venta.';
            TableRelation = "Currency";
        }
        field(80101; "Estimated Value (ACY)"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            CalcFormula = sum("Opportunity Entry"."Estimated Value (LCY)" where("Opportunity No." = field("No."),
                                                                                 Active = const(true)));
            Caption = 'Valor estimado ($)';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    trigger OnDelete()
    var
        DeliveryLine: Record "DIMA Opportunity Delivery";
    begin
        DeliveryLine.SetRange("Opportunity No.", Rec."No.");
        DeliveryLine.DeleteAll();
    end;

    trigger OnInsert()
    var
        DIMASetup: Record "Marketing Setup";
    begin
        if DIMASetup.Get() then
            if "Currency Code" = '' then
                Validate("Currency Code", DIMASetup."Currency Code");
    end;
}