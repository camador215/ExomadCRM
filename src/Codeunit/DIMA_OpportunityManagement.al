codeunit 80113 "DIMA Opportunity Management"
{
    // ============================================================
    // Este evento se ejecuta dentro de FinishWizard(), después
    // de que el usuario pulsa Aceptar para finalizar.
    //
    // Si responde NO:
    //     Error('') cancela la operación y hace rollback.
    //
    // El usuario permanece en Close Opportunity y puede corregir
    // los importes y pulsar Aceptar nuevamente.
    // ============================================================

    [EventSubscriber(
        ObjectType::Table,
        Database::"Opportunity Entry",
        'OnFinishWizardOnAfterUpdateEstimates',
        '',
        false,
        false)]
    local procedure OpportunityEntry_OnFinishWizardOnAfterUpdateEstimates(
        OpportunityEntry: Record "Opportunity Entry")
    var
        Opportunity: Record Opportunity;
        Ventas: Decimal;
    begin
        // Solo validamos cuando la oportunidad se está ganando.
        if OpportunityEntry."Action Taken" <> OpportunityEntry."Action Taken"::Won then
            exit;

        if OpportunityEntry."Currency Code" <> '' then
            Ventas := OpportunityEntry."Calcd. Current Value (ACY)"
        else
            Ventas := OpportunityEntry."Calcd. Current Value (LCY)";

        // Obtener la oportunidad actual.
        if not Opportunity.Get(OpportunityEntry."Opportunity No.") then
            Error(
                'No se encontró la oportunidad %1.',
                OpportunityEntry."Opportunity No."
            );

        // ======================================================== 
        // VALIDACIÓN DEL CRONOGRAMA 
        // 
        // Solo exigimos registros en DIMA Opportunity Delivery 
        // cuando la oportunidad todavía NO tiene un documento 
        // de venta asociado. 
        // 
        // Si "Sales Document No." tiene valor, significa que la 
        // oportunidad ya está asociada a un documento de venta y 
        // no se realiza esta validación. 
        // ========================================================
        if Opportunity."Sales Document No." = '' then begin
            if not HasDeliveryLines(OpportunityEntry."Opportunity No.") then
                Error(
                    'No se puede ganar la oportunidad %1 porque no tiene registros asociados en el Cronograma de Suministro.',
                    OpportunityEntry."Opportunity No.");

            // Si los importes coinciden, continúa normalmente.
            if not HasDeliveryValueMismatch(
                OpportunityEntry."Opportunity No.",
                Ventas)
            then
                exit;

            // ========================================================
            // El Confirm AHORA aparece solamente al finalizar
            // el wizard mediante Aceptar.
            //
            // Si el usuario responde NO:
            //
            //     Error('')
            //
            // cancela FinishWizard(), hace rollback y permite que
            // el usuario vuelva a intentar el proceso.
            // ========================================================
            if not Confirm(
                'La suma del cronograma de suministro (%1) difiere del valor actual calculado (%2). ¿Desea continuar?',
                false,
                GetDeliveryPlanTotal(OpportunityEntry."Opportunity No."),
                Ventas)
            then
                Error('');
        end;
    end;

    // ============================================================
    // CREAR PEDIDO DESPUÉS DE FINALIZAR LA OPORTUNIDAD
    //
    // Este evento se ejecuta después de InsertEntry().
    //
    // Solo se llegará aquí si:
    //
    // 1. El usuario pulsó Aceptar.
    // 2. La validación anterior no produjo Error.
    // 3. La oportunidad puede finalizarse correctamente.
    // ============================================================

    [EventSubscriber(
        ObjectType::Table,
        Database::"Opportunity Entry",
        'OnFinishWizardOnAfterInsertEntry',
        '',
        false,
        false)]
    local procedure OpportunityEntry_OnFinishWizardOnAfterInsertEntry(
        OpportunityEntry: Record "Opportunity Entry")
    var
        SalesOrderNo: Code[20];
    begin
        // Solo creamos pedido para oportunidades ganadas.
        if OpportunityEntry."Action Taken" <> OpportunityEntry."Action Taken"::Won then
            exit;

        // Si no hay cronograma, no creamos pedido.
        if not HasDeliveryLines(OpportunityEntry."Opportunity No.") then
            exit;

        // Crear pedido de venta.
        SalesOrderNo := CreateSalesOrder(OpportunityEntry."Opportunity No.");
        if (SalesOrderNo <> '') and
           Confirm('Se creo el pedido de venta %1. Desea abrirlo?', true, SalesOrderNo) then
            OpenSalesOrder(SalesOrderNo);

        // Actualmente no abrimos automáticamente el pedido.
        // Puedes agregar esa lógica posteriormente si la necesitas.
    end;

    local procedure OpenSalesOrder(SalesOrderNo: Code[20])
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("No.", SalesOrderNo);
        if SalesHeader.FindFirst() then
            Page.Run(Page::"Sales Order", SalesHeader);
    end;


    // ============================================================
    // VALIDACIÓN DE LÍNEAS
    // ============================================================

    local procedure HasDeliveryLines(OpportunityNo: Code[20]): Boolean
    var
        DeliveryLine: Record "DIMA Opportunity Delivery";
    begin
        DeliveryLine.SetRange("Opportunity No.", OpportunityNo);

        exit(DeliveryLine.FindFirst());
    end;


    local procedure HasDeliveryValueMismatch(
        OpportunityNo: Code[20];
        OpportunityCurrentValue: Decimal): Boolean
    begin
        exit(
            Abs(
                GetDeliveryPlanTotal(OpportunityNo) -
                OpportunityCurrentValue
            ) > 0.01
        );
    end;


    local procedure GetDeliveryPlanTotal(OpportunityNo: Code[20]): Decimal
    var
        DeliveryLine: Record "DIMA Opportunity Delivery";
        TotalAmount: Decimal;
    begin
        DeliveryLine.SetRange("Opportunity No.", OpportunityNo);

        if DeliveryLine.FindSet() then
            repeat
                TotalAmount += DeliveryLine.Importe;
            until DeliveryLine.Next() = 0;

        exit(TotalAmount);
    end;


    // ============================================================
    // CREACIÓN DEL PEDIDO
    // ============================================================

    local procedure CreateSalesOrder(OpportunityNo: Code[20]): Code[20]
    var
        Opportunity: Record Opportunity;
        CompanyContact: Record Contact;
        ContactBusinessRelation: Record "Contact Business Relation";
        Customer: Record Customer;
        DeliveryLine: Record "DIMA Opportunity Delivery";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CustomerNo: Code[20];
        LineNo: Integer;
    begin
        if not Opportunity.Get(OpportunityNo) then
            Error('No se encontró la oportunidad %1.', OpportunityNo);

        // Si ya existe un pedido, no creamos otro.
        if Opportunity."Sales Document No." <> '' then
            exit(Opportunity."Sales Document No.");

        DeliveryLine.Reset();
        DeliveryLine.SetRange("Opportunity No.", OpportunityNo);

        if not DeliveryLine.FindSet() then
            Error('Debe ingresar al menos una línea de suministro.');

        DeliveryLine.ValidatePreviousLines();

        CustomerNo := GetOrCreateCustomerNo(
            Opportunity."Contact Company No.",
            CompanyContact,
            ContactBusinessRelation,
            Customer);

        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
        SalesHeader."Opportunity No." := OpportunityNo;
        SalesHeader.Insert(true);

        SalesHeader.Validate("Sell-to Customer No.", CustomerNo);
        SalesHeader.Validate("Currency Code", Opportunity."Currency Code");
        SalesHeader.Modify(true);

        repeat
            SalesLine.Init();
            SalesLine."Document Type" := SalesHeader."Document Type";
            SalesLine."Document No." := SalesHeader."No.";

            LineNo += 10000;
            SalesLine."Line No." := LineNo;

            SalesLine.Type := SalesLine.Type::Item;

            SalesLine.Validate("No.", DeliveryLine."Nro. Producto");
            SalesLine.Validate(Quantity, DeliveryLine.Cantidad);
            SalesLine.Validate("Unit Price", DeliveryLine."Precio Unitario");
            SalesLine.Validate("Shipment Date", DeliveryLine."Fecha Entrega");
            SalesLine.Insert(true);

            SalesLine."Description 2" := DeliveryLine.Descripcion;
            SalesLine.Modify(true);

        until DeliveryLine.Next() = 0;

        Opportunity."Sales Document Type" := Opportunity."Sales Document Type"::Order;
        Opportunity."Sales Document No." := SalesHeader."No.";
        Opportunity.Modify(true);

        exit(SalesHeader."No.");
    end;


    // ============================================================
    // OBTENER / CREAR CUSTOMER
    // ============================================================

    local procedure GetOrCreateCustomerNo(
        ContactCompanyNo: Code[20];
        var CompanyContact: Record Contact;
        var ContactBusinessRelation: Record "Contact Business Relation";
        var Customer: Record Customer): Code[20]
    begin
        if ContactCompanyNo = '' then
            Error('La oportunidad no tiene una empresa de contacto.');

        ContactBusinessRelation.Reset();

        ContactBusinessRelation.SetRange(
            "Contact No.",
            ContactCompanyNo);

        ContactBusinessRelation.SetRange(
            "Link to Table",
            ContactBusinessRelation."Link to Table"::Customer);

        if ContactBusinessRelation.FindFirst() then
            exit(ContactBusinessRelation."No.");

        if not CompanyContact.Get(ContactCompanyNo) then
            Error(
                'No se encontró la empresa de contacto %1.',
                ContactCompanyNo);

        Customer.Init();
        Customer.Validate(Name, CompanyContact.Name);
        Customer.Insert(true);

        ContactBusinessRelation.Init();
        ContactBusinessRelation."Contact No." := ContactCompanyNo;
        ContactBusinessRelation."Link to Table" :=
            ContactBusinessRelation."Link to Table"::Customer;
        ContactBusinessRelation."No." := Customer."No.";
        ContactBusinessRelation.Insert(true);

        exit(Customer."No.");
    end;
}