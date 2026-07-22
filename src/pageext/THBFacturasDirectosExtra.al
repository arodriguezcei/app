pageextension 50002 THBFacturasDirectosExtra extends "QHT Facturas Directos y Extras"
{
    layout
    {
        AddAfter(Factura)
        {
            Field("Bono"; wBono)
            {
                ApplicationArea = All;
                Caption = 'Bono';
            }
            Field("RefFra"; wRefFra)
            {
                ApplicationArea = All;
                Caption = 'Ref. Factura';
            }
            Field("Nombre"; wNombre)
            {
                ApplicationArea = All;
                Caption = 'Nombre';
            }
        }

    }

    trigger OnAfterGetRecord()
    var
        rLineas: Record "QHT Lineas factura impresion";
        rReserva: Record "QHT Reservas";
    begin
        wBono := '';
        wNombre := '';
        wRefFra := '';
        rLineas.SETRANGE(rLineas.Factura, rec.Factura);
        IF rLineas.FIND('-') THEN BEGIN
            wBono := rLineas.Bono;
            wRefFra := rLineas."Referencia Fra.";
            rReserva.SETRANGE(rReserva.Ano, rLineas."Ano reserva");
            rReserva.SETRANGE(rReserva.Reserva, rLineas.Reserva);
            rReserva.SETRANGE(rReserva.Desglose, rLineas.Desglose);
            rReserva.SETRANGE(rReserva.Hotel, rLineas.Hotel);
            IF rReserva.FIND('-') THEN wNombre := rReserva."Apellido 1er. Ocupante";
        END;
    end;

    var
        wBono: Text;
        wNombre: Text;
        wRefFra: Text;
}
