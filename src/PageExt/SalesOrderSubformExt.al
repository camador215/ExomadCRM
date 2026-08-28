pageextension 80104 "DIMA Sales Order Subform Ext" extends "Sales Order Subform"
{
    layout
    {
        modify("Description 2")
        {
            Visible = true;
            Caption = 'Descripción';
        }
    }
}