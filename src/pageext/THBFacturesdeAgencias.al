pageextension 50001 THBFacturesdeAgencias extends "QHT Facturas de Agencias"
{
    layout
    {
        AddAfter("Importe total CC")
        {
            Field("CC Importe cobrado registrado"; Rec."CC Importe cobrado registrado")
            {
            }
            Field("ImportePendiente"; wPendiente)
            {
                ApplicationArea = All;
                Caption = 'Importe Pendiente';
            }
        }
        AddAfter("Referencia Fra.")
        {
            Field("Bono"; wBono)
            {
                ApplicationArea = All;
                Caption = 'Bono';
            }
        }
        AddAfter("Cliente")
        {
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
        //THB-101023-IFF
        wPendiente := 0;
        wBono := '';
        wNombre := '';
        rLineas.SETRANGE(rLineas.Factura, rec.Factura);
        IF rLineas.FIND('-') THEN BEGIN
            wBono := rLineas.Bono;
            rReserva.SETRANGE(rReserva.Ano, rLineas."Ano reserva");
            rReserva.SETRANGE(rReserva.Reserva, rLineas.Reserva);
            rReserva.SETRANGE(rReserva.Desglose, rLineas.Desglose);
            rReserva.SETRANGE(rReserva.Hotel, rLineas.Hotel);
            IF rReserva.FIND('-') THEN wNombre := rReserva."Apellido 1er. Ocupante";
        END;
        wPendiente := rec."Importe total CC" - rec."CC Importe cobrado registrado";
        //FIN THB-101023-IFF
    end;

    var
        wPendiente: Decimal;
        wBono: Text;
        wNombre: Text;

}
