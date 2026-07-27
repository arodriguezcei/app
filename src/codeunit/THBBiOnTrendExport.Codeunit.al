codeunit 50050 "THB BiOnTrend Export"
{
    // THB-130426-IFF: Codeunit exportacion datos BiOnTrend (Sinergycs).
    // Genera 13 ficheros CSV para integracion con plataforma BI.
    // Ruta: \\192.168.10.201\BiOnTrend\<Hotel>\
    // OnRun = modo diario. Report 50050 = modo completo (desde 2019).


    trigger OnRun()
    begin
        ExportarDatos(FALSE, '');
    end;

    var
        gRutaSalida: Text[250];
        gModoCompleto: Boolean;
        gFichero: Text;
        gFechaDesde: Date;
        gFechaHasta: Date;
        gTempBlob: Codeunit "Temp Blob";
        gOutStream: OutStream;
        gInStream: InStream;
        gRegistros: Integer;
        gTotal: Integer;
        gDialog: Dialog;
        SEP: Text[1];
        Text000: Label 'Exportando datos BiOnTrend...\\Fichero: #1################\\Registro: #2######## de #3########';
        Text001: Label 'Exportacion BiOnTrend completada. %1 ficheros generados en: %2';
        Text002: Label 'No se ha podido obtener el hotel de trabajo del usuario.';

    procedure ExportarDatos(pModoCompleto: Boolean; pRutaSalida: Text[250])
    var
        lUsr: Record "QHT Usuarios";
    begin
        IF pRutaSalida = '' THEN BEGIN
            IF lUsr.GET(USERID) THEN
                pRutaSalida := '\\192.168.10.201\BiOnTrend\' + lUsr."Hotel de trabajo" + '\'
            ELSE
                ERROR(Text002);
        END;

        gModoCompleto := pModoCompleto;
        gRutaSalida := pRutaSalida;
        SEP := ',';

        IF gModoCompleto THEN BEGIN
            gFechaDesde := DMY2DATE(1, 1, 2019);
            gFechaHasta := CALCDATE('+1A', TODAY);
        END ELSE BEGIN
            gFechaDesde := CALCDATE('-30D', TODAY);
            gFechaHasta := CALCDATE('+1A', TODAY);
        END;

        gDialog.OPEN(Text000);

        gDialog.UPDATE(1, 'Reserva');
        GenerarFicheroReserva;

        gDialog.UPDATE(1, 'Capacidad');
        GenerarFicheroCapacidad;

        gDialog.UPDATE(1, 'Bloqueo');
        GenerarFicheroBloqueo;

        gDialog.UPDATE(1, 'Servicio Extra');
        GenerarFicheroServicioExtra;

        gDialog.UPDATE(1, 'Hotel');
        GenerarFicheroHotel;

        gDialog.UPDATE(1, 'Canal');
        GenerarFicheroCanal;

        gDialog.UPDATE(1, 'Segmento');
        GenerarFicheroSegmento;

        gDialog.UPDATE(1, 'Regimen');
        GenerarFicheroRegimen;

        gDialog.UPDATE(1, 'Tarifa');
        GenerarFicheroTarifa;

        gDialog.UPDATE(1, 'Tipo Habitacion');
        GenerarFicheroTipoHabitacion;

        gDialog.UPDATE(1, 'Pais');
        GenerarFicheroPais;

        gDialog.UPDATE(1, 'Cliente');
        GenerarFicheroCliente;

        gDialog.UPDATE(1, 'Estado Reserva');
        GenerarFicheroEstadoReserva;

        gDialog.CLOSE;
        MESSAGE(Text001, 13, gRutaSalida);
    end;

    local procedure GenerarFicheroReserva()
    var
        lRvaDia: Record 7000186;
        lRva: Record 7000176;
        lLinea: Text[1024];
        lIDReserva: Text[50];
        lFecha: Date;
        lImpNeto: Decimal;
        lImpServicios: Decimal;
        lImpComision: Decimal;
        lImpIVA: Decimal;
        lImpDescuento: Decimal;
        lImpOtros: Decimal;
    begin
        Clear(gTempBlob);
        gTempBlob.CreateOutStream(gOutStream, TextEncoding::UTF8);

        gOutStream.WriteText(
          'ID_Reserva' + SEP + 'ID_Hotel' + SEP +
          'ID_Estado_Reserva' + SEP + 'Fecha_Venta' + SEP +
          'ID_Segmento' + SEP + 'ID_Cliente' + SEP +
          'ID_Canal' + SEP + 'Fecha_Extraccion' + SEP +
          'Entrada' + SEP + 'Salida' + SEP +
          'Noches' + SEP + 'ID_Tipo_Habitacion' + SEP +
          'ID_Regimen' + SEP + 'ID_Habitacion' + SEP +
          'Adultos' + SEP + 'Ninos' + SEP +
          'Cunas' + SEP + 'Importe_Neto' + SEP +
          'Importe_Comision' + SEP + 'Importe_IVA' + SEP +
          'Importe_Servicios' + SEP + 'Importe_Descuento' + SEP +
          'Importe_Otros' + SEP + 'ID_Tarifa' + SEP +
          'ID_Pais' + SEP + 'Fecha_Cancelacion' + SEP +
          'Es_Ficticia' + Format('\r\n')
        );

        lRvaDia.RESET;
        lRvaDia.SETRANGE(Fecha, gFechaDesde, gFechaHasta);

        gTotal := lRvaDia.COUNT;
        gRegistros := 0;
        gDialog.UPDATE(3, gTotal);

        IF lRvaDia.FINDSET THEN
            REPEAT
                gRegistros := gRegistros + 1;
                IF (gRegistros MOD 500) = 0 THEN
                    gDialog.UPDATE(2, gRegistros);

                IF lRva.GET(lRvaDia.Hotel, lRvaDia.Ano, lRvaDia.Reserva, lRvaDia.Desglose) THEN BEGIN

                    lFecha := lRvaDia.Fecha;

                    lImpNeto := 0;
                    lImpServicios := 0;
                    lImpComision := 0;
                    lImpIVA := 0;
                    lImpDescuento := 0;
                    lImpOtros := 0;

                    IF lFecha <= TODAY THEN
                        ObtenerImportesProdReal(
                          lRvaDia.Hotel, lRvaDia.Ano, lRvaDia.Reserva, lRvaDia.Desglose,
                          lFecha, lImpNeto, lImpServicios, lImpComision, lImpIVA, lImpDescuento, lImpOtros)
                    ELSE
                        ObtenerImportesProdFutura(
                          lRvaDia.Hotel, lRvaDia.Ano, lRvaDia.Reserva, lRvaDia.Desglose,
                          lFecha, lImpNeto, lImpServicios, lImpComision, lImpIVA, lImpDescuento, lImpOtros);

                    lIDReserva := lRvaDia.Hotel + '-' + FORMAT(lRvaDia.Ano) + '-' +
                                  lRvaDia.Reserva + '-' + lRvaDia.Desglose;

                    lLinea :=
                      Limpiar(lIDReserva) + SEP +
                      Limpiar(lRvaDia.Hotel) + SEP +
                      FORMAT(lRvaDia."Estado reserva") + SEP +
                      FmtFecha(lRva."Fecha venta") + SEP +
                      Limpiar(lRvaDia.Segmento) + SEP +
                      Limpiar(lRva.Cliente) + SEP +
                      Limpiar(lRvaDia."Canal/Origen") + SEP +
                      FmtFecha(TODAY) + SEP +
                      FmtFecha(lFecha) + SEP +
                      FmtFecha(lFecha) + SEP +
                      FORMAT(lRva.Noches) + SEP +
                      Limpiar(lRvaDia."Tipo hab. uso") + SEP +
                      Limpiar(lRvaDia."Regimen uso") + SEP +
                      Limpiar(lRvaDia.Habitacion) + SEP +
                      FmtEntero(lRvaDia.AD) + SEP +
                      FmtEntero(lRvaDia.NI) + SEP +
                      FmtEntero(lRvaDia.CU) + SEP +
                      FmtDec(lImpNeto) + SEP +
                      FmtDec(lImpComision) + SEP +
                      FmtDec(lImpIVA) + SEP +
                      FmtDec(lImpServicios) + SEP +
                      FmtDec(lImpDescuento) + SEP +
                      FmtDec(lImpOtros) + SEP +
                      Limpiar(lRvaDia."Cod. tarifa") + SEP +
                      Limpiar(lRva.Nacionalidad) + SEP +
                      FmtFecha(lRva."Fecha Borrado") + SEP +
                      '0';

                    gOutStream.WriteText(lLinea + Format('\r\n'));

                END;

            UNTIL lRvaDia.NEXT = 0;

        gTempBlob.CreateInStream(gInStream);
        gFichero := 'Reserva.csv';
        DownloadFromStream(gInStream, 'BiOnTrend Export', '', 'CSV Files (*.csv)|*.csv', gFichero);
    end;

    local procedure ObtenerImportesProdReal(pHotel: Code[10]; pAnyo: Integer; pReserva: Code[10]; pDesglose: Code[10]; pFechaCargo: Date; var pNeto: Decimal; var pServicios: Decimal; var pComision: Decimal; var pIVA: Decimal; var pDescuento: Decimal; var pOtros: Decimal)
    var
        lProd: Record 7000206;
        lProdAloj: Decimal;
        lProdPens: Decimal;
        lPctGuias: Decimal;
        lPctImpuesto: Decimal;
    begin
        pNeto := 0;
        pServicios := 0;
        pComision := 0;
        pIVA := 0;
        pDescuento := 0;
        pOtros := 0;
        lProdAloj := 0;
        lProdPens := 0;
        lPctGuias := 0;
        lPctImpuesto := 0;

        lProd.RESET;
        lProd.SETRANGE(Hotel, pHotel);
        lProd.SETRANGE("Ano reserva", pAnyo);
        lProd.SETRANGE(Reserva, pReserva);
        lProd.SETRANGE(Desglose, pDesglose);
        lProd.SETRANGE("Fecha cargo", pFechaCargo);

        IF lProd.FINDSET THEN
            REPEAT
                CASE lProd."Formato linea" OF
                    lProd."Formato linea"::Estancia:
                        BEGIN
                            IF lProd.Alojamiento THEN
                                lProdAloj := lProdAloj + lProd."Total importe produccion"
                            ELSE
                                lProdPens := lProdPens + lProd."Total importe produccion";

                            IF lProd."% Guias" <> 0 THEN
                                lPctGuias := lProd."% Guias";
                            IF lProd."% Impuesto" <> 0 THEN
                                lPctImpuesto := lProd."% Impuesto";
                        END;
                    lProd."Formato linea"::Descuento:
                        pDescuento := pDescuento + lProd."Total importe";
                    lProd."Formato linea"::Extra:
                        pOtros := pOtros + lProd."Total importe produccion";
                END;
            UNTIL lProd.NEXT = 0;

        IF lPctGuias <> 0 THEN BEGIN
            pComision := ROUND((lProdAloj + lProdPens) * lPctGuias / 100, 0.01);
            pNeto := lProdAloj - ROUND(lProdAloj * lPctGuias / 100, 0.01);
            pServicios := lProdPens - ROUND(lProdPens * lPctGuias / 100, 0.01);
        END ELSE BEGIN
            pNeto := lProdAloj;
            pServicios := lProdPens;
        END;

        IF lPctImpuesto <> 0 THEN
            pIVA := ROUND((lProdAloj + lProdPens) * lPctImpuesto / 100, 0.01);
    end;

    local procedure ObtenerImportesProdFutura(pHotel: Code[10]; pAnyo: Integer; pReserva: Code[10]; pDesglose: Code[10]; pFechaCargo: Date; var pNeto: Decimal; var pServicios: Decimal; var pComision: Decimal; var pIVA: Decimal; var pDescuento: Decimal; var pOtros: Decimal)
    var
        lProd: Record "qht lineas de produccion";
        lProdAloj: Decimal;
        lProdPens: Decimal;
        lPctGuias: Decimal;
        lPctImpuesto: Decimal;
    begin
        pNeto := 0;
        pServicios := 0;
        pComision := 0;
        pIVA := 0;
        pDescuento := 0;
        pOtros := 0;
        lProdAloj := 0;
        lProdPens := 0;
        lPctGuias := 0;
        lPctImpuesto := 0;

        lProd.RESET;
        lProd.SETRANGE(Hotel, pHotel);
        lProd.SETRANGE("Ano reserva", pAnyo);
        lProd.SETRANGE(Reserva, pReserva);
        lProd.SETRANGE(Desglose, pDesglose);
        lProd.SETRANGE("Fecha cargo", pFechaCargo);

        IF lProd.FINDSET THEN
            REPEAT
                CASE lProd."Formato linea" OF
                    lProd."Formato linea"::Estancia:
                        BEGIN
                            IF lProd.Alojamiento THEN
                                lProdAloj := lProdAloj + lProd."Total importe produccion"
                            ELSE
                                lProdPens := lProdPens + lProd."Total importe produccion";

                            IF lProd."% Guias" <> 0 THEN
                                lPctGuias := lProd."% Guias";
                            IF lProd."% Impuesto" <> 0 THEN
                                lPctImpuesto := lProd."% Impuesto";
                        END;
                    lProd."Formato linea"::Descuento:
                        pDescuento := pDescuento + lProd."Total importe";
                    lProd."Formato linea"::Extra:
                        pOtros := pOtros + lProd."Total importe produccion";
                END;
            UNTIL lProd.NEXT = 0;

        IF lPctGuias <> 0 THEN BEGIN
            pComision := ROUND((lProdAloj + lProdPens) * lPctGuias / 100, 0.01);
            pNeto := lProdAloj - ROUND(lProdAloj * lPctGuias / 100, 0.01);
            pServicios := lProdPens - ROUND(lProdPens * lPctGuias / 100, 0.01);
        END ELSE BEGIN
            pNeto := lProdAloj;
            pServicios := lProdPens;
        END;

        IF lPctImpuesto <> 0 THEN
            pIVA := ROUND((lProdAloj + lProdPens) * lPctImpuesto / 100, 0.01);
    end;

    local procedure GenerarFicheroCapacidad()
    var
        lTipoHab: Record 7000115;
        lFecha: Date;
    begin
        Clear(gTempBlob);
        gTempBlob.CreateOutStream(gOutStream, TextEncoding::UTF8);
        gOutStream.WriteText('ID_Hotel' + SEP + 'Fecha_Hasta' + SEP +
                    'ID_Tipo_Habitacion' + SEP + 'Nro_Habitaciones' + Format('\r\n'));

        lTipoHab.RESET;
        lTipoHab.SETRANGE(Real, TRUE);

        IF lTipoHab.FINDSET THEN
            REPEAT
                lFecha := gFechaDesde;
                WHILE lFecha <= gFechaHasta DO BEGIN
                    gOutStream.WriteText(
                      Limpiar(lTipoHab.Hotel) + SEP +
                      FmtFecha(lFecha) + SEP +
                      Limpiar(lTipoHab."Tipo habitacion") + SEP +
                      FORMAT(lTipoHab.Cantidad) + Format('\r\n')
                    );
                    lFecha := lFecha + 1;
                END;
            UNTIL lTipoHab.NEXT = 0;

        gTempBlob.CreateInStream(gInStream);
        gFichero := 'Capacidad.csv';
        DownloadFromStream(gInStream, 'BiOnTrend Export', '', 'CSV Files (*.csv)|*.csv', gFichero);
    end;

    local procedure GenerarFicheroBloqueo()
    var
        lInc: Record "QHT Incidencias SSTT diariasTS";
        lTipoHab: Code[10];
        lHotelAnt: Code[10];
        lFechaAnt: Date;
        lTipoAnt: Code[10];
        lContador: Integer;
    begin
        Clear(gTempBlob);
        gTempBlob.CreateOutStream(gOutStream, TextEncoding::UTF8);
        gOutStream.WriteText('ID_Hotel' + SEP + 'Fecha_Desde' + SEP + 'Fecha_Hasta' + SEP +
                    'ID_Tipo_Habitacion' + SEP + 'Nro_Habitaciones' + Format('\r\n'));

        lInc.RESET;
        lInc.SETCURRENTKEY(Hotel, Habitacion, "Esta bloqueada", Fecha);
        lInc.SETRANGE("Esta bloqueada", TRUE);
        lInc.SETRANGE(Fecha, gFechaDesde, gFechaHasta);

        lHotelAnt := '';
        lFechaAnt := 0D;
        lTipoAnt := '';
        lContador := 0;

        IF lInc.FINDSET THEN
            REPEAT
                lInc.CALCFIELDS("Tipo habitacion");
                lTipoHab := lInc."Tipo habitacion";

                IF (lInc.Hotel <> lHotelAnt) OR (lInc.Fecha <> lFechaAnt) OR (lTipoHab <> lTipoAnt) THEN BEGIN
                    IF lContador > 0 THEN
                        gOutStream.WriteText(
                          Limpiar(lHotelAnt) + SEP +
                          FmtFecha(lFechaAnt) + SEP +
                          FmtFecha(lFechaAnt) + SEP +
                          Limpiar(lTipoAnt) + SEP +
                          FORMAT(lContador) + Format('\r\n')
                        );
                    lHotelAnt := lInc.Hotel;
                    lFechaAnt := lInc.Fecha;
                    lTipoAnt := lTipoHab;
                    lContador := 1;
                END ELSE
                    lContador := lContador + 1;

            UNTIL lInc.NEXT = 0;

        IF lContador > 0 THEN
            gOutStream.WriteText(
              Limpiar(lHotelAnt) + SEP +
              FmtFecha(lFechaAnt) + SEP +
              FmtFecha(lFechaAnt) + SEP +
              Limpiar(lTipoAnt) + SEP +
              FORMAT(lContador) + Format('\r\n')
            );

        gTempBlob.CreateInStream(gInStream);
        gFichero := 'Bloqueo.csv';
        DownloadFromStream(gInStream, 'BiOnTrend Export', '', 'CSV Files (*.csv)|*.csv', gFichero);
    end;

    local procedure GenerarFicheroServicioExtra()
    var
        lProdReal: Record 7000206;
        lProdFut: Record "qht lineas de produccion";
        lIDReserva: Text[50];
    begin
        Clear(gTempBlob);
        gTempBlob.CreateOutStream(gOutStream, TextEncoding::UTF8);
        gOutStream.WriteText(
          'ID_Reserva' + SEP + 'ID_Hotel' + SEP +
          'Fecha_Servicio' + SEP + 'ID_Tipo_Servicio' + SEP +
          'Servicio' + SEP + 'Unidades' + SEP +
          'Precio_Unitario' + SEP + 'Descuento' + SEP +
          'IVA' + SEP + 'Importe'
        );

        lProdReal.RESET;
        lProdReal.SETRANGE("Fecha cargo", gFechaDesde, TODAY);
        lProdReal.SETFILTER("Formato linea", '%1', lProdReal."Formato linea"::Extra);

        IF lProdReal.FINDSET THEN
            REPEAT
                lIDReserva := lProdReal.Hotel + '-' + FORMAT(lProdReal."Ano reserva") + '-' +
                              lProdReal.Reserva + '-' + lProdReal.Desglose;
                gOutStream.WriteText(
                  Limpiar(lIDReserva) + SEP +
                  Limpiar(lProdReal.Hotel) + SEP +
                  FmtFecha(lProdReal."Fecha cargo") + SEP +
                  Limpiar(lProdReal.Centro) + SEP +
                  Limpiar(lProdReal.Concepto) + SEP +
                  FmtDec(lProdReal.Cantidad) + SEP +
                  FmtDec(lProdReal.Importe) + SEP +
                  '0.00' + SEP +
                  FmtDec(ROUND(lProdReal."Total importe produccion" *
                         lProdReal."% Impuesto" / 100, 0.01)) + SEP +
                  FmtDec(lProdReal."Total importe produccion") + Format('\r\n')
                );
            UNTIL lProdReal.NEXT = 0;

        lProdFut.RESET;
        lProdFut.SETRANGE("Fecha cargo", TODAY + 1, gFechaHasta);
        lProdFut.SETFILTER("Formato linea", '%1', lProdFut."Formato linea"::Extra);

        IF lProdFut.FINDSET THEN
            REPEAT
                lIDReserva := lProdFut.Hotel + '-' + FORMAT(lProdFut."Ano reserva") + '-' +
                              lProdFut.Reserva + '-' + lProdFut.Desglose;
                gOutStream.WriteText(
                  Limpiar(lIDReserva) + SEP +
                  Limpiar(lProdFut.Hotel) + SEP +
                  FmtFecha(lProdFut."Fecha cargo") + SEP +
                  Limpiar(lProdFut.Centro) + SEP +
                  Limpiar(lProdFut.Concepto) + SEP +
                  FmtDec(lProdFut.Cantidad) + SEP +
                  FmtDec(lProdFut.Importe) + SEP +
                  '0.00' + SEP +
                  FmtDec(ROUND(lProdFut."Total importe produccion" *
                         lProdFut."% Impuesto" / 100, 0.01)) + SEP +
                  FmtDec(lProdFut."Total importe produccion") + Format('\r\n')
                );
            UNTIL lProdFut.NEXT = 0;

        gTempBlob.CreateInStream(gInStream);
        gFichero := 'ServiciosExtra.csv';
        DownloadFromStream(gInStream, 'BiOnTrend Export', '', 'CSV Files (*.csv)|*.csv', gFichero);
    end;

    local procedure GenerarFicheroHotel()
    var
        lHotel: Record 7000110;
    begin
        Clear(gTempBlob);
        gTempBlob.CreateOutStream(gOutStream, TextEncoding::UTF8);
        gOutStream.WriteText('ID_Hotel' + SEP + 'Descripcion');
        lHotel.RESET;
        IF lHotel.FINDSET THEN
            REPEAT
                gOutStream.WriteText(Limpiar(lHotel.Hotel) + SEP + Limpiar(lHotel.Nombre) + Format('\r\n'));
            UNTIL lHotel.NEXT = 0;
        gTempBlob.CreateInStream(gInStream);
        gFichero := 'Hotel.csv';
        DownloadFromStream(gInStream, 'BiOnTrend Export', '', 'CSV Files (*.csv)|*.csv', gFichero);
    end;

    local procedure GenerarFicheroCanal()
    var
        lCanal: Record 7001016;
        lHotel: Record 7000110;
    begin
        Clear(gTempBlob);
        gTempBlob.CreateOutStream(gOutStream, TextEncoding::UTF8);
        gOutStream.WriteText('ID_Hotel' + SEP + 'ID_Canal' + SEP + 'Descripcion' + Format('\r\n'));
        lHotel.RESET;
        IF lHotel.FINDSET THEN
            REPEAT
                lCanal.RESET;
                IF lCanal.FINDSET THEN
                    REPEAT
                        gOutStream.WriteText(Limpiar(lHotel.Hotel) + SEP + Limpiar(lCanal."Canal/Origen") + SEP + Limpiar(lCanal.Descripcion) + Format('\r\n'));
                    UNTIL lCanal.NEXT = 0;
            UNTIL lHotel.NEXT = 0;
        gTempBlob.CreateInStream(gInStream);
        gFichero := 'Canal.csv';
        DownloadFromStream(gInStream, 'BiOnTrend Export', '', 'CSV Files (*.csv)|*.csv', gFichero);
    end;

    local procedure GenerarFicheroSegmento()
    var
        lSeg: Record 7001017;
        lHotel: Record 7000110;
    begin
        Clear(gTempBlob);
        gTempBlob.CreateOutStream(gOutStream, TextEncoding::UTF8);
        gOutStream.WriteText('ID_Hotel' + SEP + 'ID_Segmento' + SEP + 'Descripcion' + Format('\r\n'));
        lHotel.RESET;
        IF lHotel.FINDSET THEN
            REPEAT
                lSeg.RESET;
                IF lSeg.FINDSET THEN
                    REPEAT
                        gOutStream.WriteText(Limpiar(lHotel.Hotel) + SEP + Limpiar(lSeg.Segmento) + SEP + Limpiar(lSeg.Descripcion) + Format('\r\n'));
                    UNTIL lSeg.NEXT = 0;
            UNTIL lHotel.NEXT = 0;
        gTempBlob.CreateInStream(gInStream);
        gFichero := 'Segmento.csv';
        DownloadFromStream(gInStream, 'BiOnTrend Export', '', 'CSV Files (*.csv)|*.csv', gFichero);
    end;

    local procedure GenerarFicheroRegimen()
    var
        lReg: Record 7000112;
        lHotel: Record 7000110;
    begin
        Clear(gTempBlob);
        gTempBlob.CreateOutStream(gOutStream, TextEncoding::UTF8);
        gOutStream.WriteText('ID_Hotel' + SEP + 'ID_Regimen' + SEP + 'Descripcion' + Format('\r\n'));
        lHotel.RESET;
        IF lHotel.FINDSET THEN
            REPEAT
                lReg.RESET;
                IF lReg.FINDSET THEN
                    REPEAT
                        gOutStream.WriteText(Limpiar(lHotel.Hotel) + SEP + Limpiar(lReg.Regimen) + SEP + Limpiar(lReg.Descripcion));
                    UNTIL lReg.NEXT = 0;
            UNTIL lHotel.NEXT = 0;
        gTempBlob.CreateInStream(gInStream);
        gFichero := 'Regimen.csv';
        DownloadFromStream(gInStream, 'BiOnTrend Export', '', 'CSV Files (*.csv)|*.csv', gFichero);
    end;

    local procedure GenerarFicheroTarifa()
    var
        lTar: Record 7000985;
    begin
        Clear(gTempBlob);
        gTempBlob.CreateOutStream(gOutStream, TextEncoding::UTF8);
        gOutStream.WriteText('ID_Hotel' + SEP + 'ID_Tarifa' + SEP + 'Descripcion' + Format('\r\n'));
        lTar.RESET;
        IF lTar.FINDSET THEN
            REPEAT
                gOutStream.WriteText(Limpiar(lTar.Hotel) + SEP + Limpiar(lTar."Cod. Tarifa") + SEP + Limpiar(lTar.Descripcion) + Format('\r\n'));
            UNTIL lTar.NEXT = 0;
        gTempBlob.CreateInStream(gInStream);
        gFichero := 'Tarifa.csv';
        DownloadFromStream(gInStream, 'BiOnTrend Export', '', 'CSV Files (*.csv)|*.csv', gFichero);
    end;

    local procedure GenerarFicheroTipoHabitacion()
    var
        lTH: Record 7000115;
    begin
        Clear(gTempBlob);
        gTempBlob.CreateOutStream(gOutStream, TextEncoding::UTF8);
        gOutStream.WriteText('ID_Hotel' + SEP + 'ID_Tipo_Habitacion' + SEP + 'Descripcion');
        lTH.RESET;
        IF lTH.FINDSET THEN
            REPEAT
                gOutStream.WriteText(Limpiar(lTH.Hotel) + SEP + Limpiar(lTH."Tipo habitacion") + SEP + Limpiar(lTH.Observaciones));
            UNTIL lTH.NEXT = 0;
        gTempBlob.CreateInStream(gInStream);
        gFichero := 'TipoHabitacion.csv';
        DownloadFromStream(gInStream, 'BiOnTrend Export', '', 'CSV Files (*.csv)|*.csv', gFichero);
    end;

    local procedure GenerarFicheroPais()
    var
        lPais: Record 9;
        lHotel: Record 7000110;
    begin
        Clear(gTempBlob);
        gTempBlob.CreateOutStream(gOutStream, TextEncoding::UTF8);
        gOutStream.WriteText('ID_Hotel' + SEP + 'ID_Pais' + SEP + 'Descripcion' + Format('\r\n'));
        lHotel.RESET;
        IF lHotel.FINDSET THEN
            REPEAT
                lPais.RESET;
                IF lPais.FINDSET THEN
                    REPEAT
                        gOutStream.WriteText(Limpiar(lHotel.Hotel) + SEP + Limpiar(lPais.Code) + SEP + Limpiar(lPais.Name));
                    UNTIL lPais.NEXT = 0;
            UNTIL lHotel.NEXT = 0;
        gTempBlob.CreateInStream(gInStream);
        gFichero := 'Pais.csv';
        DownloadFromStream(gInStream, 'BiOnTrend Export', '', 'CSV Files (*.csv)|*.csv', gFichero);
    end;

    local procedure GenerarFicheroCliente()
    var
        lCli: Record Customer;
        lHotel: Record 7000110;
    begin
        Clear(gTempBlob);
        gTempBlob.CreateOutStream(gOutStream, TextEncoding::UTF8);
        gOutStream.WriteText('ID_Hotel' + SEP + 'ID_Cliente' + SEP + 'Descripcion' + Format('\r\n'));
        lHotel.RESET;
        IF lHotel.FINDSET THEN
            REPEAT
                lCli.RESET;
                IF lCli.FINDSET THEN
                    REPEAT
                        gOutStream.WriteText(Limpiar(lHotel.Hotel) + SEP + Limpiar(lCli."No.") + SEP + Limpiar(lCli.Name) + Format('\r\n'));
                    UNTIL lCli.NEXT = 0;
            UNTIL lHotel.NEXT = 0;
        gTempBlob.CreateInStream(gInStream);
        gFichero := 'Cliente.csv';
        DownloadFromStream(gInStream, 'BiOnTrend Export', '', 'CSV Files (*.csv)|*.csv', gFichero);
    end;

    local procedure GenerarFicheroEstadoReserva()
    var
        lHotel: Record 7000110;
    begin
        Clear(gTempBlob);
        gTempBlob.CreateOutStream(gOutStream, TextEncoding::UTF8);
        gOutStream.WriteText('ID_Hotel' + SEP + 'ID_Estado_Reserva' + SEP + 'Descripcion' + Format('\r\n'));
        lHotel.RESET;
        IF lHotel.FINDSET THEN
            REPEAT
                gOutStream.WriteText(Limpiar(lHotel.Hotel) + SEP + '0' + SEP + 'Reserva' + Format('\r\n'));
                gOutStream.WriteText(Limpiar(lHotel.Hotel) + SEP + '1' + SEP + 'Anulada' + Format('\r\n'));
                gOutStream.WriteText(Limpiar(lHotel.Hotel) + SEP + '2' + SEP + 'Entrada' + Format('\r\n'));
                gOutStream.WriteText(Limpiar(lHotel.Hotel) + SEP + '3' + SEP + 'Salida' + Format('\r\n'));
                gOutStream.WriteText(Limpiar(lHotel.Hotel) + SEP + '4' + SEP + 'No Show' + Format('\r\n'));
            UNTIL lHotel.NEXT = 0;
        gTempBlob.CreateInStream(gInStream);
        gFichero := 'EstadoReserva.csv';
        DownloadFromStream(gInStream, 'BiOnTrend Export', '', 'CSV Files (*.csv)|*.csv', gFichero);
    end;

    local procedure FmtFecha(pFecha: Date): Text[10]
    begin
        IF pFecha = 0D THEN
            EXIT('');
        EXIT(FORMAT(pFecha, 0, '<Year4>-<Month,2>-<Day,2>'));
    end;

    local procedure FmtDec(pDec: Decimal): Text[20]
    var
        lTxt: Text[20];
    begin
        lTxt := FORMAT(pDec, 0, '<Sign><Integer><Decimals,3>');
        EXIT(CONVERTSTR(lTxt, ',', '.'));
    end;

    local procedure FmtEntero(pDec: Decimal): Text[10]
    begin
        EXIT(FORMAT(ROUND(pDec, 1, '<'), 0, '<Integer>'));
    end;

    local procedure Limpiar(pTexto: Text[250]): Text[250]
    begin
        pTexto := CONVERTSTR(pTexto, '"', ' ');
        pTexto := CONVERTSTR(pTexto, ',', ' ');
        EXIT(pTexto);
    end;
}

