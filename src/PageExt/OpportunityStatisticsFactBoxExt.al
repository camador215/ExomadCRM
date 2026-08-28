pageextension 80100 "Opp. Statistics FactBox Ext" extends "Opportunity Statistics FactBox"
{
    layout
    {
        addafter("Current Sales Cycle Stage")
        {
            field("Cod. Divisa"; Rec."Currency Code")
            {
                ApplicationArea = All;
                ToolTip = 'Divisa en la que se negocia esta Oportunidad de Venta.';
            }
            field("Estimated Value (ACY)"; Rec."Estimated Value (ACY)")
            {
                ApplicationArea = All;
                ToolTip = 'Especifica el valor estimado de la oportunidad.';
            }
        }
        modify("Estimated Value (LCY)")
        {
            Visible = false;
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}