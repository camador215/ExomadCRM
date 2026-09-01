table 80102 "DIMA Opportunity Delivery"
{
    Caption = 'Cronograma de Suministro';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Opportunity No."; Code[20])
        {
            Caption = 'N.º oportunidad';
        }

        field(2; "Line No."; Integer)
        {
            Caption = 'N.º línea';
        }

        field(10; "Nro. Producto"; Code[20])
        {
            Caption = 'Producto';
            TableRelation = Item."No."
            where("Base Unit of Measure" = filter('CORCS|CORC|VCS|VCU|CER'));

            trigger OnValidate()
            var
                Item: Record Item;
            begin
                Descripcion := '';
                "Unidad Medida" := '';

                if "Nro. Producto" = '' then
                    exit;

                if Item.Get("Nro. Producto") then begin
                    Descripcion := Item.Description;
                    "Unidad Medida" := Item."Sales Unit of Measure";
                end;
            end;
        }

        field(11; Descripcion; Text[100])
        {
            Caption = 'Descripción';
        }

        field(20; Cantidad; Decimal)
        {
            Caption = 'Cantidad';

            // ============================================================
            // CAMBIO:
            // La cantidad ahora solamente permite números enteros.
            //
            // 0 : 0 significa:
            //   - 0 decimales mínimos
            //   - 0 decimales máximos
            //
            // Ejemplos válidos:
            //   1
            //   10
            //   100
            //   1210000
            //
            // Ejemplos que ya no se permitirán:
            //   1.5
            //   10.25
            //   100.50
            // ============================================================
            DecimalPlaces = 0 : 0;

            trigger OnValidate()
            begin
                // ========================================================
                // VALIDACIÓN:
                // La cantidad debe ser mayor a cero.
                // ========================================================
                if Cantidad <= 0 then
                    Error('La cantidad debe ser mayor a cero.');

                // ========================================================
                // CAMBIO:
                // Se mantiene el cálculo del importe.
                //
                // Como Cantidad ahora es entera, el cálculo será:
                //
                // Cantidad × Precio Unitario = Importe
                // ========================================================
                CalculateAmount();
            end;
        }

        field(21; "Unidad Medida"; Code[10])
        {
            Caption = 'Unidad de medida';

            TableRelation = "Item Unit of Measure".Code
                where("Item No." = field("Nro. Producto"));
        }

        field(30; "Precio Unitario"; Decimal)
        {
            Caption = 'Precio unitario';

            // ============================================================
            // SIN CAMBIO:
            // El precio unitario continúa permitiendo hasta 5 decimales.
            //
            // Ejemplos:
            //   123
            //   123.50
            //   123.45678
            // ============================================================
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                if "Precio Unitario" <= 0 then
                    Error('El precio unitario debe ser mayor a cero.');

                CalculateAmount();
            end;
        }

        field(31; Importe; Decimal)
        {
            Caption = 'Importe';
            DecimalPlaces = 0 : 2;
            Editable = false;
        }

        field(40; "Fecha Entrega"; Date)
        {
            Caption = 'Fecha de entrega';
        }

        field(50; "Número de entregas"; Integer)
        {
            Caption = 'Número de entregas';
        }

        field(51; "Fecha inicial"; Date)
        {
            Caption = 'Fecha inicial';
        }

        field(52; "Patrón de fechas"; Enum "DIMA Supply Date Pattern")
        {
            Caption = 'Patrón de fechas';
        }

        field(53; "Intervalo en días"; Integer)
        {
            Caption = 'Intervalo en días';
        }
    }

    keys
    {
        key(PK; "Opportunity No.", "Line No.")
        {
            Clustered = true;
            SumIndexFields = Cantidad, Importe;
        }
    }

    trigger OnInsert()
    var
        DeliveryLine: Record "DIMA Opportunity Delivery";
    begin
        if "Line No." = 0 then begin
            DeliveryLine.Reset();
            DeliveryLine.SetRange("Opportunity No.", "Opportunity No.");

            if DeliveryLine.FindLast() then begin

                // Si ya existe una línea vacía, no permitir
                // crear otra línea vacía.
                if IsLineEmpty(DeliveryLine) then
                    Error(
                        'Debe completar la línea %1 antes de agregar una nueva línea.',
                        DeliveryLine."Line No.");

                "Line No." := DeliveryLine."Line No." + 10000;
            end
            else
                "Line No." := 10000;
        end;
    end;

    // ================================================================
    // CALCULAR IMPORTE
    //
    // Cantidad ahora es un número entero.
    //
    // El precio unitario continúa siendo Decimal, por lo que el
    // resultado puede tener decimales.
    //
    // Ejemplo:
    //
    // Cantidad       = 100
    // Precio Unitario = 123.50
    // ------------------------
    // Importe        = 12,350.00
    // ================================================================
    local procedure CalculateAmount()
    begin
        Importe := Cantidad * "Precio Unitario";
    end;

    procedure ValidateLine()
    begin
        if "Nro. Producto" = '' then
            Error(
                'Debe seleccionar un producto en la línea %1.',
                "Line No.");

        if Cantidad <= 0 then
            Error(
                'La cantidad debe ser mayor a cero en la línea %1.',
                "Line No.");

        if "Precio Unitario" <= 0 then
            Error(
                'El precio unitario debe ser mayor a cero en la línea %1.',
                "Line No.");

        if "Fecha Entrega" = 0D then
            Error(
                'Debe indicar una fecha de entrega en la línea %1.',
                "Line No.");
    end;

    procedure ValidatePreviousLines()
    var
        DeliveryLine: Record "DIMA Opportunity Delivery";
    begin
        DeliveryLine.Reset();
        DeliveryLine.SetRange(
            "Opportunity No.",
            "Opportunity No.");

        if DeliveryLine.FindSet() then
            repeat
                DeliveryLine.ValidateLine();
            until DeliveryLine.Next() = 0;
    end;

    local procedure IsLineEmpty(
        DeliveryLine: Record "DIMA Opportunity Delivery"): Boolean
    begin
        exit(
            (DeliveryLine."Nro. Producto" = '') and
            (DeliveryLine.Cantidad = 0) and
            (DeliveryLine."Precio Unitario" = 0) and
            (DeliveryLine."Fecha Entrega" = 0D)
        );
    end;
}