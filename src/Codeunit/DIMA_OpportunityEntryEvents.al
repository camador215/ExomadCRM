codeunit 80104 "DIMA Opportunity Entry Events"
{
    [EventSubscriber(
        ObjectType::Table,
        Database::"Opportunity Entry",
        'OnAfterInsertEvent',
        '',
        false,
        false)]
    local procedure OpportunityEntryOnAfterInsert(
        var Rec: Record "Opportunity Entry";
        RunTrigger: Boolean)
    begin
        SyncOpportunityEntry(Rec);
    end;

    // [EventSubscriber(
    //     ObjectType::Table,
    //     Database::"Opportunity Entry",
    //     'OnAfterModifyEvent',
    //     '',
    //     false,
    //     false)]
    // local procedure OpportunityEntryOnAfterModify(
    //     var Rec: Record "Opportunity Entry";
    //     var xRec: Record "Opportunity Entry";
    //     RunTrigger: Boolean)
    // begin
    //     SyncOpportunityEntry(Rec);
    // end;

    local procedure SyncOpportunityEntry(
        var OpportunityEntry: Record "Opportunity Entry")
    var
        Opportunity: Record Opportunity;
        Modified: Boolean;
    begin
        if OpportunityEntry."Opportunity No." = '' then
            exit;

        if not Opportunity.Get(OpportunityEntry."Opportunity No.") then
            exit;

        // Divisa de la Opportunity → Opportunity Entry
        if OpportunityEntry."Currency Code" <> Opportunity."Currency Code" then begin
            OpportunityEntry."Currency Code" :=
                Opportunity."Currency Code";

            Modified := true;
        end;

        Modified := true;

        OpportunityEntry."Calcd. Current Value (ACY)" :=
            ConvertLCYToACY(
                OpportunityEntry."Calcd. Current Value (LCY)",
                Opportunity."Currency Code");

        if Modified then
            OpportunityEntry.Modify(false);
    end;
    ////////////////////////////////////////////////////////////////////////
    [EventSubscriber(
        ObjectType::Page,
        Page::"Update Opportunity",
        'OnUpdateEstimatedValuesOnBeforeModify',
        '',
        false,
        false)]
    local procedure OnUpdateEstimatedValuesOnBeforeModify(
        var OpportunityEntry: Record "Opportunity Entry";
        SalesHeader: Record "Sales Header")
    var
        Opportunity: Record Opportunity;
    begin
        if not Opportunity.Get(OpportunityEntry."Opportunity No.") then
            exit;

        OpportunityEntry."Currency Code" := Opportunity."Currency Code";

        OpportunityEntry."Estimated Value (ACY)" :=
            ConvertLCYToACY(
                OpportunityEntry."Estimated Value (LCY)",
                OpportunityEntry."Currency Code");
    end;

    procedure ConvertLCYToACY(
        AmountLCY: Decimal;
        CurrencyCode: Code[10]): Decimal
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
    begin
        if AmountLCY = 0 then
            exit(0);

        if CurrencyCode = '' then
            exit(AmountLCY);

        exit(
            CurrencyExchangeRate.ExchangeAmtLCYToFCY(
                WorkDate(),
                CurrencyCode,
                AmountLCY,
                CurrencyExchangeRate.ExchangeRate(
                    WorkDate(),
                    CurrencyCode)
            )
        );
    end;

    [EventSubscriber(
        ObjectType::Table,
        Database::"Opportunity Entry",
        'OnUpdateEstimatesOnBeforeModifyOpportunityEntry',
        '',
        false,
        false)]
    local procedure OnUpdateEstimatesOnBeforeModifyOpportunityEntry(
        var OpportunityEntry: Record "Opportunity Entry";
        SalesHeader: Record "Sales Header")
    var
        Opportunity: Record Opportunity;
    begin
        Opportunity.Get(OpportunityEntry."Opportunity No.");
        if (OpportunityEntry."Action Taken" = OpportunityEntry."Action Taken"::Won) then begin
            if SalesHeader.Get(SalesHeader."Document Type"::Quote, Opportunity."Sales Document No.") then begin
                OpportunityEntry."Calcd. Current Value (ACY)" :=
                ConvertLCYToACY(
                    OpportunityEntry.GetSalesDocValue(SalesHeader),
                    OpportunityEntry."Currency Code");
                OpportunityEntry."Estimated Value (ACY)" :=
                ConvertLCYToACY(
                    OpportunityEntry.GetSalesDocValue(SalesHeader),
                    OpportunityEntry."Currency Code");
            end;
        end;

        if (OpportunityEntry."Action Taken" = OpportunityEntry."Action Taken"::Lost) then begin
            OpportunityEntry."Calcd. Current Value (ACY)" := 0;
            OpportunityEntry."Estimated Value (ACY)" := 0;
        end;

    end;
}