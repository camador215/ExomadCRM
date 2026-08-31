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
                Caption = '&Sales Quote';
                Image = Quote;
                InFooterBar = true;
                ToolTip = 'Create a sales quote based on the opportunity.';

                trigger OnAction()
                var
                    SalesHeader: Record "Sales Header";
                    Opportunity: Record Opportunity;
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
                        Rec."Estimated Value (LCY)" :=
                            Rec.GetSalesDocValue(SalesHeader);

                        // ====================================================
                        // SOLUCIÓN DIMA
                        // ====================================================

                        // Convierte el valor LCY obtenido de la cotización
                        // a la divisa configurada en la Opportunity Entry.
                        Rec."Estimated Value (ACY)" :=
                            DIMAOpportunityEntryEvents.ConvertLCYToACY(
                                Rec."Estimated Value (LCY)",
                                Rec."Currency Code");

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
                Caption = 'Nuevo';

                actionref(DIMASalesQuote_Promoted; DIMASalesQuote)
                {
                }
            }
        }
    }

    var
        DIMAOpportunityEntryEvents: Codeunit "DIMA Opportunity Entry Events";
}