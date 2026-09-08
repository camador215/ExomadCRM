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
            column(DocumentDate2; Format("Document Date", 0, '<Day,2>/<Month,2>/<Year4>'))
            {
            }
        }
        add(Line)
        {
            column(LocationCode; "Location Code")
            {
            }
            column(UnitPrice; "Unit Price")
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