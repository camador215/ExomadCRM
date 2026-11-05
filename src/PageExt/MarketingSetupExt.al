pageextension 80102 "DIMA Marketing Setup Ext" extends "Marketing Setup"
{
    layout
    {
        addFirst(Default)
        {
            group("DIMA Opportunity Setup")
            {
                ShowCaption = false;
                field("Currency Code"; Rec."Currency Code")
                {
                    Caption = 'Cod. Divisa Oportunidad';
                    Description = 'Código de moneda predeterminado al crear una nueva oportunidad.';
                    ApplicationArea = All;
                }
            }
        }
    }
}