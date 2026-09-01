pageextension 80101 "DIMA Close Opportunity Ext" extends "Close Opportunity"
{
    layout
    {
        addlast(Content)
        {
            part(DeliveryLines; "DIMA Opportunity Delivery")
            {
                ApplicationArea = All;
                SubPageLink = "Opportunity No." = field("Opportunity No.");
                UpdatePropagation = Both;
                Visible = ShowDeliveryLines;
            }
        }
        addbefore("Calcd. Current Value (LCY)")
        {
            field("Calcd. Current Value (ACY)"; Rec."Calcd. Current Value (ACY)")
            {
                ApplicationArea = All;
                Caption = 'Ventas ($)';
                ToolTip = 'Especifica el valor actual calculado del movimiento de la oportunidad.';
                Enabled = CurrentValueACYEnable;
            }
        }

        modify("Calcd. Current Value (LCY)")
        {
            Visible = false;
        }

        modify(OptionWon)
        {
            trigger OnAfterValidate()
            begin
                UpdateDeliveryLinesVisibility();
                if Rec."Action Taken" = Rec."Action Taken"::Won then begin
                    CurrentValueACYEnable := true;

                    CalculateCurrentValue();
                end else
                    CurrentValueACYEnable := false;
            end;
        }
    }

    //////
    actions
    {
        // ============================================================
        // SOLUCIÓN DIMA
        // Ocultamos el Sales Quote estándar para utilizar nuestra
        // propia acción con la misma funcionalidad + actualización ACY.
        // ============================================================

        modify(SalesQuote)
        {
            Visible = false;
        }

        // ============================================================
        // SOLUCIÓN DIMA
        // Creamos nuestro propio botón Sales Quote.
        // ============================================================

        addlast(Processing)
        {
            action(DIMASalesQuote)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Cotización de venta';
                Image = Quote;
                InFooterBar = true;
                ToolTip = 'Modificar la Cotización de Venta asignada a esta Oportunidad.';

                trigger OnAction()
                var
                    SalesHeader: Record "Sales Header";
                    Opportunity: Record Opportunity;
                    Ventas: Decimal;
                    VentasACY: Decimal;
                begin
                    // SOLUCIÓN DIMA:
                    // Obtiene la Opportunity correspondiente al
                    // Opportunity Entry actual de la página.
                    if not Opportunity.Get(Rec."Opportunity No.") then
                        exit;

                    // SOLUCIÓN DIMA:
                    // Abre la cotización.
                    //
                    // IMPORTANTE:
                    // ShowQuote() es modal/sincrónico en este flujo.
                    // Cuando el usuario cierre la Sales Quote,
                    // la ejecución continuará en la siguiente línea.
                    Opportunity.ShowQuote();

                    // SOLUCIÓN DIMA:
                    // Después de cerrar la Sales Quote, obtenemos
                    // nuevamente el documento para tomar sus valores
                    // actualizados.
                    if SalesHeader.Get(
                        SalesHeader."Document Type"::Quote,
                        Opportunity."Sales Document No.")
                    then begin

                        // ====================================================
                        // TU LÓGICA ESTÁNDAR
                        // ====================================================

                        // Actualiza el Estimated Value (LCY) exactamente
                        // como lo hace la acción estándar de Microsoft.
                        Ventas := Rec.GetSalesDocValue(SalesHeader);
                        Rec."Estimated Value (LCY)" := Ventas;
                        Rec."Calcd. Current Value (LCY)" := Ventas;

                        // ====================================================
                        // SOLUCIÓN DIMA
                        // ====================================================

                        // Convierte el valor LCY obtenido de la cotización
                        // a la divisa configurada en la Opportunity Entry.
                        VentasACY := DIMAOpportunityEntryEvents.ConvertLCYToACY(
                            Ventas,
                            Rec."Currency Code");
                        Rec."Estimated Value (ACY)" := VentasACY;
                        Rec."Calcd. Current Value (ACY)" := VentasACY;

                        // ====================================================
                        // SOLUCIÓN DIMA
                        // ====================================================

                        // Guarda tanto el Estimated Value (LCY) como
                        // el Estimated Value (ACY).
                        Rec.Modify();

                        // Actualiza la página para mostrar los nuevos valores.
                        CurrPage.Update();
                    end;
                end;
            }
        }

        // ============================================================
        // SOLUCIÓN DIMA
        // Colocamos nuestra acción dentro de la categoría "New",
        // igual que la acción estándar SalesQuote.
        // ============================================================

        addlast(Promoted)
        {
            group(DIMACategoryNew)
            {
                Caption = 'Ver';

                actionref(DIMASalesQuote_Promoted; DIMASalesQuote)
                {
                }
            }
        }
    }

    var
        DIMAOpportunityEntryEvents: Codeunit "DIMA Opportunity Entry Events";
        ShowDeliveryLines: Boolean;
        Opp: Record Opportunity;
        CurrentValueACYEnable: Boolean;

    trigger OnAfterGetCurrRecord()
    begin
        CurrentValueACYEnable := true;
    end;

    trigger OnOpenPage()
    begin
        UpdateDeliveryLinesVisibility();
    end;

    // ============================================================
    // CAMBIO:
    //
    // Se elimina OnQueryClosePage.
    //
    // Ya NO hacemos aquí:
    //
    //     Confirm()
    //     exit(false)
    //
    // La validación de importes ahora está en:
    //
    //     DIMA_OpportunityManagement.al
    //
    // usando:
    //
    //     OnFinishWizardOnAfterUpdateEstimates
    //
    // De esta forma el Confirm solamente aparece cuando el usuario
    // realmente pulsa Aceptar para finalizar el cierre.
    // ============================================================


    local procedure UpdateDeliveryLinesVisibility()
    begin
        ShowDeliveryLines := false;

        // Solo mostramos el cronograma cuando se selecciona WON.
        if Rec."Action Taken" <> Rec."Action Taken"::Won then
            exit;

        // Obtener la oportunidad.
        if not Opp.Get(Rec."Opportunity No.") then
            exit;

        // Si ya existe un documento de venta, no mostramos
        // nuevamente el cronograma.
        if Opp."Sales Document No." = '' then
            ShowDeliveryLines := true;
    end;

    local procedure CalculateCurrentValue()
    var
        Opportunity: Record Opportunity;
        OpportunityEntry: Record "Opportunity Entry";
        DIMAOpportunityEntryEvents: Codeunit "DIMA Opportunity Entry Events";
        Ventas: Decimal;
    begin
        // Buscar la oportunidad
        if not Opportunity.Get(Rec."Opportunity No.") then
            exit;

        // Si ya tiene una cotización asociada, no modificar el valor.
        if (Opportunity."Sales Document Type" = Opportunity."Sales Document Type"::Quote) and
           (Opportunity."Sales Document No." <> '')
        then
            exit;

        // Buscar la última Opportunity Entry activa.
        OpportunityEntry.Reset();
        OpportunityEntry.SetRange("Opportunity No.", Rec."Opportunity No.");
        OpportunityEntry.SetRange(Active, true);

        if OpportunityEntry.FindLast() then begin
            Rec."Calcd. Current Value (LCY)" := OpportunityEntry."Estimated Value (LCY)";
            Ventas := DIMAOpportunityEntryEvents.ConvertLCYToACY(
                OpportunityEntry."Estimated Value (LCY)",
                OpportunityEntry."Currency Code");
            Rec."Calcd. Current Value (ACY)" := Ventas;
            Rec."Estimated Value (ACY)" := Ventas;
        end;
    end;
}