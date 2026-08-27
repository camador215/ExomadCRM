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

        modify(OptionWon)
        {
            trigger OnAfterValidate()
            begin
                UpdateDeliveryLinesVisibility();
            end;
        }
    }

    var
        ShowDeliveryLines: Boolean;
        Opp: Record Opportunity;

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
}