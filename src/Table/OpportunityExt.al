tableextension 80103 "DIMA Opportunity Ext" extends Opportunity
{
    trigger OnDelete()
    var
        DeliveryLine: Record "DIMA Opportunity Delivery";
    begin
        DeliveryLine.SetRange("Opportunity No.", Rec."No.");
        DeliveryLine.DeleteAll();
    end;
}