table 80101 "DIMA Opportunity Broker"
{
    Caption = 'Broker de oportunidad';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Opportunity No."; Code[20])
        {
            Caption = 'N.º oportunidad';
            TableRelation = Opportunity."No.";
        }

        field(2; "Line No."; Integer)
        {
            Caption = 'N.º línea';
        }

        field(10; Activo; Boolean)
        {
            Caption = 'Activo';
        }

        field(11; "Contact No."; Code[20])
        {
            Caption = 'No. contacto';
            TableRelation = Contact."No.";

            trigger OnValidate()
            var
                Contact: Record Contact;
                BrokerLine: Record "DIMA Opportunity Broker";
            begin
                Broker := '';

                if "Contact No." = '' then
                    Error('Debe indicar un contacto.');

                BrokerLine.SetRange("Opportunity No.", "Opportunity No.");
                BrokerLine.SetRange("Contact No.", "Contact No.");
                BrokerLine.SetFilter("Line No.", '<>%1', "Line No.");
                if BrokerLine.FindFirst() then
                    Error('El contacto ya está asignado como broker en esta oportunidad.');

                if Contact.Get("Contact No.") then
                    Broker := Contact.Name;
            end;
        }

        field(12; Broker; Text[100])
        {
            Caption = 'Broker';
            Editable = false;
        }

        field(13; Representa; Enum "DIMA Opportunity Broker Role")
        {
            Caption = 'Representa';

            trigger OnValidate()
            begin
                if Format(Representa) = '' then
                    Error('Debe indicar si representa a Comprador o Vendedor.');
            end;
        }

        field(14; Observaciones; Text[250])
        {
            Caption = 'Observaciones';
        }
    }

    keys
    {
        key(PK; "Opportunity No.", "Line No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
        BrokerLine: Record "DIMA Opportunity Broker";
    begin
        if "Line No." = 0 then begin
            BrokerLine.Reset();
            BrokerLine.SetRange("Opportunity No.", "Opportunity No.");

            if BrokerLine.FindLast() then
                "Line No." := BrokerLine."Line No." + 10000
            else
                "Line No." := 10000;
        end;
    end;
}
