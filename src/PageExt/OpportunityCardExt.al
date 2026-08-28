pageextension 80103 "DIMA Opportunity Broker Ext" extends "Opportunity Card"
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
        addbefore(Status)
        {
            field("Cod. Divisa"; Rec."Currency Code")
            {
                ApplicationArea = All;
                ToolTip = 'Divisa en la que se negocia esta Oportunidad de Venta. Solo es posible editar si la Oportunidad está como "No iniciada"';
                Editable = false;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        UpdateEditable();
    end;

    trigger OnNewRecord(doCommit: Boolean)
    begin
        UpdateEditable();
    end;


    local procedure UpdateEditable()
    begin
        CurrencyEditable := IsStatusNotStarted();
    end;

    local procedure IsStatusNotStarted(): Boolean
    begin
        exit(Rec.Status.AsInteger() < "Opportunity Status"::"In Progress".AsInteger());
    end;

    var
        CurrencyEditable: Boolean;
}
