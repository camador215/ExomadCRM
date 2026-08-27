pageextension 80104 "DIMA Opportunity Broker Ext" extends "Opportunity Card"
{
    layout
    {
        addlast(Content)
        {
            part(Brokers; "DIMA Opportunity Broker")
            {
                ApplicationArea = All;
                SubPageLink = "Opportunity No." = field("No.");
            }

            part(DeliveryLines; "DIMA Opportunity Delivery")
            {
                ApplicationArea = All;
                Editable = false;
                SubPageLink = "Opportunity No." = field("No.");
                Visible = Rec."Sales Document No." <> '';
            }
        }
    }
}
