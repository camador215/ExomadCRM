page 80105 "DIMA Generate Supply Lines"
{
    PageType = StandardDialog;
    Caption = 'Generar líneas de suministro';

    layout
    {
        area(Content)
        {
            field(NumberOfLines; NumberOfLines)
            {
                ApplicationArea = All;
                Caption = 'Número de entregas';
                MinValue = 1;
                MaxValue = 1000;
                ToolTip = 'Indica cuántas fechas de entrega se generarán.';
            }

            field(ItemNo; ItemNo)
            {
                ApplicationArea = All;
                Caption = 'Producto';
                TableRelation = Item."No."
                    where("Base Unit of Measure" = filter('CORCS|CORC|VCS|VCU|CER'));
                ToolTip = 'Selecciona el producto que se repetirá en las líneas.';
            }

            field(Quantity; Quantity)
            {
                ApplicationArea = All;
                Caption = 'Cantidad por entregar (CORCs)';
                MinValue = 1;
                ToolTip = 'Indica cuántas unidades del producto se entregarán en cada fecha.';
            }

            field(UnitPrice; UnitPrice)
            {
                ApplicationArea = All;
                Caption = 'Precio unitario';
                DecimalPlaces = 0 : 5;
                MinValue = 0.00001;
                ToolTip = 'Indica el precio unitario para cada línea.';
            }

            field(StartDate; StartDate)
            {
                ApplicationArea = All;
                Caption = 'A partir de';
                ToolTip = 'Indica la fecha de la primera línea de suministro.';
            }

            field(DatePattern; DatePattern)
            {
                ApplicationArea = All;
                Caption = 'Intervalo de fechas';
                ToolTip = 'Selecciona el patrón o la periodicidad de las fechas de entrega.';

                trigger OnValidate()
                begin
                    if DatePattern <> DatePattern::"Desde fecha inicial" then
                        IntervalInDays := 0;

                    UpdateDaysIntervalVisibility();
                    CurrPage.Update(false);
                end;

                trigger OnAfterLookup(Selected: RecordRef)
                begin
                    if DatePattern <> DatePattern::"Desde fecha inicial" then
                        IntervalInDays := 0;

                    UpdateDaysIntervalVisibility();
                    CurrPage.Update(false);
                end;
            }

            group(DaysIntervalGroup)
            {
                ShowCaption = false;
                Visible = ShowDaysInterval;

                field(DaysInterval; IntervalInDays)
                {
                    ApplicationArea = All;
                    Caption = 'Intervalo en días';
                    MinValue = 1;
                    ToolTip = 'Indica cada cuántos días se creará una línea para Desde fecha inicial.';
                }
            }
        }
    }

    var
        NumberOfLines: Integer;
        ItemNo: Code[20];
        Quantity: Integer;
        UnitPrice: Decimal;
        StartDate: Date;
        IntervalInDays: Integer;
        DatePattern: Enum "DIMA Supply Date Pattern";
        ShowDaysInterval: Boolean;
        DialogCaption: Text[250];

    procedure SetContext(OpportunityNo: Code[20])
    var
        Opportunity: Record Opportunity;
        CompanyContact: Record Contact;
        PersonContact: Record Contact;
        CompanyName: Text[100];
        ContactName: Text[100];
    begin
        DialogCaption := 'Generar líneas de suministro';

        if not Opportunity.Get(OpportunityNo) then
            exit;

        if CompanyContact.Get(Opportunity."Contact Company No.") then
            CompanyName := CompanyContact.Name;

        if PersonContact.Get(Opportunity."Contact No.") then
            ContactName := PersonContact.Name;

        DialogCaption := StrSubstNo(
            'Generar líneas de suministro - %1 %2 %3 %4',
            Opportunity."Contact Company No.",
            CompanyName,
            Opportunity."Contact No.",
            ContactName);
    end;

    trigger OnOpenPage()
    begin
        CurrPage.Caption := DialogCaption;
        UpdateDaysIntervalVisibility();
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction <> ACTION::OK then
            exit(true);

        if not ValidateData() then begin
            Message(GetValidationMessage());
            exit(false);
        end;

        exit(true);
    end;

    local procedure UpdateDaysIntervalVisibility()
    begin
        ShowDaysInterval := DatePattern = DatePattern::"Desde fecha inicial";

        if not ShowDaysInterval then
            IntervalInDays := 0;
    end;

    local procedure ValidateData(): Boolean
    var
        Item: Record Item;
    begin
        if NumberOfLines < 1 then
            exit(false);

        if NumberOfLines > 1000 then
            exit(false);

        if ItemNo = '' then
            exit(false);

        if not Item.Get(ItemNo) then
            exit(false);

        if Quantity <= 0 then
            exit(false);

        if UnitPrice <= 0 then
            exit(false);

        if StartDate = 0D then
            exit(false);

        if (DatePattern = DatePattern::"Desde fecha inicial") and
           (IntervalInDays <= 0) then
            exit(false);

        exit(true);
    end;

    local procedure GetValidationMessage(): Text
    var
        Item: Record Item;
    begin
        if NumberOfLines < 1 then
            exit('La cantidad de líneas debe ser mayor que cero.');

        if NumberOfLines > 1000 then
            exit('La cantidad de líneas no puede superar 1000.');

        if ItemNo = '' then
            exit('Debe seleccionar un producto.');

        if not Item.Get(ItemNo) then
            exit(StrSubstNo('El producto %1 no existe.', ItemNo));

        if Quantity <= 0 then
            exit('La cantidad debe ser mayor que cero.');

        if UnitPrice <= 0 then
            exit('El precio unitario debe ser mayor que cero.');

        if StartDate = 0D then
            exit('Debe indicar una fecha inicial.');

        if (DatePattern = DatePattern::"Desde fecha inicial") and
           (IntervalInDays <= 0) then
            exit('El intervalo en días debe ser mayor que cero.');

        exit('');
    end;

    procedure GenerateLines(OpportunityNo: Code[20])
    var
        DeliveryLine: Record "DIMA Opportunity Delivery";
        NextLineNo: Integer;
        Index: Integer;
        MonthDate: Date;
    begin
        if not ValidateData() then begin
            Message(GetValidationMessage());
            exit;
        end;

        DeliveryLine.Reset();
        DeliveryLine.SetRange("Opportunity No.", OpportunityNo);
        if DeliveryLine.FindLast() then
            NextLineNo := DeliveryLine."Line No." + 10000
        else
            NextLineNo := 10000;

        for Index := 0 to NumberOfLines - 1 do begin
            DeliveryLine.Init();
            DeliveryLine."Opportunity No." := OpportunityNo;
            DeliveryLine."Line No." := NextLineNo + (Index * 10000);
            DeliveryLine."Número de entregas" := NumberOfLines;
            DeliveryLine."Fecha inicial" := StartDate;
            DeliveryLine."Patrón de fechas" := DatePattern;
            DeliveryLine."Intervalo en días" := IntervalInDays;
            DeliveryLine.Validate("Nro. Producto", ItemNo);
            DeliveryLine.Validate(Cantidad, Quantity);
            DeliveryLine.Validate("Precio Unitario", UnitPrice);
            DeliveryLine.Validate("Fecha Entrega", GetDeliveryDate(Index));
            DeliveryLine.Insert(true);
            DeliveryLine.Descripcion := StrSubstNo('%1 - %2', DeliveryLine."Line No." div 10000, DeliveryLine.Descripcion);
            DeliveryLine.Modify(false);
        end;
    end;

    local procedure GetDeliveryDate(Index: Integer): Date
    var
        MonthDate: Date;
        MonthsPerPeriod: Integer;
        BaseDay: Integer;
        LastDayOfMonth: Integer;
    begin
        if DatePattern = DatePattern::"Desde fecha inicial" then
            exit(CalcDate(StrSubstNo('<+%1D>', Index * IntervalInDays), StartDate));

        MonthsPerPeriod := GetMonthsPerPeriod();
        BaseDay := Date2DMY(StartDate, 1);
        MonthDate := CalcDate(
            StrSubstNo('<+%1M>', Index * MonthsPerPeriod),
            DMY2Date(1, Date2DMY(StartDate, 2), Date2DMY(StartDate, 3)));
        LastDayOfMonth := Date2DMY(CalcDate('<CM>', MonthDate), 1);

        if BaseDay > LastDayOfMonth then
            BaseDay := LastDayOfMonth;

        case DatePattern of
            DatePattern::"Inicio de mes":
                exit(DMY2Date(1, Date2DMY(MonthDate, 2), Date2DMY(MonthDate, 3)));
            DatePattern::"Fin de mes":
                exit(CalcDate('<CM>', MonthDate));
            else
                exit(DMY2Date(BaseDay, Date2DMY(MonthDate, 2), Date2DMY(MonthDate, 3)));
        end;
    end;

    local procedure GetMonthsPerPeriod(): Integer
    begin
        case DatePattern of
            DatePattern::"Inicio de mes",
            DatePattern::"Fin de mes":
                exit(1);
            DatePattern::Bimestral:
                exit(2);
            DatePattern::Trimestral:
                exit(3);
            DatePattern::Cuatrimestral:
                exit(4);
            DatePattern::Semestral:
                exit(6);
            DatePattern::Anual:
                exit(12);
        end;
    end;
}
