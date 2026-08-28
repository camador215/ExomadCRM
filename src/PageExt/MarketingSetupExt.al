pageextension 80102 "DIMA Marketing Setup Ext" extends "Marketing Setup"
{
    layout
    {
        addafter(Duplicates)
        {
            group("DIMA Marketing Setup")
            {
                Caption = 'Oportunidades';

                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}