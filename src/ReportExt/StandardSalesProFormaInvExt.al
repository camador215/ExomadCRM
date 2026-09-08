reportextension 80100 "Standard Sales ProForma Ext" extends "Standard Sales - Pro Forma Inv"
{

    dataset
    {
        add(Header)
        {
            column(CustomerRegistrationNumber; "Registration Number")
            {
            }
            column(DueDate; "Due Date")
            {
            }
        }
        add(Line)
        {
            column(LocationCode; "Location Code")
            {
            }
        }
    }
    rendering
    {
        layout(MiLayout)
        {
            Type = RDLC;
            LayoutFile = 'src/Layouts/Exomad_StandardSalesProFormaInv.rdlc';
            Caption = 'Factura Exomad Green';
            Summary = 'Factura CRM';
        }

    }
}