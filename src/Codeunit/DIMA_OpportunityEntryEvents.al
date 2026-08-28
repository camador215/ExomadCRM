codeunit 80103 "DIMA Opportunity Entry Events"
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

    [EventSubscriber(
        ObjectType::Table,
        Database::"Opportunity Entry",
        'OnAfterModifyEvent',
        '',
        false,
        false)]
    local procedure OpportunityEntryOnAfterModify(
        var Rec: Record "Opportunity Entry";
        var xRec: Record "Opportunity Entry";
        RunTrigger: Boolean)
    begin
        SyncOpportunityEntry(Rec);
    end;

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

        // Sincronizar moneda
        if OpportunityEntry."Currency Code" <>
           Opportunity."Currency Code" then begin

            OpportunityEntry."Currency Code" :=
                Opportunity."Currency Code";

            Modified := true;
        end;

        // Sincronizar Estimated Value
        if OpportunityEntry."Estimated Value (ACY)" <>
           OpportunityEntry."Estimated Value (LCY)" then begin

            OpportunityEntry."Estimated Value (ACY)" :=
                OpportunityEntry."Estimated Value (LCY)";

            Modified := true;
        end;

        // Sincronizar Calcd. Current Value
        if OpportunityEntry."Calcd. Current Value (ACY)" <>
           OpportunityEntry."Calcd. Current Value (LCY)" then begin

            OpportunityEntry."Calcd. Current Value (ACY)" :=
                OpportunityEntry."Calcd. Current Value (LCY)";

            Modified := true;
        end;

        if Modified then
            OpportunityEntry.Modify(false);
    end;
}