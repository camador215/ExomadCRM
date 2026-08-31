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
                if IsUpdatingCurrencyFields then
                    exit;

                IsUpdatingCurrencyFields := true;
                Validate(
                    "Estimated Value (LCY)",
                    ConvertCurrencyToCurrency(
                        "Estimated Value (ACY)",
                        'ACY2LCY'
                    )
                );
                IsUpdatingCurrencyFields := false;
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
                if IsUpdatingCurrencyFields then
                    exit;

                IsUpdatingCurrencyFields := true;
                Validate(
                    "Calcd. Current Value (LCY)",
                    ConvertCurrencyToCurrency(
                        "Calcd. Current Value (ACY)",
                        'ACY2LCY'
                    )
                );
                IsUpdatingCurrencyFields := false;
            end;
        }
        modify("Estimated Value (LCY)")
        {
            trigger OnAfterValidate()
            begin
                if IsUpdatingCurrencyFields then
                    exit;

                IsUpdatingCurrencyFields := true;
                Validate(
                    "Estimated Value (ACY)",
                    ConvertCurrencyToCurrency(
                        "Estimated Value (LCY)",
                        'LCY2ACY'
                    )
                );
                IsUpdatingCurrencyFields := false;
            end;
        }
        modify("Calcd. Current Value (LCY)")
        {
            trigger OnAfterValidate()
            begin
                if IsUpdatingCurrencyFields then
                    exit;

                IsUpdatingCurrencyFields := true;
                Validate(
                    "Calcd. Current Value (ACY)",
                    ConvertCurrencyToCurrency(
                        "Calcd. Current Value (LCY)",
                        'LCY2ACY'
                    )
                );
                IsUpdatingCurrencyFields := false;
            end;
        }
    }

    var

        IsUpdatingCurrencyFields: Boolean;

    local procedure ConvertCurrencyToCurrency(AmountACY: Decimal; Code: Code[10]): Decimal
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        Opportunity: Record Opportunity;
        CurrencyCode: Code[10];
        PostingDate: Date;
    begin
        if AmountACY = 0 then
            exit(0);

        if not Opportunity.Get("Opportunity No.") then
            Error(
                'No se encontró la oportunidad %1.',
                "Opportunity No.");

        CurrencyCode := Opportunity."Currency Code";

        // Si la oportunidad utiliza la moneda principal,
        // no es necesaria ninguna conversión.
        if CurrencyCode = '' then
            exit(AmountACY);

        // Fecha que se utilizará para buscar el tipo de cambio.
        PostingDate := WorkDate();

        // Conversión estándar de BC:
        // Divisa de la oportunidad -> LCY.
        if Code = 'ACY2LCY' then
            exit(
                    CurrencyExchangeRate.ExchangeAmtFCYToLCY(
                        PostingDate,
                        CurrencyCode,
                        AmountACY,
                        CurrencyExchangeRate.ExchangeRate(
                            PostingDate,
                            CurrencyCode)
                    )
                )
        else
            exit(
                    CurrencyExchangeRate.ExchangeAmtLCYToFCY(
                        PostingDate,
                        CurrencyCode,
                        AmountACY,
                        CurrencyExchangeRate.ExchangeRate(
                            PostingDate,
                            CurrencyCode)
                    )
                );

    end;
}