codeunit 80105 "DIMA Opportunity Events"
{
    [EventSubscriber(
        ObjectType::Table,
        Database::"Opportunity",
        'OnBeforeRunQuotePage',
        '',
        false,
        false)]
    local procedure OnBeforeRunQuotePage(
        var SalesHeader: Record "Sales Header";
        Modal: Boolean;
        var IsHandled: Boolean)
    var
        DeliveryLine: Record "DIMA Opportunity Delivery";
    begin
        if SalesHeader."Opportunity No." = '' then
            exit;

        DeliveryLine.SetRange(
            "Opportunity No.",
            SalesHeader."Opportunity No.");

        DeliveryLine.DeleteAll();
    end;
}