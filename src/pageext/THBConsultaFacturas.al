pageextension 60002 THBConsultaFacturas extends "QHT Consulta de facturas"
{
    Editable = False;

    layout
    {
        addFirst("Control1")
        {
            Field("Hotel"; Rec.Hotel)
            {
                ApplicationArea = All;
                Caption = 'Hotel';
            }
            Field("NombreHotel"; wNombreHotel)
            {
                ApplicationArea = All;
                Caption = 'Nombre Comercial';
            }
        }
        addAfter("Cliente")
        {
            Field("NombreCliente"; wNombreCli)
            {
                ApplicationArea = All;
                Caption = 'Nombre Cliente';
            }
            Field("Bono"; wBono)
            {
                ApplicationArea = All;
                Caption = 'Bono';
            }
            Field("RefFactura"; wRefFra)
            {
                ApplicationArea = All;
                Caption = 'Referencia Factura';
            }
            Field("Nombre"; wName)
            {
                ApplicationArea = All;
                Caption = 'Nombre';
            }
            Field("NumCobro"; wCobro)
            {
                ApplicationArea = All;
                Caption = 'Número de Cobro';
            }
            Field("FecEntrada"; wFecEntrada)
            {
                ApplicationArea = All;
                Caption = 'Fecha de Entrada';
            }
            Field("FecSalida"; wFecSalida)
            {
                ApplicationArea = All;
                Caption = 'Fecha de Salida';
            }
            Field("Observaciones"; Rec.Observaciones)
            {
                ApplicationArea = All;
                Caption = 'Observaciones';
            }
            Field("Destino"; rec.Destino)
            {
                ApplicationArea = All;
                Caption = 'Destino';
            }
            Field("ImpPendCobroLoc"; rec."Importe pendiente cobro(LOCAL)")
            {
                ApplicationArea = All;
                Caption = 'Importe Pendiente de Cobro Local';
            }
            Field("NumRemesa"; rec."No. Remesa Fact. Electronica")
            {
                ApplicationArea = All;
                Caption = 'Número de Remesa Fact. Electrónica';
            }
            Field("FactElecAct"; Rec."Fact. Electronica Activada")
            {
                ApplicationArea = All;
                Caption = 'Facturas Electrónicas Activada';
            }
        }
    }

    actions
    {
        addlast("Navigation")
        {
            action("ReplicaFact")
            {
                ApplicationArea = All;
                Caption = 'Replicación Facturas';

                trigger OnAction()
                var
                begin
                    IF COMPANYNAME = 'THB Gestión' THEN BEGIN
                        IF CONFIRM('Este proceso actualizar tanto las facturas como los cobros y puede demorarse unos minutos, ¨desea continuar?') THEN
                            cIFF.fActualizaPend2
                        ELSE
                            MESSAGE('No se han hecho cambios.')
                    END ELSE
                        ERROR('Esta función sólo puede ser usada en THB Gestión.');

                end;
            }
            action("ReplicaCob")
            {
                ApplicationArea = All;
                Caption = 'Replicación Cobros';

                trigger OnAction()
                var
                begin
                    cIFF.fActualizaCobros;

                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    var

    begin
        //NOMBRE COMERCIAL

        rHotel.SETRANGE(rHotel.Hotel, rec.Hotel);
        IF rHotel.FINDFIRST THEN wNombreHotel := rHotel.Nombre;

        //NUMERO DE BONO 1501/2017-THB-IFF

        wBono := '';
        wName := '';
        wCobro := 0;
        wNombreCli := '';
        wRefFra := '';
        rLinImp.SETRANGE(rLinImp.Factura, rec.Factura);
        IF rLinImp.FIND('-') THEN BEGIN
            wBono := rLinImp.Bono;
            wRefFra := rLinImp."Referencia Fra.";
            wName := rLinImp."Nombre cliente";
            wFecEntrada := rLinImp."Fecha entrada";
            wFecSalida := rLinImp."Fecha salida";
        END;

        rCustomer.SETRANGE(rCustomer."No.", rec.Cliente);
        IF rCustomer.FINDFIRST THEN wNombreCli := rCustomer.Name;

        //NUMERO DE COBRO 1501/2017-THB-IFF

        rCobrosDet.SETRANGE(rCobrosDet."Num. Relacion", rec.Factura);
        rCobrosDet.SETRANGE(rCobrosDet.Hotel, Rec.Hotel);
        IF rCobrosDet.FIND('-') THEN wCobro := rCobrosDet."Num. Cobro";
    end;


    var
        cIFF: Codeunit 50001;
        wRefFra: Code[30];
        rCustomer: Record 18;
        wNombreCli: Text[100];
        wNombreHotel: Text[200];
        rHotel: Record 7000110;
        wFecEntrada: Date;
        wFecSalida: Date;
        rLinImp: Record 7000200;
        wBono: Code[30];
        wName: Code[50];
        wCobro: Integer;
        rCobrosDet: Record 7000681;
}
