enum 80101 "DIMA Supply Date Pattern"
{
    Extensible = false;
    Caption = 'Patrón de fechas';

    value(0; "Desde fecha inicial")
    {
        Caption = 'Desde fecha inicial';
    }

    value(1; "Inicio de mes")
    {
        Caption = 'Inicio de cada mes';
    }

    value(2; "Fin de mes")
    {
        Caption = 'Fin de cada mes';
    }

    value(3; Bimestral)
    {
        Caption = 'Bimestral';
    }

    value(4; Trimestral)
    {
        Caption = 'Trimestral';
    }

    value(5; Cuatrimestral)
    {
        Caption = 'Cuatrimestral';
    }

    value(6; Semestral)
    {
        Caption = 'Semestral';
    }

    value(7; Anual)
    {
        Caption = 'Anual';
    }
}
