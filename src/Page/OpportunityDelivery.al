page 80101 "DIMA Opportunity Delivery"
{
    PageType = ListPart;
    SourceTable = "DIMA Opportunity Delivery";
    Caption = 'Cronograma de Suministro';

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Nro. Producto"; Rec."Nro. Producto")
                {
                    ApplicationArea = All;
                    Caption = 'Producto';
                    ShowMandatory = true;
                    ToolTip = 'Es obligatorio seleccionar un producto.';
                }

                field(Descripcion; Rec.Descripcion)
                {
                    ApplicationArea = All;
                    Caption = 'Descripción';
                    Editable = true;
                }

                field(Cantidad; Rec.Cantidad)
                {
                    ApplicationArea = All;
                    Caption = 'Cantidad';
                    ShowMandatory = true;
                    BlankZero = true;
                    ToolTip = 'Es obligatorio ingresar una cantidad mayor a cero.';

                    // =====================================================
                    // CAMBIO:
                    // En un campo de una Page/ListPart NO existe
                    // OnAfterValidate().
                    //
                    // El trigger correcto es OnValidate().
                    //
                    // Aquí actualizamos los totales después de que
                    // el usuario modifique la cantidad.
                    // =====================================================
                    trigger OnValidate()
                    begin
                        UpdateTotals();
                        CurrPage.Update(false);
                    end;
                }

                field("Unidad Medida"; Rec."Unidad Medida")
                {
                    ApplicationArea = All;
                    Caption = 'Unidad de medida';
                }

                field("Precio Unitario"; Rec."Precio Unitario")
                {
                    ApplicationArea = All;
                    Caption = 'Precio unitario';
                    ShowMandatory = true;
                    BlankZero = true;
                    ToolTip = 'Es obligatorio ingresar un precio mayor a cero.';

                    // =====================================================
                    // CAMBIO:
                    // Igual que con Cantidad, usamos OnValidate().
                    //
                    // Cuando el usuario modifica el precio, volvemos
                    // a calcular los totales de toda la ListPart.
                    // =====================================================
                    trigger OnValidate()
                    begin
                        UpdateTotals();
                        CurrPage.Update(false);
                    end;
                }

                field(Importe; Rec.Importe)
                {
                    ApplicationArea = All;
                    Caption = 'Importe';
                    Editable = false;
                    BlankZero = true;
                }

                field("Fecha Entrega"; Rec."Fecha Entrega")
                {
                    ApplicationArea = All;
                    Caption = 'Fecha de entrega';
                    ShowMandatory = true;
                    ToolTip = 'Es obligatorio ingresar una fecha de entrega.';
                }
            }

            group(Totals)
            {
                ShowCaption = false;

                field(TotalQuantity; TotalQuantity)
                {
                    ApplicationArea = All;
                    Caption = 'Cantidad total';
                    Editable = false;
                    DecimalPlaces = 0 : 5;
                }

                field(TotalAmount; TotalAmount)
                {
                    ApplicationArea = All;
                    Caption = 'Importe total';
                    Editable = false;
                    DecimalPlaces = 0 : 2;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(Acciones)
            {
                Caption = 'Acciones';
                Image = Action;

                action(GenerateSupplyLines)
                {
                    ApplicationArea = All;
                    Caption = 'Generar líneas';
                    Enabled = CanGenerateSupplyLines;
                    Image = Create;
                    ToolTip = 'Genera varias líneas de suministro con fechas mensuales.';

                    trigger OnAction()
                    var
                        GenerateSupplyLinesPage: Page "DIMA Generate Supply Lines";
                    begin
                        if not CanGenerateSupplyLines then
                            Error('No se pueden generar líneas porque la oportunidad ya tiene un pedido de venta.');

                        GenerateSupplyLinesPage.SetContext(Rec."Opportunity No.");

                        if GenerateSupplyLinesPage.RunModal() = Action::OK then begin
                            GenerateSupplyLinesPage.GenerateLines(Rec."Opportunity No.");

                            // =================================================
                            // CAMBIO:
                            // Después de generar las líneas volvemos a
                            // calcular los totales.
                            // =================================================
                            UpdateTotals();

                            CurrPage.Update(false);
                        end;
                    end;
                }
            }
        }
    }

    var
        TotalQuantity: Decimal;
        TotalAmount: Decimal;
        CanGenerateSupplyLines: Boolean;

    trigger OnOpenPage()
    begin
        UpdateActionState();
        UpdateTotals();
    end;

    trigger OnAfterGetRecord()
    begin
        UpdateActionState();
        UpdateTotals();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        UpdateActionState();
        UpdateTotals();
    end;

    local procedure UpdateActionState()
    var
        Opportunity: Record Opportunity;
    begin
        CanGenerateSupplyLines := false;

        if Opportunity.Get(Rec."Opportunity No.") then
            CanGenerateSupplyLines := Opportunity."Sales Document No." = '';
    end;

    // =============================================================
    // ACTUALIZAR TOTALES
    //
    // Este procedimiento suma todas las líneas pertenecientes al
    // contexto actual de la ListPart.
    //
    // Cantidad:
    //   suma todas las cantidades.
    //
    // Importe:
    //   suma todos los importes.
    //
    // CopyFilters(Rec) permite conservar los filtros actuales de
    // la página, incluyendo el Opportunity No.
    // =============================================================
    local procedure UpdateTotals()
    var
        DeliveryLine: Record "DIMA Opportunity Delivery";
    begin
        DeliveryLine.CopyFilters(Rec);

        DeliveryLine.CalcSums(Cantidad, Importe);

        TotalQuantity := DeliveryLine.Cantidad;
        TotalAmount := DeliveryLine.Importe;
    end;
}