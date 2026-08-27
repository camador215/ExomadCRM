page 80103 "DIMA Opportunity Broker"
{
    PageType = ListPart;
    SourceTable = "DIMA Opportunity Broker";
    Caption = 'Brokers';

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field(Activo; Rec.Activo)
                {
                    ApplicationArea = All;
                    Caption = 'Activo';
                }

                field("Contact No."; Rec."Contact No.")
                {
                    ApplicationArea = All;
                    Caption = 'No. contacto';
                    ShowMandatory = true;
                }

                field(Broker; Rec.Broker)
                {
                    ApplicationArea = All;
                    Caption = 'Broker';
                    Editable = false;
                }

                field(Representa; Rec.Representa)
                {
                    ApplicationArea = All;
                    Caption = 'Representa';
                    ShowMandatory = true;
                }

                field(Observaciones; Rec.Observaciones)
                {
                    ApplicationArea = All;
                    Caption = 'Observaciones';
                }
            }
        }
    }
}
