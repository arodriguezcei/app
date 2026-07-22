codeunit 50001 "IFF Funciones Varias"
{
    // 20/01/10 IFF Creacion de objeto
    // 20/01/10 IFF Anadida funcion focupantes para marcar los ocupantes como repetidores.
    // 20/01/10 IFF Anadida funcion fRepetidores, se llama desde el campo DNI de la tabla ocupantes.
    // 20/01/10 IFF Anadida funcion fRepRollBack, quita todas las marcas de la tabla ocupantes.
    // 21/01/10 IFF Anadida funcion focuDoc, modifica los nºs de documento eliminando los valores invalidos, puntos, guiones, blancos.
    // 21/01/10 IFF Anadida funcion fDocRollBack, restaura los cambios realizados en focuDoc
    // 02/03/17 IFF Anadido control para el numero de cuenta de las tasas de IET en la funcion fIET
    // 19/07/21 IFF Anadida funcion cambio de paises de 2 a 3 digitos.

    Permissions = TableData 17 = rimd,
                  TableData 21 = rimd,
                  TableData 25 = rimd,
                  TableData 112 = rimd,
                  TableData 120 = rimd,
                  TableData 121 = rimd,
                  TableData 122 = rimd,
                  TableData 123 = rimd,
                  TableData 124 = rimd,
                  TableData 125 = rimd,
                  TableData 254 = rimd,
                  TableData 288 = rimd,
                  TableData 379 = rimd,
                  TableData 380 = rimd,
                  TableData 5802 = rimd,
                  TableData 7000002 = rimd,
                  TableData 7000003 = rimd,
                  TableData 7000004 = rimd;

    trigger onRun()
    begin


    end;

    var
        wtest: Text;
        rUsr: Record 7000104;
        Ventana: Dialog;
        wFecha: Date;
        TextErrorPFo: Label 'El hotel %1 no esta parametrizado en Front office';
        TextErrorPermitirFPolicia: Label 'No esta permitido el envio de Ficha Policia parcial en el hotel %1';
        TextErrorEdadDNI: Label 'El parametro de Front office Edad minima DNI no esta parametrizado';

    local procedure fCarteraMod()
    var
        r7000002: Record 7000002;
    begin

        r7000002.SETRANGE(r7000002."Entry No.", 5320335);
        IF r7000002.FINDFIRST THEN BEGIN
            r7000002."Bill Gr./Pmt. order No." := 'CoNF210162';
            r7000002.MoDIFY;
        END;
    end;

    procedure fActualizaPend2()
    var
        wSourceLinFacImpGes: Integer;
        wSourceLinFacGes: Integer;
        wSourceCabFacGes: Integer;
        wCountCobCab: Integer;
        wCountCobDet: Integer;
        wCountCabFac: Integer;
        wCountLinFac: Integer;
        wCountLinFacImp: Integer;
        rCompany: Record 2000000006;
        rCabFac: Record 7000196;
        rLinFacImp: Record 7000200;
        rLinFac: Record 7000198;
        rCobCab: Record 7000680;
        rCobDet: Record 7000681;
        rControlesTHB: Record 50001;
        rCabFacGes: Record 7000196;
        rLinFacImpGes: Record 7000200;
        rLinFacGes: Record 7000198;
        rCobCabGes: Record 7000680;
        rCobDetGes: Record 7000681;
    begin
        IF CoMPANYNAME <> 'THB Gestion' THEN ERRoR('No se puede ejecutar la replicacion en esta empresa.');

        rCabFacGes.RESET;
        rLinFacGes.RESET;
        rLinFacImpGes.RESET;
        rCobCabGes.RESET;
        rCobDetGes.RESET;

        Ventana.oPEN('Limpiamos Cabeceras de Factura...\' +
                     'Registros Borrados #1######', wCountCabFac);

        //DEFINIMoS LA SoCIEDAD DE DESTINo EN ToDAS LAS TABLAS EN LAS QUE VAMoS A ESCRIBIR

        //rCabFacGes.SETRANGE(rCabFacGes.Hotel,'DoS'); //LINEA DE PRUEBAS
        wCountCabFac := 0;
        IF rCabFacGes.FIND('-') THEN BEGIN
            REPEAT
                rCabFacGes.DELETE;
                wCountCabFac := wCountCabFac + 1;
                Ventana.UPDATE;
            UNTIL rCabFacGes.NEXT = 0
        END;

        Ventana.CLoSE;

        CoMMIT;

        Ventana.oPEN('Limpiamos Lineas de factura impresion...\' +
                     'Registros borrados #1######', wCountLinFacImp);

        wCountLinFacImp := 0;
        //rLinFacImpGes.SETRANGE(rLinFacImpGes.Hotel,'DoS'); //LINEA DE PRUEBAS
        IF rLinFacImpGes.FIND('-') THEN BEGIN
            REPEAT
                rLinFacImpGes.DELETE;
                wCountLinFacImp := wCountLinFacImp + 1;
                Ventana.UPDATE;
            UNTIL rLinFacImpGes.NEXT = 0
        END;
        Ventana.CLoSE;

        CoMMIT;

        Ventana.oPEN('Limpiamos Lineas de factura... \' +
                     'Registros borrados #1######', wCountLinFac);

        wCountLinFac := 0;
        //rLinFacGes.SETRANGE(rLinFacGes.Hotel,'DoS'); //LINEA DE PRUEBAS
        IF rLinFacGes.FIND('-') THEN BEGIN
            REPEAT
                rLinFacGes.DELETE;
                wCountLinFac := wCountLinFac + 1;
                Ventana.UPDATE
            UNTIL rLinFacGes.NEXT = 0;
        END;
        Ventana.CLoSE;

        CoMMIT;

        Ventana.oPEN('Limpiamos los cobros... \' +
                     'Cabeceras borradas #1###### \' +
                     'Detalles borrados #2#######', wCountCobCab, wCountCobDet);

        //BoRRAMoS LoS CoBRoS

        wCountCobCab := 0;
        wCountCobDet := 0;
        IF rCobCabGes.FIND('-') THEN BEGIN
            REPEAT
                rCobCabGes.DELETE;
                wCountCobCab := wCountCobCab + 1;
                Ventana.UPDATE
            UNTIL rCobCabGes.NEXT = 0
        END;

        CoMMIT;

        IF rCobDetGes.FIND('-') THEN BEGIN
            REPEAT
                rCobDetGes.DELETE;
                wCountCobDet := wCountCobDet + 1;
                Ventana.UPDATE
            UNTIL rCobDetGes.NEXT = 0
        END;
        CoMMIT;

        Ventana.CLoSE;

        wCountCobCab := 0;
        wCountCobDet := 0;
        wCountLinFac := 0;
        wCountLinFacImp := 0;
        wCountCabFac := 0;

        wFecha := CALCDATE('-6M', ToDAY);
        //ERRoR('%1', wFecha);
        //EMPEZAMoS CoN LA REPLICACIoN...

        Ventana.oPEN('Actualizando registros de #1######################################### \' +
                     ' \' +
                     'Cabeceras de factura actualizadas #2######## \' +
                     'Lineas de factura actualizadas #3######### \' +
                     'Lineas de factura impresion actualizadas #4######### \' +
                     'Cobros cabecera actualizados #5######### \' +
                     'Cobros detalle actualizados #6#########', rCompany.Name, wCountCabFac, wCountLinFac, wCountLinFacImp, wCountCobCab, wCountCobDet);

        wSourceCabFacGes := 0;
        wSourceLinFacGes := 0;
        wSourceLinFacImpGes := 0;

        rCompany.SETFILTER(rCompany.Name, '<>%1', 'THB Gestion');

        IF rCompany.FIND('-') AND (rCompany.Name <> 'THB Gestion') THEN BEGIN
            REPEAT

                //CAMBIAMoS ToDAS LAS SoCIEDADES EN LAS TABLAS A CoNSULTAR Y LIMPIAMoS LoS REGISTRoS DE LAS FACTURAS

                rUsr.CHANGECoMPANY(rCompany.Name);
                rUsr.GET(USERID);
                rCabFac.CHANGECoMPANY(rCompany.Name);
                rLinFac.CHANGECoMPANY(rCompany.Name);
                rLinFacImp.CHANGECoMPANY(rCompany.Name);
                rCobCab.CHANGECoMPANY(rCompany.Name);
                rCobDet.CHANGECoMPANY(rCompany.Name);

                Ventana.UPDATE;

                //FILTRAMoS PoR LAS RESERVAS CoN IMPoRTE PENDIENTE DISTINTo DE 0
                //EMPEZAMoS CoN LA INSERCIoN DE LINEAS

                rCabFac.SETRANGE(rCabFac.Tipo, 0);
                rCabFac.SETFILTER(rCabFac."Importe pendiente de cobro", '<>%1', 0);
                IF rCabFac.FIND('-') THEN BEGIN
                    REPEAT
                        Ventana.UPDATE;
                        rCabFacGes := rCabFac;
                        rCabFacGes.Sourcecounter := wSourceCabFacGes + 1;
                        IF rCabFacGes.INSERT(FALSE) THEN wCountCabFac := wCountCabFac + 1;
                        rLinFac.SETRANGE(rLinFac.Factura, rCabFac.Factura);
                        IF rLinFac.FIND('-') THEN BEGIN
                            REPEAT
                                rLinFacGes := rLinFac;
                                IF rLinFacGes.INSERT(FALSE) THEN wCountLinFac := wCountLinFac + 1;
                            UNTIL rLinFac.NEXT = 0
                        END;
                        rLinFacImp.SETRANGE(rLinFacImp.Factura, rCabFac.Factura);
                        IF rLinFacImp.FIND('-') THEN BEGIN
                            REPEAT
                                rLinFacImpGes := rLinFacImp;
                                IF rLinFacImpGes.INSERT(FALSE) THEN wCountLinFacImp := wCountLinFacImp + 1;
                            UNTIL rLinFacImp.NEXT = 0
                        END;
                    UNTIL rCabFac.NEXT = 0
                END;


            //AHoRA HACEMoS LoS CoBRoS
            /*

              rCobCab.SETFILTER(rCobCab."Fecha Cobro",'%1..',wFecha);
              IF rCobCab.FIND('-') THEN BEGIN
                REPEAT
                rCobCabGes:=rCobCab;
                wCountCobCab:=wCountCobCab+1;
                rCobCabGes.SourceCounter:=wCountCobCab;
                IF rCobCabGes.INSERT(FALSE) THEN BEGIN
                  rCobDet.SETRANGE(rCobDet.Hotel,rCobCab.Hotel);
                  rCobDet.SETRANGE(rCobDet."Num. Cobro",rCobCab."Num. Cobro");
                  IF rCobDet.FIND('-') THEN BEGIN
                    REPEAT
                    rCobDetGes:=rCobDet;
                    IF rCobDetGes.INSERT(FALSE) THEN wCountCobDet:=wCountCobDet+1;
                    UNTIL rCobDet.NEXT=0
                  END;
                Ventana.UPDATE;
                END;
              UNTIL rCobCabGes.NEXT=0
              END;
            */
            UNTIL rCompany.NEXT = 0
        END;

        Ventana.CLoSE;

        MESSAGE('Cabeceras de factura actualizadas %1 \' +
                'Lineas de factura actualizadas %2 \' +
                'Lineas de factura impresion actualizadas %3 \' +
                'Cobros cabecera actualizados %4 \' +
                'Cobros detalle actualizados %5 ', wCountCabFac, wCountLinFac, wCountLinFacImp, wCountCobCab, wCountCobDet);

    end;

    procedure fActualizaCobros()
    var
        wSourceCounterGes: Integer;
        wSourceCounter: Integer;
        wCount: Integer;
        rControlesTHB: Record 50001;
        rCobCabGes: Record 7000680;
        rCobDetGes: Record 7000681;
        rCobCab: Record 7000680;
        rCobDet: Record 7000681;
        rCompany: Record 2000000006;
    begin

        IF CoMPANYNAME <> 'THB Gestion' THEN ERRoR('Este proceso solo se puede ejecutar desde THB Gestion');

        Ventana.oPEN('Revisando empresa #1########################################## \' +
                     'Cobro actual #2############## \' +
                     'Cobros replicados #3######### \', rCompany.Name, rCobCab."Num. Cobro", wCount);

        //FIJAMoS LoS PARaMETRoS INICIALES Y CAPTURAMoS EL uLTIMo SoURCECoUNTER DE GESTIoN (INTEGER2);

        rCobCab.SETCURRENTKEY(SourceCounter);
        rCobCabGes.SETCURRENTKEY(SourceCounter);
        IF rCobCabGes.FINDLAST THEN wSourceCounterGes := rCobCabGes.SourceCounter;

        //ARRANCAMoS EL PRoCESo PASANDo PoR ToDAS LAS SoCIEDADES

        rCompany.SETFILTER(rCompany.Name, '<>%1', 'THB Gestion');
        IF rCompany.FIND('-') THEN BEGIN
            REPEAT

                //CAMBIAMoS DE EMPRESA PARA LAS TABLAS DE CoNSULTA

                rUsr.CHANGECoMPANY(rCompany.Name);
                rCobCab.CHANGECoMPANY(rCompany.Name);
                rCobDet.CHANGECoMPANY(rCompany.Name);
                rUsr.GET(USERID);

                //SI No EXISTE UN REGISTRo PARA EL HoTEL DE TRABAJo DESIGNADo, SE GENERA EL REGISTRo CoN VALoR 0
                //SI EXISTE, CAPTURAMoS EL SoURCECoUNTER DEL REGISTRo PARA QUE EL PRoCESo No SE ETERNICE Y SoLo ACTUALICE Lo NUEVo

                rControlesTHB.SETRANGE(rControlesTHB.Hotel, 'REPCABCoB');
                rControlesTHB.SETRANGE(rControlesTHB.Fecha, rUsr."Hotel de trabajo");
                IF NoT rControlesTHB.FINDFIRST THEN BEGIN
                    rControlesTHB.INIT;
                    rControlesTHB.Hotel := 'REPCABCoB';
                    rControlesTHB.Fecha := rUsr."Hotel de trabajo";
                    rControlesTHB.INSERT;
                    wSourceCounterGes := 0;
                    CoMMIT;
                END ELSE
                    wSourceCounter := rControlesTHB.Almacen + 1;

                //EMPEZAMoS A MIRAR LoS REGISTRoS DE LA EMPRESA ACTUAL

                rCobCab.SETFILTER(rCobCab.SourceCounter, '%1..', wSourceCounter);
                IF rCobCab.FIND('-') THEN BEGIN
                    REPEAT
                        wSourceCounterGes := wSourceCounterGes + 1;
                        rCobCabGes := rCobCab;
                        rCobCabGes.SourceCounter := wSourceCounterGes;
                        IF rCobCabGes.INSERT THEN;
                        Ventana.UPDATE;
                        wCount := wCount + 1;
                        wSourceCounter := rCobCab.SourceCounter;
                    UNTIL rCobCab.NEXT = 0
                END;
                rControlesTHB.SETRANGE(rControlesTHB.Hotel, 'REPCABCoB');
                rControlesTHB.SETRANGE(rControlesTHB.Fecha, rUsr."Hotel de trabajo");
                IF rControlesTHB.FINDFIRST THEN BEGIN
                    rControlesTHB.Almacen := wSourceCounter;
                    rControlesTHB.MoDIFY;
                END;
                CoMMIT;
            UNTIL rCompany.NEXT = 0;
        END;

        Ventana.CLoSE;
        MESSAGE('Se han replicado un total de %1 cobros.', wCount);
    end;

    procedure fHabCamas() wTotCamHotel: Integer
    var
        rTipHab: Record 7000115;
    begin
        rUsr.GET(USERID);
        rTipHab.SETRANGE(rTipHab.Hotel, rUsr."Hotel de trabajo");
        rTipHab.SETRANGE(rTipHab.Real, TRUE);
        IF rTipHab.FIND('-') THEN BEGIN
            REPEAT
                wTotCamHotel := (rTipHab.Cantidad * rTipHab."Capacidad media") + wTotCamHotel;
            UNTIL rTipHab.NEXT = 0;
        END;
    end;


    procedure fLimpiezaFacturas()
    var
        rCab: Record 7000196;
    begin
        Ventana.oPEN('Realizando limpieza de registros, por favor espere....');
        rCab.SETRANGE(rCab."Fact. Electronica Activada", TRUE);
        rCab.SETRANGE(rCab."Nº Remesa Fact. Electronica", 0);
        rCab.SETRANGE(rCab."Importe pendiente de cobro", 0);
        IF rCab.FIND('-') THEN BEGIN
            REPEAT
                rCab."Fact. Electronica Activada" := FALSE;
                rCab.MoDIFY;
            UNTIL rCab.NEXT = 0;
        END;
        Ventana.CLoSE;
    end;

    local procedure fModFact()
    var
        r7000196: Record 7000196;
        r7000198: Record 7000198;
        r7000200: Record 7000200;
    begin

        wFecha := 20251126D;

        r7000196.SETRANGE(r7000196.Factura, 'MIM2500001');
        IF r7000196.FINDFIRST THEN BEGIN
            r7000196."Fecha factura" := wFecha;
            r7000196.MoDIFY;
            r7000198.SETRANGE(r7000198.Factura, r7000196.Factura);
            IF r7000198.FIND('-') THEN BEGIN
                REPEAT
                    r7000198."Fecha cargo" := wFecha;
                    r7000198.MoDIFY;
                UNTIL r7000198.NEXT = 0
            END;
            r7000200.SETRANGE(r7000200.Factura, r7000196.Factura);
            IF r7000200.FIND('-') THEN BEGIN
                REPEAT
                    r7000200."Fecha cargo" := wFecha;
                    r7000200.MoDIFY;
                UNTIL r7000200.NEXT = 0
            END;
        END;
    end;


    local procedure fLineasProdNoContab()
    var
        rLinProd: Record 7000206;
    begin

        rLinProd.SETFILTER(rLinProd."Fecha cargo", '%1..', 20250703D);
        IF rLinProd.FIND('-') THEN BEGIN
            REPEAT
                rLinProd."Estancia directos" := 2;
                rLinProd.MoDIFY;
            UNTIL rLinProd.NEXT = 0
        END;
    end;

    local procedure fCuentas4()
    var
        rAccount: Record 15;
        rCheckAccount4: Record 15;
        rCheckAccount3: Record 15;
        rInsertAccount: Record 15;
        wCreated: Integer;
        wCuenta3: Code[3];
        wCuenta4: Code[4];
        wCuentaText: Code[10];
        wErrores: Text;
    begin

        wCreated := 0;
        wErrores := ''; // Variable tipo Text[250] o superior

        IF rAccount.FINDSET THEN BEGIN
            REPEAT
                IF STRLEN(rAccount."No.") = 7 THEN BEGIN
                    wCuentaText := FoRMAT(rAccount."No.");

                    wCuenta4 := CoPYSTR(wCuentaText, 1, 4); // Candidato a crear
                    wCuenta3 := CoPYSTR(wCuentaText, 1, 3); // Referencia base

                    // ¿Ya existe la cuenta de 4 digitos?
                    rCheckAccount4.SETRANGE("No.", wCuenta4);
                    IF NoT rCheckAccount4.FINDFIRST THEN BEGIN

                        // ¿Existe la cuenta de 3 digitos como modelo?
                        rCheckAccount3.SETRANGE("No.", wCuenta3);
                        IF rCheckAccount3.FINDFIRST THEN BEGIN

                            CLEAR(rInsertAccount);
                            rInsertAccount.INIT;
                            rInsertAccount := rCheckAccount3;

                            rInsertAccount."No." := wCuenta4;
                            rInsertAccount.Totaling := wCuenta4 + '..' + wCuenta4 + FoRMAT('9999999999');
                            rInsertAccount.Indentation := rCheckAccount3.Indentation + 1;
                            //rInsertAccount.SourceCounter := rInsertAccount.ActSourceCounter;

                            IF rInsertAccount.INSERT THEN
                                wCreated := wCreated + 1;

                        END ELSE BEGIN
                            // Acumular error y continuar
                            wErrores += STRSUBSTNo('No tengo referencia de tres digitos (%1) para crear la cuenta %2. ', wCuenta3, wCuenta4);
                        END;
                    END;
                END;
            UNTIL rAccount.NEXT = 0;
        END;

        MESSAGE('Se han creado %1 cuentas nuevas de 4 digitos.', wCreated);

        IF wErrores <> '' THEN
            MESSAGE('Errores encontrados: \%1', wErrores);
    end;

    local procedure CheckSetup(pHotel: Code[10])
    var
        rPFo: Record 7000111;
        rLodgingSetup: Record 7012905;
        rLodgingSetupxHotel: Record 7012906;
    begin


        rLodgingSetup.FINDFIRST();
        rLodgingSetup.TESTFIELD("URL API");
        rLodgingSetup.TESTFIELD("URL Proveedor");
        rLodgingSetup.TESTFIELD("NS Alta");
        rLodgingSetup.TESTFIELD("NS Consulta");
        rLodgingSetup.TESTFIELD("NS Anul");

        rLodgingSetupxHotel.GET(rLodgingSetup.PrimaryKey, pHotel);
        rLodgingSetupxHotel.TESTFIELD("Codigo Arrendador");
        rLodgingSetupxHotel.TESTFIELD(Aplicacion);
        rLodgingSetupxHotel.TESTFIELD("Codigo Establecimiento");
        rLodgingSetupxHotel.TESTFIELD(Usuario);
        rLodgingSetupxHotel.TESTFIELD(Password);

    end;

    procedure FiltrarRecordocupantes(var pocup: Record 7000178; pHotel: Code[10]; pFechaExp: Date; "pAno": Integer; pReserva: Code[10]; pDesglose: Code[10]; pPosicion: Integer; pParteGenerado: Boolean; pNoEnvioHosp: Code[10])
    var
        rLocPFo: Record 7000111;
        LFecNacMin: Date;
        LDifFecha: Text[30];
        TextL002: Label '-%1Y';
        lrRes: Record 7000176;
        lEnviarFichaPoliciaParc: Boolean;
    begin
        // DEJAMoS LA FUNCIoN IGUAL QUE EN LA FICHA DE PoLICIA. SE UTLIZAN LoS MISMoS PARaMETRoS DE FRoNT:
        //       - Permitir envio F. Policia parc.
        //       - Edad minima policia

        lEnviarFichaPoliciaParc := FALSE; //1802
        IF rLocPFo.GET(pHotel) THEN BEGIN
            //Calculamos cual debe ser la fecha de nacimiento minima
            LDifFecha := STRSUBSTNo(TextL002, rLocPFo."Edad minima policia");
            LFecNacMin := CALCDATE(LDifFecha, pFechaExp);
            lEnviarFichaPoliciaParc := rLocPFo."Permitir envio F.Policia parc."; //1802
        END;

        pocup.RESET;
        //Dependiendo de los parametros, seleccionamos una clave mas optima....
        IF (pAno <> 0) AND (pReserva <> '') AND (pDesglose <> '') THEN BEGIN
            pocup.SETCURRENTKEY(Hotel, Ano, Reserva, Desglose, Posicion);
            pocup.SETRANGE(Hotel, pHotel);
            pocup.SETRANGE(Ano, pAno);
            pocup.SETRANGE(Reserva, pReserva);
            pocup.SETRANGE(Desglose, pDesglose);

            IF lEnviarFichaPoliciaParc THEN
                pocup.SETRANGE("Envio Hospedajes", pNoEnvioHosp);

            IF (pPosicion <> 0) THEN
                pocup.SETRANGE(Posicion, pPosicion);

            IF lrRes.GET(pHotel, pAno, pReserva, pDesglose) AND (lrRes."Estado reserva" <> lrRes."Estado reserva"::Reserva) THEN
                pocup.SETRANGE("Check In", TRUE);

            IF (pFechaExp <> 0D) THEN
                pocup.SETRANGE("Fecha entrada", pFechaExp);

        END ELSE BEGIN
            IF (pFechaExp <> 0D) THEN BEGIN
                pocup.SETCURRENTKEY(Hotel, "Pais residencia", Documento, "Check In", "Fecha entrada", "Fecha salida");
                pocup.SETRANGE(Hotel, pHotel);
                pocup.SETRANGE("Check In", TRUE);
                pocup.SETRANGE("Fecha entrada", pFechaExp);
                // IF lEnviarFichaPolicia THEN
                pocup.SETRANGE("Envio Hospedajes", pNoEnvioHosp);
            END;
        END;

        // +2401
        /*
        IF LFecNacMin <> 0D THEN
          pocup.SETFILTER("Fecha nacimiento", '..%1', LFecNacMin);
        */
        // -2401

    end;

    procedure Datosocupanteok(pocu: Record 7000178; pEnvio: Record 7012903): Boolean
    var
        rPFo: Record 7000111;
        Lok: Boolean;
        TextL001: Label 'There is an occupant in the booking %1 -%2 - %3 with Document Issue Date in blank.';
        TextL002: Label 'The occupant 1% 2% reservation 3% 4% 5% Hotel 6% has field 7% blank';
        TextL003: Label 'El ocupante %1 %2  debe indicar Telefono o tel. movil o email';
        bMayorEdad: Boolean;
        rPais: Record 9;
        TextL004: Label 'Cod Pais ISo en blanco.';
        rPostCode: Record 225;
        TextL005: Label 'Cod Postal no encontrado.';
        cGeneral: Codeunit 7000105;
        TextL006: Label 'El ocupante %1 %2  debe no tiene un email valido.';
    begin
        //Realizamos las comprobaciones para verificar si los ocupantes tienen todos los datos necesarios para
        //actualizar su nº de parte de entradas..
        Lok := TRUE;

        IF (pocu."Fecha nacimiento" = 0D) THEN BEGIN
            // (pocu."Tipo persona" <> pocu."Tipo persona"::NI) AND (pocu."Tipo persona" <> pocu."Tipo persona"::CU) THEN BEGIN // +2403
            InsertaMensajeLog(pocu, pocu.FIELDCAPTIoN(pocu."Fecha nacimiento"), pEnvio);
            Lok := FALSE;
        END;

        IF ((pocu."Fecha nacimiento" <> 0D) AND (rPFo."Edad minima DNI" < CalcularEdad(pocu."Fecha nacimiento"))) oR (pocu."Fecha nacimiento" = 0D) THEN BEGIN

            IF (pocu.Documento = '') THEN BEGIN
                InsertaMensajeLog(pocu, pocu.FIELDCAPTIoN(pocu.Documento), pEnvio);
                Lok := FALSE;
            END;

            IF (pocu."Fecha expedicion documento" = 0D) THEN BEGIN
                InsertaMensajeLog(pocu, pocu.FIELDCAPTIoN(pocu."Fecha expedicion documento"), pEnvio);
                Lok := FALSE;
            END;

            // +2404
            IF (pocu."Tipo documento" = pocu."Tipo documento"::DNI) THEN
                IF (pocu."Soporte documento" = '') THEN BEGIN
                    InsertaMensajeLog(pocu, pocu.FIELDCAPTIoN(pocu."Soporte documento"), pEnvio);
                    Lok := FALSE;
                END;
            // -2404

        END;

        // +2404
        /*
        IF (pocu."Tipo documento"=pocu."Tipo documento"::DNI) THEN
          IF (pocu."Soporte documento"='') THEN BEGIN
               InsertaMensajeLog(pocu,pocu.FIELDCAPTIoN(pocu."Soporte documento"),pEnvio);
               Lok := FALSE;
          END;
        */
        // -2404


        //-2303
        /*
        IF ((pocu."Fecha nacimiento" <> 0D) AND (rPFo."Edad minima DNI" >= CalcularEdad(pocu."Fecha nacimiento")))  oR (pocu."Fecha nacimiento" = 0D) THEN BEGIN
        
          IF (pocu.Parentesco = '') THEN BEGIN
             InsertaMensajeLog(pocu,pocu.FIELDCAPTIoN(pocu.Parentesco),pEnvio);
             Lok := FALSE;
          END;
        
        END;*/

        IF (pocu."Apellido 1 = '') THEN BEGIN
            InsertaMensajeLog(pocu, pocu.FIELDCAPTIoN(pocu."Apellido 1), pEnvio);
            Lok := FALSE;
    END;

        IF (pocu.Nombre = '') THEN BEGIN
            InsertaMensajeLog(pocu, pocu.FIELDCAPTIoN(pocu.Nombre), pEnvio);
            Lok := FALSE;
        END;

        IF (pocu.Nacionalidad = 'ES') oR (pocu.Nacionalidad = 'ESP') THEN BEGIN
            IF (pocu."Apellido 2 = '') THEN BEGIN
                InsertaMensajeLog(pocu, pocu.FIELDCAPTIoN(pocu."Apellido 2), pEnvio);
                Lok := FALSE;
            END;

            /*
            IF (pocu."Cod. postal" <> '') THEN BEGIN
              IF rPostCode.GET(pocu."Cod. postal") THEN BEGIN
                IF rPostCode."Codigo Municipio" = '' THEN BEGIN
                  InsertaMensajeLog(pocu,rPostCode.FIELDCAPTIoN(rPostCode."Codigo Municipio"),pEnvio);
                  Lok := FALSE;
                END;
              END ELSE BEGIN
                InsertaIncidenciaLog(pocu,TextL005,pEnvio);
                Lok := FALSE
              END;
            END;
            */
        END;

        // +2402
        IF (pocu."Pais residencia" = 'ES') oR (pocu."Pais residencia" = 'ESP') THEN BEGIN

            IF (pocu."Cod. postal" <> '') THEN BEGIN
                rPostCode.RESET;
                rPostCode.SETRANGE(rPostCode.Code, pocu."Cod. postal");
                // IF rPostCode.GET(pocu."Cod. postal") THEN BEGIN
                IF rPostCode.FINDFIRST THEN BEGIN
                    IF rPostCode."Codigo Municipio" = '' THEN BEGIN
                        InsertaMensajeLog(pocu, rPostCode.FIELDCAPTIoN(rPostCode."Codigo Municipio"), pEnvio);
                        Lok := FALSE;
                    END;
                END ELSE BEGIN
                    InsertaIncidenciaLog(pocu, TextL005, pEnvio);
                    Lok := FALSE
                END;
            END;

        END;
        // -2402



        IF (pocu."Fecha entrada" = 0D) THEN BEGIN
            InsertaMensajeLog(pocu, pocu.FIELDCAPTIoN(pocu."Fecha entrada"), pEnvio);
            Lok := FALSE;
        END;

        //Si es desplazado no lo generamos...
        IF Desplazado(pocu) THEN
            Lok := FALSE;


        IF (pocu.Direccion = '') THEN BEGIN
            InsertaMensajeLog(pocu, pocu.FIELDCAPTIoN(pocu.Direccion), pEnvio);
            Lok := FALSE;
        END;

        IF (pocu."Cod. postal" = '') THEN BEGIN
            InsertaMensajeLog(pocu, pocu.FIELDCAPTIoN(pocu."Cod. postal"), pEnvio);
            Lok := FALSE;
        END;


        IF (pocu."Poblacion residencia" = '') THEN BEGIN
            InsertaMensajeLog(pocu, pocu.FIELDCAPTIoN(pocu."Poblacion residencia"), pEnvio);
            Lok := FALSE;
        END;

        IF (pocu.Telefono = '') AND (pocu."Tel. Movil" = '') AND (pocu."E-mail" = '') THEN BEGIN
            InsertaIncidenciaLog(pocu, CoPYSTR(STRSUBSTNo(TextL003, pocu.Posicion, pocu."Apellido 1), 1, 250), pEnvio);
            Lok := FALSE;
        END;

        IF pocu."E-mail" <> '' THEN
            IF NoT cGeneral.ValidaEmailQuoHotel(pocu.Hotel, pocu."E-mail") THEN BEGIN
                InsertaIncidenciaLog(pocu, CoPYSTR(STRSUBSTNo(TextL006, pocu.Posicion, pocu."Apellido 1), 1, 250), pEnvio);
                Lok := FALSE;
            END;

        IF NoT rPais.GET(pocu."Pais residencia") oR (rPais."Codigo pais ISo 3166 Alfa 3 = '') THEN BEGIN
            InsertaIncidenciaLog(pocu, TextL004, pEnvio);
            Lok := FALSE
        END;


        EXIT(Lok);

    end;

    procedure InsertaMensajeLog(pocu: Record 7000178; pNomCampo: Text[250]; pEnvio: Record 7012903)
    var
        TextL001: Label 'The occupant %1 %2 has field %3 blank.';
    begin

        InsertaIncidenciaLog(pocu,
                             CoPYSTR(STRSUBSTNo(TextL001,
                                                pocu.Posicion,
                                                pocu."Apellido 1,
                                                pNomCampo),
                             1, 250), pEnvio);
    end;

    procedure InsertaIncidenciaLog(pocu: Record 7000178; pText: Text[250]; pEnvio: Record 7012903)
    var
        rLog: Record 7012908;
        LNumLinea: Integer;
    begin
        //Insertamos en el log de incidencias..
        //Key:Usuario,Hotel,Ano Reserva,Reserva,Deslgose Reserva,Posicion,Num. Linea

        LNumLinea := 1;

        rLog.RESET;
        //rLog.SETRANGE(Hotel,pEnvio.Hotel);
        rLog.SETRANGE(Hotel, pocu.Hotel);  //+2303
        rLog.SETRANGE(rLog.Envio, pEnvio.Envio);
        //+2303
        rLog.SETRANGE("Ano Reserva", pocu.Ano);
        rLog.SETRANGE(Reserva, pocu.Reserva);
        rLog.SETRANGE("Deslgose Reserva", pocu.Desglose);
        rLog.SETRANGE(Posicion, pocu.Posicion);
        //-2303
        IF rLog.FINDLAST THEN
            LNumLinea := rLog."Num. Linea" + 1;


        rLog.INIT;

        rLog.Hotel := pocu.Hotel;
        rLog.Envio := pEnvio.Envio;
        rLog."Num. Linea" := LNumLinea;
        rLog."Ano Reserva" := pocu.Ano;
        rLog.Reserva := pocu.Reserva;
        rLog."Deslgose Reserva" := pocu.Desglose;
        rLog.Posicion := pocu.Posicion;
        rLog.Nombre := pocu.Nombre;
        rLog.Apellidos := pocu."Apellido 1 + ' ' + pocu."Apellido 2;
        rLog.Descripcion := pText;
        rLog."Parte entrada viajeros" := pocu."Nº Parte Entrada Viajeros";

        rLog.INSERT(TRUE);
    end;

    procedure Desplazado(pocu: Record 7000178): Boolean
    var
        rLocRva: Record 7000176;
        rLocHab: Record 7000116;
        rLocPFo: Record 7000111;
        LDesplazado: Boolean;
    begin
        //Desplazado
        //Comprobamos que el ocupante sea del Hotel, que no este DESPLAZADo

        LDesplazado := TRUE;
        IF rLocRva.GET(pocu.Hotel, pocu.Ano, pocu.Reserva, pocu.Desglose) THEN BEGIN
            rLocHab.RESET;
            IF rLocHab.GET(rLocRva.Habitacion, rLocRva.Hotel) THEN BEGIN
                IF rLocPFo.GET(rLocRva.Hotel) THEN
                    LDesplazado := (rLocHab."Tipo habitacion" = rLocPFo."Tipo habit. desplazados");
            END ELSE
                LDesplazado := FALSE;
        END;

        EXIT(LDesplazado);
    end;

    procedure CalcularEdad(pFecha: Date): Decimal
    var
        decEdad: Decimal;
    begin
        decEdad := 0;
        IF pFecha <> 0D THEN BEGIN
            decEdad := (WoRKDATE - pFecha) / (DMY2DATE(1, 1, DATE2DMY(WoRKDATE, 3) + 1) - DMY2DATE(1, 1, DATE2DMY(WoRKDATE, 3)));
            decEdad := RoUND(decEdad - 0.015, 1, '<');
            EXIT(decEdad);
        END;
    end;

    procedure ActualizaEstadoEnvio(var pRecEnvio: Record 7012903; pEstado: Integer)
    var
        rLocEnvio: Record 7012903;
        LNumEnvio: Code[10];
    begin
        //Actualizamos la tabla de envios de parte de entradas...
        //parametros...

        CASE pEstado oF
            0:
                pRecEnvio.Estado := pRecEnvio.Estado::Enviado;
            1:
                pRecEnvio.Estado := pRecEnvio.Estado::Error;
            2:
                pRecEnvio.Estado := pRecEnvio.Estado::"Envio con errores";
            3:
                pRecEnvio.Estado := pRecEnvio.Estado::"Pendiente validacion";
            4:
                pRecEnvio.Estado := pRecEnvio.Estado::Anulado;
        END;

        pRecEnvio.Usuario := USERID;
        pRecEnvio."Fecha proceso" := ToDAY;
        pRecEnvio."Hora Proceso" := TIME;
        pRecEnvio.MoDIFY;
    end;

    procedure HayErrores(pEnvio: Record 7012903): Boolean
    var
        rLog: Record 7012908;
    begin
        rLog.RESET;
        rLog.SETRANGE(Hotel, pEnvio.Hotel);
        rLog.SETRANGE(Envio, pEnvio.Envio);
        EXIT(NoT rLog.ISEMPTY);
    end;


    procedure AnularEnvio(var rLocEnv: Record 7012903)
    var
        TextL001: Label 'No se puede anular si no ha sido enviado.';
        bok: Boolean;
        cGestionXMLHospedaje: Codeunit 7043133;
        rocc: Record 7000178;
        TextL002: Label '¿Deser anular el envio %1?';
        rDetEnvio: Record 7012904;
    begin
        /*
        IF NoT CoNFIRM(STRSUBSTNo(TextL002,rLocEnv.Envio)) THEN
          EXIT;
        */
        bok := FALSE;

        IF (rLocEnv.Estado <> rLocEnv.Estado::Enviado) AND (rLocEnv.Estado <> rLocEnv.Estado::"Envio con errores") THEN
            ERRoR(TextL001);


        // +2400
        IF NoT TieneDetalleEnvio(rLocEnv) THEN BEGIN
            rLocEnv.Estado := rLocEnv.Estado::Anulado;
            rLocEnv.MoDIFY;

            bok := TRUE;
        END ELSE
            // -2400
            cGestionXMLHospedaje.ProcessShipment(rLocEnv, 2, bok);

        IF bok THEN BEGIN

            rocc.RESET;
            rocc.SETRANGE(Hotel, rLocEnv.Hotel);
            rocc.SETRANGE("Envio Hospedajes", rLocEnv.Envio);
            IF rocc.FINDSET() THEN BEGIN
                REPEAT
                    rocc."Envio Hospedajes" := '';
                    rocc.MoDIFY;
                UNTIL rocc.NEXT = 0;
            END;

            rDetEnvio.RESET;
            rDetEnvio.SETRANGE(Hotel, rLocEnv.Hotel);
            rDetEnvio.SETRANGE(Envio, rLocEnv.Envio);
            rDetEnvio.MoDIFYALL(Estado, rDetEnvio.Estado::Anulado);

        END;

    end;

    
    procedure ConsultarEnvio(var rLocEnv: Record 7012903)
    var
        bok: Boolean;
        rocc: Record 7000178;
        cGestionXMLHospedaje: Codeunit 7043133;
        TextL001: Label 'El envio no esta pendiente de validar/consultar.';
    begin

        bok := FALSE;

        IF (rLocEnv.Estado <> rLocEnv.Estado::"Pendiente validacion") AND (rLocEnv.Estado <> rLocEnv.Estado::Enviado) AND (rLocEnv.Estado <> rLocEnv.Estado::"Envio con errores") THEN
            ERRoR(TextL001);


        cGestionXMLHospedaje.ProcessShipment(rLocEnv, 1, bok);
    end;

    local procedure CheckEnvio(pEnv: Record 7012903)
    var
        lText003: Label 'Proceso cancelado.';
        rLEnvios: Record 7012903;
        LSeguir: Boolean;
        lNoEnvio: Integer;
        TextL001: Label 'Hotel and date must be indicated in order to continue';
        TextL002: Label 'Day %1 was already generated for Hotel %2. Continue?';
        TextLErrorEnvio: Label 'El filtrado para imprimir el parte no sera correcto porque el codigo de envio %1 no es numerico.';
        TextL004: Label 'El envio ha sido anulado por lo que no es posible enviarlo.';
        TextL005: Label 'Ya ha sido enviado.';
        TextL006: Label 'Ya ha sido enviado. Para enviar los datos de ocupantes pendientes debe generar un nuevo envio.';
    begin

        IF pEnv.Estado = pEnv.Estado::Anulado THEN
            ERRoR(TextL004);

        IF (pEnv.Estado = pEnv.Estado::"Envio con errores") AND HayErrores(pEnv) THEN
            ERRoR(TextL006);

        //IF (pEnv.Estado=pEnv.Estado::Enviado) oR (pEnv.Estado=pEnv.Estado::"Envio con errores") oR (pEnv.Estado=pEnv.Estado::"Pendiente validacion") THEN
        IF (pEnv.Estado <> pEnv.Estado::Temporal) AND (pEnv.Estado <> pEnv.Estado::Error) THEN
            ERRoR(TextL005);

        LSeguir := TRUE;

        rLEnvios.RESET;
        rLEnvios.SETRANGE(Hotel, pEnv.Hotel);
        rLEnvios.SETRANGE("Fecha Envio", pEnv."Fecha Envio");
        rLEnvios.SETFILTER(rLEnvios.Estado, '<>%1', rLEnvios.Estado::Temporal);
        IF NoT rLEnvios.ISEMPTY THEN
            LSeguir := CoNFIRM(STRSUBSTNo(TextL002, pEnv."Fecha Envio", pEnv.Hotel));

        IF LSeguir THEN BEGIN
            lNoEnvio := 0;
            IF (pEnv.Envio <> '') AND (NoT EVALUATE(lNoEnvio, pEnv.Envio)) THEN
                ERRoR(TextLErrorEnvio, pEnv.Envio);
        END ELSE
            ERRoR(lText003);
    end;

    
    procedure NuevoEnvio(pHotel: Code[10]; pDate: Date)
    var
        rPFo: Record 7000111;
        cHospedaje: Codeunit 7043134;
        TextL001: Label 'Hotel and date must be indicated in order to continue';
        rLEnvios: Record 7012903;
        LSeguir: Boolean;
        TextL002: Label 'Created sent already exists for day %1 in hotel %2';
        TextL003: Label 'Created sent';
        TextL004: Label 'No se permite tener mas de un envio temporal, elimine el actual y vuelva a crear el nuevo.';
        TextPreguntaNuevoEnvio: Label '¿Desea crear un nuevo envio?';
        TextErrorNoEnviarFPolicia: Label 'Ha cancelado el nuevo envio';
    begin

        IF (pHotel = '') oR (pDate = 0D) THEN BEGIN
            MESSAGE(TextL001);
        END ELSE BEGIN

            rLEnvios.RESET;
            rLEnvios.SETRANGE(Hotel, pHotel);
            rLEnvios.SETFILTER(Estado, '=%1', rLEnvios.Estado::Temporal);
            IF NoT rLEnvios.ISEMPTY THEN
                ERRoR(TextL004);


            rLEnvios.RESET;
            rLEnvios.SETRANGE(Hotel, pHotel);
            rLEnvios.SETRANGE("Fecha Envio", pDate);
            rLEnvios.SETFILTER(Estado, '<>%1', rLEnvios.Estado::Anulado);  // +2405
            IF NoT rLEnvios.ISEMPTY THEN BEGIN
                rPFo.RESET();
                rPFo.SETRANGE(Hotel, pHotel);
                IF NoT rPFo.FINDFIRST THEN
                    ERRoR(TextErrorPFo, pHotel)
                ELSE BEGIN
                    IF rPFo."Permitir envio F.Policia parc." THEN BEGIN
                        IF NoT CoNFIRM(TextPreguntaNuevoEnvio) THEN
                            ERRoR(TextErrorNoEnviarFPolicia)
                    END ELSE
                        ERRoR(TextErrorPermitirFPolicia, pHotel);
                END;
            END;

            RecuperaEnvio(pHotel, pDate, rLEnvios);
            CoMMIT;
            EnviarParte(rLEnvios, 0, '', '', 0, TRUE);
        END;
    end;

    
    procedure InicializaLogocupante(pocc: Record 7000178)
    var
        rLog: Record 7012908;
    begin
        //+2303

        rLog.RESET;
        rLog.SETRANGE(Hotel, pocc.Hotel);
        rLog.SETRANGE(Envio, '');
        rLog.SETRANGE("Ano Reserva", pocc.Ano);
        rLog.SETRANGE(Reserva, pocc.Reserva);
        rLog.SETRANGE("Deslgose Reserva", pocc.Desglose);
        rLog.SETRANGE(Posicion, pocc.Posicion);
        rLog.DELETEALL;
    end;

    
    procedure ComprobarocupantesSinEnvio(pocc: Record 7000178): Boolean
    var
        rPFo: Record 7000111;
        rocc: Record 7000178;
        rEnvio: Record 7012903;
        lHayErrores: Boolean;
        TextLocc: Label 'Hay errores relacionados con el envio de hospedaje. Por favor, revise el log de errores de hospedaje';
        bok: Boolean;
        TextLoccError: Label 'Hay errores relacionados con el envio de hospedaje. Para poder continuar debe rellenar los datos que faltan en los ocupantes.\Por favor, revise el log de errores de hospedaje';
    begin
        //+2303

        bok := TRUE;

        IF rPFo.GET(pocc.Hotel) AND (rPFo."Verificar envio hospedaje" <> rPFo."Verificar envio hospedaje"::"0) THEN BEGIN

            rEnvio.RESET;
            lHayErrores := FALSE;

            rocc.RESET;
            rocc.SETRANGE(Hotel, pocc.Hotel);
            rocc.SETRANGE(Ano, pocc.Ano);
            rocc.SETRANGE(Reserva, pocc.Reserva);
            rocc.SETRANGE(Desglose, pocc.Desglose);
            rocc.SETRANGE("Check In", TRUE);
            rocc.SETRANGE("Envio Hospedajes", '');
            IF rocc.FINDSET THEN BEGIN
                REPEAT

                    InicializaLogocupante(rocc);
                    Datosocupanteok(rocc, rEnvio);
                    CoMMIT;

                    IF bok THEN
                        IF HayErroresocupante(rocc) THEN
                            bok := FALSE;

                UNTIL rocc.NEXT = 0;
            END;

            IF NoT bok THEN BEGIN
                // +2304
                /*
                  MESSAGE(TextLocc);
                  IF rPFo."Verificar envio hospedaje" = rPFo."Verificar envio hospedaje"::Aviso THEN
                    bok :=  TRUE;
                */
                IF rPFo."Verificar envio hospedaje" = rPFo."Verificar envio hospedaje"::"1 THEN BEGIN
                    MESSAGE(TextLocc);
                    bok := TRUE;
                END ELSE
                    MESSAGE(TextLoccError);
                // -2304
            END;
        END;

        EXIT(bok);

    end;

    
    procedure HayErroresocupante(pocc: Record 7000178): Boolean
    var
        rLog: Record 7012908;
    begin
        //+2303

        rLog.RESET;
        rLog.SETRANGE(Hotel, pocc.Hotel);
        rLog.SETRANGE(Envio, '');
        rLog.SETRANGE("Ano Reserva", pocc.Ano);
        rLog.SETRANGE(Reserva, pocc.Reserva);
        rLog.SETRANGE("Deslgose Reserva", pocc.Desglose);
        rLog.SETRANGE(Posicion, pocc.Posicion);
        EXIT(NoT rLog.ISEMPTY);
    end;

    local procedure TieneDetalleEnvio(var rLocEnv: Record 7012903): Boolean
    var
        rDetEnvio: Record 7012904;
    begin
        // +2400
        rDetEnvio.RESET;
        rDetEnvio.SETRANGE(Hotel, rLocEnv.Hotel);
        rDetEnvio.SETRANGE(Envio, rLocEnv.Envio);
        rDetEnvio.SETRANGE(Estado, rDetEnvio.Estado::Enviado);
        EXIT(rDetEnvio.FINDFIRST);
    end;

    local procedure fRegistroMovContaDELETE()
    var
        r45: Record "45;
    begin
        /*
        r45.SETFILTER(r45."No.",'%1..%2',35513,35536);
        IF r45.FIND('-') THEN BEGIN
          REPEAT
          MESSAGE('%1 %2 %3',r45."No.",r45."From Entry No.",r45."To Entry No.");
          r45.DELETE;
          UNTIL r45.NEXT=0
        END;
        */

    end;

    local procedure f380Sistema()
    var
        r380: Record "380;
    begin

        r380.SETRANGE(r380."User ID", '');
        IF r380.FIND('-') THEN BEGIN
            REPEAT
                r380."User ID" := 'SISTEMA';
                r380.MoDIFY;
            UNTIL r380.NEXT = 0
        END;
        CoMMIT;
    end;

    local procedure fCodPostalesRep()
    var
        rCompany: Record "2000000006;
        r225: Record "225;
        r225new: Record "225;
        r7043031: Record 7043031;
        r7043031new: Record 7043031;
        wTabla: Text[40];
        wPoblacion: Code[30];
    begin
        //REVISADo HASTA EL CoDIGo PoSTAL 11999
        /*
        Ventana.oPEN('Revisando codigo postal #1########',r7043031.CodigoPostal);
        
        IF r7043031.FIND('-') THEN BEGIN
          REPEAT
          Ventana.UPDATE;
          wPoblacion:=CoPYSTR(r7043031.Poblacion,1,30);
          r225.SETRANGE(r225.Code,r7043031.CodigoPostal);
          r225.SETRANGE(r225.City,wPoblacion);
          IF r225.FIND('-') THEN BEGIN
            REPEAT
            r225.DELETE;
            UNTIL r225.NEXT=0
          END;
          r225.INIT;
          r225.Code:=r7043031.CodigoPostal;
          r225."Country/Region Code":='ESP';
          r225.City:=CoPYSTR(r7043031.Poblacion,1,30);
          r225."Codigo Municipio":=r7043031.CodMunicipio;
          IF r225.INSERT(TRUE) THEN;
          UNTIL r7043031.NEXT=0
        END;
        */
        Ventana.oPEN('Revisando tabla #1#################################### de la empresa #2###########################################################.', wTabla, rCompany.Name);
        rCompany.SETFILTER(rCompany.Name, '<>%1', 'HoTEL FELIP 1890, S.L.U.');

        IF rCompany.FIND('-') THEN BEGIN
            REPEAT
                r225new.RESET;
                r225new.CHANGECoMPANY(rCompany.Name);
                r7043031new.RESET;
                r7043031new.CHANGECoMPANY(rCompany.Name);
                IF r225.FIND('-') THEN BEGIN
                    REPEAT
                        wTabla := 'Codigos postales 225';
                        Ventana.UPDATE;
                        r225new.SETRANGE(r225new.Code, r225.Code);
                        r225new.SETRANGE(r225new.City, r225.City);
                        IF r225new.FINDFIRST THEN BEGIN
                            r225new.DELETE;
                            r225new.INIT;
                            r225new := r225;
                            r225new.INSERT
                        END;

                    UNTIL r225.NEXT = 0
                END;
                wTabla := 'Municipios 7043031';
                Ventana.UPDATE;
                IF r7043031.FIND('-') THEN BEGIN
                    REPEAT
                        r7043031new.SETRANGE(r7043031new.CodigoPostal, r7043031.CodigoPostal);
                        r7043031new.SETRANGE(r7043031new.CodMunicipio, r7043031.CodMunicipio);
                        IF r7043031new.FINDFIRST THEN BEGIN
                            r7043031new.DELETE;
                            r7043031new.INIT;
                            r7043031new := r7043031;
                            r7043031new.INSERT;
                        END;
                    UNTIL r7043031.NEXT = 0
                END;
            UNTIL rCompany.NEXT = 0
        END;

    end;

    local procedure fCodPostalPais()
    var
        r225: Record "225;
    begin

        r225.SETFILTER(r225."Codigo Municipio", '<>%1', '');
        IF r225.FIND('-') THEN BEGIN
            REPEAT
                r225."Country/Region Code" := 'ESP';
                r225.MoDIFY(TRUE);
            UNTIL r225.NEXT = 0
        END;
    end;

    
    procedure fCreaCodPostal(wFecha: Date)
    var
        rocupantes: Record 7000178;
        rCodPostal: Record 7001030;
    begin

        rCodPostal.SETRANGE(rCodPostal.City, '');
        IF rCodPostal.FIND('-') THEN BEGIN
            REPEAT
                rCodPostal.DELETE(TRUE);
            UNTIL rCodPostal.NEXT = 0
        END;

        rCodPostal.SETRANGE(rCodPostal.Code, '');
        IF rCodPostal.FIND('-') THEN BEGIN
            REPEAT
                rCodPostal.DELETE(TRUE);
            UNTIL rCodPostal.NEXT = 0
        END;


        rocupantes.SETRANGE(rocupantes."Fecha entrada", wFecha);
        rocupantes.SETRANGE(rocupantes."Check In", TRUE);
        rocupantes.SETFILTER(rocupantes."Poblacion residencia", '<>%1', '');
        rocupantes.SETFILTER(rocupantes."Pais residencia", '=%1|%2', 'ES', 'ESP');
        IF rocupantes.FIND('-') THEN BEGIN
            REPEAT
                IF rocupantes."Poblacion residencia" <> '' THEN BEGIN
                    rCodPostal.SETRANGE(rCodPostal.Code, rocupantes."Cod. postal");
                    rCodPostal.SETRANGE(rCodPostal.City, rocupantes."Poblacion residencia");
                    IF rCodPostal.FIND('-') THEN BEGIN
                        IF rCodPostal."Country/Region Code" = '' THEN BEGIN
                            rCodPostal."Country/Region Code" := 'ESP';
                            rCodPostal.MoDIFY(TRUE)
                        END;
                    END ELSE BEGIN
                        rCodPostal.INIT;
                        rCodPostal.Code := rocupantes."Cod. postal";
                        rCodPostal.City := rocupantes."Poblacion residencia";
                        rCodPostal."Country/Region Code" := 'ESP';
                        IF rCodPostal.INSERT(TRUE) THEN;
                    END;
                END ELSE BEGIN
                    rCodPostal.SETRANGE(rCodPostal.Code, rocupantes."Cod. postal");
                    rCodPostal.SETRANGE(rCodPostal."Country/Region Code", rocupantes."Pais residencia");
                    IF rCodPostal.FINDFIRST THEN BEGIN
                        rocupantes."Poblacion residencia" := rCodPostal.City;
                        rocupantes.MoDIFY;
                    END;
                END;
            UNTIL rocupantes.NEXT = 0
        END;

        CoMMIT;
    end;

    
    procedure fCorregirenyes(wFecha: Date)
    var
        rocupantes: Record 7000178;
        T: Text;
        Pos: Integer;
        MapSrc: Label 'aÀÂÃÄeÈÊËiÌÎÏoÒÔÕÖuÙÛÜÇnØaàâãäeèêëiìîïoòôõöuùûüçnøLlÆæŒœß';
        MapDst: Label 'AAAAAEEEEIIIIoooooUUUUCNoaaaaaeeeeiiiiooooouuuucnoLlAaooS';
        CombMarksA: Label 'a`a´a^a~a¯a?a?a¨a?a°a?a?a?a¸';
        CombMarks: Text;
        QuoteCharsC: Label '’‘''''''''“”„""';
        QuoteChars: Text;
    begin

        // 0) Construcciones auxiliares
        // 0.1) Marcas combinantes (desde CombMarksA con aes acentuadas)
        CombMarks := CombMarksA;
        CombMarks := DELCHR(CombMarks, '=', 'a '); // quita 'a' y espacios

        // 0.2) Conjunto de comillas/apostrofos a eliminar:
        QuoteChars := QuoteCharsC;   // Unicode “curly” + fullwidth
        QuoteChars := QuoteChars + ''''; // anade ASCII apostrophe (U+0027)  -> 4 comillas para 1
        QuoteChars := QuoteChars + '"';  // anade ASCII double quote (U+0022)

        // --- 1) BoRRADo PREVIo  ---
        rocupantes.RESET;
        rocupantes.SETRANGE("Fecha entrada", wFecha);
        rocupantes.SETRANGE("Check In", TRUE);
        rocupantes.SETRANGE(Reserva, '');
        IF rocupantes.FIND('-') THEN
            REPEAT
                rocupantes.DELETE;
            UNTIL rocupantes.NEXT = 0;

        // --- 2) PRoGRESo ---
        Ventana.oPEN('Corrigiendo digitos incorrectos...');

        // --- 3) RANGo A CoRREGIR ---
        rocupantes.RESET;
        rocupantes.SETRANGE("Check In", TRUE);
        rocupantes.SETRANGE("Fecha entrada", wFecha);

        IF rocupantes.FINDSET(TRUE, FALSE) THEN
            REPEAT
                // ======= Nombre =======
                T := rocupantes.Nombre;
                T := DELCHR(T, '=', CombMarks);                // quita combinantes (incl. ¨)
                T := DELCHR(T, '=', '¨´`^~¯??°??¸?');         // diacriticos “espaciadores”
                T := DELCHR(T, '=', QuoteChars);               // todas las comillas/apostrofos
                T := CoNVERTSTR(T, MapSrc, MapDst);            // normalizacion basica
                T := CoNVERTSTR(T, ',', ' ');                  // comas -> espacio
                WHILE STRPoS(T, '  ') > 0 Do                   // compacta espacios
                    T := DELSTR(T, STRPoS(T, '  '), 1);
                T := DELCHR(T, '<', ' ');                      // trim left
                T := DELCHR(T, '>', ' ');                      // trim right
                rocupantes.Nombre := T;

                // ======= Apellido 1 =======
                T := rocupantes."Apellido 1;
                T := DELCHR(T, '=', CombMarks);
                T := DELCHR(T, '=', '¨´`^~¯??°??¸?');
                T := DELCHR(T, '=', QuoteChars);
                T := CoNVERTSTR(T, MapSrc, MapDst);
                T := CoNVERTSTR(T, ',', ' ');
                WHILE STRPoS(T, '  ') > 0 Do
                    T := DELSTR(T, STRPoS(T, '  '), 1);
                T := DELCHR(T, '<', ' ');
                T := DELCHR(T, '>', ' ');
                rocupantes."Apellido 1 := T;

                // ======= Apellido 2 =======
                T := rocupantes."Apellido 2;
                T := DELCHR(T, '=', CombMarks);
                T := DELCHR(T, '=', '¨´`^~¯??°??¸?');
                T := DELCHR(T, '=', QuoteChars);
                T := CoNVERTSTR(T, MapSrc, MapDst);
                T := CoNVERTSTR(T, ',', ' ');
                WHILE STRPoS(T, '  ') > 0 Do
                    T := DELSTR(T, STRPoS(T, '  '), 1);
                T := DELCHR(T, '<', ' ');
                T := DELCHR(T, '>', ' ');
                rocupantes."Apellido 2 := T;

                // ======= E-mail =======
                T := rocupantes."E-mail";
                T := DELCHR(T, '=', CombMarks);
                T := DELCHR(T, '=', '¨´`^~¯??°??¸?');
                T := DELCHR(T, '=', QuoteChars);
                T := CoNVERTSTR(T, MapSrc, MapDst);
                T := DELCHR(T, '=', '/\-'); // quita / \ -
                T := DELCHR(T, '=', ' ');   // quita espacios
                rocupantes."E-mail" := T;

                // ======= Soporte documento =======
                T := rocupantes."Soporte documento";
                T := DELCHR(T, '=', CombMarks);
                T := DELCHR(T, '=', '¨´`^~¯??°??¸?');
                T := DELCHR(T, '=', QuoteChars);
                T := CoNVERTSTR(T, MapSrc, MapDst);
                T := CoNVERTSTR(T, ',', ' ');
                WHILE STRPoS(T, '  ') > 0 Do
                    T := DELSTR(T, STRPoS(T, '  '), 1);
                T := DELCHR(T, '<', ' ');
                T := DELCHR(T, '>', ' ');
                rocupantes."Soporte documento" := T;

                // ======= Direccion =======
                T := rocupantes.Direccion;
                T := DELCHR(T, '=', CombMarks);
                T := DELCHR(T, '=', '¨´`^~¯??°??¸?');
                T := DELCHR(T, '=', QuoteChars);
                T := CoNVERTSTR(T, MapSrc, MapDst);
                T := CoNVERTSTR(T, ',', ' ');
                WHILE STRPoS(T, '  ') > 0 Do
                    T := DELSTR(T, STRPoS(T, '  '), 1);
                T := DELCHR(T, '<', ' ');
                T := DELCHR(T, '>', ' ');
                rocupantes.Direccion := T;

                rocupantes.MoDIFY;
            UNTIL rocupantes.NEXT = 0;

        Ventana.CLoSE;
        CoMMIT;



        /*
        rocupantes.SETRANGE(rocupantes."Fecha entrada",wFecha);
        rocupantes.SETRANGE(rocupantes."Check In",TRUE);
        rocupantes.SETRANGE(rocupantes.Reserva,'');
        IF rocupantes.FIND('-') THEN BEGIN
          REPEAT
          rocupantes.DELETE;
          UNTIL rocupantes.NEXT=0
        END;
        
        //LINEA PARA EXCEL =("  rocupantes.Nombre:=CoNVERTSTR(rocupantes.Nombre,'"&G5&"','"&H5&"');")
        
        Ventana.oPEN('Corrigiendo digitos incorrectos...');
        rocupantes.SETRANGE(rocupantes."Check In",TRUE);
        rocupantes.SETRANGE(rocupantes."Fecha entrada",wFecha);
        IF rocupantes.FIND('-') THEN BEGIN
          REPEAT
          rocupantes.Nombre:=CoNVERTSTR(rocupantes.Nombre,'n','N');
          rocupantes.Nombre:=CoNVERTSTR(rocupantes.Nombre,'n','n');
          rocupantes.Nombre:=CoNVERTSTR(rocupantes.Nombre,'Ø','o');
          rocupantes.Nombre:=CoNVERTSTR(rocupantes.Nombre,'a','A');
          rocupantes.Nombre:=CoNVERTSTR(rocupantes.Nombre,'À','A');
          rocupantes.Nombre:=CoNVERTSTR(rocupantes.Nombre,'Â','A');
          rocupantes.Nombre:=CoNVERTSTR(rocupantes.Nombre,'e','E');
          rocupantes.Nombre:=CoNVERTSTR(rocupantes.Nombre,'È','E');
          rocupantes.Nombre:=CoNVERTSTR(rocupantes.Nombre,'Ê','E');
          rocupantes.Nombre:=CoNVERTSTR(rocupantes.Nombre,'i','I');
          rocupantes.Nombre:=CoNVERTSTR(rocupantes.Nombre,'Ì','I');
          rocupantes.Nombre:=CoNVERTSTR(rocupantes.Nombre,'Î','I');
          rocupantes.Nombre:=CoNVERTSTR(rocupantes.Nombre,'o','o');
          rocupantes.Nombre:=CoNVERTSTR(rocupantes.Nombre,'Ò','o');
          rocupantes.Nombre:=CoNVERTSTR(rocupantes.Nombre,'Ô','o');
          rocupantes.Nombre:=CoNVERTSTR(rocupantes.Nombre,'u','U');
          rocupantes.Nombre:=CoNVERTSTR(rocupantes.Nombre,'Ù','U');
          rocupantes.Nombre:=CoNVERTSTR(rocupantes.Nombre,'Û','U');
          rocupantes.Nombre:=CoNVERTSTR(rocupantes.Nombre,'a','a');
          rocupantes.Nombre:=CoNVERTSTR(rocupantes.Nombre,'à','a');
          rocupantes.Nombre:=CoNVERTSTR(rocupantes.Nombre,'â','a');
          rocupantes.Nombre:=CoNVERTSTR(rocupantes.Nombre,'e','e');
          rocupantes.Nombre:=CoNVERTSTR(rocupantes.Nombre,'è','e');
          rocupantes.Nombre:=CoNVERTSTR(rocupantes.Nombre,'ê','e');
          rocupantes.Nombre:=CoNVERTSTR(rocupantes.Nombre,'i','i');
          rocupantes.Nombre:=CoNVERTSTR(rocupantes.Nombre,'ì','i');
          rocupantes.Nombre:=CoNVERTSTR(rocupantes.Nombre,'î','i');
          rocupantes.Nombre:=CoNVERTSTR(rocupantes.Nombre,'o','o');
          rocupantes.Nombre:=CoNVERTSTR(rocupantes.Nombre,'ò','o');
          rocupantes.Nombre:=CoNVERTSTR(rocupantes.Nombre,'ô','o');
          rocupantes.Nombre:=CoNVERTSTR(rocupantes.Nombre,'u','u');
          rocupantes.Nombre:=CoNVERTSTR(rocupantes.Nombre,'ù','u');
          rocupantes.Nombre:=CoNVERTSTR(rocupantes.Nombre,'û','u');
          rocupantes.Nombre:=CoNVERTSTR(rocupantes.Nombre,'Ä','A');
          rocupantes.Nombre:=CoNVERTSTR(rocupantes.Nombre,'Ë','E');
          rocupantes.Nombre:=CoNVERTSTR(rocupantes.Nombre,'Ï','I');
          rocupantes.Nombre:=CoNVERTSTR(rocupantes.Nombre,'Ö','o');
          rocupantes.Nombre:=CoNVERTSTR(rocupantes.Nombre,'Ü','U');
          rocupantes.Nombre:=CoNVERTSTR(rocupantes.Nombre,'Ç','C');
          rocupantes.Nombre:=CoNVERTSTR(rocupantes.Nombre,'ç','c');
          rocupantes.Nombre:=CoNVERTSTR(rocupantes.Nombre,'ä','a');
          rocupantes.Nombre:=CoNVERTSTR(rocupantes.Nombre,'ë','e');
          rocupantes.Nombre:=CoNVERTSTR(rocupantes.Nombre,'ï','i');
          rocupantes.Nombre:=CoNVERTSTR(rocupantes.Nombre,'ö','o');
          rocupantes.Nombre:=CoNVERTSTR(rocupantes.Nombre,'ü','u');
          rocupantes.Nombre:=CoNVERTSTR(rocupantes.Nombre,',',' ');
          rocupantes.Nombre:=CoNVERTSTR(rocupantes.Nombre,'ã','a');
          rocupantes.Nombre:=CoNVERTSTR(rocupantes.Nombre,'Ã','A');
          rocupantes.Nombre:=CoNVERTSTR(rocupantes.Nombre,'õ','o');
          rocupantes.Nombre:=CoNVERTSTR(rocupantes.Nombre,'Õ','o');
          rocupantes.Nombre:=CoNVERTSTR(rocupantes.Nombre,'Æ','A');
          rocupantes.Nombre:=CoNVERTSTR(rocupantes.Nombre,'L','L');
          rocupantes.Nombre:=CoNVERTSTR(rocupantes.Nombre,'Ø','o');
        
        
          rocupantes."Apellido 1:=CoNVERTSTR(rocupantes."Apellido 1,'a','A');
          rocupantes."Apellido 1:=CoNVERTSTR(rocupantes."Apellido 1,'C','C');
          rocupantes."Apellido 1:=CoNVERTSTR(rocupantes."Apellido 1,'À','A');
          rocupantes."Apellido 1:=CoNVERTSTR(rocupantes."Apellido 1,'Â','A');
          rocupantes."Apellido 1:=CoNVERTSTR(rocupantes."Apellido 1,'e','E');
          rocupantes."Apellido 1:=CoNVERTSTR(rocupantes."Apellido 1,'È','E');
          rocupantes."Apellido 1:=CoNVERTSTR(rocupantes."Apellido 1,'Ê','E');
          rocupantes."Apellido 1:=CoNVERTSTR(rocupantes."Apellido 1,'i','I');
          rocupantes."Apellido 1:=CoNVERTSTR(rocupantes."Apellido 1,'Ì','I');
          rocupantes."Apellido 1:=CoNVERTSTR(rocupantes."Apellido 1,'Î','I');
          rocupantes."Apellido 1:=CoNVERTSTR(rocupantes."Apellido 1,'o','o');
          rocupantes."Apellido 1:=CoNVERTSTR(rocupantes."Apellido 1,'Ò','o');
          rocupantes."Apellido 1:=CoNVERTSTR(rocupantes."Apellido 1,'Ô','o');
          rocupantes."Apellido 1:=CoNVERTSTR(rocupantes."Apellido 1,'u','U');
          rocupantes."Apellido 1:=CoNVERTSTR(rocupantes."Apellido 1,'Ù','U');
          rocupantes."Apellido 1:=CoNVERTSTR(rocupantes."Apellido 1,'Û','U');
          rocupantes."Apellido 1:=CoNVERTSTR(rocupantes."Apellido 1,'a','a');
          rocupantes."Apellido 1:=CoNVERTSTR(rocupantes."Apellido 1,'à','a');
          rocupantes."Apellido 1:=CoNVERTSTR(rocupantes."Apellido 1,'â','a');
          rocupantes."Apellido 1:=CoNVERTSTR(rocupantes."Apellido 1,'e','e');
          rocupantes."Apellido 1:=CoNVERTSTR(rocupantes."Apellido 1,'è','e');
          rocupantes."Apellido 1:=CoNVERTSTR(rocupantes."Apellido 1,'ê','e');
          rocupantes."Apellido 1:=CoNVERTSTR(rocupantes."Apellido 1,'i','i');
          rocupantes."Apellido 1:=CoNVERTSTR(rocupantes."Apellido 1,'ì','i');
          rocupantes."Apellido 1:=CoNVERTSTR(rocupantes."Apellido 1,'î','i');
          rocupantes."Apellido 1:=CoNVERTSTR(rocupantes."Apellido 1,'o','o');
          rocupantes."Apellido 1:=CoNVERTSTR(rocupantes."Apellido 1,'ò','o');
          rocupantes."Apellido 1:=CoNVERTSTR(rocupantes."Apellido 1,'ô','o');
          rocupantes."Apellido 1:=CoNVERTSTR(rocupantes."Apellido 1,'u','u');
          rocupantes."Apellido 1:=CoNVERTSTR(rocupantes."Apellido 1,'ù','u');
          rocupantes."Apellido 1:=CoNVERTSTR(rocupantes."Apellido 1,'û','u');
          rocupantes."Apellido 1:=CoNVERTSTR(rocupantes."Apellido 1,'ã','a');
          rocupantes."Apellido 1:=CoNVERTSTR(rocupantes."Apellido 1,'Ã','A');
          rocupantes."Apellido 1:=CoNVERTSTR(rocupantes."Apellido 1,'õ','o');
          rocupantes."Apellido 1:=CoNVERTSTR(rocupantes."Apellido 1,'Õ','o');
          rocupantes."Apellido 1:=CoNVERTSTR(rocupantes."Apellido 1,'Ø','o');
          rocupantes."Apellido 1:=CoNVERTSTR(rocupantes."Apellido 1,'Ö','o');
          rocupantes."Apellido 1:=CoNVERTSTR(rocupantes."Apellido 1,'Æ','A');
          rocupantes."Apellido 1:=CoNVERTSTR(rocupantes."Apellido 1,'L','L');
          rocupantes."Apellido 1:=CoNVERTSTR(rocupantes."Apellido 1,'Ä','A');
          rocupantes."Apellido 1:=CoNVERTSTR(rocupantes."Apellido 1,'Ë','E');
          rocupantes."Apellido 1:=CoNVERTSTR(rocupantes."Apellido 1,'Ï','I');
          rocupantes."Apellido 1:=CoNVERTSTR(rocupantes."Apellido 1,'Ö','o');
          rocupantes."Apellido 1:=CoNVERTSTR(rocupantes."Apellido 1,'Ü','U');
          rocupantes."Apellido 1:=CoNVERTSTR(rocupantes."Apellido 1,'ä','a');
          rocupantes."Apellido 1:=CoNVERTSTR(rocupantes."Apellido 1,'ë','e');
          rocupantes."Apellido 1:=CoNVERTSTR(rocupantes."Apellido 1,'ï','i');
          rocupantes."Apellido 1:=CoNVERTSTR(rocupantes."Apellido 1,'ö','o');
          rocupantes."Apellido 1:=CoNVERTSTR(rocupantes."Apellido 1,'ü','u');
          rocupantes."Apellido 1:=CoNVERTSTR(rocupantes."Apellido 1,',',' ');
          rocupantes."Apellido 1:=CoNVERTSTR(rocupantes."Apellido 1,'Ç','C');
          rocupantes."Apellido 1:=CoNVERTSTR(rocupantes."Apellido 1,'ç','c');
          rocupantes."Apellido 1:=CoNVERTSTR(rocupantes."Apellido 1,'n','N');
          rocupantes."Apellido 1:=CoNVERTSTR(rocupantes."Apellido 1,'n','n');
          rocupantes."Apellido 1:=CoNVERTSTR(rocupantes."Apellido 1,'Ø','o');
          rocupantes."Apellido 1:=CoNVERTSTR(rocupantes."Apellido 1,'L','L');
          rocupantes."Apellido 1:=CoNVERTSTR(rocupantes."Apellido 1,'l','l');
        
          rocupantes."Apellido 2:=CoNVERTSTR(rocupantes."Apellido 2,'Ä','A');
          rocupantes."Apellido 2:=CoNVERTSTR(rocupantes."Apellido 2,'Ë','E');
          rocupantes."Apellido 2:=CoNVERTSTR(rocupantes."Apellido 2,'Ï','I');
          rocupantes."Apellido 2:=CoNVERTSTR(rocupantes."Apellido 2,'Ö','o');
          rocupantes."Apellido 2:=CoNVERTSTR(rocupantes."Apellido 2,'Ü','U');
          rocupantes."Apellido 2:=CoNVERTSTR(rocupantes."Apellido 2,'ä','a');
          rocupantes."Apellido 2:=CoNVERTSTR(rocupantes."Apellido 2,'ë','e');
          rocupantes."Apellido 2:=CoNVERTSTR(rocupantes."Apellido 2,'ï','i');
          rocupantes."Apellido 2:=CoNVERTSTR(rocupantes."Apellido 2,'ö','o');
          rocupantes."Apellido 2:=CoNVERTSTR(rocupantes."Apellido 2,'ü','u');
          rocupantes."Apellido 2:=CoNVERTSTR(rocupantes."Apellido 2,',',' ');
          rocupantes."Apellido 2:=CoNVERTSTR(rocupantes."Apellido 2,'n','N');
          rocupantes."Apellido 2:=CoNVERTSTR(rocupantes."Apellido 2,'n','n');
          rocupantes."Apellido 2:=CoNVERTSTR(rocupantes."Apellido 2,'a','A');
          rocupantes."Apellido 2:=CoNVERTSTR(rocupantes."Apellido 2,'À','A');
          rocupantes."Apellido 2:=CoNVERTSTR(rocupantes."Apellido 2,'Â','A');
          rocupantes."Apellido 2:=CoNVERTSTR(rocupantes."Apellido 2,'e','E');
          rocupantes."Apellido 2:=CoNVERTSTR(rocupantes."Apellido 2,'È','E');
          rocupantes."Apellido 2:=CoNVERTSTR(rocupantes."Apellido 2,'Ê','E');
          rocupantes."Apellido 2:=CoNVERTSTR(rocupantes."Apellido 2,'i','I');
          rocupantes."Apellido 2:=CoNVERTSTR(rocupantes."Apellido 2,'Ì','I');
          rocupantes."Apellido 2:=CoNVERTSTR(rocupantes."Apellido 2,'Î','I');
          rocupantes."Apellido 2:=CoNVERTSTR(rocupantes."Apellido 2,'o','o');
          rocupantes."Apellido 2:=CoNVERTSTR(rocupantes."Apellido 2,'Ò','o');
          rocupantes."Apellido 2:=CoNVERTSTR(rocupantes."Apellido 2,'Ô','o');
          rocupantes."Apellido 2:=CoNVERTSTR(rocupantes."Apellido 2,'u','U');
          rocupantes."Apellido 2:=CoNVERTSTR(rocupantes."Apellido 2,'Ù','U');
          rocupantes."Apellido 2:=CoNVERTSTR(rocupantes."Apellido 2,'Û','U');
          rocupantes."Apellido 2:=CoNVERTSTR(rocupantes."Apellido 2,'a','a');
          rocupantes."Apellido 2:=CoNVERTSTR(rocupantes."Apellido 2,'à','a');
          rocupantes."Apellido 2:=CoNVERTSTR(rocupantes."Apellido 2,'â','a');
          rocupantes."Apellido 2:=CoNVERTSTR(rocupantes."Apellido 2,'e','e');
          rocupantes."Apellido 2:=CoNVERTSTR(rocupantes."Apellido 2,'è','e');
          rocupantes."Apellido 2:=CoNVERTSTR(rocupantes."Apellido 2,'ê','e');
          rocupantes."Apellido 2:=CoNVERTSTR(rocupantes."Apellido 2,'i','i');
          rocupantes."Apellido 2:=CoNVERTSTR(rocupantes."Apellido 2,'ì','i');
          rocupantes."Apellido 2:=CoNVERTSTR(rocupantes."Apellido 2,'î','i');
          rocupantes."Apellido 2:=CoNVERTSTR(rocupantes."Apellido 2,'o','o');
          rocupantes."Apellido 2:=CoNVERTSTR(rocupantes."Apellido 2,'ò','o');
          rocupantes."Apellido 2:=CoNVERTSTR(rocupantes."Apellido 2,'ô','o');
          rocupantes."Apellido 2:=CoNVERTSTR(rocupantes."Apellido 2,'u','u');
          rocupantes."Apellido 2:=CoNVERTSTR(rocupantes."Apellido 2,'ù','u');
          rocupantes."Apellido 2:=CoNVERTSTR(rocupantes."Apellido 2,'û','u');
          rocupantes."Apellido 2:=CoNVERTSTR(rocupantes."Apellido 2,'Æ','A');
          rocupantes."Apellido 2:=CoNVERTSTR(rocupantes."Apellido 2,'Ç','C');
          rocupantes."Apellido 2:=CoNVERTSTR(rocupantes."Apellido 2,'ç','c');
          rocupantes."Apellido 2:=CoNVERTSTR(rocupantes."Apellido 2,'ã','a');
          rocupantes."Apellido 2:=CoNVERTSTR(rocupantes."Apellido 2,'Ã','A');
          rocupantes."Apellido 2:=CoNVERTSTR(rocupantes."Apellido 2,'õ','o');
          rocupantes."Apellido 2:=CoNVERTSTR(rocupantes."Apellido 2,'Õ','o');
          rocupantes."Apellido 2:=CoNVERTSTR(rocupantes."Apellido 2,'C','C');
          rocupantes."Apellido 2:=CoNVERTSTR(rocupantes."Apellido 2,'Ø','o');
        
          rocupantes."E-mail":=CoNVERTSTR(rocupantes."E-mail",'n','N');
          rocupantes."E-mail":=CoNVERTSTR(rocupantes."E-mail",'n','n');
          rocupantes."E-mail":=CoNVERTSTR(rocupantes."E-mail",'Ø','o');
          rocupantes."E-mail":=CoNVERTSTR(rocupantes."E-mail",'a','A');
          rocupantes."E-mail":=CoNVERTSTR(rocupantes."E-mail",'À','A');
          rocupantes."E-mail":=CoNVERTSTR(rocupantes."E-mail",'Â','A');
          rocupantes."E-mail":=CoNVERTSTR(rocupantes."E-mail",'e','E');
          rocupantes."E-mail":=CoNVERTSTR(rocupantes."E-mail",'È','E');
          rocupantes."E-mail":=CoNVERTSTR(rocupantes."E-mail",'Ê','E');
          rocupantes."E-mail":=CoNVERTSTR(rocupantes."E-mail",'i','I');
          rocupantes."E-mail":=CoNVERTSTR(rocupantes."E-mail",'Ì','I');
          rocupantes."E-mail":=CoNVERTSTR(rocupantes."E-mail",'Î','I');
          rocupantes."E-mail":=CoNVERTSTR(rocupantes."E-mail",'o','o');
          rocupantes."E-mail":=CoNVERTSTR(rocupantes."E-mail",'Ò','o');
          rocupantes."E-mail":=CoNVERTSTR(rocupantes."E-mail",'Ô','o');
          rocupantes."E-mail":=CoNVERTSTR(rocupantes."E-mail",'u','U');
          rocupantes."E-mail":=CoNVERTSTR(rocupantes."E-mail",'Ù','U');
          rocupantes."E-mail":=CoNVERTSTR(rocupantes."E-mail",'Û','U');
          rocupantes."E-mail":=CoNVERTSTR(rocupantes."E-mail",'a','a');
          rocupantes."E-mail":=CoNVERTSTR(rocupantes."E-mail",'à','a');
          rocupantes."E-mail":=CoNVERTSTR(rocupantes."E-mail",'â','a');
          rocupantes."E-mail":=CoNVERTSTR(rocupantes."E-mail",'e','e');
          rocupantes."E-mail":=CoNVERTSTR(rocupantes."E-mail",'è','e');
          rocupantes."E-mail":=CoNVERTSTR(rocupantes."E-mail",'ê','e');
          rocupantes."E-mail":=CoNVERTSTR(rocupantes."E-mail",'i','i');
          rocupantes."E-mail":=CoNVERTSTR(rocupantes."E-mail",'ì','i');
          rocupantes."E-mail":=CoNVERTSTR(rocupantes."E-mail",'î','i');
          rocupantes."E-mail":=CoNVERTSTR(rocupantes."E-mail",'o','o');
          rocupantes."E-mail":=CoNVERTSTR(rocupantes."E-mail",'ò','o');
          rocupantes."E-mail":=CoNVERTSTR(rocupantes."E-mail",'ô','o');
          rocupantes."E-mail":=CoNVERTSTR(rocupantes."E-mail",'u','u');
          rocupantes."E-mail":=CoNVERTSTR(rocupantes."E-mail",'ù','u');
          rocupantes."E-mail":=CoNVERTSTR(rocupantes."E-mail",'û','u');
          rocupantes."E-mail":=CoNVERTSTR(rocupantes."E-mail",'Ä','A');
          rocupantes."E-mail":=CoNVERTSTR(rocupantes."E-mail",'Ë','E');
          rocupantes."E-mail":=CoNVERTSTR(rocupantes."E-mail",'Ï','I');
          rocupantes."E-mail":=CoNVERTSTR(rocupantes."E-mail",'Ö','o');
          rocupantes."E-mail":=CoNVERTSTR(rocupantes."E-mail",'Ü','U');
          rocupantes."E-mail":=CoNVERTSTR(rocupantes."E-mail",'Ç','C');
          rocupantes."E-mail":=CoNVERTSTR(rocupantes."E-mail",'ç','c');
          rocupantes."E-mail":=CoNVERTSTR(rocupantes."E-mail",'ä','a');
          rocupantes."E-mail":=CoNVERTSTR(rocupantes."E-mail",'ë','e');
          rocupantes."E-mail":=CoNVERTSTR(rocupantes."E-mail",'ï','i');
          rocupantes."E-mail":=CoNVERTSTR(rocupantes."E-mail",'ö','o');
          rocupantes."E-mail":=CoNVERTSTR(rocupantes."E-mail",'ü','u');
          rocupantes."E-mail":=CoNVERTSTR(rocupantes."E-mail",'ã','a');
          rocupantes."E-mail":=CoNVERTSTR(rocupantes."E-mail",'Ã','A');
          rocupantes."E-mail":=CoNVERTSTR(rocupantes."E-mail",'õ','o');
          rocupantes."E-mail":=CoNVERTSTR(rocupantes."E-mail",'Õ','o');
          rocupantes."E-mail":=CoNVERTSTR(rocupantes."E-mail",'Æ','A');
        
          rocupantes."Soporte documento":=CoNVERTSTR(rocupantes."Soporte documento",'n','N');
          rocupantes."Soporte documento":=CoNVERTSTR(rocupantes."Soporte documento",'n','n');
          rocupantes."Soporte documento":=CoNVERTSTR(rocupantes."Soporte documento",'Ø','o');
          rocupantes."Soporte documento":=CoNVERTSTR(rocupantes."Soporte documento",'a','A');
          rocupantes."Soporte documento":=CoNVERTSTR(rocupantes."Soporte documento",'À','A');
          rocupantes."Soporte documento":=CoNVERTSTR(rocupantes."Soporte documento",'Â','A');
          rocupantes."Soporte documento":=CoNVERTSTR(rocupantes."Soporte documento",'e','E');
          rocupantes."Soporte documento":=CoNVERTSTR(rocupantes."Soporte documento",'È','E');
          rocupantes."Soporte documento":=CoNVERTSTR(rocupantes."Soporte documento",'Ê','E');
          rocupantes."Soporte documento":=CoNVERTSTR(rocupantes."Soporte documento",'i','I');
          rocupantes."Soporte documento":=CoNVERTSTR(rocupantes."Soporte documento",'Ì','I');
          rocupantes."Soporte documento":=CoNVERTSTR(rocupantes."Soporte documento",'Î','I');
          rocupantes."Soporte documento":=CoNVERTSTR(rocupantes."Soporte documento",'o','o');
          rocupantes."Soporte documento":=CoNVERTSTR(rocupantes."Soporte documento",'Ò','o');
          rocupantes."Soporte documento":=CoNVERTSTR(rocupantes."Soporte documento",'Ô','o');
          rocupantes."Soporte documento":=CoNVERTSTR(rocupantes."Soporte documento",'u','U');
          rocupantes."Soporte documento":=CoNVERTSTR(rocupantes."Soporte documento",'Ù','U');
          rocupantes."Soporte documento":=CoNVERTSTR(rocupantes."Soporte documento",'Û','U');
          rocupantes."Soporte documento":=CoNVERTSTR(rocupantes."Soporte documento",'a','a');
          rocupantes."Soporte documento":=CoNVERTSTR(rocupantes."Soporte documento",'à','a');
          rocupantes."Soporte documento":=CoNVERTSTR(rocupantes."Soporte documento",'â','a');
          rocupantes."Soporte documento":=CoNVERTSTR(rocupantes."Soporte documento",'e','e');
          rocupantes."Soporte documento":=CoNVERTSTR(rocupantes."Soporte documento",'è','e');
          rocupantes."Soporte documento":=CoNVERTSTR(rocupantes."Soporte documento",'ê','e');
          rocupantes."Soporte documento":=CoNVERTSTR(rocupantes."Soporte documento",'i','i');
          rocupantes."Soporte documento":=CoNVERTSTR(rocupantes."Soporte documento",'ì','i');
          rocupantes."Soporte documento":=CoNVERTSTR(rocupantes."Soporte documento",'î','i');
          rocupantes."Soporte documento":=CoNVERTSTR(rocupantes."Soporte documento",'o','o');
          rocupantes."Soporte documento":=CoNVERTSTR(rocupantes."Soporte documento",'ò','o');
          rocupantes."Soporte documento":=CoNVERTSTR(rocupantes."Soporte documento",'ô','o');
          rocupantes."Soporte documento":=CoNVERTSTR(rocupantes."Soporte documento",'u','u');
          rocupantes."Soporte documento":=CoNVERTSTR(rocupantes."Soporte documento",'ù','u');
          rocupantes."Soporte documento":=CoNVERTSTR(rocupantes."Soporte documento",'û','u');
          rocupantes."Soporte documento":=CoNVERTSTR(rocupantes."Soporte documento",'Ä','A');
          rocupantes."Soporte documento":=CoNVERTSTR(rocupantes."Soporte documento",'Ë','E');
          rocupantes."Soporte documento":=CoNVERTSTR(rocupantes."Soporte documento",'Ï','I');
          rocupantes."Soporte documento":=CoNVERTSTR(rocupantes."Soporte documento",'Ö','o');
          rocupantes."Soporte documento":=CoNVERTSTR(rocupantes."Soporte documento",'Ü','U');
          rocupantes."Soporte documento":=CoNVERTSTR(rocupantes."Soporte documento",'Ç','C');
          rocupantes."Soporte documento":=CoNVERTSTR(rocupantes."Soporte documento",'ç','e');
          rocupantes."Soporte documento":=CoNVERTSTR(rocupantes."Soporte documento",'ä','a');
          rocupantes."Soporte documento":=CoNVERTSTR(rocupantes."Soporte documento",'ë','e');
          rocupantes."Soporte documento":=CoNVERTSTR(rocupantes."Soporte documento",'ï','i');
          rocupantes."Soporte documento":=CoNVERTSTR(rocupantes."Soporte documento",'ö','o');
          rocupantes."Soporte documento":=CoNVERTSTR(rocupantes."Soporte documento",'ü','u');
          rocupantes."Soporte documento":=CoNVERTSTR(rocupantes."Soporte documento",',',' ');
          rocupantes."Soporte documento":=CoNVERTSTR(rocupantes."Soporte documento",'ã','a');
          rocupantes."Soporte documento":=CoNVERTSTR(rocupantes."Soporte documento",'Ã','A');
          rocupantes."Soporte documento":=CoNVERTSTR(rocupantes."Soporte documento",'õ','o');
          rocupantes."Soporte documento":=CoNVERTSTR(rocupantes."Soporte documento",'Õ','o');
          rocupantes."Soporte documento":=CoNVERTSTR(rocupantes."Soporte documento",'Æ','A');
        
          rocupantes.Direccion:=CoNVERTSTR(rocupantes.Direccion,'n','N');
          rocupantes.Direccion:=CoNVERTSTR(rocupantes.Direccion,'n','n');
          rocupantes.Direccion:=CoNVERTSTR(rocupantes.Direccion,'Ø','o');
          rocupantes.Direccion:=CoNVERTSTR(rocupantes.Direccion,'a','A');
          rocupantes.Direccion:=CoNVERTSTR(rocupantes.Direccion,'À','A');
          rocupantes.Direccion:=CoNVERTSTR(rocupantes.Direccion,'Â','A');
          rocupantes.Direccion:=CoNVERTSTR(rocupantes.Direccion,'e','E');
          rocupantes.Direccion:=CoNVERTSTR(rocupantes.Direccion,'È','E');
          rocupantes.Direccion:=CoNVERTSTR(rocupantes.Direccion,'Ê','E');
          rocupantes.Direccion:=CoNVERTSTR(rocupantes.Direccion,'i','I');
          rocupantes.Direccion:=CoNVERTSTR(rocupantes.Direccion,'Ì','I');
          rocupantes.Direccion:=CoNVERTSTR(rocupantes.Direccion,'Î','I');
          rocupantes.Direccion:=CoNVERTSTR(rocupantes.Direccion,'o','o');
          rocupantes.Direccion:=CoNVERTSTR(rocupantes.Direccion,'Ò','o');
          rocupantes.Direccion:=CoNVERTSTR(rocupantes.Direccion,'Ô','o');
          rocupantes.Direccion:=CoNVERTSTR(rocupantes.Direccion,'u','U');
          rocupantes.Direccion:=CoNVERTSTR(rocupantes.Direccion,'Ù','U');
          rocupantes.Direccion:=CoNVERTSTR(rocupantes.Direccion,'Û','U');
          rocupantes.Direccion:=CoNVERTSTR(rocupantes.Direccion,'a','a');
          rocupantes.Direccion:=CoNVERTSTR(rocupantes.Direccion,'à','a');
          rocupantes.Direccion:=CoNVERTSTR(rocupantes.Direccion,'â','a');
          rocupantes.Direccion:=CoNVERTSTR(rocupantes.Direccion,'e','e');
          rocupantes.Direccion:=CoNVERTSTR(rocupantes.Direccion,'è','e');
          rocupantes.Direccion:=CoNVERTSTR(rocupantes.Direccion,'ê','e');
          rocupantes.Direccion:=CoNVERTSTR(rocupantes.Direccion,'i','i');
          rocupantes.Direccion:=CoNVERTSTR(rocupantes.Direccion,'ì','i');
          rocupantes.Direccion:=CoNVERTSTR(rocupantes.Direccion,'î','i');
          rocupantes.Direccion:=CoNVERTSTR(rocupantes.Direccion,'o','o');
          rocupantes.Direccion:=CoNVERTSTR(rocupantes.Direccion,'ò','o');
          rocupantes.Direccion:=CoNVERTSTR(rocupantes.Direccion,'ô','o');
          rocupantes.Direccion:=CoNVERTSTR(rocupantes.Direccion,'u','u');
          rocupantes.Direccion:=CoNVERTSTR(rocupantes.Direccion,'ù','u');
          rocupantes.Direccion:=CoNVERTSTR(rocupantes.Direccion,'û','u');
          rocupantes.Direccion:=CoNVERTSTR(rocupantes.Direccion,'Ä','A');
          rocupantes.Direccion:=CoNVERTSTR(rocupantes.Direccion,'Ë','E');
          rocupantes.Direccion:=CoNVERTSTR(rocupantes.Direccion,'Ï','I');
          rocupantes.Direccion:=CoNVERTSTR(rocupantes.Direccion,'Ö','o');
          rocupantes.Direccion:=CoNVERTSTR(rocupantes.Direccion,'Ü','U');
          rocupantes.Direccion:=CoNVERTSTR(rocupantes.Direccion,'Ç','C');
          rocupantes.Direccion:=CoNVERTSTR(rocupantes.Direccion,'ç','e');
          rocupantes.Direccion:=CoNVERTSTR(rocupantes.Direccion,'ä','a');
          rocupantes.Direccion:=CoNVERTSTR(rocupantes.Direccion,'ë','e');
          rocupantes.Direccion:=CoNVERTSTR(rocupantes.Direccion,'ï','i');
          rocupantes.Direccion:=CoNVERTSTR(rocupantes.Direccion,'ö','o');
          rocupantes.Direccion:=CoNVERTSTR(rocupantes.Direccion,'ü','u');
          rocupantes.Direccion:=CoNVERTSTR(rocupantes.Direccion,',',' ');
          rocupantes.Direccion:=CoNVERTSTR(rocupantes.Direccion,'ã','a');
          rocupantes.Direccion:=CoNVERTSTR(rocupantes.Direccion,'Ã','A');
          rocupantes.Direccion:=CoNVERTSTR(rocupantes.Direccion,'õ','o');
          rocupantes.Direccion:=CoNVERTSTR(rocupantes.Direccion,'Õ','o');
          rocupantes.Direccion:=CoNVERTSTR(rocupantes.Direccion,'Æ','A');
        
        {
          rocupantes."E-mail":=DELCHR(rocupantes."E-mail",',');
          rocupantes."E-mail":=DELCHR(rocupantes."E-mail",'\');
          rocupantes."E-mail":=DELCHR(rocupantes."E-mail",'/');
          rocupantes."E-mail":=DELCHR(rocupantes."E-mail",'-');
        }
          rocupantes.MoDIFY;
        
          UNTIL rocupantes.NEXT=0
        END;
        Ventana.CLoSE;
        CoMMIT;
        */

    end;

    local procedure fArregloCardex()
    var
        rCompany: Record "2000000006;
        rParentocupRef: Record 7012891;
        rParentocup: Record 7012891;
        rParFront: Record 7000111;
        rHospeHotel: Record 7012906;
        rEnvHospe: Record 7012905;
        rEnvHospeRef: Record 7012905;
        rConfHospeHot: Record 7012906;
        rConfHospeHotRef: Record 7012906;
    begin
        rParentocupRef.CHANGECoMPANY('HoTEL FELIP 1890, S.L.U.');
        rEnvHospeRef.CHANGECoMPANY('HoTEL FELIP 1890, S.L.U.');
        rConfHospeHotRef.CHANGECoMPANY('HoTEL FELIP 1890, S.L.U.');
        rCompany.SETFILTER(rCompany.Name, '<>%1', 'HoTEL FELIP 1890, S.L.U.');

        IF rCompany.FIND('-') THEN BEGIN
            REPEAT
                rUsr.CHANGECoMPANY(rCompany.Name);
                rUsr.GET(USERID);
                /*
                  rParentocup.CHANGECoMPANY(rCompany.Name);
                  IF rParentocup.FIND('-') THEN BEGIN
                    REPEAT
                    rParentocup.DELETE;
                    UNTIL rParentocup.NEXT=0
                  END;
                  IF rParentocupRef.FIND('-') THEN BEGIN
                    REPEAT
                    rParentocup.INIT;
                    rParentocup:=rParentocupRef;
                    rParentocup.INSERT;
                    UNTIL rParentocupRef.NEXT=0
                  END;
                  rEnvHospe.CHANGECoMPANY(rCompany.Name);
                  IF rEnvHospe.FIND('-') THEN BEGIN
                    REPEAT
                    rEnvHospe.DELETE
                    UNTIL rEnvHospe.NEXT=0
                  END;
                  IF rEnvHospeRef.FIND('-') THEN BEGIN
                    REPEAT
                    rEnvHospe.INIT;
                    rEnvHospe:=rEnvHospeRef;
                    rEnvHospe.INSERT;
                    UNTIL rEnvHospeRef.NEXT=0
                  END;

                  rConfHospeHot.CHANGECoMPANY(rCompany.Name);
                  IF rConfHospeHot.FIND('-') THEN BEGIN
                    REPEAT
                    rConfHospeHot.DELETE
                    UNTIL rConfHospeHot.NEXT=0
                  END;

                  IF rConfHospeHotRef.FINDFIRST THEN BEGIN
                    rConfHospeHot.INIT;
                    rConfHospeHot:=rConfHospeHotRef;
                    rConfHospeHot.Hotel:=rUsr."Hotel de trabajo";
                    rConfHospeHot.INSERT;
                  END;

                */
                rParFront.CHANGECoMPANY(rCompany.Name);
                rParFront.SETRANGE(rParFront.Hotel, rUsr."Hotel de trabajo");
                IF rParFront.FINDFIRST THEN BEGIN
                    rParFront."Edad minima policia" := 0;
                    rParFront."Edad minima DNI" := 16;
                    rParFront."Permitir envio F.Policia parc." := FALSE;
                    rParFront."Parentesco por defecto" := 'oT';
                    rParFront.MoDIFY
                END;
            UNTIL rCompany.NEXT = 0
        END;

    end;

    local procedure fArreglaMovs()
    var
        R380: Record "380;
    begin
        R380.SETRANGE(R380."Vendor No.", 'A001417');
        //R380.SETFILTER(R380."Entry No.",'%1..%2',195187,237365);
        R380.SETFILTER(R380."Entry No.", '..%1', 170862);
        IF R380.FIND('-') THEN BEGIN
            REPEAT
                R380."User ID" := 'SISTEMA';
                R380.MoDIFY;
            UNTIL R380.NEXT = 0
        END;
    end;

    local procedure fCompruebaProvConta()
    var
        wCount: Integer;
        rControlesTHB: Record "50001;
        rGLEntry: Record "17;
        rVendor: Record "23;
        bExisto: Boolean;
    begin
        rUsr.GET(USERID);

        rControlesTHB.SETRANGE(rControlesTHB.Hotel, 'PRoVNoEXISTE');
        rControlesTHB.SETRANGE(rControlesTHB.Recuento, rUsr."Hotel de trabajo");
        IF rControlesTHB.FIND('-') THEN BEGIN
            REPEAT
                rControlesTHB.DELETE;
            UNTIL rControlesTHB.NEXT = 0
        END;
        rGLEntry.SETFILTER(rGLEntry."G/L Account No.", '%1|%2|%3|%4|%5|%6|%7', '4000003', '4100002', '4010001', '4100101', '4100003', '4100001', '4110015');
        rGLEntry.SETFILTER(rGLEntry."Source No.", '<>%1', '');

        IF rGLEntry.FIND('-') THEN BEGIN
            REPEAT
                bExisto := FALSE;
                rVendor.RESET;
                rVendor.SETRANGE(rVendor."No.", rGLEntry."Source No.");
                IF rVendor.FINDFIRST THEN bExisto := TRUE;
                rVendor.RESET;
                rVendor.SETRANGE(rVendor."Telex No.", rGLEntry."Source No.");
                IF rVendor.FINDFIRST THEN bExisto := TRUE;

                IF bExisto = FALSE THEN BEGIN
                    rControlesTHB.INIT;
                    rControlesTHB.Hotel := 'PRoVNoEXISTE';
                    rControlesTHB.Fecha := FoRMAT(wCount + 1);
                    rControlesTHB.Recuento := rUsr."Hotel de trabajo";
                    rControlesTHB.Producto := FoRMAT(rGLEntry."Entry No.");
                    rControlesTHB."Unidad 1 := rGLEntry."G/L Account No.";
                    rControlesTHB.Date1 := rGLEntry."Posting Date";
                    rControlesTHB."Unidad Medida 2 := rGLEntry."Source No.";
                    rControlesTHB.Decimal := rGLEntry.Amount;
                    rControlesTHB.INSERT;
                    wCount := wCount + 1;
                END;
            UNTIL rGLEntry.NEXT = 0
        END;
    end;

    local procedure fContaProv()
    var
        wCount: Integer;
        wConta: Decimal;
        rControlesTHB: Record "50001;
        rGLEntry: Record "17;
        rVendor: Record "23;
    begin
        Ventana.oPEN('Comprobando saldos de contabilidad vs Saldo Proveedor #1######## #2################################################', rVendor."No.", rVendor.Name);
        rUsr.GET(USERID);

        rControlesTHB.SETRANGE(rControlesTHB.Hotel, 'CoNTAVSMoV');
        rControlesTHB.SETRANGE(rControlesTHB.Recuento, rUsr."Hotel de trabajo");
        IF rControlesTHB.FIND('-') THEN BEGIN
            REPEAT
                rControlesTHB.DELETE;
            UNTIL rControlesTHB.NEXT = 0
        END;
        IF rVendor.FIND('-') THEN BEGIN
            REPEAT
                wConta := 0;
                rVendor.SETFILTER(rVendor."Date Filter", '..%1', 311223D);
                rVendor.CALCFIELDS(rVendor."Debit Amount", rVendor."Credit Amount", rVendor."Net Change", rVendor."Balance (LCY)", rVendor."Net Change (LCY)");
                rGLEntry.SETFILTER(rGLEntry."Posting Date", '..%1', 311223D);
                rGLEntry.SETFILTER(rGLEntry."G/L Account No.", '%1|%2|%3|%4|%5|%6|%7', '4000003', '4100002', '4010001', '4100101', '4100003', '4100001', '4110015');
                IF rVendor."Telex No." <> '' THEN
                    rGLEntry.SETFILTER(rGLEntry."Source No.", '%1|%2', rVendor."No.", rVendor."Telex No.")
                ELSE
                    rGLEntry.SETRANGE(rGLEntry."Source No.", rVendor."No.");
                IF rGLEntry.FIND('-') THEN BEGIN
                    REPEAT
                        wConta := wConta + rGLEntry.Amount;
                    UNTIL rGLEntry.NEXT = 0
                END;
                IF (wConta <> 0) oR (rVendor."Net Change" <> 0) AND (wConta + rVendor."Net Change" <> 0) THEN BEGIN
                    rControlesTHB.INIT;
                    rControlesTHB.Hotel := 'CoNTAVSMoV';
                    rControlesTHB.Fecha := FoRMAT(wCount + 1);
                    rControlesTHB.Recuento := rUsr."Hotel de trabajo";
                    rControlesTHB.Producto := rVendor."No.";
                    rControlesTHB.Decimal := wConta;
                    rControlesTHB."Decimal 3 := wConta + rVendor."Net Change";
                    rControlesTHB."Decimal 2 := rVendor."Net Change";
                    rControlesTHB.INSERT;
                    wCount := wCount + 1;
                END;
                Ventana.UPDATE;
            UNTIL rVendor.NEXT = 0
        END;

        Ventana.CLoSE;
    end;

    local procedure fVendCuadreTest()
    var
        wCount: Decimal;
        rVendor: Record "23;
        wDescuadre: Decimal;
        rControles: Record "50001;
    begin
        Ventana.oPEN('Comprobando los proveedores con descuadres de Importes Debe-Haber-Saldo...');
        rUsr.GET(USERID);
        rControles.SETRANGE(rControles.Hotel, 'VENDCUADRE');
        rControles.SETRANGE(rControles.Recuento, rUsr."Hotel de trabajo");
        IF rControles.FIND('-') THEN BEGIN
            REPEAT
                rControles.DELETE;
            UNTIL rControles.NEXT = 0
        END;

        rUsr.GET(USERID);
        IF rVendor.FIND('-') THEN BEGIN
            REPEAT
                wCount := wCount + 1;
                //rVendor.SETFILTER(rVendor."Date Filter",'..%1',311024D);
                rVendor.CALCFIELDS(rVendor."Debit Amount", rVendor."Credit Amount", rVendor.Balance);
                IF rVendor."Debit Amount" + rVendor.Balance <> rVendor."Credit Amount" THEN BEGIN
                    wDescuadre := (rVendor."Debit Amount" + rVendor.Balance) - rVendor."Credit Amount";
                    rControles.INIT;
                    rControles.Hotel := 'VENDCUADRE';
                    rControles.Fecha := FoRMAT(wCount);
                    rControles.Recuento := rUsr."Hotel de trabajo";
                    rControles.Producto := rVendor."No.";
                    rControles.Decimal := wDescuadre;
                    rControles."Decimal 2 := rVendor."Debit Amount";
                    rControles."Decimal 3 := rVendor."Credit Amount";
                    rControles.INSERT;
                    //ERRoR('%1 - %2',rVendor."No.",wDescuadre)
                END;
            UNTIL rVendor.NEXT = 0
        END;
        Ventana.CLoSE;
    end;

    local procedure fFixSaldoProvTest()
    var
        wCount: Integer;
        r380: Record "380;
        r380Mod: Record "380;
        wImporte: Decimal;
        rControles: Record "50001;
        rControlesTHB: Record "50001;
    begin
        Ventana.oPEN('Comprobando movimientos de liquidacion importados...');
        rUsr.GET(USERID);
        rControles.SETRANGE(rControles.Hotel, 'MoVCUADRE');
        rControles.SETRANGE(rControles.Recuento, rUsr."Hotel de trabajo");
        IF rControles.FIND('-') THEN BEGIN
            REPEAT
                rControles.DELETE;
            UNTIL rControles.NEXT = 0
        END;

        rControlesTHB.SETRANGE(rControlesTHB.Recuento, rUsr."Hotel de trabajo");
        rControlesTHB.SETRANGE(rControlesTHB.Hotel, 'VENDCUADRE');
        IF rControlesTHB.FIND('-') THEN BEGIN
            REPEAT
                r380.SETRANGE(r380."Vendor No.", rControlesTHB.Producto);
                //r380.SETRANGE(r380."User ID",'SISTEMA','VFERNANDEZ');
                r380.SETFILTER(r380."User ID", '=%1|%2|%3|%4|%5', 'SISTEMA', 'APERELLo', 'VFERNANDEZ', 'MSERRA', 'CMoRELL');
                r380.SETRANGE(r380."Entry Type", r380."Entry Type"::Application);
                IF r380.FIND('-') THEN BEGIN
                    REPEAT
                        r380Mod.SETRANGE(r380Mod."Entry Type", r380Mod."Entry Type"::"Initial Entry");
                        //  r380Mod.SETRANGE(r380Mod."User ID",'SISTEMA');
                        r380Mod.SETFILTER(r380Mod."User ID", '=%1|%2|%3|%4|%5', 'SISTEMA', 'APERELLo', 'VFERNANDEZ', 'MSERRA', 'CMoRELL');
                        r380Mod.SETRANGE(r380Mod."Vendor Ledger Entry No.", r380."Vendor Ledger Entry No.");
                        IF r380Mod.FIND('-') THEN BEGIN
                            wCount := wCount + 1;
                            wImporte := r380Mod.Amount + r380.Amount;
                            rControles.INIT;
                            rControles.Hotel := 'MoVCUADRE';
                            rControles.Fecha := FoRMAT(wCount);
                            rControles.Recuento := rUsr."Hotel de trabajo";
                            rControles.Producto := r380Mod."Document No.";
                            rControles.Almacen := r380."Vendor Ledger Entry No.";
                            rControles."Unidad Medida 1 := r380."Entry No.";
                            rControles.Date1 := r380Mod."Posting Date";
                            rControles."Unidad 1 := r380Mod."Vendor No.";
                            rControles.Decimal := r380Mod."Amount (LCY)";
                            rControles."Decimal 2 := r380."Amount (LCY)";
                            rControles."Decimal 3 := r380Mod."Amount (LCY)" + r380."Amount (LCY)";
                            rControles.INSERT;
                        END;
                    UNTIL r380.NEXT = 0
                END;
            UNTIL rControlesTHB.NEXT = 0
        END;
        Ventana.CLoSE;
    end;

    local procedure fFixSaldoProv()
    var
        wImporteTot: Decimal;
        rControlesTHB: Record "50001;
        r380: Record "380;
        r380Mod: Record "380;
        wImporte: Decimal;
    begin

        rUsr.GET(USERID);
        rControlesTHB.SETRANGE(rControlesTHB.Hotel, 'MoVCUADRE');
        rControlesTHB.SETRANGE(rControlesTHB.Recuento, rUsr."Hotel de trabajo");
        //rControlesTHB.SETRANGE(rControlesTHB."Valor de campo",'IBS1700021');
        IF rControlesTHB.FIND('-') THEN BEGIN
            REPEAT
                //r380.SETRANGE(r380."Vendor Ledger Entry No.",rControlesTHB.Integer);
                r380.SETRANGE(r380."Entry No.", rControlesTHB."Unidad Medida 1);
                r380.SETFILTER(r380."User ID", '=%1|%2|%3|%4', 'SISTEMA', 'APERELLo', 'VFERNANDEZ', 'MSERRA');
                r380.SETRANGE(r380."Entry Type", r380."Entry Type"::Application);
                IF r380.FIND('-') THEN BEGIN
                    REPEAT
                        wImporteTot := wImporteTot + r380.Amount;
                        r380Mod.SETRANGE(r380Mod."Entry Type", r380Mod."Entry Type"::"Initial Entry");
                        r380Mod.SETFILTER(r380Mod."User ID", '=%1|%2|%3|%4', 'SISTEMA', 'APERELLo', 'VFERNANDEZ', 'MSERRA');
                        r380Mod.SETRANGE(r380Mod."Vendor Ledger Entry No.", r380."Vendor Ledger Entry No.");
                        IF r380Mod.FIND('-') THEN BEGIN
                            wImporte := r380Mod.Amount + r380.Amount;
                            r380Mod.Amount := wImporte;
                            r380Mod."Amount (LCY)" := wImporte;
                            IF wImporte < 0 THEN BEGIN
                                r380Mod."Credit Amount" := wImporte * -1;
                                r380Mod."Credit Amount (LCY)" := wImporte * -1
                            END ELSE
                                IF wImporte > 0 THEN BEGIN
                                    r380Mod."Debit Amount" := wImporte;
                                    r380Mod."Debit Amount (LCY)" := wImporte;
                                END ELSE
                                    IF wImporte = 0 THEN BEGIN
                                        r380Mod."Debit Amount" := 0;
                                        r380Mod."Debit Amount (LCY)" := 0;
                                        r380Mod."Credit Amount" := 0;
                                        r380Mod."Credit Amount (LCY)" := 0
                                    END;
                            r380Mod.MoDIFY;
                            CoMMIT;
                        END;

                        r380.DELETE;
                    UNTIL r380.NEXT = 0
                END;
            UNTIL rControlesTHB.NEXT = 0
        END;
        /*
        //r380.SETRANGE(r380."Entry No.",45368);
        rControlesTHB.SETRANGE(rControlesTHB.Control,rUsr."Hotel de trabajo");
        rControlesTHB.SETRANGE(rControlesTHB."ID Tabla",'VENDCUADRE');
        IF rControlesTHB.FIND('-') THEN BEGIN
          REPEAT
          r380.SETRANGE(r380."Vendor No.",rControlesTHB."Valor de campo");
          r380.SETRANGE(r380."User ID",'SISTEMA');
          r380.SETRANGE(r380."Entry Type",r380."Entry Type"::Application);
          IF r380.FIND('-') THEN BEGIN
            REPEAT
            r380Mod.SETRANGE(r380Mod."Entry Type",r380Mod."Entry Type"::"Initial Entry");
            r380Mod.SETRANGE(r380Mod."User ID",'SISTEMA');
            r380Mod.SETRANGE(r380Mod."Vendor Ledger Entry No.",r380."Vendor Ledger Entry No.");
            IF r380Mod.FIND('-') THEN BEGIN
              wImporte:=r380Mod.Amount+r380.Amount;
              r380Mod.Amount:=wImporte;
              r380Mod."Amount (LCY)":=wImporte;
              IF wImporte<0 THEN BEGIN
                r380Mod."Credit Amount":=wImporte*-1;
                r380Mod."Credit Amount (LCY)":=wImporte*-1;
              END ELSE BEGIN
                r380Mod."Debit Amount":=wImporte;
                r380Mod."Debit Amount (LCY)":=wImporte;
              END;
            //r380Mod.MoDIFY;
            CoMMIT;
            END;
            wImporteTot:=wImporteTot+r380.Amount;
            //r380.DELETE;
            UNTIL r380.NEXT=0
          END;
          UNTIL rControlesTHB.NEXT=0
        END;
        */
        MESSAGE('%1', wImporteTot);

    end;

    local procedure fMovCuenta()
    var
        rMovs: Record "17;
        rCuenta: Record "15;
    begin
        IF rMovs.FIND('-') THEN BEGIN
            REPEAT
                rCuenta.SETRANGE(rCuenta."No.", rMovs."G/L Account No.");
                IF NoT rCuenta.FINDFIRST THEN ERRoR('Falta la cuenta %1', rMovs."G/L Account No.");
            UNTIL rMovs.NEXT = 0
        END;
    end;

    
    procedure fCaabNo()
    var
        rLinFacImp: Record 7000200;
        rControles: Record "50001;
    begin
        rLinFacImp.SETRANGE(rLinFacImp."Fecha cargo", WoRKDATE);
        //rLinFacImp.SETRANGE(rLinFacImp."Fecha cargo",221024D);
        rLinFacImp.SETRANGE(rLinFacImp."Formato linea", 2);
        rLinFacImp.SETRANGE(rLinFacImp.Concepto, 'Gui');
        IF rLinFacImp.FIND('-') THEN BEGIN
            REPEAT
                rControles.INIT;
                rControles.Hotel := 'CAABNo';
                rControles.Fecha := rLinFacImp.Factura;
                rControles.Recuento := FoRMAT(rLinFacImp."Secuencia grabacion");
                IF rControles.INSERT THEN;
                rLinFacImp."Formato linea" := 0;
                rLinFacImp.MoDIFY;
            UNTIL rLinFacImp.NEXT = 0
        END;
    end;

    local procedure fHospedajes()
    var
        rCompany: Record "2000000006;
        r7012905: Record 7012905;
        r7012905new: Record 7012905;
    begin
        r7012905.CHANGECoMPANY('HoTEL FELIP 1890, S.L.U.');
        r7012905.FINDFIRST;
        rCompany.SETFILTER(rCompany.Name, '<>%1', 'HoTEL FELIP 1890, S.L.U.');
        IF rCompany.FIND('-') THEN BEGIN
            REPEAT
                r7012905new.CHANGECoMPANY(rCompany.Name);
                IF r7012905new.FIND('-') THEN BEGIN
                    REPEAT
                        r7012905new.DELETE;
                    UNTIL r7012905new.NEXT = 0
                END;
                r7012905new.INIT;
                r7012905new := r7012905;
                IF r7012905new.INSERT THEN;
            UNTIL rCompany.NEXT = 0
        END;
    end;

    local procedure fCopiaEmails()
    var
        r23: Record 23;
    begin

        IF r23.FIND('-') THEN BEGIN
            REPEAT
                r23.Contact := r23."E-Mail";
                r23.MoDIFY;
            UNTIL r23.NEXT = 0
        END;
    end;

    local procedure fGeneraLiqPend()
    var
        r25: Record 25;
        r380Pago: Record 380;
        r380: Record 380;
        r380new: Record 380;
        wNumMov: Integer;
        wNumDoc: Code[200];
        wMovLiq: Integer;
        p29: Page 29;
    begin
        /*
        wNumDoc:='TBV2000003/14';
        
        r380Pago.SETRANGE(r380Pago."Document No.",p29.RetornaLiqDocumento(r380));
        IF r380Pago.FINDFIRST THEN BEGIN
          wMovLiq:=r380Pago."Vendor Ledger Entry No.";
          wFecha:=r380Pago."Posting Date"
        END;
        */
        wNumDoc := '';
        r380.RESET;
        IF r380.FINDLAST THEN wNumMov := r380."Entry No.";
        r380.RESET;
        //r380.SETFILTER(r380."Entry No.",'%1|%2|%3|%4|%5|%6|%7|%8|%9|%10',150547,151588,153319,153393,153868,154356,154477,154483,156083,157268);
        r380.SETFILTER(r380."Entry No.", '%1|%2', 158115, 158799);
        //r380.SETRANGE(r380."Entry No.",1331);
        IF r380.FIND('-') THEN BEGIN
            REPEAT
                r25.SETRANGE(r25."Entry No.", r380."Vendor Ledger Entry No.");
                IF r25.FINDFIRST THEN;
                wNumDoc := p29.RetornaLiqDocumento(r25);
                IF STRLEN(wNumDoc) > 20 THEN wNumDoc := CoPYSTR(wNumDoc, 1, 20);
                r380Pago.SETRANGE(r380Pago."Document No.", wNumDoc);
                IF r380Pago.FINDFIRST THEN BEGIN
                    wMovLiq := r380Pago."Vendor Ledger Entry No.";
                    wFecha := r380Pago."Posting Date";

                END;
                wNumMov := wNumMov + 1;
                r380new.INIT;
                r380new."Entry No." := wNumMov;
                r380new."Vendor Ledger Entry No." := r380."Vendor Ledger Entry No.";
                r380new."Document Type" := r380new."Document Type"::Payment;
                r380new."Entry Type" := r380new."Entry Type"::Application;
                r380new."Posting Date" := wFecha;
                r380new."Document No." := wNumDoc;
                r380new.Amount := r380.Amount * -1;
                r380new."Amount (LCY)" := r380."Amount (LCY)" * -1;
                r380new."Source Code" := 'LIQCoMPRA';
                r380new."Transaction No." := 0;
                r380new."Journal Batch Name" := '';
                r380new."Applied Vend. Ledger Entry No." := r25."Entry No.";
                r380new."Excluded from calculation" := FALSE;
                r380new."Ledger Entry Amount" := FALSE;
                r380new."Debit Amount" := r380."Credit Amount";
                r380new."Credit Amount" := r380."Debit Amount";
                r380new."Debit Amount (LCY)" := r380."Credit Amount (LCY)";
                r380new."Credit Amount (LCY)" := r380."Debit Amount (LCY)";
                r380new."Vendor No." := r380."Vendor No.";
                r380new."Currency Code" := r380."Currency Code";
                r380new."User ID" := 'SISTEMA';
                r380new.INSERT;
                //r380."Vendor Ledger Entry No."
            UNTIL r380.NEXT = 0
        END;

    end;

    local procedure fMovProvAntTest()
    var
        rProv: Record 23;
        rControlesTHB: Record 50001;
        r25: Record 25;
        r380: Record 380;
    begin
        Ventana.oPEN('Comprobando existencia de movimientos con codigos antiguos...');
        //LoCALIZAMoS ToDoS LoS MoVIMIENToS CoN CoDIGo ANTIGUo Y LoS ALMACENAMoS EN CoNTRoLES THB
        //rProv.SETRANGE(rProv."No.", ?);
        rProv.SETFILTER(rProv."Telex No.", '<>%1', '');
        IF rProv.FIND('-') THEN BEGIN
            REPEAT
                r25.SETRANGE(r25."Vendor No.", rProv."Telex No.");
                IF r25.FIND('-') THEN BEGIN
                    REPEAT
                        rControlesTHB.INIT;
                        rControlesTHB.Hotel := 'MPRoVANT';
                        rControlesTHB.Fecha := '25';
                        rControlesTHB.Recuento := FoRMAT(r25."Entry No.");
                        rControlesTHB.Producto := rProv."Telex No.";
                        rControlesTHB."Unidad 1 := rProv."No.";
                        rControlesTHB.Decimal := r25."original Amt. (LCY)";
                        IF rControlesTHB.INSERT THEN;
                    UNTIL r25.NEXT = 0
                END;
                r380.SETRANGE(r380."Vendor No.", rProv."Telex No.");
                IF r380.FIND('-') THEN BEGIN
                    REPEAT
                        rControlesTHB.INIT;
                        rControlesTHB.Hotel := 'MPRoVDETANT';
                        rControlesTHB.Fecha := '380';
                        rControlesTHB.Recuento := FoRMAT(r380."Entry No.");
                        rControlesTHB.Producto := rProv."Telex No.";
                        rControlesTHB."Unidad 1 := rProv."No.";
                        rControlesTHB.Decimal := r380."Amount (LCY)";
                        rControlesTHB."Unidad 2 := r380."Document No.";
                        IF rControlesTHB.INSERT THEN;
                    UNTIL r380.NEXT = 0
                END;


            UNTIL rProv.NEXT = 0
        END;
        Ventana.CLoSE;
    end;

    local procedure f7000120()
    var
        rCompocli: Record 7000120;
    begin
        IF rCompocli.FIND('-') THEN BEGIN
            REPEAT
                rCompocli."Libro Reg. Imp. Alt." := 'TToo';
                rCompocli.MoDIFY(TRUE);
            UNTIL rCompocli.NEXT = 0
        END;
    end;

    local procedure f7012()
    var
        r7012: Record 7012;
        wCount: Integer;
    begin
        wCount := 94176;
        r7012.SETRANGE(r7012.SourceCounter, 0);
        IF r7012.FIND('-') THEN BEGIN
            REPEAT
                wCount := 94176 + 1;
                r7012.SourceCounter := wCount;
                r7012.MoDIFY(TRUE);
            UNTIL r7012.NEXT = 0
        END;
    end;

        
    procedure fReplicaEmail()
    var
        r7000564: Record 7000564;
        r7000565: Record 7000565;
        r7000564new: Record 7000564;
        r7000565new: Record 7000565;
        rCompany: Record "2000000006;
        wCount: Integer;
        wCountTot: Integer;
    begin

        IF CoMPANYNAME <> 'THB Gestion' THEN ERRoR('Vaya a THB Gestion para replicar las configuraciones de e-mail.');

        wCount := 0;
        wCountTot := 0;
        Ventana.oPEN('Introduciendo configuraciones de e-mail en #1############################### \' +
                     'Introducidas en sociedad actual #2###### \' +
                     'Registros totales introducidos #3########', rCompany.Name, wCount, wCountTot);


        IF rCompany.FIND('-') THEN BEGIN
            REPEAT
                wCount := 0;
                r7000564new.CHANGECoMPANY(rCompany.Name);
                r7000565new.CHANGECoMPANY(rCompany.Name);
                IF r7000564.FIND('-') THEN BEGIN
                    REPEAT
                        r7000564new.DELETEALL;
                        r7000564new := r7000564;
                        IF r7000564new.INSERT THEN BEGIN
                            wCount := wCount + 1;
                            wCountTot := wCountTot + 1;
                            Ventana.UPDATE;
                        END;
                    UNTIL r7000564.NEXT = 0;
                END;
                IF r7000565.FIND('-') THEN BEGIN
                    REPEAT
                        r7000565new.DELETEALL;
                        r7000565new := r7000565;
                        IF r7000565new.INSERT THEN BEGIN
                            wCount := wCount + 1;
                            wCountTot := wCountTot + 1;
                            Ventana.UPDATE
                        END;
                    UNTIL r7000565.NEXT = 0
                END;

            UNTIL rCompany.NEXT = 0
        END;

        MESSAGE('Se han actualizado un total de #1###### registros totales.', wCountTot);
    end;

    local procedure fItem()
    var
        rItem: Record "27;
    begin
    end;

    local procedure fLimpiaQuoPoS()
    var
        wCount: Integer;
        r7000739: Record 7000739;
        r7000740: Record 7000740;
        r7043405: Record 7043405;
        r7043404: Record 7043404;
    begin

        Ventana.oPEN('Eliminando registros #1########', wCount);
        IF r7000739.FIND('-') THEN BEGIN
            REPEAT
                r7000739.DELETE;
                wCount := wCount + 1;
                Ventana.UPDATE;
            UNTIL r7000739.NEXT = 0
        END;

        IF r7000740.FIND('-') THEN BEGIN
            REPEAT
                r7000740.DELETE;
                wCount := wCount + 1;
                Ventana.UPDATE;
            UNTIL r7000740.NEXT = 0
        END;

        IF r7043405.FIND('-') THEN BEGIN
            REPEAT
                r7043405.DELETE;
                wCount := wCount + 1;
                Ventana.UPDATE;
            UNTIL r7043405.NEXT = 0
        END;

        IF r7043404.FIND('-') THEN BEGIN
            REPEAT
                r7043404.DELETE;
                wCount := wCount + 1;
                Ventana.UPDATE;
            UNTIL r7043404.NEXT = 0
        END;
        MESSAGE('Se han borrado %1 registros.', wCount);
    end;

    local procedure fDivisaHistFacCompra()
    var
        r122: Record "122;
        r123: Record "123;
    begin
        r122.SETRANGE(r122."No.", 'SFS2200887');
        IF r122.FINDFIRST THEN BEGIN
            r122."Currency Code" := 'EUR';
            r122.MoDIFY;
        END;
    end;

    local procedure fPreciosRes()
    var
        r7000181: Record 7000181;
    begin
        IF r7000181.FIND('-') THEN BEGIN
            REPEAT
                r7000181."Tipo precio" := 1;
                r7000181.MoDIFY(TRUE);
            UNTIL r7000181.NEXT = 0
        END;
    end;

    local procedure fBorraRes()
    var
        r7135050: Record "7135050;
        r7000176: Record 7000176;
        r7000181: Record 7000181;
        r7000177: Record 7000177;
        r7000186: Record 7000186;
        r7000206: Record 7000206;
    begin
        IF r7135050.FIND('-') THEN BEGIN
            REPEAT
                r7135050.DELETE;
            UNTIL r7135050.NEXT = 0
        END;

        IF r7000176.FIND('-') THEN BEGIN
            REPEAT
                r7000176.DELETE;
            UNTIL r7000176.NEXT = 0
        END;

        IF r7000181.FIND('-') THEN BEGIN
            REPEAT
                r7000181.DELETE;
            UNTIL r7000181.NEXT = 0
        END;

        IF r7000177.FIND('-') THEN BEGIN
            REPEAT
                r7000177.DELETE;
            UNTIL r7000177.NEXT = 0
        END;

        IF r7000186.FIND('-') THEN BEGIN
            REPEAT
                r7000186.DELETE;
            UNTIL r7000186.NEXT = 0
        END;

        IF r7000206.FIND('-') THEN BEGIN
            REPEAT
                r7000206.DELETE;
            UNTIL r7000206.NEXT = 0
        END;
    end;

    
    procedure fRevisaSIIRoyal()
    var
        r25: Record "25;
        r21: Record "21;
        r7199803: Record "7199803;
        r112: Record "112;
        r122: Record "122;
    begin

        r21.SETFILTER(r21."Posting Date", '%1..', 010123D);
        r21.SETRANGE(r21."Special Scheme Code", 6);
        IF r21.FIND('-') THEN BEGIN
            REPEAT
                r21."Special Scheme Code" := 0;
                r21.MoDIFY;
            UNTIL r21.NEXT = 0
        END;

        r112.SETFILTER(r112."Posting Date", '%1..', 010123D);
        r112.SETRANGE(r112."Special Scheme Code", 6);
        IF r112.FIND('-') THEN BEGIN
            REPEAT
                r112."Special Scheme Code" := 0;
                r112.MoDIFY;
            UNTIL r112.NEXT = 0
        END;

        r7199803.SETFILTER(r7199803."Posting Date", '%1..', 010123D);
        r7199803.SETRANGE(r7199803."SII Entity", 'AEAT');
        IF r7199803.FIND('-') THEN BEGIN
            REPEAT
                r7199803."SII Entity" := 'ATCN';
                r7199803.MoDIFY;
            UNTIL r7199803.NEXT = 0
        END;

        r21.RESET;
        r21.SETRANGE(r21."SII Entity", 'AEAT');
        IF r21.FIND('-') THEN BEGIN
            REPEAT
                r21."SII Entity" := 'ATCN';
                r21.MoDIFY;
            UNTIL r21.NEXT = 0
        END;

        r112.RESET;
        r112.SETRANGE(r112."SII Entity", 'AEAT');
        IF r112.FIND('-') THEN BEGIN
            REPEAT
                r112."SII Entity" := 'ATCN';
                r112.MoDIFY;
            UNTIL r112.NEXT = 0
        END;

        r122.SETFILTER(r122."Posting Date", '%1..', 010123D);
        r122.SETRANGE(r122."Special Scheme Code", 6);
        IF r122.FIND('-') THEN BEGIN
            REPEAT
                r122."Special Scheme Code" := 0;
                r122.MoDIFY;
            UNTIL r122.NEXT = 0
        END;

        r25.SETFILTER(r25."Posting Date", '%1..', 010123D);
        r25.SETRANGE(r25."Special Scheme Code", 6);
        IF r25.FIND('-') THEN BEGIN
            REPEAT
                r25."Special Scheme Code" := 0;
                r25.MoDIFY;
            UNTIL r25.NEXT = 0
        END;

        r25.RESET;
        r25.SETFILTER(r25."Posting Date", '%1..', 010123D);
        r25.SETRANGE(r25."SII Entity", 'AEAT');
        IF r25.FIND('-') THEN BEGIN
            REPEAT
                r25."SII Entity" := 'ATCN';
                r25.MoDIFY;
            UNTIL r25.NEXT = 0
        END;
    end;

    
        local procedure fLineaContrato34()
    var
        r7000168: Record 7000168;
    begin
        r7000168.INIT;
        r7000168.Hotel := 'SUR';
        r7000168.Ano := 2022;
        r7000168."Num. contrato" := '34';
        r7000168.Secuencia := 128;
        r7000168.Usuario := 'THBASPCEN\JRECSUR';
        r7000168.Fecha := 010622D;
        r7000168.Tabla := 0;
        r7000168.Texto := 'Cambiado Hotel del contrato de SUR a ';
        r7000168.Replicado := FALSE;
        r7000168.INSERT;
    end;

    local procedure fFechaActivos()
    var
        r5601: Record "5601;
        r5612: Record "5612;
    begin

        //r5612.SETRANGE(r5612."FA No.",'21004');
        IF r5612.FIND('-') THEN BEGIN
            REPEAT
                r5601.SETRANGE(r5601."FA No.", r5612."FA No.");
                IF r5601.FINDLAST THEN BEGIN
                    r5612."Last Depreciation Date" := r5601."Posting Date";
                    r5612.MoDIFY;
                    //  MESSAGE('Voy a quitar %1 y voy a poner %2',r5612."Last Depreciation Date",r5601."Posting Date");
                END;
            UNTIL r5612.NEXT = 0
        END;
    end;

    local procedure fProveedoresActivos()
    var
        r23: Record "23;
        rControlesTHB: Record "50001;
        rCompany: Record "2000000006;
        wCount: Integer;
    begin

        Ventana.oPEN('EMPRESA #1##################################### PRoVEEDoR #2###########', rCompany.Name, r23."No.");

        //r23.CHANGECoMPANY(rCompany.Name);
        r23.RESET;
        rControlesTHB.SETRANGE(rControlesTHB.Hotel, 'PRoVACTIVoS');
        IF rControlesTHB.FINDLAST THEN EVALUATE(wCount, rControlesTHB.Fecha);
        r23.SETFILTER(r23."Date Filter", '010121D..311222D');
        IF r23.FIND('-') THEN BEGIN
            REPEAT
                Ventana.UPDATE;
                r23.CALCFIELDS(r23."Net Change (LCY)");
                IF r23."Net Change (LCY)" <> 0 THEN BEGIN
                    rControlesTHB.SETRANGE(rControlesTHB.Hotel, 'PRoVACTIVoS');
                    rControlesTHB.SETRANGE(rControlesTHB.Recuento, r23."No.");
                    IF NoT rControlesTHB.FINDFIRST THEN BEGIN
                        wCount := wCount + 1;
                        rControlesTHB.INIT;
                        rControlesTHB.Hotel := 'PRoVACTIVoS';
                        rControlesTHB.Fecha := FoRMAT(wCount);
                        rControlesTHB.Recuento := r23."No.";
                        rControlesTHB.INSERT;
                    END;
                END;
            UNTIL r23.NEXT = 0
        END;
    end;

    
    procedure fRevisaNacionalidad()
    var
        rocupDes: Record 7000474;
        Ventana: Dialog;
        rocup: Record 7000178;
        rResDia: Record 7000186;
        wLineaTot: Text;
        rRes: Record 7000176;
    begin
        wLineaTot := 'Totales periodo';
        Ventana.oPEN('REVISANDo RESERVA #1#########', rResDia.Reserva);
        rocup.RESET;
        rocup.SETFILTER(rocup."Fecha entrada", '..%1', 31121930D);
        rocup.SETFILTER(rocup."Fecha salida", '%1..', 010121D);
        //rocup.SETFILTER(rocup."Pais residencia",'<>%1','');
        //rocup.SETRANGE(rocup.Posicion,1);
        rocup.SETFILTER(rocup."Pais residencia", '<>%1', '');
        rocup.SETRANGE(rocup."Check In", TRUE);
        IF rocup.FIND('-') THEN BEGIN
            REPEAT
                //rResDia.RESET;
                //rResDia.SETRANGE(rResDia.Fecha,wFecIni,wFecFin);
                rResDia.SETRANGE(rResDia.Hotel, rocup.Hotel);
                rResDia.SETRANGE(rResDia.Ano, rocup.Ano);
                rResDia.SETRANGE(rResDia.Reserva, rocup.Reserva);
                rResDia.SETRANGE(rResDia.Desglose, rocup.Desglose);
                //rResDia.SETRANGE(rResDia.Pais,'');
                IF rResDia.FIND('-') THEN BEGIN
                    REPEAT
                        rResDia.Pais := rocup."Pais residencia";
                        rResDia.MoDIFY;
                        Ventana.UPDATE;
                    UNTIL rResDia.NEXT = 0;
                END;
                IF rocup.Posicion = 1 THEN BEGIN
                    rRes.SETRANGE(rRes.Hotel, rocup.Hotel);
                    rRes.SETRANGE(rRes.Ano, rocup.Ano);
                    rRes.SETRANGE(rRes.Reserva, rocup.Reserva);
                    rRes.SETRANGE(rRes.Desglose, rocup.Desglose);
                    IF rRes.FIND('-') THEN BEGIN
                        rRes.Nacionalidad := rocup.Nacionalidad;
                        rRes.MoDIFY;
                    END;
                END;
                rocupDes.SETRANGE(rocupDes.Hotel, rocup.Hotel);
                rocupDes.SETRANGE(rocupDes.Reserva, rocup.Reserva);
                rocupDes.SETRANGE(rocupDes.Ano, rocup.Ano);
                IF rocupDes.FIND('-') THEN BEGIN
                    REPEAT
                        rocupDes.Nacionalidad := rocup.Nacionalidad;
                        rocupDes.MoDIFY;
                    UNTIL rocupDes.NEXT = 0
                END;
            UNTIL rocup.NEXT = 0;
        END;
        Ventana.CLoSE;
    end;

    local procedure fConciliarNo()
    var
        rMovConta: Record "17;
    begin
        rMovConta.SETRANGE(rMovConta."G/L Account No.", '4312051');
        rMovConta.SETRANGE(rMovConta.Pendiente, FALSE);
        rMovConta.SETFILTER(rMovConta."Posting Date", '..%1', 310320D);
        IF rMovConta.FINDSET THEN
            REPEAT
                rMovConta.Pendiente := TRUE;
                rMovConta.MoDIFY;
            UNTIL rMovConta.NEXT = 0;
    end;

    local procedure fRestaurarPRoV()
    var
        r17: Record "17;
        r17new: Record "50004;
        r120: Record "120;
        r120new: Record "50006;
        r121: Record "121;
        r121new: Record "50007;
        r122: Record "122;
        r122new: Record "50008;
        r123: Record "123;
        r123new: Record "50009;
        r124: Record "124;
        r124new: Record "50010;
        r125: Record "125;
        r125new: Record "50011;
        r254: Record "254;
        r254new: Record "50013;
        r25: Record "25;
        r25new: Record "50005;
        r380: Record "380;
        r380new: Record "50018;
        r7000002: Record 7000002;
        r7000002new: Record "50016;
        r288: Record "288;
        r288new: Record "50017;
        r7000003: Record 7000003;
        r7000003new: Record "50019;
        r7000004: Record 7000004;
        r7000004new: Record "50020;
        r7012: Record 7012;
        r7012new: Record "50014;
        r7014: Record 7014;
        r7014new: Record "50015;
    begin

        r17new.RESET;
        IF r17new.FINDSET THEN
            REPEAT
                r17.SETRANGE(r17."Entry No.", r17new.TToo);
                IF r17.FINDFIRST THEN r17.DELETE;
                r17.TRANSFERFIELDS(r17new);
                IF r17.INSERT THEN;
            UNTIL r17new.NEXT = 0;

        r25new.RESET;
        IF r25new.FINDSET THEN
            REPEAT
                r25.SETRANGE(r25."Entry No.", r25new.Codigo);
                IF r25.FINDFIRST THEN r25.DELETE;
                r25.TRANSFERFIELDS(r25new);
                IF r25.INSERT THEN;
            UNTIL r25new.NEXT = 0;

        r380new.RESET;
        IF r380new.FINDSET THEN
            REPEAT
                r380.SETRANGE(r380."Entry No.", r380new."Entry No.");
                IF r380.FINDFIRST THEN r380.DELETE;
                r380.TRANSFERFIELDS(r380new);
                IF r380.INSERT THEN;
            UNTIL r380new.NEXT = 0;

        r288new.RESET;
        IF r288new.FINDSET THEN
            REPEAT
                r288.SETRANGE(r288."Vendor No.", r288new."Vendor No.");
                r288.SETRANGE(r288.Code, r288new.Code);
                IF r288.FINDFIRST THEN r288.DELETE;
                r288.TRANSFERFIELDS(r288new);
                IF r288.INSERT THEN;
            UNTIL r288new.NEXT = 0;

        r120new.RESET;
        IF r120new.FINDSET THEN
            REPEAT
                r120.SETRANGE(r120."No.", r120new."Nº Fichero");
                IF r120.FINDFIRST THEN r120.DELETE;
                r120.TRANSFERFIELDS(r120new);
                IF r120.INSERT THEN;
            UNTIL r120new.NEXT = 0;

        r121new.RESET;
        IF r121new.FINDSET THEN
            REPEAT
                r121.SETRANGE(r121."Document No.", r121new."Document No.");
                r121.SETRANGE(r121."Line No.", r121new."Line No.");
                IF r121.FINDFIRST THEN r121.DELETE;
                IF r121.INSERT THEN;
            UNTIL r121new.NEXT = 0;

        r122new.RESET;
        IF r122new.FINDSET THEN
            REPEAT
                r122.SETRANGE(r122."No.", r122new."No.");
                IF r122.FINDFIRST THEN r122.DELETE;
                r122.TRANSFERFIELDS(r122new);
                IF r122.INSERT THEN;
            UNTIL r122new.NEXT = 0;

        r123new.RESET;
        IF r123new.FINDSET THEN
            REPEAT
                r123.SETRANGE(r123."Document No.", r123new."Document No.");
                r123.SETRANGE(r123."Line No.", r123new."Line No.");
                IF r123.FINDFIRST THEN r123.DELETE;
                CoMMIT;
                r123.TRANSFERFIELDS(r123new);
                r123.INSERT;
            UNTIL r123new.NEXT = 0;

        r124new.RESET;
        IF r124new.FINDSET THEN
            REPEAT
                r124.SETRANGE(r124."No.", r124new."No.");
                IF r124.FINDFIRST THEN r124.DELETE;
                r124.TRANSFERFIELDS(r124new);
                IF r124.INSERT THEN;
            UNTIL r124new.NEXT = 0;

        r125new.RESET;
        IF r125new.FINDSET THEN
            REPEAT
                r125.SETRANGE(r125."Document No.", r125new."Document No.");
                r125.SETRANGE(r125."Line No.", r125new."Line No.");
                IF r125.FINDFIRST THEN r125.DELETE;
                r125.TRANSFERFIELDS(r125new);
                IF r125.INSERT THEN;
            UNTIL r125new.NEXT = 0;

        r254new.RESET;
        IF r254new.FINDSET THEN
            REPEAT
                r254.SETRANGE(r254."Entry No.", r254new."Entry No.");
                IF r254.FINDFIRST THEN r254.DELETE;
                r254.TRANSFERFIELDS(r254new);
                IF r254.INSERT THEN;
            UNTIL r254new.NEXT = 0;

        /*
            r7012new.RESET;
            IF r7012new.FINDSET THEN
            REPEAT
               r7012.TRANSFERFIELDS(r7012new);
               IF r7012.INSERT THEN;
            UNTIL r7012new.NEXT = 0;
        
            r7014new.RESET;
            IF r7014new.FINDSET THEN
            REPEAT
               r7014.TRANSFERFIELDS(r7014new);
               IF r7014new.INSERT THEN;
            UNTIL r7014new.NEXT = 0;
        */

        r7000002new.RESET;
        IF r7000002new.FINDSET THEN
            REPEAT
                r7000002.SETRANGE(r7000002."Entry No.", r7000002new."Entry No.");
                IF r7000002.FINDFIRST THEN r7000002.DELETE;
                r7000002.TRANSFERFIELDS(r7000002new);
                IF r7000002.INSERT THEN;
            UNTIL r7000002new.NEXT = 0;

        r7000003new.RESET;
        IF r7000003new.FINDSET THEN
            REPEAT
                r7000003.SETRANGE(r7000003."Entry No.", r7000003new."Entry No.");
                IF r7000003.FINDFIRST THEN r7000003.DELETE;
                r7000003.TRANSFERFIELDS(r7000003new);
                IF r7000003.INSERT THEN;
            UNTIL r7000003new.NEXT = 0;

        r7000004new.RESET;
        IF r7000004new.FINDSET THEN
            REPEAT
                r7000004.SETRANGE(r7000004."Entry No.", r7000004new."Entry No.");
                IF r7000004.FINDFIRST THEN r7000004.DELETE;
                r7000004.TRANSFERFIELDS(r7000004new);
                IF r7000004.INSERT THEN;
            UNTIL r7000004new.NEXT = 0;


    end;

    local procedure fProvERRoR()
    var
        rControlesTHB2: Record "50001;
        rControlesTHB: Record "50001;
        r17: Record "17;
        r17new: Record "50004;
        r120: Record "120;
        r120new: Record "50006;
        r121: Record "121;
        r121new: Record "50007;
        r122: Record "122;
        r122new: Record "50008;
        r123: Record "123;
        r123new: Record "50009;
        r124: Record "124;
        r124new: Record "50010;
        r125: Record "125;
        r125new: Record "50011;
        r254: Record "254;
        r254new: Record "50013;
        r25: Record "25;
        r25new: Record "50005;
        r380: Record "380;
        r380new: Record "50018;
        r7000002: Record 7000002;
        r7000002new: Record "50016;
        r288: Record "288;
        r288new: Record "50017;
        r7000003: Record 7000003;
        r7000003new: Record "50019;
        r7000004: Record 7000004;
        r7000004new: Record "50020;
        r7012: Record 7012;
        r7012new: Record "50014;
        r7014: Record 7014;
        r7014new: Record "50015;
        wCount: Integer;
        w120: Integer;
        w121: Integer;
        w122: Integer;
        w123: Integer;
        w124: Integer;
        w125: Integer;
        w254: Integer;
        w25: Integer;
        w380: Integer;
        w7000002: Integer;
        w288: Integer;
    begin
        rUsr.GET(USERID);
        /*
        r17new.DELETEALL;
        r25new.DELETEALL;
        r380new.DELETEALL;
        r120new.DELETEALL;
        r121new.DELETEALL;
        r122new.DELETEALL;
        r123new.DELETEALL;
        r124new.DELETEALL;
        r125new.DELETEALL;
        r254new.DELETEALL;
        r7000002new.DELETEALL;
        r7000003new.DELETEALL;
        r7000004new.DELETEALL;
        r7012new.DELETEALL;
        r7014new.DELETEALL;
        r380new.DELETEALL;
        r288new.DELETEALL;
        */
        IF CoNFIRM('oJo!! Vas a cambiar los codigos de proveedor segun los errores previstos en ControlesTHB, ¿seguro? LA PUEDES LIAR PARDA!!!') THEN BEGIN
            //rControlesTHB.SETRANGE(rControlesTHB.Control,'38');
            //rControlesTHB.SETFILTER(rControlesTHB.Control,'%1|%2','40','39');
            //rControlesTHB.SETRANGE(rControlesTHB."Valor de campo",'FLR');
            rControlesTHB.SETRANGE(rControlesTHB.Hotel, 'CoNTEoMoVS');
            rControlesTHB.SETRANGE(rControlesTHB.Recuento, rUsr."Hotel de trabajo");
            //rControlesTHB.SETRANGE(rControlesTHB.Code,'A000306');
            IF rControlesTHB.FIND('-') THEN BEGIN
                REPEAT
                    r17.RESET;
                    IF rControlesTHB.Code3 <> '' THEN
                        r17.SETRANGE(r17."Source No.", rControlesTHB."Unidad Medida 2, rControlesTHB.Code3)
                    ELSE
                        r17.SETRANGE(r17."Source No.", rControlesTHB."Unidad Medida 2);
                    IF r17.FINDSET THEN
                        REPEAT
                            r17new.TRANSFERFIELDS(r17);
                            IF r17new.INSERT THEN;
                            CoMMIT;
                            r17."Source No." := rControlesTHB."Unidad 1;
                            r17.MoDIFY;
                        UNTIL r17.NEXT = 0;

                    r25.RESET;
                    IF rControlesTHB.Code3 <> '' THEN
                        r25.SETRANGE(r25."Vendor No.", rControlesTHB."Unidad Medida 2, rControlesTHB.Code3)
                    ELSE
                        r25.SETRANGE(r25."Vendor No.", rControlesTHB."Unidad Medida 2);
                    IF r25.FINDSET THEN
                        REPEAT
                            r25new.TRANSFERFIELDS(r25);
                            IF r25new.INSERT THEN;
                            CoMMIT;
                            r25."Vendor No." := rControlesTHB."Unidad 1;
                            r25."Buy-from Vendor No." := rControlesTHB."Unidad 1;
                            r25.MoDIFY;
                        UNTIL r25.NEXT = 0;

                    r380.RESET;
                    IF rControlesTHB.Code3 <> '' THEN
                        r380.SETRANGE(r380."Vendor No.", rControlesTHB."Unidad Medida 2, rControlesTHB.Code3)
                    ELSE
                        r380.SETRANGE(r380."Vendor No.", rControlesTHB."Unidad Medida 2);
                    IF r380.FINDSET THEN
                        REPEAT
                            r380new.TRANSFERFIELDS(r380);
                            IF r380new.INSERT THEN;
                            CoMMIT;
                            r380."Vendor No." := rControlesTHB."Unidad 1;
                            r380.MoDIFY;
                        UNTIL r380.NEXT = 0;

                    r288.RESET;
                    IF rControlesTHB.Code3 <> '' THEN
                        r288.SETRANGE(r288."Vendor No.", rControlesTHB."Unidad Medida 2, rControlesTHB.Code3)
                    ELSE
                        r288.SETRANGE(r288."Vendor No.", rControlesTHB."Unidad Medida 2);
                    IF r288.FINDSET THEN
                        REPEAT
                            r288new.TRANSFERFIELDS(r288);
                            IF r288new.INSERT THEN;
                            CoMMIT;
                            //    r288.RENAME(rControlesTHB.Code,r288.Code);
                        UNTIL r288.NEXT = 0;

                    r120.RESET;
                    IF rControlesTHB.Code3 <> '' THEN
                        r120.SETRANGE(r120."Buy-from Vendor No.", rControlesTHB."Unidad Medida 2, rControlesTHB.Code3)
                    ELSE
                        r120.SETRANGE(r120."Buy-from Vendor No.", rControlesTHB."Unidad Medida 2);
                    IF r120.FINDSET THEN
                        REPEAT
                            r120new.TRANSFERFIELDS(r120);
                            IF r120new.INSERT THEN;
                            CoMMIT;
                            r120."Buy-from Vendor No." := rControlesTHB."Unidad 1;
                            r120."Pay-to Vendor No." := rControlesTHB."Unidad 1;
                            r120.MoDIFY;
                        UNTIL r120.NEXT = 0;

                    r121.RESET;
                    IF rControlesTHB.Code3 <> '' THEN
                        r121.SETRANGE(r121."Buy-from Vendor No.", rControlesTHB."Unidad Medida 2, rControlesTHB.Code3)
                    ELSE
                        r121.SETRANGE(r121."Buy-from Vendor No.", rControlesTHB."Unidad Medida 2);
                    IF r121.FINDSET THEN
                        REPEAT
                            r121new.TRANSFERFIELDS(r121);
                            IF r121new.INSERT THEN;
                            CoMMIT;
                            r121."Buy-from Vendor No." := rControlesTHB."Unidad 1;
                            r121."Pay-to Vendor No." := rControlesTHB."Unidad 1;
                            r121.MoDIFY;
                        UNTIL r121.NEXT = 0;

                    r122.RESET;
                    IF rControlesTHB.Code3 <> '' THEN
                        r122.SETRANGE(r122."Buy-from Vendor No.", rControlesTHB."Unidad Medida 2, rControlesTHB.Code3)
                    ELSE
                        r122.SETRANGE(r122."Buy-from Vendor No.", rControlesTHB."Unidad Medida 2);
                    IF r122.FINDSET THEN
                        REPEAT
                            r122new.TRANSFERFIELDS(r122);
                            IF r122new.INSERT THEN;
                            CoMMIT;
                            r122."Buy-from Vendor No." := rControlesTHB."Unidad 1;
                            r122."Pay-to Vendor No." := rControlesTHB."Unidad 1;
                            r122.MoDIFY;
                        UNTIL r122.NEXT = 0;

                    r123.RESET;
                    IF rControlesTHB.Code3 <> '' THEN
                        r123.SETRANGE(r123."Buy-from Vendor No.", rControlesTHB."Unidad Medida 2, rControlesTHB.Code3)
                    ELSE
                        r123.SETRANGE(r123."Buy-from Vendor No.", rControlesTHB."Unidad Medida 2);
                    IF r123.FINDSET THEN
                        REPEAT
                            r123new.TRANSFERFIELDS(r123);
                            IF r123new.INSERT THEN;
                            CoMMIT;
                            r123."Buy-from Vendor No." := rControlesTHB."Unidad 1;
                            r123."Pay-to Vendor No." := rControlesTHB."Unidad 1;
                            r123.MoDIFY;
                        UNTIL r123.NEXT = 0;

                    r124.RESET;
                    IF rControlesTHB.Code3 <> '' THEN
                        r124.SETRANGE(r124."Buy-from Vendor No.", rControlesTHB."Unidad Medida 2, rControlesTHB.Code3)
                    ELSE
                        r124.SETRANGE(r124."Buy-from Vendor No.", rControlesTHB."Unidad Medida 2);
                    IF r124.FINDSET THEN
                        REPEAT
                            r124new.TRANSFERFIELDS(r124);
                            IF r124new.INSERT THEN;
                            CoMMIT;
                            r124."Buy-from Vendor No." := rControlesTHB."Unidad 1;
                            r124."Pay-to Vendor No." := rControlesTHB."Unidad 1;
                            r124.MoDIFY;
                        UNTIL r124.NEXT = 0;

                    r125.RESET;
                    IF rControlesTHB.Code3 <> '' THEN
                        r125.SETRANGE(r125."Buy-from Vendor No.", rControlesTHB."Unidad Medida 2, rControlesTHB.Code3)
                    ELSE
                        r125.SETRANGE(r125."Buy-from Vendor No.", rControlesTHB."Unidad Medida 2);
                    IF r125.FINDSET THEN
                        REPEAT
                            r125new.TRANSFERFIELDS(r125);
                            IF r125new.INSERT THEN;
                            CoMMIT;
                            r125."Buy-from Vendor No." := rControlesTHB."Unidad 1;
                            r125."Pay-to Vendor No." := rControlesTHB."Unidad 1;
                            r125.MoDIFY;
                        UNTIL r125.NEXT = 0;

                    r254.RESET;
                    IF rControlesTHB.Code3 <> '' THEN
                        r254.SETRANGE(r254."Bill-to/Pay-to No.", rControlesTHB."Unidad Medida 2, rControlesTHB.Code3)
                    ELSE
                        r254.SETRANGE(r254."Bill-to/Pay-to No.", rControlesTHB."Unidad Medida 2);
                    IF r254.FINDSET THEN
                        REPEAT
                            r254new.TRANSFERFIELDS(r254);
                            IF r254new.INSERT THEN;
                            CoMMIT;
                            r254."Bill-to/Pay-to No." := rControlesTHB."Unidad 1;
                            r254.MoDIFY;
                        UNTIL r254.NEXT = 0;

                    r7012.RESET;
                    IF rControlesTHB.Code3 <> '' THEN
                        r7012.SETRANGE(r7012."Vendor No.", rControlesTHB."Unidad Medida 2, rControlesTHB.Code3)
                    ELSE
                        r7012.SETRANGE(r7012."Vendor No.", rControlesTHB."Unidad Medida 2);
                    IF r7012.FINDSET THEN
                        REPEAT
                            r7012new.TRANSFERFIELDS(r7012);
                            IF r7012new.INSERT THEN;
                            CoMMIT;
                            //     r7012.RENAME(r7012."Item No.",rControlesTHB.Code,r7012."Starting Date",r7012."Currency Code",r7012."Variant Code",r7012."Cod. Zona",r7012."Unit of Measure Code",r7012."Minimum Quantity");
                        UNTIL r7012.NEXT = 0;

                    r7014.RESET;
                    IF rControlesTHB.Code3 <> '' THEN
                        r7014.SETRANGE(r7014."Vendor No.", rControlesTHB."Unidad Medida 2, rControlesTHB.Code3)
                    ELSE
                        r7014.SETRANGE(r7014."Vendor No.", rControlesTHB."Unidad Medida 2);
                    IF r7014.FINDSET THEN
                        REPEAT
                            r7014new.TRANSFERFIELDS(r7014);
                            IF r7014new.INSERT THEN;
                            CoMMIT;
                            //     r7014.RENAME(r7014."Item No.",rControlesTHB.Code,r7014."Starting Date",r7014."Currency Code",r7014."Variant Code",r7014."Cod. Zona",r7014."Unit of Measure Code",r7014."Minimum Quantity");
                        UNTIL r7014.NEXT = 0;

                    r7000002.RESET;
                    IF rControlesTHB.Code3 <> '' THEN
                        r7000002.SETRANGE(r7000002."Account No.", rControlesTHB."Unidad Medida 2, rControlesTHB.Code3)
                    ELSE
                        r7000002.SETRANGE(r7000002."Account No.", rControlesTHB."Unidad Medida 2);
                    IF r7000002.FINDSET THEN
                        REPEAT
                            r7000002new.TRANSFERFIELDS(r7000002);
                            IF r7000002new.INSERT THEN;
                            CoMMIT;
                        UNTIL r7000002.NEXT = 0;

                    r7000003.RESET;
                    IF rControlesTHB.Code3 <> '' THEN
                        r7000003.SETRANGE(r7000003."Cust./Vendor Bank Acc. Code", rControlesTHB."Unidad Medida 2, rControlesTHB.Code3)
                    ELSE
                        r7000003.SETRANGE(r7000003."Cust./Vendor Bank Acc. Code", rControlesTHB."Unidad Medida 2);
                    IF r7000003.FINDSET THEN
                        REPEAT
                            r7000003new.TRANSFERFIELDS(r7000003);
                            IF r7000003new.INSERT THEN;
                            CoMMIT;
                        UNTIL r7000003.NEXT = 0;

                    r7000004.RESET;
                    IF rControlesTHB.Code3 <> '' THEN
                        r7000004.SETRANGE(r7000004."Cust./Vendor Bank Acc. Code", rControlesTHB."Unidad Medida 2, rControlesTHB.Code3)
                    ELSE
                        r7000004.SETRANGE(r7000004."Cust./Vendor Bank Acc. Code", rControlesTHB."Unidad Medida 2);
                    IF r7000004.FINDSET THEN
                        REPEAT
                            r7000004new.TRANSFERFIELDS(r7000004);
                            IF r7000004new.INSERT THEN;
                            CoMMIT;
                        UNTIL r7000004.NEXT = 0;
                UNTIL rControlesTHB.NEXT = 0
            END;
        END;

    end;

    local procedure fConteoMovProv()
    var
        rControlesTHB: Record "50001;
        r25: Record "25;
        rControlesTHB2: Record "50001;
        rCompany: Record "2000000006;
        wCount1: Integer;
        wCount2: Integer;
        wCount3: Integer;
        wControl: Integer;
    begin
        Ventana.oPEN('Revisando #1############################# - Proveedor #2###### #3###### #4###### - Movimientos #5###### #6###### #7######', rCompany.Name, rControlesTHB."Unidad 1, rControlesTHB."Unidad Medida 2, rControlesTHB.Code3, wCount1, wCount2,
        Wrong E);
        IF rCompany.FIND('-') THEN BEGIN
            REPEAT
                r25.CHANGECoMPANY(rCompany.Name);
                rUsr.CHANGECoMPANY(rCompany.Name);
                rUsr.GET(USERID);
                rControlesTHB.SETRANGE(rControlesTHB.Hotel, 'PRoVREPCoMP');
                IF rControlesTHB.FIND('-') THEN BEGIN
                    REPEAT
                        wCount1 := 0;
                        wCount2 := 0;
                        wCount3 := 0;
                        r25.SETRANGE(r25."Vendor No.", rControlesTHB."Unidad 1);
                        IF r25.FIND('-') THEN BEGIN
                            REPEAT
                                wCount1 := wCount1 + 1;
                                Ventana.UPDATE;
                            UNTIL r25.NEXT = 0
                        END;
                        r25.RESET;
                        r25.SETRANGE(r25."Vendor No.", rControlesTHB."Unidad Medida 2);
                        IF r25.FIND('-') THEN BEGIN
                            REPEAT
                                wCount2 := wCount2 + 1;
                                Ventana.UPDATE;
                            UNTIL r25.NEXT = 0
                        END;
                        IF (rControlesTHB2.Code3 <> '') THEN BEGIN
                            r25.RESET;
                            r25.SETRANGE(r25."Vendor No.", rControlesTHB.Code3);
                            IF r25.FIND('-') THEN BEGIN
                                REPEAT
                                    wCount3 := wCount3 + 1;
                                    Ventana.UPDATE;
                                UNTIL r25.NEXT = 0
                            END;
                        END;
                        IF (wCount2 <> 0) oR (wCount3 <> 0) THEN BEGIN
                            wControl := wControl + 1;
                            rControlesTHB2.INIT;
                            rControlesTHB2."Unidad 2 := rCompany.Name;
                            rControlesTHB2.Hotel := 'CoNTEoMoVS';
                            rControlesTHB2.Recuento := rUsr."Hotel de trabajo";
                            rControlesTHB2."Unidad 1 := rControlesTHB."Unidad 1;
                            rControlesTHB2.Almacen := wCount1;
                            rControlesTHB2."Unidad Medida 2 := rControlesTHB."Unidad Medida 2;
                            rControlesTHB2."Unidad Medida 1 := wCount2;
                            rControlesTHB2."Unidad 2 := rCompany.Name;
                            rControlesTHB2.Fecha := FoRMAT(wControl);
                            rControlesTHB2.Code3 := rControlesTHB.Code3;
                            rControlesTHB2.Integer3 := wCount3;
                            rControlesTHB2.INSERT
                        END;
                    UNTIL rControlesTHB.NEXT = 0;
                END;
            UNTIL rCompany.NEXT = 0
        END;
    end;

    local procedure fLimpiaSegCredCli()
    var
        rCustomer: Record "18;
    begin
        rCustomer.SETFILTER(rCustomer."Seguro credito", '<>%1', '');
        IF rCustomer.FIND('-') THEN BEGIN
            REPEAT
                rCustomer."Seguro credito" := '';
                rCustomer.MoDIFY;
            UNTIL rCustomer.NEXT = 0
        END;
    end;

    
    procedure fRevisaRepFac(wHotel: Code[10]; wFactura: Code[15]; wSecGra: Integer)
    var
        rHoteles: Record 7000110;
        rLinFac: Record 7000198;
        rLinFacNew: Record 7000198;
        Ventana: Dialog;
    begin
        //MESSAGE('%1   %2',wHotel,wFactura);
        rHoteles.SETRANGE(rHoteles.Hotel, wHotel);
        IF rHoteles.FINDFIRST THEN BEGIN
            rLinFac.CHANGECoMPANY(rHoteles."Empresa Fiscal");
            rLinFac.SETRANGE(rLinFac.Factura, wFactura);
            IF rLinFac.FIND('-') THEN BEGIN
                REPEAT
                    wSecGra := wSecGra + 1;
                    rLinFacNew := rLinFac;
                    rLinFacNew."Secuencia grabacion" := wSecGra;
                    //  MESSAGE('%1',rLinFac."Total importe");
                    IF rLinFacNew.INSERT THEN;
                UNTIL rLinFac.NEXT = 0;
            END;
        END;
    end;

    local procedure fCodPostal()
    var
        rCustomer: Record "18;
        rVendor: Record "23;
    begin
        IF rCustomer.FIND('-') THEN BEGIN
            REPEAT
                IF STRLEN(rCustomer."Post Code") = 4 THEN rCustomer."Post Code" := '0' + FoRMAT(rCustomer."Post Code");
                rCustomer.MoDIFY;
            UNTIL rCustomer.NEXT = 0;
        END;

        IF rVendor.FIND('-') THEN BEGIN
            REPEAT
                IF STRLEN(rVendor."Post Code") = 4 THEN rVendor."Post Code" := '0' + FoRMAT(rVendor."Post Code");
                rVendor.MoDIFY;
            UNTIL rVendor.NEXT = 0
        END;
    end;

    
    procedure fActualizaPendInd()
    var
        wCountCobCab: Integer;
        wCountCobDet: Integer;
        wCountCabFac: Integer;
        wCountLinFac: Integer;
        wCountLinFacImp: Integer;
        rCompany: Record "2000000006;
        rCabFac: Record 7000196;
        rLinFacImp: Record 7000200;
        rLinFac: Record 7000198;
        rCobCab: Record 7000680;
        rCobDet: Record 7000681;
        rControlesTHB: Record "50001;
        rCabFacGes: Record 7000196;
        rLinFacImpGes: Record 7000200;
        rLinFacGes: Record 7000198;
        rCobCabGes: Record 7000680;
        rCobDetGes: Record 7000681;
        wSecGra: Integer;
    begin
        EXIT;
        /*
        Ventana.oPEN('Actualizando registros de #1######################################### \'+
                     ' \'+
                     'Cabeceras de factura actualizadas #2######## \'+
                     'Lineas de factura actualizadas #3######### \'+
                     'Lineas de factura impresion actualizadas #4######### \'+
                     'Cobros cabecera actualizados #5######### \'+
                     'Cobros detalle actualizados #6#########',rCompany.Name,wCountCabFac,wCountLinFac,wCountLinFacImp,wCountCobCab,wCountCobDet);
        
        */
        //DEFINIMoS LA SoCIEDAD DE DESTINo EN ToDAS LAS TABLAS EN LAS QUE VAMoS A ESCRIBIR

        rCabFacGes.CHANGECoMPANY('THB Gestion');
        rLinFacGes.CHANGECoMPANY('THB Gestion');
        rLinFacImpGes.CHANGECoMPANY('THB Gestion');
        rCobCabGes.CHANGECoMPANY('THB Gestion');
        rCobDetGes.CHANGECoMPANY('THB Gestion');

        rLinFacGes.SETCURRENTKEY(rLinFacGes."Secuencia grabacion");
        IF rLinFacGes.FINDLAST THEN;
        wSecGra := rLinFacGes."Secuencia grabacion";

        /*
        rCompany.SETFILTER(rCompany.Name,'<>%1','THB Gestion');
        //rCompany.SETRANGE(rCompany.Name,'HoTEL SANT JoRDI, S.A.');
        IF rCompany.FIND('-') AND (rCompany.Name<>'THB Gestion') THEN BEGIN
          Ventana.UPDATE;
          REPEAT
        
        
        //CAMBIAMoS ToDAS LAS SoCIEDADES EN LAS TABLAS A CoNSULTAR
        
          rUsr.CHANGECoMPANY(rCompany.Name);
          rCabFac.CHANGECoMPANY(rCompany.Name);
          rLinFac.CHANGECoMPANY(rCompany.Name);
          rLinFacImp.CHANGECoMPANY(rCompany.Name);
          rCobCab.CHANGECoMPANY(rCompany.Name);
          rCobDet.CHANGECoMPANY(rCompany.Name);
        */
        //CoNSULTAMoS LoS SoURCECoUNTERS DE FACTURAS PARA SABER SI HAY ALGo QUE ACTUALIZAR o AnADIR

        rUsr.GET(USERID);
        rControlesTHB.SETRANGE(rControlesTHB.Hotel, 'REPCABFAC');
        rControlesTHB.SETRANGE(rControlesTHB.Fecha, rUsr."Hotel de trabajo");
        IF rControlesTHB.FINDFIRST THEN BEGIN
            rCabFac.SETCURRENTKEY(Sourcecounter);
            rCabFac.SETFILTER(rCabFac.Sourcecounter, '>%1', rControlesTHB.Almacen);

            //SI ENCoNTRAMoS REGISTRoS, AQUi EMPIEZA LA FIESTA

            IF rCabFac.FIND('-') THEN BEGIN
                REPEAT
                    rCabFacGes.SETRANGE(rCabFacGes.Hotel, rCabFac.Hotel);
                    rCabFacGes.SETRANGE(rCabFacGes.Factura, rCabFac.Factura);
                    IF rCabFacGes.FINDSET(TRUE, TRUE) THEN rCabFacGes.DELETE(FALSE);
                    rCabFacGes := rCabFac;
                    IF rCabFacGes.INSERT(FALSE) THEN wCountCabFac := wCountCabFac + 1;
                    //    Ventana.UPDATE;
                    rLinFac.SETRANGE(rLinFac.Factura, rCabFac.Factura);
                    IF rLinFac.FIND('-') THEN BEGIN
                        REPEAT
                            wSecGra := wSecGra + 1;
                            rLinFacGes.SETRANGE(rLinFacGes.Factura, rLinFac.Factura);
                            rLinFacGes.SETRANGE(rLinFacGes."Secuencia grabacion", rLinFac."Secuencia grabacion");
                            IF rLinFacGes.FINDFIRST THEN rLinFacGes.DELETE(FALSE);
                            rLinFacGes := rLinFac;
                            rLinFacGes."Secuencia grabacion" := wSecGra;
                            IF rLinFacGes.INSERT(FALSE) THEN wCountLinFac := wCountLinFac + 1;
                            //      Ventana.UPDATE;
                        UNTIL rLinFac.NEXT = 0
                    END;
                    rLinFacImp.SETRANGE(rLinFacImp.Factura, rCabFac.Factura);
                    IF rLinFacImp.FIND('-') THEN BEGIN
                        REPEAT
                            rLinFacImpGes.SETRANGE(rLinFacImpGes.Factura, rLinFacImp.Factura);
                            rLinFacImpGes.SETRANGE(rLinFacImpGes."Secuencia grabacion", rLinFacImp."Secuencia grabacion");
                            IF rLinFacImpGes.FINDFIRST THEN rLinFacImpGes.DELETE(FALSE);
                            rLinFacImpGes := rLinFacImp;
                            IF rLinFacImpGes.INSERT(FALSE) THEN wCountLinFacImp := wCountLinFacImp + 1;
                            //      Ventana.UPDATE;
                        UNTIL rLinFacImp.NEXT = 0
                    END;
                    rControlesTHB.Almacen := rCabFac.Sourcecounter;
                    rControlesTHB.MoDIFY(FALSE);
                    //    Ventana.UPDATE;
                UNTIL rCabFac.NEXT = 0;
            END;
        END ELSE BEGIN
            rControlesTHB.INIT;
            rControlesTHB.Hotel := 'REPCABFAC';
            rControlesTHB.Fecha := rUsr."Hotel de trabajo";
            rControlesTHB.Almacen := 0;
            rControlesTHB.INSERT
        END;

        rControlesTHB.RESET;
        rControlesTHB.SETRANGE(rControlesTHB.Hotel, 'REPCABCoB');
        rControlesTHB.SETRANGE(rControlesTHB.Fecha, rUsr."Hotel de trabajo");
        IF rControlesTHB.FINDFIRST THEN BEGIN
            rCobCab.SETCURRENTKEY(SourceCounter);
            rCobCab.SETFILTER(rCobCab.SourceCounter, '>%1', rControlesTHB.Almacen);

            //SI ENCoNTRAMoS REGISTRoS, AQUi EMPIEZA LA FIESTA

            IF rCobCab.FIND('-') THEN BEGIN
                REPEAT
                    rCobCabGes.SETRANGE(rCobCabGes.Hotel, rCobCab.Hotel);
                    rCobCabGes.SETRANGE(rCobCabGes."Num. Cobro", rCobCab."Num. Cobro");
                    IF rCobCabGes.FINDSET(TRUE, TRUE) THEN rCobCabGes.DELETE(FALSE);
                    rCobCabGes := rCobCab;
                    IF rCobCabGes.INSERT(FALSE) THEN wCountCobCab := wCountCobCab + 1;
                    //    Ventana.UPDATE;
                    rCobDet.SETRANGE(rCobDet.Hotel, rCobCab.Hotel);
                    rCobDet.SETRANGE(rCobDet."Num. Cobro", rCobCab."Num. Cobro");
                    IF rCobDet.FIND('-') THEN BEGIN
                        REPEAT
                            rCobDetGes.SETRANGE(rCobDetGes.Hotel, rCobDet.Hotel);
                            rCobDetGes.SETRANGE(rCobDetGes."Num. Cobro", rCobDet."Num. Cobro");
                            rCobDetGes.SETRANGE(rCobDetGes."Num. Linea", rCobDet."Num. Linea");
                            IF rCobDetGes.FINDFIRST THEN rCobDetGes.DELETE(FALSE);
                            rCobDetGes := rCobDet;
                            IF rCobDetGes.INSERT(FALSE) THEN wCountCobDet := wCountCobDet + 1;
                            //      Ventana.UPDATE;
                        UNTIL rCobDet.NEXT = 0
                    END;
                    rControlesTHB.Almacen := rCobCab.SourceCounter;
                    rControlesTHB.MoDIFY(FALSE)
              UNTIL rCobCab.NEXT = 0;
                //Ventana.UPDATE;
            END;
        END ELSE BEGIN
            rControlesTHB.INIT;
            rControlesTHB.Hotel := 'REPCABCoB';
            rControlesTHB.Fecha := rUsr."Hotel de trabajo";
            rControlesTHB.Almacen := 0;
            rControlesTHB.INSERT
        END;
        //  CoMMIT;
        /*
          UNTIL rCompany.NEXT=0
        END;
        Ventana.UPDATE;
        
        Ventana.CLoSE;
        
        
        MESSAGE('Cabeceras de factura actualizadas %1 \'+
                'Lineas de factura actualizadas %2 \'+
                'Lineas de factura impresion actualizadas %3 \'+
                'Cobros cabecera actualizados %4 \'+
                'Cobros detalle actualizados %5 ',wCountCabFac,wCountLinFac,wCountLinFacImp,wCountCobCab,wCountCobDet);
        */
        /*
        Ventana.oPEN('Actualizando registros de #1######################################### \'+
                     ' \'+
                     'Cabeceras de factura actualizadas #2######## \'+
                     'Lineas de factura actualizadas #3######### \'+
                     'Lineas de factura impresion actualizadas #4######### \'+
                     'Cobros cabecera actualizados #5######### \'+
                     'Cobros detalle actualizados #6#########',rCompany.Name,wCountCabFac,wCountLinFac,wCountLinFacImp,wCountCobCab,wCountCobDet);
        
        //DEFINIMoS LA SoCIEDAD DE DESTINo EN ToDAS LAS TABLAS EN LAS QUE VAMoS A ESCRIBIR
        
        rCabFacGes.CHANGECoMPANY('THB Gestion');
        rLinFacGes.CHANGECoMPANY('THB Gestion');
        rLinFacImpGes.CHANGECoMPANY('THB Gestion');
        rCobCabGes.CHANGECoMPANY('THB Gestion');
        rCobDetGes.CHANGECoMPANY('THB Gestion');
        
        
        rCompany.SETFILTER(rCompany.Name,'<>%1','THB Gestion');
        //rCompany.SETRANGE(rCompany.Name,'HoTEL SANT JoRDI, S.A.');
        IF rCompany.FIND('-') AND (rCompany.Name<>'THB Gestion') THEN BEGIN
          Ventana.UPDATE;
          REPEAT
        
        
        //CAMBIAMoS ToDAS LAS SoCIEDADES EN LAS TABLAS A CoNSULTAR
        
          rUsr.CHANGECoMPANY(rCompany.Name);
          rCabFac.CHANGECoMPANY(rCompany.Name);
          rLinFac.CHANGECoMPANY(rCompany.Name);
          rLinFacImp.CHANGECoMPANY(rCompany.Name);
          rCobCab.CHANGECoMPANY(rCompany.Name);
          rCobDet.CHANGECoMPANY(rCompany.Name);
        
        //CoNSULTAMoS LoS SoURCECoUNTERS DE FACTURAS PARA SABER SI HAY ALGo QUE ACTUALIZAR o AnADIR
        
          rUsr.GET(USERID);
          rControlesTHB.SETRANGE(rControlesTHB."ID Tabla",'REPCABFAC');
          rControlesTHB.SETRANGE(rControlesTHB.Control,rUsr."Hotel de trabajo");
          IF rControlesTHB.FINDFIRST THEN BEGIN
            rCabFac.SETCURRENTKEY(Sourcecounter);
            rCabFac.SETFILTER(rCabFac.Sourcecounter,'>%1',rControlesTHB.Integer);
            rCabFac.SETRANGE(rCabFac.Tipo,0);
        
        //SI ENCoNTRAMoS REGISTRoS, AQUi EMPIEZA LA FIESTA
        
            IF rCabFac.FIND('-') THEN BEGIN
              REPEAT
              rCabFacGes.SETRANGE(rCabFacGes.Hotel,rCabFac.Hotel);
              rCabFacGes.SETRANGE(rCabFacGes.Factura,rCabFac.Factura);
        
              IF rCabFacGes.FINDSET(TRUE,TRUE) THEN rCabFacGes.DELETE(FALSE);
              rCabFacGes:=rCabFac;
              IF rCabFacGes.INSERT(FALSE) THEN wCountCabFac:=wCountCabFac+1;
        //    Ventana.UPDATE;
              rLinFac.SETRANGE(rLinFac.Factura,rCabFac.Factura);
              IF rLinFac.FIND('-') THEN BEGIN
                REPEAT
                rLinFacGes.SETRANGE(rLinFacGes.Factura,rLinFac.Factura);
                rLinFacGes.SETRANGE(rLinFacGes."Secuencia grabacion",rLinFac."Secuencia grabacion");
                IF rLinFacGes.FINDFIRST THEN rLinFacGes.DELETE(FALSE);
                rLinFacGes:=rLinFac;
                IF rLinFacGes.INSERT(FALSE) THEN wCountLinFac:=wCountLinFac+1;
        //      Ventana.UPDATE;
                UNTIL rLinFac.NEXT=0
              END;
              rLinFacImp.SETRANGE(rLinFacImp.Factura,rCabFac.Factura);
              IF rLinFacImp.FIND('-') THEN BEGIN
                REPEAT
                rLinFacImpGes.SETRANGE(rLinFacImpGes.Factura,rLinFacImp.Factura);
                rLinFacImpGes.SETRANGE(rLinFacImpGes."Secuencia grabacion",rLinFacImp."Secuencia grabacion");
                IF rLinFacImpGes.FINDFIRST THEN rLinFacImpGes.DELETE(FALSE);
                rLinFacImpGes:=rLinFacImp;
                IF rLinFacImpGes.INSERT(FALSE) THEN wCountLinFacImp:=wCountLinFacImp+1;
        //      Ventana.UPDATE;
                UNTIL rLinFacImp.NEXT=0
              END;
              rControlesTHB.Integer:=rCabFac.Sourcecounter;
              rControlesTHB.MoDIFY(FALSE);
            //Ventana.UPDATE;
              UNTIL rCabFac.NEXT=0;
            END;
          END ELSE BEGIN
            rControlesTHB.INIT;
            rControlesTHB."ID Tabla":='REPCABFAC';
            rControlesTHB.Control:=rUsr."Hotel de trabajo";
            rControlesTHB.Integer:=0;
            rControlesTHB.INSERT
          END;
        
          rControlesTHB.RESET;
          rControlesTHB.SETRANGE(rControlesTHB."ID Tabla",'REPCABCoB');
          rControlesTHB.SETRANGE(rControlesTHB.Control,rUsr."Hotel de trabajo");
          IF rControlesTHB.FINDFIRST THEN BEGIN
            rCobCab.SETCURRENTKEY(SourceCounter);
            rCobCab.SETFILTER(rCobCab.SourceCounter,'>%1',rControlesTHB.Integer);
        
        //SI ENCoNTRAMoS REGISTRoS, AQUi EMPIEZA LA FIESTA
        
            IF rCobCab.FIND('-') THEN BEGIN
              REPEAT
              rCobCabGes.SETRANGE(rCobCabGes.Hotel,rCobCab.Hotel);
              rCobCabGes.SETRANGE(rCobCabGes."Num. Cobro",rCobCab."Num. Cobro");
              IF rCobCabGes.FINDSET(TRUE,TRUE) THEN rCobCabGes.DELETE(FALSE);
              rCobCabGes:=rCobCab;
              IF rCobCabGes.INSERT(FALSE) THEN wCountCobCab:=wCountCobCab+1;
        //    Ventana.UPDATE;
              rCobDet.SETRANGE(rCobDet.Hotel,rCobCab.Hotel);
              rCobDet.SETRANGE(rCobDet."Num. Cobro",rCobCab."Num. Cobro");
              IF rCobDet.FIND('-') THEN BEGIN
                REPEAT
                rCobDetGes.SETRANGE(rCobDetGes.Hotel,rCobDet.Hotel);
                rCobDetGes.SETRANGE(rCobDetGes."Num. Cobro",rCobDet."Num. Cobro");
                rCobDetGes.SETRANGE(rCobDetGes."Num. Linea",rCobDet."Num. Linea");
                IF rCobDetGes.FINDFIRST THEN rCobDetGes.DELETE(FALSE);
                rCobDetGes:=rCobDet;
                IF rCobDetGes.INSERT(FALSE) THEN wCountCobDet:=wCountCobDet+1;
        //      Ventana.UPDATE;
                UNTIL rCobDet.NEXT=0
              END;
            rControlesTHB.Integer:=rCobCab.SourceCounter;
            rControlesTHB.MoDIFY(FALSE)
            UNTIL rCobCab.NEXT=0;
        //  Ventana.UPDATE;
            END;
          END ELSE BEGIN
            rControlesTHB.INIT;
            rControlesTHB."ID Tabla":='REPCABCoB';
            rControlesTHB.Control:=rUsr."Hotel de trabajo";
            rControlesTHB.Integer:=0;
            rControlesTHB.INSERT
          END;
        
          CoMMIT;
          UNTIL rCompany.NEXT=0
        END;
        
        Ventana.UPDATE;
        Ventana.CLoSE;
        
        MESSAGE('Cabeceras de factura actualizadas %1 \'+
                'Lineas de factura actualizadas %2 \'+
                'Lineas de factura impresion actualizadas %3 \'+
                'Cobros cabecera actualizados %4 \'+
                'Cobros detalle actualizados %5 ',wCountCabFac,wCountLinFac,wCountLinFacImp,wCountCobCab,wCountCobDet);
        */

    end;

    local procedure fValorableYES()
    var
        r5802: Record "5802;
    begin

        r5802.SETRANGE(r5802."Document No.", 'INV01');
        IF r5802.FIND('-') THEN BEGIN
            REPEAT
                r5802."Valorable inventario" := TRUE;
                r5802.MoDIFY;
            UNTIL r5802.NEXT = 0
        END;
    end;

    local procedure fBorraDocCartera()
    var
        r7000002: Record 7000002;
    begin

        r7000002.SETRANGE(r7000002."Entry No.", 781995, 781996);
        IF r7000002.FIND('-') THEN BEGIN
            REPEAT
                //MESSAGE('me cargare %1',r7000002."Document No.");
                r7000002.DELETE;
            UNTIL r7000002.NEXT = 0
        END;
    end;

    local procedure fCheckPais()
    var
        r9: Record "9;
        r7000178: Record 7000178;
    begin

        r7000178.SETRANGE(r7000178."Fecha entrada", ToDAY);
        IF r7000178.FIND('-') THEN BEGIN
            REPEAT
                IF STRLEN(r7000178."Pais residencia") = 2 THEN BEGIN
                    r9.SETRANGE(r9."EU Country/Region Code", r7000178."Pais residencia");
                    IF r9.FINDFIRST THEN BEGIN
                        r7000178."Pais residencia" := r9.Code;
                        r7000178."Pais nacimiento" := r9.Code;
                        r7000178.Nacionalidad := r9.Code;
                        r7000178.MoDIFY;
                    END;
                END;
            UNTIL r7000178.NEXT = 0
        END;
        CoMMIT;
    end;

    local procedure fCompruebaBancos()
    var
        r23: Record "23;
        r288: Record "288;
        rControlesTHB: Record "50001;
    begin

        rUsr.GET(USERID);

        IF r23.FIND('-') THEN BEGIN
            REPEAT
                r288.SETRANGE(r288."Vendor No.", r23."No.");
                r288.SETRANGE(r288.Code, r23."Preferred Bank Account Code");
                IF NoT (r288.FINDFIRST) AND (r23."Preferred Bank Account Code" <> '') THEN BEGIN
                    rControlesTHB.INIT;
                    rControlesTHB.Hotel := 'FALTABANCo';
                    rControlesTHB.Fecha := r23."No.";
                    rControlesTHB.Recuento := r23."Telex No.";
                    rControlesTHB."Unidad 1 := r23."Preferred Bank Account Code";
                    rControlesTHB."Unidad 2 := r23.Name;
                    IF rControlesTHB.INSERT THEN;
                END;
            UNTIL r23.NEXT = 0
        END;
    end;

    local procedure fModificaAsientos()
    var
        r17: Record "17;
    begin
        /*
        r17.SETRANGE(r17."Entry No.",328529);
        IF r17.FINDFIRST THEN BEGIN
          r17."Source No.":='PP0226';
          r17.MoDIFY
        END;
        r17.SETRANGE(r17."Entry No.",328532);
        IF r17.FINDFIRST THEN BEGIN
          r17."Source No.":='AB040489';
          r17.MoDIFY
        END;
        */


    end;

    local procedure fCompruebaAsientos()
    var
        r17: Record "17;
        r17test: Record "17;
        rControlesTHB: Record "50001;
        wSaldo: Decimal;
        wCount: Integer;
        wTotal: Decimal;
        wNum: Integer;
    begin
        rUsr.GET(USERID);
        Ventana.oPEN('Comprobando movimiento #1######## / ERRoRES ENCoNTRADoS #2#### / ToTAL IMPoRTES #3#########', r17."Entry No.", wCount, wTotal);
        //r17.SETRANGE(r17."Posting Date",010121D,311221);
        IF r17.FIND('-') THEN BEGIN
            REPEAT
                Ventana.UPDATE;
                wSaldo := 0;
                r17test.SETRANGE(r17test."Transaction No.", r17."Transaction No.");
                IF r17test.FIND('-') THEN BEGIN
                    REPEAT
                        wSaldo := wSaldo + r17test.Amount
                    UNTIL r17test.NEXT = 0
                END;
                IF wSaldo <> 0 THEN BEGIN
                    wNum := wNum + 1;
                    rControlesTHB.INIT;
                    rControlesTHB.Hotel := 'ASIENToTEST';
                    rControlesTHB.Recuento := FoRMAT(wNum);
                    rControlesTHB.Producto := rUsr."Hotel de trabajo";
                    rControlesTHB.Almacen := r17."Transaction No.";
                    rControlesTHB.Decimal := wSaldo;
                    wCount := wCount + 1;
                    rControlesTHB.Fecha := FoRMAT(wCount);
                    rControlesTHB.INSERT;
                    wTotal := wSaldo + wTotal
                END;
            UNTIL r17.NEXT = 0
        END;
        MESSAGE('Han cascado %1 registros por un total de %2', wNum, wTotal);
    end;

    local procedure fMovClivsMovCliDet()
    var
        rMovCli: Record "21;
        rMovCliDet: Record "379;
        rControlesTHB: Record "50001;
        wCount: Integer;
    begin
        rUsr.GET(USERID);
        rControlesTHB.SETFILTER(rControlesTHB.Hotel, '=%1|%2|%3|%4', 'NoMoVCLIDET', 'NoMoVCLIER', 'NoMoVCLILI', 'NoMoVCLI');
        rControlesTHB.SETRANGE(rControlesTHB.Recuento, rUsr."Hotel de trabajo");
        IF rControlesTHB.FIND('-') THEN rControlesTHB.DELETEALL;
        //CoMPRoBAMoS QUE No HAYA MoVIMIENToS CLIENTE SIN SU DETALLADo INICIAL Y VICEVERSA.


        Ventana.oPEN('REVISANDo Movimiento Cliente #1####### Pendiente #2######', rMovCli."Entry No.", rMovCli.open);

        //PRIMERo ToDoS LoS MoVIMIENToS DEBEN TENER SU MoVIMIENTo INICIAL

        IF rMovCli.FIND('-') THEN BEGIN
            REPEAT
                Ventana.UPDATE;
                rMovCliDet.SETRANGE(rMovCliDet."Cust. Ledger Entry No.", rMovCli."Entry No.");
                rMovCliDet.SETRANGE(rMovCliDet."Entry Type", rMovCliDet."Entry Type"::"Initial Entry");
                IF NoT rMovCliDet.FINDFIRST THEN BEGIN
                    wCount := wCount + 1;
                    rControlesTHB.INIT;
                    rControlesTHB.Hotel := 'NoMoVCLIDET';
                    rControlesTHB.Fecha := FoRMAT(wCount);
                    rControlesTHB.Recuento := rUsr."Hotel de trabajo";
                    rControlesTHB.Producto := rMovCli."Customer No.";
                    rControlesTHB.Almacen := rMovCli."Entry No.";
                    //rControlesTHB.Integer2:=rMovCli."Entry No.";
                    rControlesTHB."Unidad 3 := rMovCli.open;
                    IF rControlesTHB.INSERT THEN;
                END;
            UNTIL rMovCli.NEXT = 0
        END;

        Ventana.CLoSE;

        //ToDoS LoS MoVIMIENToS No PENDIENTES DEBEN TENER UN MoVIMIENTo DE PAGo

        rMovCli.RESET;
        rMovCli.SETRANGE(rMovCli.open, FALSE);
        Ventana.oPEN('REVISANDo Movimiento Cliente #1####### Pendiente #2######', rMovCli."Entry No.", rMovCli.open);
        //rMovCli.SETRANGE(rMovCli."Entry No.",1398268);

        IF rMovCli.FIND('-') THEN BEGIN
            REPEAT

                Ventana.UPDATE;
                rMovCliDet.SETRANGE(rMovCliDet."Cust. Ledger Entry No.", rMovCli."Entry No.");
                rMovCliDet.SETRANGE(rMovCliDet."Entry Type", rMovCliDet."Entry Type"::Application);
                IF NoT rMovCliDet.FINDFIRST THEN BEGIN
                    wCount := wCount + 1;
                    rControlesTHB.INIT;
                    rControlesTHB.Hotel := 'NoMoVCLIDET';
                    rControlesTHB.Fecha := FoRMAT(wCount);
                    rControlesTHB.Recuento := rUsr."Hotel de trabajo";
                    rControlesTHB.Producto := rMovCli."Customer No.";
                    rControlesTHB.Almacen := rMovCli."Entry No.";
                    //rControlesTHB.Integer2:=rMovCli."Entry No.";
                    //  rControlesTHB.Boleana:=rMovCli.open;
                    IF rControlesTHB.INSERT THEN;
                END;
            UNTIL rMovCli.NEXT = 0
        END;

        Ventana.CLoSE;

        Ventana.oPEN('REVISANDo Movimiento Cliente #1####### Pendiente #2######', rMovCli."Entry No.", rMovCli.open);
        rMovCliDet.RESET;
        rMovCli.RESET;
        IF rMovCli.FIND('-') THEN BEGIN
            REPEAT
                Ventana.UPDATE;
                rMovCliDet.SETRANGE(rMovCliDet."Cust. Ledger Entry No.", rMovCli."Entry No.");
                IF rMovCliDet.FIND('-') THEN BEGIN
                    REPEAT
                        IF rMovCli."Customer No." <> rMovCliDet."Customer No." THEN BEGIN
                            wCount := wCount + 1;
                            rControlesTHB.INIT;
                            rControlesTHB.Hotel := 'NoMoVCLIER';
                            rControlesTHB.Fecha := FoRMAT(wCount);
                            rControlesTHB.Recuento := rUsr."Hotel de trabajo";
                            rControlesTHB.Producto := rMovCli."Customer No.";
                            rControlesTHB."Unidad 2 := rMovCliDet."Customer No.";
                            rControlesTHB.Almacen := rMovCli."Entry No."
                        END;
                    UNTIL rMovCliDet.NEXT = 0
                END;
            UNTIL rMovCli.NEXT = 0
        END;


        //ToDoS LoS MoVIMIENToS DETALLADoS DEBEN TENER SU MoVIMIENTo RELACIoNADo EN MoV. CLIENTE

        Ventana.oPEN('REVISANDo Movimiento Cliente Detallado #1####### que corresponde a #2####### ', rMovCliDet."Entry No.", rMovCliDet."Cust. Ledger Entry No.");
        rMovCli.RESET;
        rMovCliDet.RESET;
        IF rMovCliDet.FIND('-') THEN BEGIN
            REPEAT
                Ventana.UPDATE;
                rMovCli.SETRANGE(rMovCli."Entry No.", rMovCliDet."Cust. Ledger Entry No.");
                IF NoT rMovCli.FINDFIRST THEN BEGIN
                    wCount := wCount + 1;
                    rControlesTHB.INIT;
                    rControlesTHB.Hotel := 'NoMoVCLI';
                    rControlesTHB.Fecha := FoRMAT(wCount);
                    rControlesTHB.Recuento := rUsr."Hotel de trabajo";
                    rControlesTHB.Producto := rMovCli."Customer No.";
                    rControlesTHB.Almacen := rMovCliDet."Cust. Ledger Entry No.";
                    //rControlesTHB.Integer2:=rMovCli."Entry No.";
                    //  rControlesTHB.Boleana:=rMovCli.open;
                    rControlesTHB.INSERT;
                END;
            UNTIL rMovCliDet.NEXT = 0
        END;
        CoMMIT;

        //ToDoS LoS MoVIMIENToS QUE INDIQUEN RELACIoN CoN EL MoVIMIENTo LIQUIDADo, DEBEN TENER SU MoVIMIENTo oRIGINAL LIQUIDADo.

        Ventana.oPEN('REVISANDo Movimiento Cliente Detallado #1####### que corresponde a #2####### ', rMovCliDet."Entry No.", rMovCliDet."Cust. Ledger Entry No.");
        rMovCli.RESET;
        rMovCliDet.RESET;
        rMovCliDet.SETFILTER(rMovCliDet."Applied Cust. Ledger Entry No.", '<>%1', 0);
        IF rMovCliDet.FIND('-') THEN BEGIN
            REPEAT
                Ventana.UPDATE;
                rMovCli.SETRANGE(rMovCli."Entry No.", rMovCliDet."Applied Cust. Ledger Entry No.");
                IF NoT rMovCli.FINDFIRST THEN BEGIN
                    wCount := wCount + 1;
                    rControlesTHB.INIT;
                    rControlesTHB.Hotel := 'NoMoVCLILI';
                    rControlesTHB.Fecha := FoRMAT(wCount);
                    rControlesTHB.Recuento := rUsr."Hotel de trabajo";
                    rControlesTHB.Producto := rMovCliDet."Customer No.";
                    rControlesTHB.Almacen := rMovCliDet."Applied Cust. Ledger Entry No.";
                    //rControlesTHB.Integer2:=rMovCli."Entry No.";
                    //  rControlesTHB.Boleana:=rMovCli.open;
                    rControlesTHB.INSERT;
                END;
            UNTIL rMovCliDet.NEXT = 0
        END;
        CoMMIT;


        //FIN CoMPRoBACIoN MoVIMIENToS INICIALES FALTANTES
    end;

    local procedure fInicioConciliar()
    var
        rMovConta: Record "17;
        rLinConcil: Record 7012812;
        rCabConcil: Record 7012814;
        wCabConcil: Integer;
        wCount: Integer;
    begin

        rMovConta.SETRANGE(rMovConta.Pendiente, TRUE);
        rMovConta.SETFILTER(rMovConta.Description, '%1|%2', 'ASIENTo APERTURA 2015', 'AJUSTE PRoV-CLI');
        //rMovConta.SETFILTER(rMovConta."Entry No.",'=%1|%2|%3|%4|%5|%6|%7|%8|%9|%10',874260,874259,879028,879030,879029,879031,874260,874259,879027,879026);
        //rMovConta.SETFILTER(rMovConta."Entry No.",'=%1|%2|%3|%4|%5|%6|%7|%8|%9',1016929,1017612,1017614,1017694,1018627,1018729,1023008,1026210,1067614);
        IF rMovConta.FIND('-') THEN BEGIN
            IF rCabConcil.FINDLAST THEN BEGIN
                wCabConcil := rCabConcil."Nº" + 1;
                MESSAGE('hago la cabecera %1', wCabConcil);
                rCabConcil.INIT;
                rCabConcil."Nº" := wCabConcil;
                rCabConcil.Usuario := 'SISTEMA';
                rCabConcil.Fecha := ToDAY;
                rCabConcil.Hora := TIME;
                rCabConcil.INSERT;
            END;
            REPEAT
                wCount := wCount + 1;
                //MESSAGE('Movimiento %1 Conciliacion %2 Cuenta %3 Cantidad %4',rMovConta."Entry No.",wCabConcil,rMovConta."G/L Account No.",rMovConta.Amount);

                rLinConcil.INIT;
                rLinConcil."Nº Mov." := rMovConta."Entry No.";
                rLinConcil."Nº Conciliacion" := wCabConcil;
                rLinConcil."Importe conciliado" := rMovConta.Amount;
                rLinConcil."Nº cuenta" := rMovConta."G/L Account No.";
                rLinConcil."Fecha conciliacion" := ToDAY;
                IF rLinConcil.INSERT THEN;
                rMovConta.Pendiente := FALSE;
                rMovConta.MoDIFY;
            UNTIL rMovConta.NEXT = 0
        END;
        MESSAGE('Hago %1 Movimientos', wCount);
    end;

    local procedure fRevMovProvDet()
    var
        rMovProvDet: Record "380;
        rVendor: Record "23;
        rVendor2: Record "23;
    begin
        rMovProvDet.SETRANGE(rMovProvDet."User ID", 'SISTEMA');
        //rMovProvDet.SETFILTER(rMovProvDet."Vendor No.",'<>%1','');
        IF rMovProvDet.FIND('-') THEN BEGIN
            REPEAT
                rVendor.SETRANGE(rVendor."No.", rMovProvDet."Vendor No.");
                IF NoT rVendor.FINDFIRST THEN BEGIN
                    rVendor2.SETRANGE(rVendor2."Telex No.", rMovProvDet."Vendor No.");
                    IF rVendor2.FINDFIRST THEN BEGIN
                        //    if CoNFIRM('Te voy a cambiar el movimiento %1 - %2 por %3',rMovProvDet."Entry No.",rMovProvDet."Vendor No.",rVendor2."No.") THEN BEGIN
                        rMovProvDet."Vendor No." := rVendor2."No.";
                        rMovProvDet.MoDIFY;
                        //    END;
                    END;
                END;
            UNTIL rMovProvDet.NEXT = 0;
        END;
    end;

    local procedure fResFecNoValida()
    var
        rReservas: Record 7000176;
        rocupantes: Record 7000178;
    begin
        rReservas.SETRANGE(rReservas."Fecha salida", WoRKDATE);
        rReservas.SETRANGE(rReservas."Fecha entrada", 0D);
        IF rReservas.FIND('-') THEN BEGIN
            REPEAT
                /*
                  rocupantes.RESET;
                  rocupantes.SETRANGE(rocupantes.Hotel,rReservas.Hotel);
                  rocupantes.SETRANGE(rocupantes.Ano,rReservas.Ano);
                  rocupantes.SETRANGE(rocupantes.Reserva,rReservas.Reserva);
                  rocupantes.SETRANGE(rocupantes.Desglose,rReservas.Desglose);
                  IF rocupantes.FIND('-') THEN BEGIN
                */
                rReservas."Fecha entrada" := CALCDATE('-1D', WoRKDATE);
                rReservas."Dia llegada" := CALCDATE('-1D', WoRKDATE);
                rReservas.MoDIFY
            /*
              END;
            */
            UNTIL rReservas.NEXT = 0
        END;
        CoMMIT;

    end;

    local procedure fResFecNoValid()
    var
        rReservas: Record 7000176;
        rocupantes: Record 7000178;
    begin
        rReservas.SETRANGE(rReservas."Fecha salida", WoRKDATE);
        rReservas.SETRANGE(rReservas."Fecha entrada", 0D);
        IF rReservas.FIND('-') THEN BEGIN
            REPEAT
                /*
                  rocupantes.RESET;
                  rocupantes.SETRANGE(rocupantes.Hotel,rReservas.Hotel);
                  rocupantes.SETRANGE(rocupantes.Ano,rReservas.Ano);
                  rocupantes.SETRANGE(rocupantes.Reserva,rReservas.Reserva);
                  rocupantes.SETRANGE(rocupantes.Desglose,rReservas.Desglose);
                  IF rocupantes.FIND('-') THEN BEGIN
                */
                rReservas."Fecha entrada" := CALCDATE('-1D', WoRKDATE);
                rReservas."Dia llegada" := CALCDATE('-1D', WoRKDATE);
                rReservas.MoDIFY
            /*
              END;
            */
            UNTIL rReservas.NEXT = 0
        END;
        CoMMIT;

    end;

    local procedure fConciliar()
    var
        wNumConcil: Integer;
        rCabConcil: Record 7012814;
        rLinConcil: Record 7012812;
        rMovConta: Record "17;
        wCount: Integer;
    begin


        rMovConta.SETRANGE(rMovConta."G/L Account No.", '5700010');
        rMovConta.SETFILTER(rMovConta."Posting Date", '..%1', 311223D);
        rMovConta.SETRANGE(rMovConta.Pendiente, TRUE);
        IF rMovConta.FIND('-') THEN BEGIN
            IF rCabConcil.FINDLAST THEN wNumConcil := rCabConcil."Nº" + 1;
            rCabConcil.INIT;
            rCabConcil."Nº" := wNumConcil;
            rCabConcil.Comentario := 'CoNCILIADo SISTEMA ' + FoRMAT(ToDAY);
            rCabConcil.Fecha := ToDAY;
            rCabConcil.Usuario := 'SISTEMA';
            IF rCabConcil.INSERT THEN;
            REPEAT
                rLinConcil.INIT;
                rLinConcil."Nº Mov." := rMovConta."Entry No.";
                rLinConcil."Nº Conciliacion" := wNumConcil;
                rLinConcil."Importe conciliado" := rMovConta."Importe pendiente";
                rLinConcil."Nº cuenta" := rMovConta."G/L Account No.";
                rLinConcil."Fecha conciliacion" := ToDAY;
                IF rLinConcil.INSERT THEN;
                IF rMovConta.Pendiente = TRUE THEN BEGIN
                    rMovConta.Pendiente := FALSE;
                    rMovConta."Importe pendiente" := 0;
                    rMovConta.MoDIFY;
                    wCount := wCount + 1
                END;
            UNTIL rMovConta.NEXT = 0
        END;


        /*
        
        rCabConcil.SETRANGE(rCabConcil.Usuario,'');
        IF rCabConcil.FIND('-') THEN BEGIN
           REPEAT
           rLinConcil.SETRANGE(rLinConcil."Nº Conciliacion",rCabConcil."Nº");
           IF rLinConcil.FIND('-') THEN BEGIN
             REPEAT
             rMovConta.SETRANGE(rMovConta."Entry No.",rLinConcil."Nº Mov.");
             rMovConta."Importe pendiente":=0;
             IF rMovConta.FINDFIRST THEN BEGIN
               IF rMovConta.Pendiente=TRUE THEN BEGIN
                  rMovConta.Pendiente:=FALSE;
                  wCount:=wCount+1
              END;
             rMovConta.MoDIFY;
             END;
             UNTIL rLinConcil.NEXT=0
           END;
         UNTIL rCabConcil.NEXT=0
        END;
        */




        MESSAGE('Se han modificado %1 movimientos de contabilidad', wCount);

    end;

    local procedure fProvRep()
    var
        wRegistro: Integer;
        r23: Record "23;
        r23Count: Record "23;
        wCount: Integer;
        rControlesTHB: Record "50001;
        x: Integer;
        wProv: array[3] of Text;
        wCodigo: array[3] of Code[10];
        rControlesTHB2: Record "50001;
    begin
        r23.SETFILTER(r23."VAT Registration No.", '<>%1', '');
        IF r23.FIND('-') THEN BEGIN
            REPEAT
                wCount := 0;
                r23Count.SETRANGE(r23Count."VAT Registration No.", r23."VAT Registration No.");
                IF r23Count.FIND('-') THEN BEGIN
                    REPEAT
                        wCount := wCount + 1;
                    UNTIL r23Count.NEXT = 0
                END;
                IF wCount > 1 THEN BEGIN
                    wRegistro := wRegistro + 1;
                    rControlesTHB.INIT;
                    rControlesTHB.Hotel := 'PRoVREP';
                    rControlesTHB.Fecha := FoRMAT(wRegistro);
                    rControlesTHB."Unidad 1 := r23."VAT Registration No.";
                    rControlesTHB."Unidad Medida 2 := r23."No.";
                    rControlesTHB."Unidad 2 := r23.Name;
                    rControlesTHB.INSERT;
                END;
            UNTIL r23.NEXT = 0
        END;

        r23.RESET;

        wRegistro := 0;
        rControlesTHB.SETRANGE(rControlesTHB.Hotel, 'PRoVREP');
        IF rControlesTHB.FIND('-') THEN BEGIN
            REPEAT
                r23.SETRANGE(r23."VAT Registration No.", rControlesTHB."Unidad 1);
                x := 0;
                wProv[1] := '';
                wProv[2] := '';
                wProv[3] := '';
                wCodigo[1] := '';
                wCodigo[2] := '';
                wCodigo[3] := '';
                IF r23.FIND('-') THEN BEGIN
                    REPEAT
                        x := x + 1;
                        wProv[x] := r23.Name;
                        wCodigo[x] := r23."No.";
                    UNTIL r23.NEXT = 0
                END;
                wRegistro := wRegistro + 1;
                rControlesTHB2.INIT;
                rControlesTHB2.Hotel := 'PRoVREPCoMP';
                rControlesTHB2.Fecha := FoRMAT(wRegistro);
                rControlesTHB.Recuento := r23."VAT Registration No.";
                rControlesTHB2."Unidad 2 := wProv[1];
                rControlesTHB2."Unidad Medida 3 := wProv[2];
                rControlesTHB2.Texto3 := wProv[3];
                rControlesTHB2."Unidad 1 := wCodigo[1];
                rControlesTHB2."Unidad Medida 2 := wCodigo[2];
                rControlesTHB2.Code3 := wCodigo[3];
                rControlesTHB2.INSERT;
            UNTIL rControlesTHB.NEXT = 0
        END;
    end;

    local procedure fVaciaReserva()
    var
        rReservasDia: Record 7000186;
        rReservas: Record 7000176;
    begin
        /*
        IF rReservas.FIND('-') THEN BEGIN
          REPEAT
          rReservas.DELETE;
          UNTIL rReservas.NEXT=0;
        END;
        */
        /*
        IF rReservasDia.FIND('-') THEN BEGIN
          REPEAT
          rReservasDia.DELETE;
          UNTIL rReservasDia.NEXT=0
        END;
        */

    end;

    local procedure fRevisaUdCompra()
    var
        rItem: Record "27;
    begin
        rItem.SETRANGE(rItem."Purch. Unit of Measure", '');
        IF rItem.FIND('-') THEN BEGIN
            REPEAT
                rItem."Purch. Unit of Measure" := rItem."Base Unit of Measure";
                rItem.MoDIFY(TRUE);
            UNTIL rItem.NEXT = 0
        END;
    end;

    local procedure fFixCIDPRoD(wFecha: Date)
    var
        rLinProd: Record 7000206;
        wCount: Integer;
        rDetTPV: Record 7000739;
        rGrupXTPV: Record 7000733;
        rLinProdNew: Record 7000206;
        wCentro: Code[10];
    begin
        Ventana.oPEN('Comprobando Produccion del dia #1######## \ Tipo de Registro #2####### \ ' +
                      'Registros Actualizados #3#######', wFecha, rLinProd.Ticket, wCount);


        /*
        wCount:=0;
        rLinProd.SETRANGE(rLinProd.Concepto,'Ext./Srv. Rva.:EXTRA DESAYUNo');
        rLinProd.SETRANGE(rLinProd."Fecha cargo",wFecha);
        rLinProd.SETFILTER(rLinProd.Centro,'<>%1','IET');
        IF rLinProd.FIND('-') THEN BEGIN
          REPEAT
          rLinProd.RENAME(rLinProd.Hotel,rLinProd."Fecha cargo",'DESAEX',rLinProd."Fecha proceso",rLinProd."Secuencia grabacion");
          wCount:=wCount+1;
          UNTIL rLinProd.NEXT=0
        END;
        //MESSAGE('Se han cambiado %1 registros');
        */

        wCount := 0;
        rLinProd.RESET;
        rLinProd.SETFILTER(rLinProd.Ticket, '<>%1', '');
        rLinProd.SETRANGE(rLinProd."Fecha cargo", wFecha);
        IF rLinProd.FIND('-') THEN BEGIN
            REPEAT
                IF (rLinProd.Centro = 'HASA') oR (rLinProd.Centro = 'HAHD') oR (rLinProd.Centro = 'HAMP') oR (rLinProd.Centro = 'HATI') oR (rLinProd.Centro = 'HAPC') THEN BEGIN
                    wCentro := rLinProd.Centro;
                    rDetTPV.SETRANGE(rDetTPV.Ticket, rLinProd.Ticket);
                    rDetTPV.SETRANGE(rDetTPV.Cantidad, rLinProd.Cantidad);
                    rDetTPV.SETRANGE(rDetTPV.Importe, rLinProd.Importe);
                    rDetTPV.SETRANGE(rDetTPV."Total original", rLinProd."Total importe");
                    IF rDetTPV.FINDFIRST THEN;
                    rGrupXTPV.SETRANGE(rGrupXTPV.TPV, rDetTPV.TPV);
                    rGrupXTPV.SETRANGE(rGrupXTPV.Grupo, rDetTPV.Grupo);
                    IF rGrupXTPV.FINDFIRST THEN wCentro := rGrupXTPV."Centro productivo";
                    rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", wCentro, rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                    wCount := wCount + 1;
                    //  IF NoT rLinProd.FIND('-') THEN EXIT;
                    //  IF rLinProd.FIND('-') THEN;
                    Ventana.UPDATE;
                END;
            UNTIL rLinProd.NEXT = 0;
        END;
        //MESSAGE('Para el dia %1 se han cambiado %2 registros',wFecha,wCount);

    end;

    local procedure fMovProvMovDet()
    var
        wImpMovCli: Decimal;
        rMovCliDet: Record "380;
        rMovCli: Record "25;
        rControles: Record "50001;
        wCount: Integer;
        rMovCli2: Record "25;
        wFiltro: Code[100];
        rProv: Record "23;
        wImpMovCliDet: Decimal;
        rControles2: Record "50001;
        bCambios: Boolean;
        rMovCliDet2: Record "380;
    begin

        //IF CoNFIRM('Haz click en si si quieres ejecutar los cambios, si solo quieres comprobar, haz click en "Cancelar"') THEN bCambios:=TRUE;

        rUsr.GET(USERID);

        //ANALIZAMoS SI HAY DISCREPANCIAS ENTRE LoS ToTATLES X PRoVEEDoR DE MoV. PRoVEEDoR
        //Y MoV. PRoVEEDoR DETALLADo Y SI LAS ENCoNTRAMoS LAS REFLEJAMoS EN CoNTRoLES THB

        IF rProv.FIND('-') THEN BEGIN
            REPEAT
                wImpMovCli := 0;
                wImpMovCliDet := 0;
                rMovCli.SETFILTER(rMovCli."Posting Date", '..%1', 081219D);
                rMovCli.SETRANGE(rMovCli."Vendor No.", rProv."No.");
                //rMovCli.SETRANGE(rMovCli.open,TRUE);
                IF rMovCli.FIND('-') THEN BEGIN
                    REPEAT
                        rMovCli.CALCFIELDS(rMovCli.Amount);
                        wImpMovCli := rMovCli.Amount + wImpMovCli;
                    UNTIL rMovCli.NEXT = 0
                END;
                rMovCliDet.RESET;
                rMovCliDet.SETFILTER(rMovCliDet."Posting Date", '..%1', 081219D);
                rMovCliDet.SETRANGE(rMovCliDet."Excluded from calculation", FALSE);
                rMovCliDet.SETRANGE(rMovCliDet."Vendor No.", rProv."No.");
                IF rMovCliDet.FIND('-') THEN BEGIN
                    REPEAT
                        wImpMovCliDet := rMovCliDet.Amount + wImpMovCliDet;
                    UNTIL rMovCliDet.NEXT = 0
                END;
                IF wImpMovCli <> wImpMovCliDet THEN BEGIN
                    rControles.INIT;
                    rControles.Hotel := 'SALDoMoVS';
                    rControles.Fecha := rUsr."Hotel de trabajo";
                    rControles.Recuento := rProv."No.";
                    rControles.Decimal := wImpMovCli;
                    rControles."Decimal 2 := wImpMovCliDet;
                    IF rControles.INSERT THEN;
                END;
            UNTIL rProv.NEXT = 0
        END;

        //CoMPRoBAMoS SI ESTaN CoRRECTAMENTE RELACIoNADoS LoS MoVIMIENToS PRoVEEDoR VS MoVS PRoV. DET.
        //Y BUSCAMoS QUE NuMERo LE CoRRESPoNDE REALMENTE PoR NuMERo DE DoCUMENTo.
        /*
        rMovCli.RESET;
        rMovCliDet.RESET;
        
        IF rMovCliDet.FIND('-') THEN BEGIN
          REPEAT
          rMovCli.SETRANGE(rMovCli."Entry No.",rMovCliDet."Vendor Ledger Entry No.");
          IF NoT rMovCli.FINDFIRST THEN BEGIN
            wCount:=wCount+1;
            wFiltro:='';
            rControles.INIT;
            rControles."ID Tabla":='MoVCLIDET';
            rControles.Control:=rUsr."Hotel de trabajo";
            rControles.Campo:=FoRMAT(wCount);
            rControles."Valor de campo":=rMovCliDet."Vendor No.";
            rControles.Integer:=rMovCliDet."Entry No.";
            rControles.Integer2:=rMovCliDet."Vendor Ledger Entry No.";
            rMovCli2.SETRANGE(rMovCli2."Document No.",rMovCliDet."Document No.");
            IF rMovCli2.FINDFIRST THEN BEGIN
              REPEAT
              IF wFiltro<>'' THEN wFiltro:=FoRMAT(rMovCli2."Entry No.")+'|'+wFiltro
              ELSE wFiltro:=FoRMAT(rMovCli2."Entry No.")
              UNTIL rMovCli2.NEXT=0
            END;
            rControles.Texto:=wFiltro;
            IF rControles.INSERT THEN;
          END;
          UNTIL rMovCliDet.NEXT=0
        END;
        */
        CoMMIT;

        //NoS VAMoS A CoNTRoLESTHB Y RELACIoNAMoS CoRRECTAMENTE LoS MoVS PRoVEEDoR DET CoN
        //MoVIMIENTo DE PRoVEEDoR.

        //PRIMERo BoRRAMoS LoS QUE SoBRAN
        /*
        IF bCambios THEN BEGIN
          rControles.RESET;
          rControles.SETRANGE(rControles."ID Tabla",'MoVCLIDET');
          rControles.SETRANGE(rControles.Texto,'');
          IF rControles.FINDFIRST THEN BEGIN
            REPEAT
            rMovCliDet.SETRANGE(rMovCliDet."Entry No.",rControles.Integer);
            IF rMovCliDet.FINDFIRST THEN rMovCliDet.DELETE;
            UNTIL rControles.NEXT=0
          END;
        
        CoMMIT;
        
        //VoLVEMoS A HACER LoS CaLCULoS PoR PRoVEEDoR PARA VER SI HA CAMBIADo ALGo
        
          rMovCli.RESET;
          rMovCliDet.RESET;
        
          rControles.RESET;
          rControles.SETRANGE(rControles."ID Tabla",'SALDoMoVS');
          IF rControles.FIND('-') THEN BEGIN
            REPEAT
              rProv.SETRANGE(rProv."No.",rControles.Campo);
              IF rProv.FIND('-') THEN BEGIN
              REPEAT
              wImpMovCli:=0;
              wImpMovCliDet:=0;
              rMovCli.SETRANGE(rMovCli."Vendor No.",rProv."No.");
              rMovCli.SETRANGE(rMovCli.open,TRUE);
              IF rMovCli.FIND('-') THEN BEGIN
                REPEAT
                rMovCli.CALCFIELDS(rMovCli.Amount);
                wImpMovCli:=rMovCli.Amount+wImpMovCli;
                UNTIL rMovCli.NEXT=0
              END;
              rMovCliDet.SETRANGE(rMovCliDet."Excluded from calculation",FALSE);
              rMovCliDet.SETRANGE(rMovCliDet."Vendor No.",rProv."No.");
              IF rMovCliDet.FIND('-') THEN BEGIN
                REPEAT
                wImpMovCliDet:=rMovCliDet.Amount+wImpMovCliDet;
                UNTIL rMovCliDet.NEXT=0
              END;
              rControles2.INIT;
              rControles2."ID Tabla":='SALDoMoVS2';
              rControles2.Control:=rUsr."Hotel de trabajo";
              rControles2.Campo:=rProv."No.";
              rControles2.Decimal:=wImpMovCli;
              rControles2."Decimal 2:=wImpMovCliDet;
              IF rControles2.INSERT THEN;
              UNTIL rProv.NEXT=0
            END;
            UNTIL rControles.NEXT=0
          END;
        
        //AHoRA NoS VAMoS A REoRGANIZAR LoS MoVIMIENToS, PERo PRIMERo
        //CoMPRoBAREMoS QUE No HAY UN MoVIMIENTo YA RELACIoNADo, PoR
        //Lo QUE EL MoVIMIENTo No RELACIoNADo, SoBRA.
        
          rMovCli.RESET;
          rMovCliDet.RESET;
        
          rControles.RESET;
          rControles.SETRANGE(rControles."ID Tabla",'MoVCLIDET');
          rControles.SETFILTER(rControles.Texto,'<>%1','');
        //rControles.SETRANGE(rControles.Texto,'363331');
          IF rControles.FINDFIRST THEN BEGIN
            REPEAT
            rMovCliDet.SETRANGE(rMovCliDet."Entry No.",rControles.Integer);
            IF rMovCliDet.FINDFIRST THEN BEGIN
              rMovCliDet2.SETRANGE(rMovCliDet2."Document No.",rMovCliDet."Document No.");
              rMovCliDet2.SETFILTER(rMovCliDet2."Entry No.",'<>%1',rMovCliDet."Entry No.");
              rMovCliDet2.SETRANGE(rMovCliDet2."Entry Type",rMovCliDet."Entry Type");
              IF (rMovCliDet2.FINDFIRST) AND (FoRMAT(rMovCliDet2."Vendor Ledger Entry No.")=rControles.Texto) THEN rMovCliDet.DELETE
            END;
            UNTIL rControles.NEXT=0
          END;
        
          rControles.RESET;
          rControles.SETRANGE(rControles."ID Tabla",'SALDoMoVS');
          IF rControles.FIND('-') THEN BEGIN
            REPEAT
              rProv.SETRANGE(rProv."No.",rControles.Campo);
              IF rProv.FIND('-') THEN BEGIN
              REPEAT
              wImpMovCli:=0;
              wImpMovCliDet:=0;
              rMovCli.SETRANGE(rMovCli."Vendor No.",rProv."No.");
              rMovCli.SETRANGE(rMovCli.open,TRUE);
              IF rMovCli.FIND('-') THEN BEGIN
                REPEAT
                rMovCli.CALCFIELDS(rMovCli.Amount);
                wImpMovCli:=rMovCli.Amount+wImpMovCli;
                UNTIL rMovCli.NEXT=0
              END;
              rMovCliDet.SETRANGE(rMovCliDet."Excluded from calculation",FALSE);
              rMovCliDet.SETRANGE(rMovCliDet."Vendor No.",rProv."No.");
              IF rMovCliDet.FIND('-') THEN BEGIN
                REPEAT
                wImpMovCliDet:=rMovCliDet.Amount+wImpMovCliDet;
                UNTIL rMovCliDet.NEXT=0
              END;
              rControles2.INIT;
              rControles2."ID Tabla":='SALDoMoVS3';
              rControles2.Control:=rUsr."Hotel de trabajo";
              rControles2.Campo:=rProv."No.";
              rControles2.Decimal:=wImpMovCli;
              rControles2."Decimal 2:=wImpMovCliDet;
              IF rControles2.INSERT THEN;
              UNTIL rProv.NEXT=0
            END;
            UNTIL rControles.NEXT=0
          END;
        END;
        */

    end;

    local procedure fMovProDetRevisa()
    var
        r380: Record "380;
    begin

        IF r380.FIND('-') THEN BEGIN
            REPEAT
                IF r380."Entry Type" = r380."Entry Type"::Application THEN
                    r380."Ledger Entry Amount" := FALSE
                ELSE
                    r380."Ledger Entry Amount" := TRUE;
                r380.MoDIFY;
            UNTIL r380.NEXT = 0
        END;
    end;

    local procedure fMovCliDetRevisa()
    var
        r379: Record "379;
    begin

        IF r379.FIND('-') THEN BEGIN
            REPEAT
                IF r379."Entry Type" = r379."Entry Type"::Application THEN
                    r379."Ledger Entry Amount" := FALSE
                ELSE
                    r379."Ledger Entry Amount" := TRUE;
                r379.MoDIFY;
            UNTIL r379.NEXT = 0
        END;
    end;

    local procedure fRevisaAsiento2()
    var
        wCount: Integer;
        wFechaAsiento: Date;
        wToEntry: Integer;
        wFromEntry: Integer;
        wRegistro: Integer;
        rRegistro2: Record "45;
        rRegistro: Record "45;
        rMovConta: Record "17;
        rMovIva: Record "254;
    begin

        Ventana.oPEN('Revisando asiento #1####### Asientos modificados #2##### ', rRegistro."No.", wCount);
        rRegistro.SETRANGE(rRegistro."No.", 1, 9559);
        IF rRegistro.FIND('-') THEN BEGIN
            REPEAT
                Ventana.UPDATE;
                rMovConta.SETRANGE(rMovConta."Transaction No.", rRegistro."No.");
                IF rMovConta.FIND('-') THEN BEGIN
                    REPEAT
                        wFechaAsiento := rMovConta."Posting Date";
                        rMovConta."Transaction No." := rMovConta."Transaction No." + 1000000;
                        rMovConta.MoDIFY;
                    UNTIL rMovConta.NEXT = 0;
                    rRegistro2 := rRegistro;
                    rRegistro2."No." := rRegistro."No." + 1000000;
                    IF rRegistro2.INSERT THEN BEGIN
                        wCount := wCount + 1;
                        rRegistro.DELETE
                    END;
                    Ventana.UPDATE;
                END;
            UNTIL rRegistro.NEXT = 0;
        END;

        MESSAGE('Se han generado %1 asientos', wCount);
    end;

    local procedure fRevisaAsiento()
    var
        wCount: Integer;
        wFechaAsiento: Date;
        wToEntry: Integer;
        wFromEntry: Integer;
        wRegistro: Integer;
        rRegistro2: Record "45;
        rRegistro: Record "45;
        rMovConta: Record "17;
        rMovIva: Record "254;
    begin
        Ventana.oPEN('Revisando asiento #1####### Asientos creados #2##### ', rRegistro."No.", wCount);
        //rRegistro.SETRANGE(rRegistro."No.",1,100);
        IF rRegistro.FIND('-') THEN BEGIN
            REPEAT
                Ventana.UPDATE;
                wFromEntry := 0;
                rMovConta.SETRANGE(rMovConta."Transaction No.", rRegistro."No.");
                //rMovConta.SEtrange(rMovConta."Document No.",rRegistro."From Entry No.",rRegistro2."To Entry No.");
                IF rMovConta.FIND('-') THEN BEGIN
                    REPEAT
                        IF (rMovConta."Entry No." < rRegistro."From Entry No.") oR (rMovConta."Entry No." > rRegistro."To Entry No.") THEN BEGIN
                            IF wFromEntry = 0 THEN wFromEntry := rMovConta."Entry No.";
                            IF rRegistro2.FINDLAST THEN wRegistro := rRegistro2."No.";
                            wToEntry := rMovConta."Entry No.";
                            wFechaAsiento := rMovConta."Posting Date";
                            rMovConta."Transaction No." := wRegistro + 1;
                            rMovConta.MoDIFY;
                            //    MESSAGE('Documento %1 Movimiento %2',rMovConta."Document No.",rMovConta."Entry No.");
                        END;
                        //  wFromEntry:=rMovConta."Entry No.";
                    UNTIL rMovConta.NEXT = 0;
                    IF wFromEntry <> 0 THEN BEGIN
                        rRegistro2.INIT;
                        rRegistro2."Creation Date" := wFechaAsiento;
                        rRegistro2."No." := wRegistro + 1;
                        rRegistro2."From Entry No." := wFromEntry;
                        rRegistro2."To Entry No." := wToEntry;
                        rRegistro2."Source Code" := 'AJ.IMPoRT';
                        rRegistro2."User ID" := 'SISTEMA';
                        rRegistro2."Posting Date" := wFechaAsiento;
                        IF rRegistro2.INSERT THEN wCount := wCount + 1;
                        Ventana.UPDATE;
                        //      MESSAGE(' %1 , desde %2 hasta %3 con fecha %4',wRegistro+1,wFromEntry,wToEntry,wFechaAsiento);
                    END;
                END;
            UNTIL rRegistro.NEXT = 0;
        END;

        MESSAGE('Se han generado %1 asientos', wCount);
    end;

    
    procedure fActualizaPend()
    var
        wCountCobCab: Integer;
        wCountCobDet: Integer;
        wCountCabFac: Integer;
        wCountLinFac: Integer;
        wCountLinFacImp: Integer;
        rCompany: Record "2000000006;
        rCabFac: Record 7000196;
        rLinFacImp: Record 7000200;
        rLinFac: Record 7000198;
        rCobCab: Record 7000680;
        rCobDet: Record 7000681;
        rControlesTHB: Record "50001;
        rCabFacGes: Record 7000196;
        rLinFacImpGes: Record 7000200;
        rLinFacGes: Record 7000198;
        rCobCabGes: Record 7000680;
        rCobDetGes: Record 7000681;
    begin

        Ventana.oPEN('Actualizando registros de #1######################################### \' +
                     ' \' +
                     'Cabeceras de factura actualizadas #2######## \' +
                     'Lineas de factura actualizadas #3######### \' +
                     'Lineas de factura impresion actualizadas #4######### \' +
                     'Cobros cabecera actualizados #5######### \' +
                     'Cobros detalle actualizados #6#########', rCompany.Name, wCountCabFac, wCountLinFac, wCountLinFacImp, wCountCobCab, wCountCobDet);

        //DEFINIMoS LA SoCIEDAD DE DESTINo EN ToDAS LAS TABLAS EN LAS QUE VAMoS A ESCRIBIR

        rCabFacGes.CHANGECoMPANY('THB Gestion');
        rLinFacGes.CHANGECoMPANY('THB Gestion');
        rLinFacImpGes.CHANGECoMPANY('THB Gestion');
        rCobCabGes.CHANGECoMPANY('THB Gestion');
        rCobDetGes.CHANGECoMPANY('THB Gestion');

        rCompany.SETFILTER(rCompany.Name, '<>%1', 'THB Gestion');
        //rCompany.SETRANGE(rCompany.Name,'HoTEL SANT JoRDI, S.A.');
        IF rCompany.FIND('-') AND (rCompany.Name <> 'THB Gestion') THEN BEGIN
            Ventana.UPDATE;
            REPEAT


                //CAMBIAMoS ToDAS LAS SoCIEDADES EN LAS TABLAS A CoNSULTAR

                rUsr.CHANGECoMPANY(rCompany.Name);
                rCabFac.CHANGECoMPANY(rCompany.Name);
                rLinFac.CHANGECoMPANY(rCompany.Name);
                rLinFacImp.CHANGECoMPANY(rCompany.Name);
                rCobCab.CHANGECoMPANY(rCompany.Name);
                rCobDet.CHANGECoMPANY(rCompany.Name);

                //CoNSULTAMoS LoS SoURCECoUNTERS DE FACTURAS PARA SABER SI HAY ALGo QUE ACTUALIZAR o AnADIR

                rUsr.GET(USERID);
                rControlesTHB.SETRANGE(rControlesTHB.Hotel, 'REPCABFAC');
                rControlesTHB.SETRANGE(rControlesTHB.Fecha, rUsr."Hotel de trabajo");
                IF rControlesTHB.FINDFIRST THEN BEGIN
                    rCabFac.SETCURRENTKEY(Sourcecounter);
                    rCabFac.SETFILTER(rCabFac.Sourcecounter, '>%1', rControlesTHB.Almacen);
                    rCabFac.SETRANGE(rCabFac.Tipo, 0);

                    //SI ENCoNTRAMoS REGISTRoS, AQUi EMPIEZA LA FIESTA

                    IF rCabFac.FIND('-') THEN BEGIN
                        REPEAT
                            rCabFacGes.SETRANGE(rCabFacGes.Hotel, rCabFac.Hotel);
                            rCabFacGes.SETRANGE(rCabFacGes.Factura, rCabFac.Factura);
                            IF rCabFacGes.FINDSET(TRUE, TRUE) THEN rCabFacGes.DELETE(FALSE);
                            rCabFacGes := rCabFac;
                            IF rCabFacGes.INSERT(FALSE) THEN wCountCabFac := wCountCabFac + 1;
                            //    Ventana.UPDATE;
                            rLinFac.SETRANGE(rLinFac.Factura, rCabFac.Factura);
                            IF rLinFac.FIND('-') THEN BEGIN
                                REPEAT
                                    rLinFacGes.SETRANGE(rLinFacGes.Factura, rLinFac.Factura);
                                    rLinFacGes.SETRANGE(rLinFacGes."Secuencia grabacion", rLinFac."Secuencia grabacion");
                                    IF rLinFacGes.FINDFIRST THEN rLinFacGes.DELETE(FALSE);
                                    rLinFacGes := rLinFac;
                                    IF rLinFacGes.INSERT(FALSE) THEN wCountLinFac := wCountLinFac + 1;
                                    //      Ventana.UPDATE;
                                UNTIL rLinFac.NEXT = 0
                            END;
                            rLinFacImp.SETRANGE(rLinFacImp.Factura, rCabFac.Factura);
                            IF rLinFacImp.FIND('-') THEN BEGIN
                                REPEAT
                                    rLinFacImpGes.SETRANGE(rLinFacImpGes.Factura, rLinFacImp.Factura);
                                    rLinFacImpGes.SETRANGE(rLinFacImpGes."Secuencia grabacion", rLinFacImp."Secuencia grabacion");
                                    IF rLinFacImpGes.FINDFIRST THEN rLinFacImpGes.DELETE(FALSE);
                                    rLinFacImpGes := rLinFacImp;
                                    IF rLinFacImpGes.INSERT(FALSE) THEN wCountLinFacImp := wCountLinFacImp + 1;
                                    //      Ventana.UPDATE;
                                UNTIL rLinFacImp.NEXT = 0
                            END;
                            rControlesTHB.Almacen := rCabFac.Sourcecounter;
                            rControlesTHB.MoDIFY(FALSE);
                            Ventana.UPDATE;
                        UNTIL rCabFac.NEXT = 0;
                    END;
                END ELSE BEGIN
                    rControlesTHB.INIT;
                    rControlesTHB.Hotel := 'REPCABFAC';
                    rControlesTHB.Fecha := rUsr."Hotel de trabajo";
                    rControlesTHB.Almacen := 0;
                    rControlesTHB.INSERT
                END;

                rControlesTHB.RESET;
                rControlesTHB.SETRANGE(rControlesTHB.Hotel, 'REPCABCoB');
                rControlesTHB.SETRANGE(rControlesTHB.Fecha, rUsr."Hotel de trabajo");
                IF rControlesTHB.FINDFIRST THEN BEGIN
                    rCobCab.SETCURRENTKEY(SourceCounter);
                    rCobCab.SETFILTER(rCobCab.SourceCounter, '>%1', rControlesTHB.Almacen);

                    //SI ENCoNTRAMoS REGISTRoS, AQUi EMPIEZA LA FIESTA

                    IF rCobCab.FIND('-') THEN BEGIN
                        REPEAT
                            rCobCabGes.SETRANGE(rCobCabGes.Hotel, rCobCab.Hotel);
                            rCobCabGes.SETRANGE(rCobCabGes."Num. Cobro", rCobCab."Num. Cobro");
                            IF rCobCabGes.FINDSET(TRUE, TRUE) THEN rCobCabGes.DELETE(FALSE);
                            rCobCabGes := rCobCab;
                            IF rCobCabGes.INSERT(FALSE) THEN wCountCobCab := wCountCobCab + 1;
                            //    Ventana.UPDATE;
                            rCobDet.SETRANGE(rCobDet.Hotel, rCobCab.Hotel);
                            rCobDet.SETRANGE(rCobDet."Num. Cobro", rCobCab."Num. Cobro");
                            IF rCobDet.FIND('-') THEN BEGIN
                                REPEAT
                                    rCobDetGes.SETRANGE(rCobDetGes.Hotel, rCobDet.Hotel);
                                    rCobDetGes.SETRANGE(rCobDetGes."Num. Cobro", rCobDet."Num. Cobro");
                                    rCobDetGes.SETRANGE(rCobDetGes."Num. Linea", rCobDet."Num. Linea");
                                    IF rCobDetGes.FINDFIRST THEN rCobDetGes.DELETE(FALSE);
                                    rCobDetGes := rCobDet;
                                    IF rCobDetGes.INSERT(FALSE) THEN wCountCobDet := wCountCobDet + 1;
                                    //      Ventana.UPDATE;
                                UNTIL rCobDet.NEXT = 0
                            END;
                            rControlesTHB.Almacen := rCobCab.SourceCounter;
                            rControlesTHB.MoDIFY(FALSE)
                      UNTIL rCobCab.NEXT = 0;
                        Ventana.UPDATE;
                    END;
                END ELSE BEGIN
                    rControlesTHB.INIT;
                    rControlesTHB.Hotel := 'REPCABCoB';
                    rControlesTHB.Fecha := rUsr."Hotel de trabajo";
                    rControlesTHB.Almacen := 0;
                    rControlesTHB.INSERT
                END;
                CoMMIT;
            UNTIL rCompany.NEXT = 0
        END;
        Ventana.UPDATE;
        Ventana.CLoSE;

        MESSAGE('Cabeceras de factura actualizadas %1 \' +
                'Lineas de factura actualizadas %2 \' +
                'Lineas de factura impresion actualizadas %3 \' +
                'Cobros cabecera actualizados %4 \' +
                'Cobros detalle actualizados %5 ', wCountCabFac, wCountLinFac, wCountLinFacImp, wCountCobCab, wCountCobDet);
    end;

    
    procedure fICDDeuda(wFecha: Date)
    var
        wFechaBucle: Date;
        rBook: Record 7000189;
        wocupDiaHA: Integer;
        wResDiaHA: Integer;
        wResDiaHD: Integer;
        wocupDiaHD: Integer;
        wResDiaMP: Integer;
        wocupDiaMP: Integer;
        wResDiaPC: Integer;
        wocupDiaPC: Integer;
        wResDiaTI: Integer;
        wocupDiaTI: Integer;
        rResDia: Record 7000186;
        rCliente: Record "18;
        rCab: Record 7000196;
        wFecha30: Date;
        wFecha60: Date;
        wFecha90: Date;
        wFecha120: Date;
        wMenos30: Decimal;
        w30: Decimal;
        w60: Decimal;
        w90: Decimal;
        w120: Decimal;
        rICDDeuda: Record "50003;
        wFMenos30: Decimal;
        wF3060: Decimal;
        wF6090: Decimal;
        wF90120: Decimal;
        wFMas120: Decimal;
        wResDiaHAAD: Decimal;
        wResDiaHANI: Decimal;
        wResDiaHAJR: Decimal;
        wResDiaHDAD: Decimal;
        wResDiaHDNI: Decimal;
        wResDiaHDJR: Decimal;
        wResDiaMPAD: Decimal;
        wResDiaMPJR: Decimal;
        wResDiaMPNI: Decimal;
        wResDiaPCAD: Decimal;
        wResDiaPCNI: Decimal;
        wResDiaPCJR: Decimal;
        wResDiaTIAD: Decimal;
        wResDiaTINI: Decimal;
        wResDiaTIJR: Decimal;
    begin

        rUsr.GET(USERID);
        rUsr.FINDFIRST;


        //ERRoR('hotel de trabajo %1 %2',USERID,rUsr."Hotel de trabajo");
        //CALCULAMoS LAS FECHAS A TENER EN CUENTA

        wFecha30 := CALCDATE('-30D', wFecha);
        wFecha60 := CALCDATE('-60D', wFecha);
        wFecha90 := CALCDATE('-90D', wFecha);
        wFecha120 := CALCDATE('-120D', wFecha);

        //BoRRADo PREVIo PoR SI SE HAN GENERADo DAToS ANTES DEL CIERRE


        rICDDeuda.SETRANGE(rICDDeuda.Fecha, wFecha);
        rICDDeuda.SETRANGE(rICDDeuda.Hotel, rUsr."Hotel de trabajo");
        IF rICDDeuda.FIND('-') THEN BEGIN
            REPEAT
                rICDDeuda.DELETE;
            UNTIL rICDDeuda.NEXT = 0
        END;

        Ventana.oPEN('Cliente #1########', rCliente."No.");

        //LE APLICAMoS LAS CLAVES DE oRDENACIoN ADECUADAS THB-310815-IFF

        rCab.SETCURRENTKEY(rCab.Cliente, rCab.Hotel, rCab."Fecha factura", rCab.Tipo);

        //LE APLICAMoS LAS CLAVES DE oRDENACIoN ADECUADAS THB-310815-IFF

        IF rCliente.FIND('-') THEN BEGIN
            REPEAT
                rCliente.SETRANGE(rCliente."Date Filter", wFecha30, wFecha);
                rCliente.CALCFIELDS(rCliente."Importe facturado");
                wFMenos30 := rCliente."Importe facturado";
                rCliente.SETRANGE(rCliente."Date Filter", wFecha60, CALCDATE('+1D', wFecha30));
                rCliente.CALCFIELDS(rCliente."Importe facturado");
                wF3060 := rCliente."Importe facturado";
                rCliente.SETRANGE(rCliente."Date Filter", wFecha90, CALCDATE('+1D', wFecha60));
                rCliente.CALCFIELDS(rCliente."Importe facturado");
                wF6090 := rCliente."Importe facturado";
                rCliente.SETRANGE(rCliente."Date Filter", wFecha120, CALCDATE('+1D', wFecha90));
                rCliente.CALCFIELDS(rCliente."Importe facturado");
                wF90120 := rCliente."Importe facturado";
                rCliente.SETRANGE(rCliente."Date Filter", 010199D, CALCDATE('+1D', wFecha120));
                rCliente.CALCFIELDS(rCliente."Importe facturado");
                wFMas120 := rCliente."Importe facturado";
                rCab.RESET;
                rCab.SETRANGE(rCab.Cliente, rCliente."No.");
                rCab.SETRANGE(rCab."Cobrada registrada", FALSE);
                rCab.SETRANGE(rCab.Tipo, 0);
                rCab.SETFILTER(rCab."Importe pendiente de cobro", '<> %1', 0);
                //rCab.SETRANGE(rCab."Fecha factura",wFecha120,wFecha);
                IF rCab.FIND('-') THEN BEGIN
                    REPEAT
                        IF (rCab."Fecha factura" > wFecha30) THEN wMenos30 := rCab."Importe pendiente de cobro" + wMenos30;
                        IF (rCab."Fecha factura" > wFecha60) AND (rCab."Fecha factura" < CALCDATE('+1D', wFecha30)) THEN
                            w30 := rCab."Importe pendiente de cobro" + w30;
                        IF (rCab."Fecha factura" > wFecha90) AND (rCab."Fecha factura" < CALCDATE('+1D', wFecha60)) THEN
                            w60 := rCab."Importe pendiente de cobro" + w60;
                        IF (rCab."Fecha factura" > wFecha120) AND (rCab."Fecha factura" < CALCDATE('+1D', wFecha90)) THEN
                            w90 := rCab."Importe pendiente de cobro" + w90;
                        IF (rCab."Fecha factura" < wFecha120) THEN w120 := rCab."Importe pendiente de cobro" + w120;
                    UNTIL rCab.NEXT = 0
                END;
                IF (w30 <> 0) oR (w60 <> 0) oR (w90 <> 0) oR (w120 <> 0) oR (wMenos30 <> 0) THEN BEGIN
                    rICDDeuda.INIT;
                    rICDDeuda.Hotel := rUsr."Hotel de trabajo";
                    rICDDeuda.Nombre := rCliente.Name;
                    rICDDeuda.Cliente := rCliente."No.";
                    rICDDeuda.Fecha := wFecha;
                    rICDDeuda."Menos de 30 := wMenos30;
                    rICDDeuda."Entre 30 y 60 := w30;
                    rICDDeuda."Entre 60 y 90 := w60;
                    rICDDeuda."Entre 90 y 120 := w90;
                    rICDDeuda."Mas de 120 := w120;
                    rICDDeuda."Facturado Menos de 30 := wFMenos30;
                    rICDDeuda."Facturado Entre 30 y 60 := wF3060;
                    rICDDeuda."Facturado Entre 60 y 90 := wF6090;
                    rICDDeuda."Facturado Entre 90 y 120 := wF90120;
                    rICDDeuda."Facturado Mas de 120 := wFMas120;
                    rICDDeuda."Total Cliente" := wMenos30 + w30 + w60 + w90 + w120;
                    IF rICDDeuda.INSERT THEN;
                END;
                w30 := 0;
                w60 := 0;
                w90 := 0;
                w120 := 0;
                wMenos30 := 0;
                wFMenos30 := 0;
                wF3060 := 0;
                wF6090 := 0;
                wF90120 := 0;
                wFMas120 := 0;
                Ventana.UPDATE;
            UNTIL rCliente.NEXT = 0;
        END;


        //NoS GENERAMoS UN ICD CoN LoS DAToS DE LAS RESERVAS DIARIAS, YA QUE EL ICD DE ESTANCIAS X REGIMEN VA EN FUNCIoN AL ReGIMEN FRA.
        //ANTES LIMPIAMoS LoS ICD'S GENERADoS DURANTE EL MES ANTERIoR PARA TENER EN CUENTA LAS PoSIBLES RESERVAS ANULADAS.

        rICDDeuda.RESET;
        rICDDeuda.SETRANGE(rICDDeuda.Hotel, rUsr."Hotel de trabajo");
        rICDDeuda.SETRANGE(rICDDeuda.Cliente, 'ESTXREG');
        rICDDeuda.SETRANGE(rICDDeuda.Fecha, wFecha120, wFecha);
        //rICDDeuda.SETRANGE(rICDDeuda.Fecha,010114D,WoRKDATE);
        IF rICDDeuda.FIND('-') THEN BEGIN
            REPEAT
                rICDDeuda.DELETE;
            UNTIL rICDDeuda.NEXT = 0
        END;



        FoR wFechaBucle := wFecha120 To wFecha Do BEGIN
            //FoR wFechaBucle:=010114D To wFecha Do BEGIN
            rBook.RESET;
            rBook.SETRANGE(rBook.Hotel, rUsr."Hotel de trabajo");
            rBook.SETRANGE(rBook."Rango Fecha", wFechaBucle);
            rBook.SETFILTER(rBook."Rango Estado", '%1|%2|%3',
            rBook."Rango Estado"::Reserva, rBook."Rango Estado"::Entrada, rBook."Rango Estado"::Salida);
            IF rBook.FIND('-') THEN;
            rBook.SETRANGE(rBook."Rango Regimen fact.", 'HA');
            rBook.CALCFIELDS(rBook.AD, rBook.JR, rBook.NI, rBook.ocupacion);
            wResDiaHA := rBook.AD + rBook.JR + rBook.NI;
            wocupDiaHA := rBook.ocupacion;
            wResDiaHAAD := rBook.AD;
            wResDiaHAJR := rBook.JR;
            wResDiaHANI := rBook.NI;
            rBook.SETRANGE(rBook."Rango Regimen fact.", 'SA');
            rBook.CALCFIELDS(rBook.AD, rBook.JR, rBook.NI, rBook.ocupacion);
            wResDiaHA := wResDiaHA + rBook.AD + rBook.JR + rBook.NI;
            wocupDiaHA := wocupDiaHA + rBook.ocupacion;
            wResDiaHAAD := wResDiaHAAD + rBook.AD;
            wResDiaHAJR := wResDiaHAJR + rBook.JR;
            wResDiaHANI := wResDiaHANI + rBook.NI;
            rBook.SETRANGE(rBook."Rango Regimen fact.", 'HD');
            rBook.CALCFIELDS(rBook.AD, rBook.JR, rBook.NI, rBook.ocupacion);
            wResDiaHD := rBook.AD + rBook.JR + rBook.NI;
            wocupDiaHD := rBook.ocupacion;
            wResDiaHDAD := rBook.AD;
            wResDiaHDJR := rBook.JR;
            wResDiaHDNI := rBook.NI;
            IF rUsr."Hotel de trabajo" <> 'LNB' THEN
                rBook.SETFILTER(rBook."Rango Regimen fact.", '%1|%2', 'MP', 'MPA')
            ELSE
                rBook.SETRANGE(rBook."Rango Regimen fact.", 'MP');
            rBook.CALCFIELDS(rBook.AD, rBook.JR, rBook.NI, rBook.ocupacion);
            wResDiaMP := rBook.AD + rBook.JR + rBook.NI;
            wocupDiaMP := rBook.ocupacion;
            wResDiaMPAD := rBook.AD;
            wResDiaMPJR := rBook.JR;
            wResDiaMPNI := rBook.NI;
            rBook.SETRANGE(rBook."Rango Regimen fact.", 'PC');
            rBook.CALCFIELDS(rBook.AD, rBook.JR, rBook.NI, rBook.ocupacion);
            wResDiaPC := rBook.AD + rBook.JR + rBook.NI;
            wocupDiaPC := rBook.ocupacion;
            wResDiaPCAD := rBook.AD;
            wResDiaPCJR := rBook.JR;
            wResDiaPCNI := rBook.NI;
            IF rUsr."Hotel de trabajo" = 'LNB' THEN
                rBook.SETFILTER(rBook."Rango Regimen fact.", '%1|%2', 'TI', 'MPA')
            ELSE
                rBook.SETRANGE(rBook."Rango Regimen fact.", 'TI');
            rBook.CALCFIELDS(rBook.AD, rBook.JR, rBook.NI, rBook.ocupacion);
            wResDiaTI := rBook.AD + rBook.JR + rBook.NI;
            wocupDiaTI := rBook.ocupacion;
            wResDiaTIAD := rBook.AD;
            wResDiaTIJR := rBook.JR;
            wResDiaTINI := rBook.NI;
            rICDDeuda.INIT;
            rICDDeuda.Hotel := rUsr."Hotel de trabajo";
            rICDDeuda.Nombre := 'ESTXREG';
            rICDDeuda.Cliente := 'ESTXREG';
            rICDDeuda.Fecha := wFechaBucle;
            rICDDeuda."Menos de 30 := wResDiaHA;
            rICDDeuda."Entre 30 y 60 := wResDiaHD;
            rICDDeuda."Entre 60 y 90 := wResDiaMP;
            rICDDeuda."Entre 90 y 120 := wResDiaPC;
            rICDDeuda."Mas de 120 := wResDiaTI;
            rICDDeuda."Facturado Menos de 30 := wocupDiaHA;
            rICDDeuda."Facturado Entre 30 y 60 := wocupDiaHD;
            rICDDeuda."Facturado Entre 60 y 90 := wocupDiaMP;
            rICDDeuda."Facturado Entre 90 y 120 := wocupDiaPC;
            rICDDeuda."Facturado Mas de 120 := wocupDiaTI;
            //if rICDDeuda.INSERT then;
            rICDDeuda.INSERT;
            rICDDeuda.INIT;
            rICDDeuda.Hotel := rUsr."Hotel de trabajo";
            rICDDeuda.Nombre := 'HA';
            rICDDeuda.Cliente := 'ESTXREG';
            rICDDeuda.Fecha := wFechaBucle;
            rICDDeuda."Menos de 30 := wResDiaHAAD;
            rICDDeuda."Entre 30 y 60 := wResDiaHAJR;
            rICDDeuda."Entre 60 y 90 := wResDiaHANI;
            //if rICDDeuda.INSERT then;
            rICDDeuda.INSERT;
            rICDDeuda.INIT;
            rICDDeuda.Hotel := rUsr."Hotel de trabajo";
            rICDDeuda.Nombre := 'HD';
            rICDDeuda.Cliente := 'ESTXREG';
            rICDDeuda.Fecha := wFechaBucle;
            rICDDeuda."Menos de 30 := wResDiaHDAD;
            rICDDeuda."Entre 30 y 60 := wResDiaHDJR;
            rICDDeuda."Entre 60 y 90 := wResDiaHDNI;
            //if rICDDeuda.INSERT then;
            rICDDeuda.INSERT;
            rICDDeuda.INIT;
            rICDDeuda.Hotel := rUsr."Hotel de trabajo";
            rICDDeuda.Nombre := 'MP';
            rICDDeuda.Cliente := 'ESTXREG';
            rICDDeuda.Fecha := wFechaBucle;
            rICDDeuda."Menos de 30 := wResDiaMPAD;
            rICDDeuda."Entre 30 y 60 := wResDiaMPJR;
            rICDDeuda."Entre 60 y 90 := wResDiaMPNI;
            //if rICDDeuda.INSERT then;
            rICDDeuda.INSERT;
            rICDDeuda.INIT;
            rICDDeuda.Hotel := rUsr."Hotel de trabajo";
            rICDDeuda.Nombre := 'PC';
            rICDDeuda.Cliente := 'ESTXREG';
            rICDDeuda.Fecha := wFechaBucle;
            rICDDeuda."Menos de 30 := wResDiaPCAD;
            rICDDeuda."Entre 30 y 60 := wResDiaPCJR;
            rICDDeuda."Entre 60 y 90 := wResDiaPCNI;
            //if rICDDeuda.INSERT then;
            rICDDeuda.INSERT;
            rICDDeuda.INIT;
            rICDDeuda.Hotel := rUsr."Hotel de trabajo";
            rICDDeuda.Nombre := 'TI';
            rICDDeuda.Cliente := 'ESTXREG';
            rICDDeuda.Fecha := wFechaBucle;
            rICDDeuda."Menos de 30 := wResDiaTIAD;
            rICDDeuda."Entre 30 y 60 := wResDiaTIJR;
            rICDDeuda."Entre 60 y 90 := wResDiaTINI;
            IF rICDDeuda.INSERT THEN BEGIN
                wResDiaHA := 0;
                wResDiaHD := 0;
                wResDiaMP := 0;
                wResDiaPC := 0;
                wResDiaTI := 0;
                wocupDiaHA := 0;
                wocupDiaHD := 0;
                wocupDiaMP := 0;
                wocupDiaPC := 0;
                wocupDiaTI := 0
            END ELSE
                ERRoR('PETo!');
        END;
    end;

    local procedure fProvRellena()
    var
        rProv: Record "23;
        rBank: Record "288;
    begin

        IF rBank.FIND('-') THEN BEGIN
            REPEAT
                rBank."Country/Region Code" := 'ESP';
                rBank."Use For Electronic Payments" := TRUE;
                rBank.MoDIFY(TRUE);
            UNTIL rBank.NEXT = 0
        END;

        IF rProv.FIND('-') THEN BEGIN
            REPEAT
                //rProv.MoDIFY(TRUE);
                rBank.SETRANGE(rBank."Vendor No.", rProv."No.");
                IF rBank.FINDFIRST THEN BEGIN
                    rProv."Preferred Bank Account Code" := rBank.Code;
                    rProv."our Account No." := rBank."CCC No.";
                    rBank."Use For Electronic Payments" := TRUE;
                    rBank.MoDIFY(TRUE);
                    rProv.MoDIFY;
                END;
            UNTIL rProv.NEXT = 0
        END;
    end;

    local procedure fGeneraLineas()
    var
        rCabFac: Record 7000196;
        rLinFac: Record 7000198;
        wSec: Integer;
        rImpFac: Record 7000197;
    begin

        //wSec:=0;
        //rCabFac.SETRANGE(rCabFac.Destino,1);
        //rCabFac.SETRANGE(rCabFac.Factura,'MIE1801371');
        //rCabFac.SETRANGE(rCabFac."Importe neto CoPIA",0);
        IF rCabFac.FIND('-') THEN BEGIN
            REPEAT
                /*
                      rLinFac.SETRANGE(rLinFac.Factura,rCabFac.Factura);
                  IF NoT rLinFac.FINDFIRST THEN BEGIN
                */
                rCabFac.SETFILTER(rCabFac.Factura, '%1|%2', 'CIE1902434', 'CIR2000093');
                //rCabFac.SETFILTER(rCabFac."Fecha factura",'..%1',311219D);
                rCabFac.CALCFIELDS(rCabFac."Importe total CC");
                IF rCabFac."Importe total CC" = 0 THEN BEGIN
                    rImpFac.SETRANGE(rImpFac.Factura, rCabFac.Factura);
                    IF NoT rImpFac.FINDFIRST THEN ERRoR('No hay impuestos para %1', rCabFac.Factura);
                    wSec := wSec + 1000;
                    rLinFac.INIT;
                    rLinFac.Hotel := rCabFac.Hotel;
                    rLinFac.Factura := rCabFac.Factura;
                    rLinFac."Fecha cargo" := rCabFac."Fecha factura";
                    rLinFac.Usuario := 'SISTEMA';
                    rLinFac.Centro := 'ALoJ';
                    rLinFac."Fecha proceso" := rCabFac."Fecha proceso";
                    rLinFac."Secuencia grabacion" := wSec;
                    rLinFac."Ano reserva" := rCabFac.Ano;
                    rLinFac.Reserva := rCabFac.Reserva;
                    rLinFac.Desglose := rCabFac.Desglose;
                    rLinFac.Posicion := rCabFac.Posicion;
                    rLinFac.Cliente := rCabFac.Cliente;
                    rLinFac.TToo := rCabFac.TToo;
                    rLinFac.Agencia := rCabFac.Agencia;
                    rLinFac."Nombre cliente" := rCabFac."Nombre cliente";
                    rLinFac.Concepto := 'Alo';
                    rLinFac.Cantidad := 1;
                    rLinFac."Importe sin sup. ni dtos." := rImpFac."Importe con Impuesto";
                    rLinFac.Importe := rImpFac."Importe con Impuesto";
                    rLinFac."Total importe" := rImpFac."Importe con Impuesto";
                    rLinFac.Destino := 1;
                    rLinFac."Usuario facturando" := 'SISTEMA';
                    rLinFac."Grupo contable negocio" := 'GENERAL';
                    rLinFac."Grupo contable producto" := rImpFac."Grupo contable producto";
                    rLinFac."Formato linea" := 0;
                    rLinFac."Grupo registro Imp. negocio" := 'GENERAL';
                    rLinFac."Grupo registro Imp. producto" := rImpFac."Grupo contable producto";
                    rLinFac."Fecha cargo en facturas" := rCabFac."Fecha factura";
                    rLinFac.Divisa := 'EUR';
                    rLinFac."Importe original" := rImpFac."Importe Neto";
                    rLinFac."Total original" := rImpFac."Importe Neto";
                    rLinFac.Tipo := 0;
                    rLinFac.Cambio := 1;
                    rLinFac."Importe produccion" := rImpFac."Importe Neto";
                    rLinFac."Total importe produccion" := rImpFac."Importe Neto";
                    rLinFac."Total Importe Base/Neto" := rImpFac."Importe Neto";
                    rLinFac."Total cuota Impuestos" := rImpFac."Cuota Impuesto";

                    IF rLinFac.INSERT THEN;
                    //  rCabFac."Importe neto CoPIA":=rImpFac."Importe Neto";
                    //  rCabFac."Importe Impuesto CoPIA":=rImpFac."Cuota Impuesto";
                    //  rCabFac."Importe total CoPIA":=rImpFac."Importe con Impuesto";
                    //  rCabFac.MoDIFY;
                END;
            UNTIL rCabFac.NEXT = 0
        END;

        rLinFac.SETRANGE(rLinFac."Total Importe Base/Neto", 0);
        IF rLinFac.FIND('-') THEN BEGIN
            REPEAT
                rLinFac."Total Importe Base/Neto" := rLinFac."Total importe produccion";
                rLinFac."Total cuota Impuestos" := rLinFac."Total importe" - rLinFac."Total importe produccion";
                rLinFac.MoDIFY;
            UNTIL rLinFac.NEXT = 0
        END;

    end;

    local procedure fConfProd()
    var
        rItem: Record "27;
    begin

        IF rItem.FIND('-') THEN BEGIN
            REPEAT
                //rItem."VAT Bus. Posting Gr. (Price)":='GENERAL';
                //IF rItem."VAT Prod. Posting Group"='.10' THEN rItem."VAT Prod. Posting Group":='10';
                rItem.MoDIFY(TRUE)
            UNTIL rItem.NEXT = 0
        END;
    end;

    local procedure f02Tabla()
    var
        rVendor: Record "23;
    begin

        rVendor.SETRANGE(rVendor."Country/Region Code", 'ESP');
        IF rVendor.FIND('-') THEN BEGIN
            REPEAT
                rVendor."Country/Region Code" := 'ESP';
                rVendor."VAT Reg No. Type" := '';
                rVendor."Purch Special Regimen" := '01';
                rVendor.MoDIFY;
            UNTIL rVendor.NEXT = 0
        END;
    end;

    local procedure fRenameTabla()
    var
        rTabla: Record 7012;
        rCompany: Record "2000000006;
    begin
        //rTabla.SETCURRENTKEY(rTabla."Item No.",rTabla."Vendor No.",rTabla."Starting Date",rTabla."Currency Code",rTabla."Variant Code",rTabla."Cod. Zona",rTabla."Unit of Measure Code",rTabla."Minimum Quantity");
        //Item No.,Vendor No.,Starting Date,Currency Code,Variant Code,Cod. Zona,Unit of Measure Code,Minimum Quantity
        /*
        rCompany.SETFILTER(rCompany.Name,'<>%1','LoS MoLINoS DE IBIZA, S.A.');
        IF rCompany.FIND('-') THEN BEGIN
          REPEAT
          rTabla.CHANGECoMPANY(rCompany.Name);
        */

        //rTabla.SETRANGE(rTabla."Cod. Zona",'MALLoRCA');
        rTabla.SETFILTER(rTabla."Vendor No.", 'A001306');
        IF rTabla.FIND('-') THEN BEGIN
            REPEAT
                rTabla.RENAME(rTabla."Item No.", rTabla."Vendor No.", rTabla."Starting Date", rTabla."Currency Code", rTabla."Variant Code", 'MALLoRCA', rTabla."Unit of Measure Code", rTabla."Minimum Quantity");
                IF rTabla.FINDFIRST THEN;
            UNTIL rTabla.NEXT = 0;
        END;
        /*
          UNTIL rCompany.NEXT=0;
        END;
        */

    end;

    local procedure fRellenaTabla()
    var
        rTabla: Record 7012;
    begin

        IF rTabla.FIND('-') THEN BEGIN
            REPEAT
                /*
                  IF rTabla."Cod. Zona"='BALEARES' THEN rTabla."Tipo Agrupacion":=3
                  ELSE rTabla."Tipo Agrupacion":=4;
                */
                IF rTabla.MoDIFY(TRUE) THEN;
            UNTIL rTabla.NEXT = 0
        END;

    end;

    local procedure fVaciaTabla()
    var
        rCompany: Record "2000000006;
        rTabla: Record 7012;
    begin
        rCompany.SETFILTER(rCompany.Name, '<>%1', 'LoS MoLINoS DE IBIZA, S.A.');
        IF rCompany.FIND('-') THEN BEGIN
            REPEAT
                rTabla.CHANGECoMPANY(rCompany.Name);
                MESSAGE('ESToY EN %1', rCompany.Name);
                IF rTabla.FIND('-') THEN BEGIN
                    REPEAT
                        rTabla.DELETE;
                    UNTIL rTabla.NEXT = 0
                END;

            UNTIL rCompany.NEXT = 0;
        END;

        CoMMIT;
    end;

    local procedure fLimpiaVariante()
    var
        rItemPrice: Record 7012;
    begin
        rItemPrice.SETRANGE(rItemPrice."Variant Code", '<>%1', '');
        IF rItemPrice.FIND('-') THEN BEGIN
            REPEAT
                //rItemPrice."Variant Code":='';
                rItemPrice.RENAME(rItemPrice."Vendor No.", rItemPrice."Item No.", '', rItemPrice."Cod. Zona");
                rItemPrice.MoDIFY;
                IF rItemPrice.FIND('-') THEN;
            UNTIL rItemPrice.NEXT = 0
        END;
    end;

    local procedure fRellenaCliMovCli()
    var
        rMovCli: Record "21;
    begin
        rMovCli.SETRANGE(rMovCli."Customer No.", '');
        IF rMovCli.FIND('-') THEN BEGIN
            REPEAT
                rMovCli."Customer No." := rMovCli."Sell-to Customer No.";
                rMovCli.MoDIFY;
            UNTIL rMovCli.NEXT = 0
        END;
    end;

    local procedure fLimpiaPreDupli()
    var
        rPreCompra: Record 7012;
        rPreCompraBIS: Record 7012;
        wCuenta: Integer;
    begin

        IF rPreCompra.FIND('-') THEN BEGIN
            REPEAT
                rPreCompraBIS.SETRANGE(rPreCompraBIS."Item No.", rPreCompra."Item No.");
                rPreCompraBIS.SETRANGE(rPreCompraBIS."Vendor No.", rPreCompra."Vendor No.");
                rPreCompraBIS.SETRANGE(rPreCompraBIS."Starting Date", rPreCompra."Starting Date");
                wCuenta := 0;
                IF rPreCompraBIS.FIND('-') THEN BEGIN
                    REPEAT
                        wCuenta := wCuenta + 1;
                        IF wCuenta <> 1 THEN rPreCompraBIS.DELETE(TRUE);
                        //   ERRoR('yo habria borrado %1 - %2 - %3',rPreCompra."Item No.",rPreCompra."Vendor No.",rPreCompra."Starting Date");


                    UNTIL rPreCompraBIS.NEXT = 0
                END;
            UNTIL rPreCompra.NEXT = 0
        END;
    end;

    local procedure fExistenciaItem()
    var
        rItem: Record "27;
    begin
        IF rItem.FIND('-') THEN BEGIN
            REPEAT
                rItem."Inventory Posting Group" := 'EXISTENCIA';
                rItem.MoDIFY(TRUE)
            UNTIL rItem.NEXT = 0
        END;
    end;

    local procedure fActualizaItemUnit()
    var
        rItemUnit: Record "5404;
    begin
        IF rItemUnit.FIND('-') THEN BEGIN
            REPEAT
                rItemUnit.MoDIFY(TRUE);
            UNTIL rItemUnit.NEXT = 0
        END;
    end;

    local procedure fPreciosZona()
    var
        rPreComp: Record 7012;
    begin
        /*
        IF rPreComp.FIND('-') THEN BEGIN
          REPEAT
          rPreComp.DELETE;
        //IF rPreComp.MoDIFY(TRUE) THEN;
          UNTIL rPreComp.NEXT=0
        END;
        */
        //MoDIFICAR
        rPreComp.SETRANGE(rPreComp."Cod. Zona", '');
        IF rPreComp.FIND('-') THEN BEGIN
            REPEAT
                rPreComp.RENAME(rPreComp."Item No.", rPreComp."Vendor No.", rPreComp."Starting Date", rPreComp."Currency Code", rPreComp."Variant Code", 'CANARIAS', rPreComp."Unit of Measure Code", rPreComp."Minimum Quantity");
                IF rPreComp.FIND('-') THEN;
            UNTIL rPreComp.NEXT = 0
        END;

    end;

    local procedure fActualizaRes()
    var
        rocu: Record 7000178;
        rRes: Record 7000176;
    begin
        //rRes.SETRANGE(rRes.Reserva,'3928');
        //rRes.SETRANGE(rRes."Estado reserva",0);
        IF rRes.FIND('-') THEN BEGIN
            REPEAT
                /*
                   rocu.SETRANGE(rocu.Hotel,rRes.Hotel);
                   rocu.SETRANGE(rocu.Ano,rRes.Ano);
                   rocu.SETRANGE(rocu.Reserva,rRes.Reserva);
                   rocu.SETRANGE(rocu.Desglose,rRes.Desglose);
                   rocu.SETRANGE(rocu.Posicion,1);
                   IF rocu.FINDFIRST THEN BEGIN
                     rRes."Apellido 1er. ocupante":=rocu."Apellido 1;
                // rRes."Regimen uso":=rRes."Regimen factura";
                // rRes.Desglosada:=TRUE;
                  //rRes."Usuario venta":='THBASPCEN\SGB';
                */
                rRes.Precio := 1;
                /*
                  IF rRes.Noches=0 THEN BEGIN
                  rRes.Noches:=rRes."Fecha salida"-rRes."Fecha entrada";
                */
                /*
                    rRes.MoDIFY(TRUE);
                  END;
                */
                //  rRes."Canal/origen":='THB';
                rRes.MoDIFY;
            UNTIL rRes.NEXT = 0
        END;

    end;

    local procedure fCleanItemUnit()
    var
        rItemUnit: Record "5404;
        rItem: Record "27;
    begin
        IF rItemUnit.FIND('-') THEN BEGIN
            REPEAT
                rItem.SETRANGE(rItem."No.", rItemUnit."Item No.");
                IF NoT rItem.FIND('-') THEN rItemUnit.DELETE;
            UNTIL rItemUnit.NEXT = 0
        END;
    end;

    local procedure fBorraConta()
    var
        rMovConta: Record "17;
    begin
        //rMovConta.SETFILTER(rMovConta."Posting Date",'%1..%2',010116D,311216D);
        IF rMovConta.FIND('-') THEN BEGIN
            REPEAT
                rMovConta.DELETE;
            UNTIL rMovConta.NEXT = 0
        END;
    end;

    local procedure focupBorra()
    var
        rocupDes: Record 7000474;
    begin
        rocupDes.SETFILTER(rocupDes.Fecha, '..%1', 081219D);
        //rocupDes.SETRANGE(rocupDes.Fecha,081219D);
        IF rocupDes.FIND('-') THEN BEGIN
            REPEAT
                rocupDes.DELETE;
            UNTIL rocupDes.NEXT = 0
        END;
    end;

    
    procedure fCoste0()
    var
        wProd: Integer;
        wValorTot: Decimal;
        wNum: Integer;
        rMovValor: Record "5802;
        rProdAlm: Record 7000523;
    begin
        wProd := 0;
        IF rMovValor.FIND('+') THEN wNum := rMovValor."Entry No.";

        rUsr.GET(USERID);
        rProdAlm.SETRANGE(rProdAlm."Cod. Hotel", rUsr."Hotel de trabajo");
        //rProdAlm.SETRANGE(rProdAlm."Cod. Almacen",'BAR');
        //rProdAlm.SETRANGE(rProdAlm.Producto,'');
        IF rProdAlm.FIND('-') THEN BEGIN
            REPEAT
                //wNum:=wNum+1;
                rProdAlm.CALCFIELDS(rProdAlm."Stock Actual", rProdAlm."Importe Coste");
                IF (rProdAlm."Stock Actual" = 0) AND (rProdAlm."Importe Coste" <> 0) THEN BEGIN
                    rMovValor.INIT;
                    rMovValor."Item No." := rProdAlm.Producto;
                    rMovValor."Entry No." := wNum + 1;
                    rMovValor."Posting Date" := 310318D;
                    rMovValor."Document No." := 'AUToREGUL';
                    IF rProdAlm."Importe Coste" > 0 THEN
                        rMovValor."Item Ledger Entry Type" := 3
                    ELSE
                        rMovValor."Item Ledger Entry Type" := 2;
                    rMovValor."Source No." := rProdAlm."Cod. Almacen";
                    rMovValor.Description := 'AUToREGUL';
                    rMovValor."Inventory Posting Group" := 'EXISTENCIA';
                    rMovValor."Cost Amount (Actual)" := rProdAlm."Importe Coste" * -1;
                    rMovValor."Journal Batch Name" := 'EXTRACIoN';
                    rMovValor."Gen. Bus. Posting Group" := 'GENERAL';
                    rMovValor.Inventoriable := TRUE;
                    rMovValor."Location Code" := rProdAlm."Cod. Almacen";
                    rMovValor."Cod. Hotel" := rProdAlm."Cod. Hotel";
                    rMovValor."Valuation Date" := 310318D;
                    rMovValor."Entry Type" := 0;
                    rMovValor."Valorable inventario" := TRUE;
                    rMovValor.Subtipo := 8;
                    wValorTot := wValorTot + (rProdAlm."Importe Coste" * -1);
                    wProd := wProd + 1;
                    IF rMovValor.INSERT THEN wNum := wNum + 1;
                END;
            UNTIL rProdAlm.NEXT = 0
        END;
        MESSAGE('Se van a meter %1 lineas con un total de %2 euros', wProd, wValorTot);
    end;

    
    procedure fRevisaCobros(wFactura: Code[20])
    var
        rCab: Record 7000196;
        rCobDet: Record 7000681;
    begin
        /*
        rCab.SETRANGE(rCab.Factura,wFactura);
        IF rCab.FIND('-') THEN BEGIN
          rCab.CALCFIELDS(rCab."CC Importe cobrado registrado");
          IF rCab."CC Importe cobrado registrado"=rCab."Importe total" THEN BEGIN
            rCab."Importe pendiente cobro(LoCAL)":=0;
            rCab."Importe pendiente de cobro":=0;
            rCab."Importe cobrado":=rCab."CC Importe cobrado registrado";
            rCab."Importe cobrado(LoCAL)":=rCab."CC Importe cobrado registrado";
            rCab.Cobrada:=TRUE;
            rCab.MoDIFY;
          END ELSE BEGIN
            rCab."Importe pendiente cobro(LoCAL)":=rCab."Importe total"-rCab."CC Importe cobrado registrado";
            rCab."Importe pendiente de cobro":=rCab."Importe total"-rCab."CC Importe cobrado registrado";
            rCab."Importe cobrado":=rCab."CC Importe cobrado registrado";
            rCab."Importe cobrado(LoCAL)":=rCab."CC Importe cobrado registrado";
            rCab.MoDIFY;
          END;
        END;
        */

    end;

    
    procedure fPostReplicaConta()
    var
        rCab: Record 7000196;
        wCabeceras: Integer;
        rAlb: Record "120;
        wAlbaranes: Integer;
    begin
        /*
        //MARCAR CoNTABILIZADAS ToDAS LAS CABECERAS DE FACTURA
        
        Ventana.oPEN('Marcando como contabilizada la factura #1#############, marcadas #2#####', rCab.Factura,wCabeceras);
        rCab.SETRANGE(rCab.Contabilizada,FALSE);
        IF rCab.FIND('-') THEN BEGIN
          REPEAT
          rCab.Contabilizada:=TRUE;
          rCab.MoDIFY;
          Ventana.UPDATE;
          wCabeceras:=wCabeceras+1;
          UNTIL rCab.NEXT=0
        END;
        */
        /*
        //MARCAR CoNTABILIZADoS EN 120
        
        Ventana.oPEN('Marcando como contabilizada albaran #1#############, marcados #2#####', rAlb."No.",wAlbaranes);
        rAlb.SETRANGE(rAlb.Contabilizado,FALSE);
        IF rAlb.FIND('-') THEN BEGIN
          REPEAT
          wAlbaranes:=wAlbaranes+1;
          rAlb.Contabilizado:=TRUE;
          rAlb.MoDIFY;
          Ventana.UPDATE;
          UNTIL rAlb.NEXT=0
        END;
        
        MESSAGE('Se han marcado %1 albaranes como Contabilizados',wAlbaranes);
        //MARCAR CoMo FACTURADAS ToDoS LoS ALBARANES
        */
        wAlbaranes := 0;

        Ventana.oPEN('Marcando como contabilizada albaran #1#############, marcados #2#####', rAlb."No.", wAlbaranes);
        rAlb.RESET;
        rAlb.SETRANGE(rAlb.Facturado, FALSE);
        rAlb.SETFILTER(rAlb."Posting Date", '..%1', 311215D);
        IF rAlb.FIND('-') THEN BEGIN
            REPEAT
                wAlbaranes := wAlbaranes + 1;
                rAlb.Facturado := TRUE;
                rAlb.MoDIFY;
                Ventana.UPDATE;
            UNTIL rAlb.NEXT = 0
        END;

        MESSAGE('Se han marcado %1 albaranes como facturados', wAlbaranes);

    end;

    
    procedure fCtrlAnticipo(Reservas: Record 7000176)
    var
        rReservas: Record 7000176;
        rAnticipos: Record 7000229;
    begin

        rAnticipos.SETRANGE(rAnticipos.Hotel, Reservas.Hotel);
        rAnticipos.SETRANGE(rAnticipos."Hotel Rva", Reservas.Hotel);
        rAnticipos.SETRANGE(rAnticipos."Ano Rva", Reservas.Ano);
        rAnticipos.SETRANGE(rAnticipos."Num. Rva.", Reservas.Reserva);
        rAnticipos.SETRANGE(rAnticipos."Desglose Rva.", Reservas.Desglose);
        IF NoT rAnticipos.FIND('-') THEN ERRoR('No se pueden introducir anticipos en reservas ya entradas o con fecha de entrada de hoy.');
    end;

    
    procedure fTToovsSegmento()
    var
        wNoSegmento: Integer;
        rTToo: Record 7000119;
        rSegmentos: Record 7001017;
    begin
        Ventana.oPEN('Revisando TToo #1#########, se han encontrado #2###### segmentos que no existen', rTToo.Codigo, wNoSegmento);
        IF rTToo.FIND('-') THEN BEGIN
            REPEAT
                rSegmentos.RESET;
                rSegmentos.SETRANGE(rSegmentos.Segmento, rTToo.Segmento);
                IF NoT rSegmentos.FIND('-') THEN wNoSegmento := wNoSegmento + 1;
                Ventana.UPDATE;
            UNTIL rTToo.NEXT = 0
        END;

        MESSAGE('Se han encontrado %1 TToos que tienen segmentos que no existen', wNoSegmento);
    end;

    
    procedure focuCardex()
    var
        wCardex: Integer;
        wVisitas: Integer;
        rocu: Record 7000178;
        rCardex: Record 7000179;
        rVisitas: Record 7000180;
    begin

        Ventana.oPEN('Nuevos Cardexs #1########  Nuevas Visitas #2#######', wCardex, wVisitas);
        rocu.SETRANGE(rocu."Check In", TRUE);
        IF rocu.FIND('-') THEN BEGIN
            REPEAT
                IF rocu."E-mail" <> '' THEN BEGIN
                    rCardex.INIT;
                    rCardex."Pais residencia" := rocu."Pais residencia";
                    rCardex.Documento := rocu.Documento;
                    rCardex."Nombre / Razon Social" := rocu.Nombre;
                    rCardex."Apellido 1 := rocu."Apellido 1;
                    rCardex."Apellido 2 := rocu."Apellido 2;
                    rCardex."Fecha nacimiento" := rocu."Fecha nacimiento";
                    rCardex.Sexo := rocu.Sexo;
                    rCardex.Direccion := rocu.Direccion;
                    rCardex."Cod. Postal" := rocu."Cod. postal";
                    rCardex."Poblacion residencia" := rocu."Poblacion residencia";
                    rCardex."Provincia residencia" := rocu."Provincia residencia";
                    rCardex."E-mail" := rocu."E-mail";
                    IF rCardex.INSERT THEN wCardex := wCardex + 1;
                    rVisitas.INIT;
                    rVisitas.Pais := rocu."Pais residencia";
                    rVisitas.Documento := rocu.Documento;
                    rVisitas.Hotel := rocu.Hotel;
                    rVisitas.Ano := rocu.Ano;
                    rVisitas.Reserva := rocu.Reserva;
                    rVisitas.Desglose := rocu.Desglose;
                    rVisitas."Fecha entrada" := rocu."Fecha entrada";
                    rVisitas."Fecha salida" := rocu."Fecha salida";
                    rVisitas.TToo := rocu.TToo;
                    rVisitas.Agencia := rocu.Agencia;
                    IF rVisitas.INSERT THEN wVisitas := wVisitas + 1;
                    Ventana.UPDATE;
                END;
            UNTIL rocu.NEXT = 0
        END;

        MESSAGE('Se han anadido %1 registros de Cardex y %2 Visitas', wCardex, wVisitas);
    end;

    
    procedure fMovValorVSProdxAlm()
    var
        wCount: Integer;
        r5802: Record "5802;
        r27: Record "27;
        rProdxAlm: Record 7000523;
    begin
        rUsr.GET(USERID);
        IF CoNFIRM('¿Quiere revisar los Productos x Almacen del hotel?, esto puede ayudar a que el Cuadrante de Economato y ' +
                   'el Inventario x Almacen cuadren a la perfeccion.') THEN BEGIN
            Ventana.oPEN('Se estan revisando los Productos por Almacen, por favor espere.....');
            IF r5802.FIND('-') THEN BEGIN
                REPEAT
                    rProdxAlm.SETRANGE(rProdxAlm."Cod. Almacen", r5802."Location Code");
                    rProdxAlm.SETRANGE(rProdxAlm.Producto, r5802."Item No.");
                    IF NoT rProdxAlm.FIND('-') THEN BEGIN
                        rProdxAlm.INIT;
                        rProdxAlm."Cod. Hotel" := rUsr."Hotel de trabajo";
                        rProdxAlm."Cod. Almacen" := r5802."Location Code";
                        rProdxAlm.Producto := r5802."Item No.";
                        rProdxAlm."Cod. Grupo Familia" := r5802."Gen. Bus. Posting Group";
                        rProdxAlm."Cod. Familia" := r5802."Gen. Prod. Posting Group";
                        rProdxAlm."Cod. Subfamilia" := r5802."Gen. Prod. Posting Group";
                        IF rProdxAlm.INSERT THEN wCount := wCount + 1
                    END;

                UNTIL r5802.NEXT = 0;
                Ventana.CLoSE;
                IF wCount <> 0 THEN
                    MESSAGE('Se han anadido %1 registros', wCount)
                ELSE
                    MESSAGE('No se han anadido registros');

            END;
        END ELSE
            MESSAGE('Proceso cancelado');
    end;

    
    procedure fRecocupMails()
    var
        rocup: Record 7000178;
        rCardex: Record 7000179;
        wocup: Integer;
        wCardex: Integer;
        wFechaIni: Date;
        wFechaFin: Date;
    begin
        Ventana.oPEN('Introduzca las fechas deseadas para el recuento \' +
                      'Fecha de Inicio #1######### \' + 'Fecha Final #2#########');
        Ventana.INPUT(1, wFechaIni);
        Ventana.INPUT(2, wFechaFin);

        Ventana.oPEN('Progreso  ocupantes #1########  Direcciones de E-mail #2#######', wocup, wCardex);

        rocup.SETRANGE(rocup."Fecha entrada", wFechaIni, wFechaFin);
        rocup.SETRANGE(rocup."Check In", TRUE);
        IF rocup.FIND('-') THEN BEGIN
            REPEAT
                wocup := wocup + 1;
                Ventana.UPDATE;
            UNTIL rocup.NEXT = 0
        END;

        rCardex.SETFILTER(rCardex."E-mail", '<>%1', '');
        IF rCardex.FIND('-') THEN BEGIN
            REPEAT
                wCardex := wCardex + 1;
                Ventana.UPDATE;
            UNTIL rCardex.NEXT = 0
        END;
        Ventana.CLoSE;
        MESSAGE('Hay %1 ocupantes y %2 direcciones de e-mail', wocup, wCardex);
    end;

    
    procedure "fApanoCardexDiario"()
    var
        r120: Record "120;
        wVisitas: Integer;
        wCount: Integer;
        rCardex: Record 7000179;
        rocupantes: Record 7000178;
        rVisitas: Record 7000180;
        rPais: Record "9;
    begin
        /*
        r120.SETFILTER(r120."Posting Date",'%1..',010405D);
        IF r120.FIND('-') THEN BEGIN
          REPEAT
          r120.Replicado:=FALSE;
          r120.MoDIFY;
          UNTIL r120.NEXT=0
        END;
        */

        rCardex.RESET;
        rCardex.SETRANGE(rCardex.Documento, '');
        Ventana.oPEN('Se estan analizando los registros de Cardex sin Nº Documento....');
        IF rCardex.FIND('-') THEN BEGIN
            REPEAT
                rCardex.DELETE;
                //  wCardexNoPais:=wCardexNoPais+1
            UNTIL rCardex.NEXT = 0
        END;

        rCardex.RESET;
        rCardex.SETRANGE(rCardex."Pais residencia", '');
        Ventana.oPEN('Se estan analizando los registros de Cardex sin Pais....');
        IF rCardex.FIND('-') THEN BEGIN
            REPEAT
                rCardex.DELETE;
            UNTIL rCardex.NEXT = 0
        END;

        rVisitas.RESET;
        rVisitas.SETRANGE(rVisitas.Pais, '');
        Ventana.oPEN('Se estan borrando las visitas sin codigo de Pais....');
        IF rVisitas.FIND('-') THEN BEGIN
            REPEAT
                rVisitas.DELETE;
            UNTIL rVisitas.NEXT = 0
        END;

        rVisitas.RESET;
        rVisitas.SETRANGE(rVisitas.Documento, '');
        Ventana.oPEN('Se estan borrando las visitas sin Nº Documento....');
        IF rVisitas.FIND('-') THEN BEGIN
            REPEAT
                rVisitas.DELETE;
            UNTIL rVisitas.NEXT = 0
        END;


        /*
        rCardex.RESET;
        Ventana.oPEN('Se estan analizando los registros de Cardex sin Pais....');
        IF rCardex.FIND('-') THEN BEGIN
          REPEAT
          rPais.SETRANGE(rPais.Code,rCardex."Pais residencia");
          IF NoT rPais.FIND('-') THEN BEGIN
            rCardex.DELETE;
        //  wCardexNoPais:=wCardexNoPais+1
          END;
          UNTIL rCardex.NEXT=0
        END;
        
        
        Ventana.CLoSE;
        
        rCardex.RESET;
        rVisitas.RESET;
        Ventana.oPEN('Se estan analizando los registros de Visitas sin Contactos....');
        IF rVisitas.FIND('-') THEN BEGIN
          REPEAT
          rCardex.SETRANGE(rCardex."Pais residencia",rVisitas.Pais);
          rCardex.SETRANGE(rCardex.Documento,rVisitas.Documento);
          IF NoT rCardex.FIND('-') THEN BEGIN
            rVisitas.DELETE;
        //  wVisitasNoCardex:=wVisitasNoCardex+1
          END;
          UNTIL rVisitas.NEXT=0
        END;
        
        Ventana.CLoSE;
        */

        rocupantes.RESET;
        rocupantes.SETRANGE(rocupantes."Pais residencia", 'ES');
        IF rocupantes.FIND('-') THEN BEGIN
            REPEAT
                rocupantes."Pais residencia" := 'ESP';
                rocupantes."Pais nacimiento" := 'ESP';
                rocupantes.Nacionalidad := 'ESP';
                rocupantes.MoDIFY;
            UNTIL rocupantes.NEXT = 0
        END;

        CoMMIT;

        rocupantes.RESET;

        rUsr.GET(USERID);
        rocupantes.SETRANGE(rocupantes."Check In", TRUE);
        rocupantes.SETRANGE(rocupantes."Fecha entrada", WoRKDATE);
        rocupantes.SETFILTER(rocupantes."E-mail", '<>%1', '');
        IF rocupantes.FIND('-') THEN BEGIN
            REPEAT
                rCardex.INIT;
                rCardex."Pais residencia" := rocupantes."Pais residencia";
                rCardex.Documento := rocupantes.Documento;
                rCardex."Nombre / Razon Social" := rocupantes.Nombre;
                rCardex."Apellido 1 := rocupantes."Apellido 1;
                rCardex."Fecha nacimiento" := rocupantes."Fecha nacimiento";
                rCardex.Sexo := rocupantes.Sexo;
                rCardex."E-mail" := rocupantes."E-mail";
                IF rCardex.INSERT THEN;
                rVisitas.INIT;
                rVisitas.Pais := rocupantes."Pais residencia";
                rVisitas.Documento := rocupantes.Documento;
                rVisitas.Hotel := rocupantes.Hotel;
                rVisitas.Ano := rocupantes.Ano;
                rVisitas.Reserva := rocupantes.Reserva;
                rVisitas.Desglose := rocupantes.Desglose;
                rVisitas."Fecha entrada" := rocupantes."Fecha entrada";
                rVisitas."Fecha salida" := rocupantes."Fecha salida";
                rVisitas.TToo := rocupantes.TToo;
                rVisitas.Agencia := rocupantes.Agencia;
                rVisitas.Cliente := rocupantes.TToo;
                IF rVisitas.INSERT THEN;
            UNTIL rocupantes.NEXT = 0
        END;

    end;

    
    procedure "fApanoCardex"()
    var
        wVisitas: Integer;
        wCount: Integer;
        rCardex: Record 7000179;
        rocupantes: Record 7000178;
        rVisitas: Record 7000180;
    begin
        Ventana.oPEN('LLEVAMoS IMPoRTADoS #1###### Contactos y #2#######', wCount, wVisitas);
        rUsr.GET(USERID);
        rocupantes.SETFILTER(rocupantes."E-mail", '<>%1', '');
        IF rocupantes.FIND('-') THEN BEGIN
            REPEAT
                rCardex.INIT;
                rCardex."Pais residencia" := rocupantes."Pais residencia";
                rCardex.Documento := rocupantes.Documento;
                rCardex."Nombre / Razon Social" := rocupantes.Nombre;
                rCardex."Apellido 1 := rocupantes."Apellido 1;
                rCardex."Fecha nacimiento" := rocupantes."Fecha nacimiento";
                rCardex.Sexo := rocupantes.Sexo;
                rCardex."E-mail" := rocupantes."E-mail";
                IF rCardex.INSERT THEN BEGIN
                    Ventana.UPDATE;
                    wCount := wCount + 1
                END;
                rVisitas.INIT;
                rVisitas.Pais := rocupantes."Pais residencia";
                rVisitas.Documento := rocupantes.Documento;
                rVisitas.Hotel := rocupantes.Hotel;
                rVisitas.Ano := rocupantes.Ano;
                rVisitas.Reserva := rocupantes.Reserva;
                rVisitas.Desglose := rocupantes.Desglose;
                rVisitas."Fecha entrada" := rocupantes."Fecha entrada";
                rVisitas."Fecha salida" := rocupantes."Fecha salida";
                rVisitas.TToo := rocupantes.TToo;
                rVisitas.Agencia := rocupantes.Agencia;
                rVisitas.Cliente := rocupantes.TToo;
                IF rVisitas.INSERT THEN BEGIN
                    Ventana.UPDATE;
                    wVisitas := wVisitas + 1
                END;
            UNTIL rocupantes.NEXT = 0
        END;
        MESSAGE('Hemos importado %1 contactos y %2', wCount, wVisitas);
    end;

    
    procedure foaci()
    var
        rPais: Record "9;
    begin
        IF rPais.FIND('-') THEN BEGIN
            REPEAT
                IF rPais."Codigo oACI" = '' THEN rPais."Codigo oACI" := rPais.Code;
                rPais.MoDIFY;
            UNTIL rPais.NEXT = 0;
        END;
    end;

    
    procedure fTPV()
    var
        rGruxTPV: Record 7000733;
        rPrecios: Record 7000737;
        wGrupo: Code[10];
        wCriterio: Code[3];
        rMaster: Record 7000755;
        rArt: Record 7000728;
        wReg: Integer;
        rGrupos: Record 7000727;
        rArtxGrupo: Record 7000736;
        worden: Integer;
        wTPV: Code[10];
    begin
        rUsr.GET(USERID);

        //PASAR ARTiCULoS DE MASTER ARTiCULoS A ARTiCULoS
        /*
        Ventana.oPEN('Revisando articulo #1########## con descripcion #2######################## \' +
                     'Registros insertados hasta el momento #3##### ',rMaster.Articulo,rMaster.Descripcion,wReg);
        IF rMaster.FIND('-') THEN BEGIN
          REPEAT
          Ventana.UPDATE;
          rArt.SETRANGE(rArt.Articulo,rMaster.Articulo);
          IF NoT rArt.FIND('-') THEN BEGIN
            rArt.INIT;
            rArt.Hotel:=rUsr."Hotel de trabajo";
            rArt.Articulo:=rMaster.Articulo;
            rArt.Descripcion:=rMaster.Descripcion;
            rArt.INSERT;
            wReg:=wReg+1;
          END;
          UNTIL rMaster.NEXT=0;
        END;
        MESSAGE('Se han insertado un total de %1 articulos',wReg);
        
        
        //CREAR ARTiCULoS X GRUPo TENIENDo EN CUENTA LAS INICIALES USAR SoLo EN BD LIMPIAS!! o SE LIA PARDA.
        
        
        Ventana.oPEN('Introduce datos \' +
                      'Grupo de Articulos #1######### \' + 'Criterio de busqueda #2#########');
        
        Ventana.INPUT(1,wGrupo);
        Ventana.INPUT(2,wCriterio);
        
          Ventana.oPEN('Creando grupo %1 , CRITERIo DE BuSQUEDA %2 , ARTiCULo %3 \' +
                       'CoN DESCRIPCIoN %4',wGrupo,wCriterio,rArt.Articulo,rArt.Descripcion);
          rArt.SETRANGE(rArt.Hotel,rUsr."Hotel de trabajo");
          rArt.SETFILTER(rArt.Articulo,'%1',FoRMAT(wCriterio+'*'));
          IF rArt.FIND('-') THEN BEGIN
          REPEAT
          worden:=worden+1;
          rArtxGrupo.INIT;
          rArtxGrupo.Hotel:=rUsr."Hotel de trabajo";
          rArtxGrupo.Grupo:=wGrupo;
          rArtxGrupo.Articulo:=rArt.Articulo;
          rArtxGrupo.orden:=worden;
          IF rArtxGrupo.INSERT THEN;
          Ventana.UPDATE;
          UNTIL rArt.NEXT=0;
        END;
        
        */
        //CREACIoN DE LAS LINEAS DE PRECIoS EN FUNCIoN A LoS GRUPoS DE ARTiCULoS QUE TENGA EL TPV

        Ventana.oPEN('Introduce el TPV para el que quieres crear los precios a 0 #1#########', wTPV);
        Ventana.INPUT(1, wTPV);
        rGruxTPV.SETRANGE(rGruxTPV.TPV, wTPV);
        IF rGruxTPV.FIND('-') THEN BEGIN
            REPEAT
                rArtxGrupo.SETRANGE(rArtxGrupo.Hotel, rUsr."Hotel de trabajo");
                rArtxGrupo.SETRANGE(rArtxGrupo.Grupo, rGruxTPV.Grupo);
                IF rArtxGrupo.FIND('-') THEN BEGIN
                    REPEAT
                        rArt.SETRANGE(rArt.Articulo, rArtxGrupo.Articulo);
                        IF rArt.FIND('-') THEN;
                        rPrecios.INIT;
                        rPrecios.Hotel := rUsr."Hotel de trabajo";
                        rPrecios.TPV := rGruxTPV.TPV;
                        rPrecios.Grupo := rGruxTPV.Grupo;
                        rPrecios.Articulo := rArtxGrupo.Articulo;
                        rPrecios."Fecha inicial" := 010107D;
                        rPrecios."Hora inicial" := 000000T;
                        rPrecios."Fecha final" := 311230D;
                        rPrecios."Hora final" := 000000T;
                        rPrecios."Descripcion Articulo" := rArt.Descripcion;
                        IF rPrecios.INSERT THEN;
                    UNTIL rArtxGrupo.NEXT = 0;
                END;
            UNTIL rGruxTPV.NEXT = 0;
        END;

    end;

    
    procedure fLimpiaResDia()
    var
        rRxD: Record 7000186;
        rRes: Record 7000176;
    begin
        Ventana.oPEN('Revisando Ano #1### Reserva #2### Desglose #3#', rRxD.Ano, rRxD.Reserva, rRxD.Desglose);
        IF rRxD.FIND('-') THEN BEGIN
            REPEAT
                rRes.RESET;
                rRes.SETRANGE(rRes.Hotel, rRxD.Hotel);
                rRes.SETRANGE(rRes.Ano, rRxD.Ano);
                rRes.SETRANGE(rRes.Reserva, rRxD.Reserva);
                rRes.SETRANGE(rRes.Desglose, rRxD.Desglose);
                IF NoT rRes.FIND('-') THEN rRxD.DELETE;
                Ventana.UPDATE;
            UNTIL rRxD.NEXT = 0;
        END;
    end;

    
    procedure fHab() wTotHabHotel: Integer
    var
        rTipHab: Record 7000115;
    begin
        rUsr.GET(USERID);
        rTipHab.SETRANGE(rTipHab.Hotel, rUsr."Hotel de trabajo");
        rTipHab.SETRANGE(rTipHab.Real, TRUE);
        IF rTipHab.FIND('-') THEN BEGIN
            REPEAT
                wTotHabHotel := rTipHab.Cantidad + wTotHabHotel;
            UNTIL rTipHab.NEXT = 0;
        END;
    end;

    
    

    
    procedure fFactElec()
    var
        rCli: Record "18;
        rCab: Record 7000196;
        wAct: Integer;
    begin
        Ventana.oPEN('Comprobando Cliente #1########\' + 'Factura #2#########\' + 'Fecha #3#######\' +
                     'Facturas activadas #4#######', rCli."No.", rCab.Factura, rCab."Fecha factura", wAct);
        rCli.SETRANGE(rCli."Permitir Fact. Electronica", TRUE);
        rCli.SETRANGE(rCli."Proveedor FE", 'VoXEL');
        IF rCli.FIND('-') THEN BEGIN
            REPEAT
                rCab.SETRANGE(rCab.Cliente, rCli."No.");
                rCab.SETFILTER(rCab."Importe pendiente de cobro", '<>%1', 0);
                rCab.SETRANGE(rCab."Nº Remesa Fact. Electronica", 0);
                rCab.SETFILTER(rCab."Fecha factura", '>%1', 310711D);
                rCab.SETRANGE(rCab."Fact. Electronica Activada", FALSE);
                IF rCab.FIND('-') THEN BEGIN
                    REPEAT
                        rCab."Fact. Electronica Activada" := TRUE;
                        Ventana.UPDATE;
                        wAct := wAct + 1;
                        rCab.MoDIFY;
                        //  rCab.FIND('-');
                    UNTIL rCab.NEXT = 0;
                END;
            UNTIL rCli.NEXT = 0;
        END;
        MESSAGE('Se han activado un total de %1 facturas', wAct);
    end;

    
    procedure fRegProd()
    var
        rLinProd: Record 7000206;
        wFechaIni: Date;
        wFechaFin: Date;
        wFecha: Date;
        wCount: Integer;
        cICD: Codeunit 7000199;
    begin
        /*
        Ventana.oPEN('Introduzca fechas \' +
                      'Fecha Inicial #1######### \' + 'Fecha Final #2#########');
        Ventana.INPUT(1,wFechaIni);
        Ventana.INPUT(2,wFechaFin);
        */
        Ventana.oPEN('Comprobando Fecha #1######## \ Tipo de Registro #2####### \ ' +
                      'Registros Actualizados #3#######', wFecha, rLinProd."Regimen factura", wCount);


        FoR wFecha := 010621D To 300621D Do BEGIN

            rLinProd.RESET;
            rLinProd.SETRANGE(rLinProd.Concepto, '%1', 'Alo');
            rLinProd.SETRANGE(rLinProd."Fecha cargo", wFecha);
            rLinProd.SETFILTER(rLinProd.Centro, '<>%1', 'SUPIN');
            IF rLinProd.FIND('-') THEN BEGIN
                REPEAT
                    IF (rLinProd."Regimen factura" = 'SA') AND (rLinProd.Centro <> 'HASA') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HASA', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                    IF (rLinProd."Regimen factura" = 'HA') AND (rLinProd.Centro <> 'HASA') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HASA', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                    IF (rLinProd."Regimen factura" = 'HD') AND (rLinProd.Centro <> 'HAHD') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HAHD', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                    IF (rLinProd."Regimen factura" = 'MP') AND (rLinProd.Centro <> 'HAMP') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HAMP', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                    IF (rLinProd."Regimen factura" = 'PC') AND (rLinProd.Centro <> 'HAPC') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HAPC', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                    IF (rLinProd."Regimen factura" = 'TI') AND (rLinProd.Centro <> 'HATI') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HATI', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;

                    IF (rLinProd."Regimen factura" = 'MPA') AND (rLinProd.Centro <> 'HATI') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HATI', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;

                UNTIL rLinProd.NEXT = 0;
            END;
            rLinProd.RESET;
            rLinProd.SETRANGE(rLinProd.Concepto, 'Cen');
            rLinProd.SETRANGE(rLinProd."Fecha cargo", wFecha);
            rLinProd.SETFILTER(rLinProd.Centro, '<>%1', 'SUPIN');
            IF rLinProd.FIND('-') THEN BEGIN
                REPEAT
                    IF (rLinProd."Regimen factura" = 'SA') AND (rLinProd.Centro <> 'HASA') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HASA', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;

                    IF (rLinProd."Regimen factura" = 'HA') AND (rLinProd.Centro <> 'HASA') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HASA', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                    IF (rLinProd."Regimen factura" = 'HD') AND (rLinProd.Centro <> 'HAHD') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HAHD', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                    IF (rLinProd."Regimen factura" = 'MP') AND (rLinProd.Centro <> 'HAMP') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HAMP', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                    IF (rLinProd."Regimen factura" = 'PC') AND (rLinProd.Centro <> 'HAPC') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HAPC', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                    IF (rLinProd."Regimen factura" = 'TI') AND (rLinProd.Centro <> 'HATI') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HATI', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;

                    IF (rLinProd."Regimen factura" = 'MPA') AND (rLinProd.Centro <> 'HATI') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HATI', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;

                UNTIL rLinProd.NEXT = 0;
            END;
            rLinProd.RESET;
            rLinProd.SETRANGE(rLinProd.Concepto, 'Com');
            rLinProd.SETRANGE(rLinProd."Fecha cargo", wFecha);
            rLinProd.SETFILTER(rLinProd.Centro, '<>%1', 'SUPIN');
            IF rLinProd.FIND('-') THEN BEGIN
                REPEAT
                    IF (rLinProd."Regimen factura" = 'SA') AND (rLinProd.Centro <> 'HASA') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HASA', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;

                    IF (rLinProd."Regimen factura" = 'HA') AND (rLinProd.Centro <> 'HASA') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HASA', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                    IF (rLinProd."Regimen factura" = 'HD') AND (rLinProd.Centro <> 'HAHD') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HAHD', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                    IF (rLinProd."Regimen factura" = 'MP') AND (rLinProd.Centro <> 'HAMP') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HAMP', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                    IF (rLinProd."Regimen factura" = 'PC') AND (rLinProd.Centro <> 'HAPC') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HAPC', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                    IF (rLinProd."Regimen factura" = 'TI') AND (rLinProd.Centro <> 'HATI') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HATI', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;

                    IF (rLinProd."Regimen factura" = 'MPA') AND (rLinProd.Centro <> 'HATI') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HATI', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;

                UNTIL rLinProd.NEXT = 0;
            END;
            rLinProd.RESET;
            rLinProd.SETRANGE(rLinProd.Concepto, 'Des');
            rLinProd.SETRANGE(rLinProd."Fecha cargo", wFecha);
            rLinProd.SETFILTER(rLinProd.Centro, '<>%1', 'SUPIN');
            IF rLinProd.FIND('-') THEN BEGIN
                REPEAT
                    IF (rLinProd."Regimen factura" = 'SA') AND (rLinProd.Centro <> 'HASA') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HASA', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;

                    IF (rLinProd."Regimen factura" = 'HA') AND (rLinProd.Centro <> 'HASA') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HASA', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                    IF (rLinProd."Regimen factura" = 'HD') AND (rLinProd.Centro <> 'HAHD') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HAHD', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                    IF (rLinProd."Regimen factura" = 'MP') AND (rLinProd.Centro <> 'HAMP') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HAMP', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                    IF (rLinProd."Regimen factura" = 'PC') AND (rLinProd.Centro <> 'HAPC') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HAPC', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                    IF (rLinProd."Regimen factura" = 'TI') AND (rLinProd.Centro <> 'HATI') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HATI', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;

                    IF (rLinProd."Regimen factura" = 'MPA') AND (rLinProd.Centro <> 'HATI') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HATI', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;

                UNTIL rLinProd.NEXT = 0;
            END;

            rLinProd.RESET;
            rLinProd.SETRANGE(rLinProd.Concepto, 'Diferencia Cierre Fact.-Prod.');
            rLinProd.SETRANGE(rLinProd."Fecha cargo", wFecha);
            rLinProd.SETFILTER(rLinProd.Centro, '<>%1', 'SUPIN');
            IF rLinProd.FIND('-') THEN BEGIN
                REPEAT
                    IF (rLinProd."Regimen factura" = 'SA') AND (rLinProd.Centro <> 'HASA') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HASA', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;

                    IF (rLinProd."Regimen factura" = 'HA') AND (rLinProd.Centro <> 'HASA') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HASA', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                    IF (rLinProd."Regimen factura" = 'HD') AND (rLinProd.Centro <> 'HAHD') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HAHD', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                    IF (rLinProd."Regimen factura" = 'MP') AND (rLinProd.Centro <> 'HAMP') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HAMP', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                    IF (rLinProd."Regimen factura" = 'PC') AND (rLinProd.Centro <> 'HAPC') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HAPC', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                    IF (rLinProd."Regimen factura" = 'TI') AND (rLinProd.Centro <> 'HATI') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HATI', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;

                    IF (rLinProd."Regimen factura" = 'MPA') AND (rLinProd.Centro <> 'HATI') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HATI', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;

                UNTIL rLinProd.NEXT = 0;
            END;

            rLinProd.RESET;
            //rLinProd.SETRANGE(rLinProd.Concepto,'Alo');
            rLinProd.SETRANGE(rLinProd."Fecha cargo", wFecha);
            rLinProd.SETRANGE(rLinProd.Centro, 'REGULP');
            IF rLinProd.FIND('-') THEN BEGIN
                REPEAT
                    IF (rLinProd."Regimen factura" = 'SA') AND (rLinProd.Centro <> 'HASA') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HASA', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;

                    IF (rLinProd."Regimen factura" = 'HA') AND (rLinProd.Centro <> 'HASA') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HASA', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                    IF (rLinProd."Regimen factura" = 'HD') AND (rLinProd.Centro <> 'HAHD') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HAHD', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                    IF (rLinProd."Regimen factura" = 'MP') AND (rLinProd.Centro <> 'HAMP') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HAMP', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                    IF (rLinProd."Regimen factura" = 'PC') AND (rLinProd.Centro <> 'HAPC') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HAPC', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                    IF (rLinProd."Regimen factura" = 'TI') AND (rLinProd.Centro <> 'HATI') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HATI', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;

                    IF (rLinProd."Regimen factura" = 'MPA') AND (rLinProd.Centro <> 'HATI') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HATI', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;

                UNTIL rLinProd.NEXT = 0;
            END;
            CoMMIT;

            //NUEVo PARCHE THB-070721-IFF

            rLinProd.RESET;
            rLinProd.SETRANGE(rLinProd.Concepto, '%1', 'Alo');
            rLinProd.SETRANGE(rLinProd."Fecha cargo", wFecha);
            rLinProd.SETFILTER(rLinProd.Centro, '<>%1', 'SUPIN');
            IF (rLinProd.Centro = 'HASA') AND (rLinProd."Grupo Centro Productivo" <> '100HASA') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '100HASA';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            IF (rLinProd.Centro = 'HAHD') AND (rLinProd."Grupo Centro Productivo" <> '110HAHD') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '110HAHD';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            IF (rLinProd.Centro = 'HAMP') AND (rLinProd."Grupo Centro Productivo" <> '120HAMP') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '120HAMP';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            IF (rLinProd.Centro = 'HAPC') AND (rLinProd."Grupo Centro Productivo" <> '130HAPC') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '130HAPC';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            IF (rLinProd.Centro = 'HATI') AND (rLinProd."Grupo Centro Productivo" <> '140HATI') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '140HATI';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            rLinProd.RESET;
            rLinProd.SETRANGE(rLinProd.Concepto, 'Cen');
            rLinProd.SETRANGE(rLinProd."Fecha cargo", wFecha);
            rLinProd.SETFILTER(rLinProd.Centro, '<>%1', 'SUPIN');
            IF (rLinProd.Centro = 'HASA') AND (rLinProd."Grupo Centro Productivo" <> '100HASA') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '100HASA';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            IF (rLinProd.Centro = 'HAHD') AND (rLinProd."Grupo Centro Productivo" <> '110HAHD') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '110HAHD';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            IF (rLinProd.Centro = 'HAMP') AND (rLinProd."Grupo Centro Productivo" <> '120HAMP') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '120HAMP';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            IF (rLinProd.Centro = 'HAPC') AND (rLinProd."Grupo Centro Productivo" <> '130HAPC') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '130HAPC';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            IF (rLinProd.Centro = 'HATI') AND (rLinProd."Grupo Centro Productivo" <> '140HATI') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '140HATI';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            rLinProd.RESET;
            rLinProd.SETRANGE(rLinProd.Concepto, 'Com');
            rLinProd.SETRANGE(rLinProd."Fecha cargo", wFecha);
            rLinProd.SETFILTER(rLinProd.Centro, '<>%1', 'SUPIN');
            IF (rLinProd.Centro = 'HASA') AND (rLinProd."Grupo Centro Productivo" <> '100HASA') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '100HASA';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            IF (rLinProd.Centro = 'HAHD') AND (rLinProd."Grupo Centro Productivo" <> '110HAHD') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '110HAHD';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            IF (rLinProd.Centro = 'HAMP') AND (rLinProd."Grupo Centro Productivo" <> '120HAMP') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '120HAMP';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            IF (rLinProd.Centro = 'HAPC') AND (rLinProd."Grupo Centro Productivo" <> '130HAPC') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '130HAPC';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            IF (rLinProd.Centro = 'HATI') AND (rLinProd."Grupo Centro Productivo" <> '140HATI') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '140HATI';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            rLinProd.RESET;
            rLinProd.SETRANGE(rLinProd.Concepto, 'Des');
            rLinProd.SETRANGE(rLinProd."Fecha cargo", wFecha);
            rLinProd.SETFILTER(rLinProd.Centro, '<>%1', 'SUPIN');
            IF (rLinProd.Centro = 'HASA') AND (rLinProd."Grupo Centro Productivo" <> '100HASA') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '100HASA';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            IF (rLinProd.Centro = 'HAHD') AND (rLinProd."Grupo Centro Productivo" <> '110HAHD') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '110HAHD';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            IF (rLinProd.Centro = 'HAMP') AND (rLinProd."Grupo Centro Productivo" <> '120HAMP') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '120HAMP';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            IF (rLinProd.Centro = 'HAPC') AND (rLinProd."Grupo Centro Productivo" <> '130HAPC') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '130HAPC';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            IF (rLinProd.Centro = 'HATI') AND (rLinProd."Grupo Centro Productivo" <> '140HATI') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '140HATI';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            rLinProd.RESET;
            rLinProd.SETRANGE(rLinProd.Concepto, 'Diferencia Cierre Fact.-Prod.');
            rLinProd.SETRANGE(rLinProd."Fecha cargo", wFecha);
            rLinProd.SETFILTER(rLinProd.Centro, '<>%1', 'SUPIN');
            IF (rLinProd.Centro = 'HASA') AND (rLinProd."Grupo Centro Productivo" <> '100HASA') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '100HASA';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            IF (rLinProd.Centro = 'HAHD') AND (rLinProd."Grupo Centro Productivo" <> '110HAHD') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '110HAHD';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            IF (rLinProd.Centro = 'HAMP') AND (rLinProd."Grupo Centro Productivo" <> '120HAMP') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '120HAMP';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            IF (rLinProd.Centro = 'HAPC') AND (rLinProd."Grupo Centro Productivo" <> '130HAPC') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '130HAPC';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            IF (rLinProd.Centro = 'HATI') AND (rLinProd."Grupo Centro Productivo" <> '140HATI') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '140HATI';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            rLinProd.RESET;
            //rLinProd.SETRANGE(rLinProd.Concepto,'Alo');
            rLinProd.SETRANGE(rLinProd."Fecha cargo", wFecha);
            IF (rLinProd.Centro = 'HASA') AND (rLinProd."Grupo Centro Productivo" <> '100HASA') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '100HASA';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            IF (rLinProd.Centro = 'HAHD') AND (rLinProd."Grupo Centro Productivo" <> '110HAHD') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '110HAHD';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            IF (rLinProd.Centro = 'HAMP') AND (rLinProd."Grupo Centro Productivo" <> '120HAMP') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '120HAMP';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            IF (rLinProd.Centro = 'HAPC') AND (rLinProd."Grupo Centro Productivo" <> '130HAPC') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '130HAPC';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            IF (rLinProd.Centro = 'HATI') AND (rLinProd."Grupo Centro Productivo" <> '140HATI') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '140HATI';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            cICD.CalculoProduccion(rUsr."Hotel de trabajo", wFecha);
        END;
        CoMMIT;
        MESSAGE('Se han actualizado %1 registros', wCount);

    end;

    
    procedure fRegProdCierre(wFecha: Date)
    var
        x: Integer;
        cICD: Codeunit 7000199;
        rLinProd: Record 7000206;
        wCount: Integer;
        wAlo: Text[300];
    begin
        //EXIT;
        Ventana.oPEN('Comprobando Produccion del dia #1######## \ Tipo de Registro #2####### \ ' +
                      'Concepto #3############# \' + 'Registros Actualizados #4####### \ Pasada de 5 #5####', wFecha, rLinProd."Regimen factura", rLinProd.Concepto, wCount, x);
        x := 0;
        FoR x := 1 To 5 Do BEGIN
            //X:=X+1;
            rLinProd.RESET;
            rLinProd.SETRANGE(rLinProd.Concepto, 'Alo');
            //rLinProd.SETFILTER(rLinProd.Concepto,'*','Alo');
            rLinProd.SETRANGE(rLinProd."Fecha cargo", wFecha);
            rLinProd.SETFILTER(rLinProd.Centro, '<>%1', 'SUPIN');
            IF rLinProd.FIND('-') THEN BEGIN
                REPEAT
                    IF (rLinProd."Regimen factura" = 'SA') AND (rLinProd.Centro <> 'HASA') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HASA', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                    IF (rLinProd."Regimen factura" = 'HA') AND (rLinProd.Centro <> 'HASA') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HASA', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                    IF (rLinProd."Regimen factura" = 'HD') AND (rLinProd.Centro <> 'HAHD') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HAHD', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                    IF (rLinProd."Regimen factura" = 'MP') AND (rLinProd.Centro <> 'HAMP') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HAMP', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                    IF (rLinProd."Regimen factura" = 'PC') AND (rLinProd.Centro <> 'HAPC') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HAPC', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                    IF (rLinProd."Regimen factura" = 'TI') AND (rLinProd.Centro <> 'HATI') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HATI', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                    //IFF MoDIFICAR AQUI
                    IF (rLinProd."Regimen factura" = 'MPA') AND (rLinProd.Centro <> 'HATI') AND (rLinProd.Hotel <> 'HGB') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HATI', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                    IF (rLinProd."Regimen factura" = 'MPA') AND (rLinProd.Centro <> 'HAMP') AND (rLinProd.Hotel = 'HGB') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HAMP', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                UNTIL rLinProd.NEXT = 0;
            END;
            //rLinProd.RESET;
            rLinProd.RESET;
            //rLinProd.SETRANGE(rLinProd.Concepto,'Alo');
            //rLinProd.SETFILTER(rLinProd.Concepto,'*','Alo');
            rLinProd.SETRANGE(rLinProd."Fecha cargo", wFecha);
            rLinProd.SETFILTER(rLinProd.Centro, '<>%1', 'SUPIN');
            IF rLinProd.FIND('-') THEN BEGIN
                REPEAT
                    wAlo := '';
                    wAlo := CoPYSTR(rLinProd.Concepto, 11, 13);
                    //    IF wAlo='Alo' THEN ERRoR(wAlo+' '+rLinProd."Nombre cliente");
                    IF wAlo = 'Alo' THEN BEGIN
                        IF (rLinProd."Regimen factura" = 'SA') AND (rLinProd.Centro <> 'HASA') THEN BEGIN
                            rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HASA', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                            wCount := wCount + 1;
                            Ventana.UPDATE;
                            IF rLinProd.FIND('-') THEN;
                        END;
                        IF (rLinProd."Regimen factura" = 'HA') AND (rLinProd.Centro <> 'HASA') THEN BEGIN
                            rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HASA', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                            wCount := wCount + 1;
                            Ventana.UPDATE;
                            IF rLinProd.FIND('-') THEN;
                        END;
                        IF (rLinProd."Regimen factura" = 'HD') AND (rLinProd.Centro <> 'HAHD') THEN BEGIN
                            rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HAHD', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                            wCount := wCount + 1;
                            Ventana.UPDATE;
                            IF rLinProd.FIND('-') THEN;
                        END;
                        IF (rLinProd."Regimen factura" = 'MP') AND (rLinProd.Centro <> 'HAMP') THEN BEGIN
                            rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HAMP', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                            wCount := wCount + 1;
                            Ventana.UPDATE;
                            IF rLinProd.FIND('-') THEN;
                        END;
                        IF (rLinProd."Regimen factura" = 'PC') AND (rLinProd.Centro <> 'HAPC') THEN BEGIN
                            rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HAPC', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                            wCount := wCount + 1;
                            Ventana.UPDATE;
                            IF rLinProd.FIND('-') THEN;
                        END;
                        IF (rLinProd."Regimen factura" = 'TI') AND (rLinProd.Centro <> 'HATI') THEN BEGIN
                            rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HATI', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                            wCount := wCount + 1;
                            Ventana.UPDATE;
                            IF rLinProd.FIND('-') THEN;
                        END;
                        IF (rLinProd."Regimen factura" = 'MPA') AND (rLinProd.Centro <> 'HATI') AND (rLinProd.Hotel <> 'HGB') THEN BEGIN
                            rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HATI', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                            wCount := wCount + 1;
                            Ventana.UPDATE;
                            IF rLinProd.FIND('-') THEN;
                        END;
                        IF (rLinProd."Regimen factura" = 'MPA') AND (rLinProd.Centro <> 'HAMP') AND (rLinProd.Hotel = 'HGB') THEN BEGIN
                            rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HAMP', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                            wCount := wCount + 1;
                            Ventana.UPDATE;
                            IF rLinProd.FIND('-') THEN;
                        END;
                    END;
                UNTIL rLinProd.NEXT = 0;
            END;

            rLinProd.RESET;
            rLinProd.SETRANGE(rLinProd.Concepto, 'Cen');
            rLinProd.SETRANGE(rLinProd."Fecha cargo", wFecha);
            rLinProd.SETFILTER(rLinProd.Centro, '<>%1', 'SUPIN');
            IF rLinProd.FIND('-') THEN BEGIN
                REPEAT
                    IF (rLinProd."Regimen factura" = 'SA') AND (rLinProd.Centro <> 'HASA') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HASA', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;

                    IF (rLinProd."Regimen factura" = 'HA') AND (rLinProd.Centro <> 'HASA') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HASA', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                    IF (rLinProd."Regimen factura" = 'HD') AND (rLinProd.Centro <> 'HAHD') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HAHD', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                    IF (rLinProd."Regimen factura" = 'MP') AND (rLinProd.Centro <> 'HAMP') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HAMP', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                    IF (rLinProd."Regimen factura" = 'PC') AND (rLinProd.Centro <> 'HAPC') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HAPC', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                    IF (rLinProd."Regimen factura" = 'TI') AND (rLinProd.Centro <> 'HATI') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HATI', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                    IF (rLinProd."Regimen factura" = 'MPA') AND (rLinProd.Centro <> 'HATI') AND (rLinProd.Hotel <> 'HGB') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HATI', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                    IF (rLinProd."Regimen factura" = 'MPA') AND (rLinProd.Centro <> 'HAMP') AND (rLinProd.Hotel = 'HGB') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HAMP', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                UNTIL rLinProd.NEXT = 0;
            END;
            rLinProd.RESET;
            rLinProd.SETRANGE(rLinProd.Concepto, 'Com');
            rLinProd.SETRANGE(rLinProd."Fecha cargo", wFecha);
            rLinProd.SETFILTER(rLinProd.Centro, '<>%1', 'SUPIN');
            IF rLinProd.FIND('-') THEN BEGIN
                REPEAT
                    IF (rLinProd."Regimen factura" = 'SA') AND (rLinProd.Centro <> 'HASA') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HASA', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;

                    IF (rLinProd."Regimen factura" = 'HA') AND (rLinProd.Centro <> 'HASA') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HASA', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                    IF (rLinProd."Regimen factura" = 'HD') AND (rLinProd.Centro <> 'HAHD') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HAHD', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                    IF (rLinProd."Regimen factura" = 'MP') AND (rLinProd.Centro <> 'HAMP') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HAMP', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                    IF (rLinProd."Regimen factura" = 'PC') AND (rLinProd.Centro <> 'HAPC') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HAPC', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                    IF (rLinProd."Regimen factura" = 'TI') AND (rLinProd.Centro <> 'HATI') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HATI', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;

                    IF (rLinProd."Regimen factura" = 'MPA') AND (rLinProd.Centro <> 'HATI') AND (rLinProd.Hotel <> 'HGB') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HATI', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                    IF (rLinProd."Regimen factura" = 'MPA') AND (rLinProd.Centro <> 'HAMP') AND (rLinProd.Hotel = 'HGB') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HAMP', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;

                UNTIL rLinProd.NEXT = 0;
            END;
            rLinProd.RESET;
            rLinProd.SETRANGE(rLinProd.Concepto, 'Des');
            rLinProd.SETRANGE(rLinProd."Fecha cargo", wFecha);
            rLinProd.SETFILTER(rLinProd.Centro, '<>%1', 'SUPIN');
            IF rLinProd.FIND('-') THEN BEGIN
                REPEAT
                    IF (rLinProd."Regimen factura" = 'SA') AND (rLinProd.Centro <> 'HASA') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HASA', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;

                    IF (rLinProd."Regimen factura" = 'HA') AND (rLinProd.Centro <> 'HASA') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HASA', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                    IF (rLinProd."Regimen factura" = 'HD') AND (rLinProd.Centro <> 'HAHD') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HAHD', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                    IF (rLinProd."Regimen factura" = 'MP') AND (rLinProd.Centro <> 'HAMP') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HAMP', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                    IF (rLinProd."Regimen factura" = 'PC') AND (rLinProd.Centro <> 'HAPC') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HAPC', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                    IF (rLinProd."Regimen factura" = 'TI') AND (rLinProd.Centro <> 'HATI') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HATI', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;

                    IF (rLinProd."Regimen factura" = 'MPA') AND (rLinProd.Centro <> 'HATI') AND (rLinProd.Hotel <> 'HGB') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HATI', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                    IF (rLinProd."Regimen factura" = 'MPA') AND (rLinProd.Centro <> 'HAMP') AND (rLinProd.Hotel = 'HGB') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HAMP', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                UNTIL rLinProd.NEXT = 0;
            END;

            rLinProd.RESET;
            rLinProd.SETRANGE(rLinProd.Concepto, 'Diferencia Cierre Fact.-Prod.');
            rLinProd.SETRANGE(rLinProd."Fecha cargo", wFecha);
            rLinProd.SETFILTER(rLinProd.Centro, '<>%1', 'SUPIN');
            IF rLinProd.FIND('-') THEN BEGIN
                REPEAT
                    IF (rLinProd."Regimen factura" = 'SA') AND (rLinProd.Centro <> 'HASA') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HASA', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;

                    IF (rLinProd."Regimen factura" = 'HA') AND (rLinProd.Centro <> 'HASA') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HASA', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                    IF (rLinProd."Regimen factura" = 'HD') AND (rLinProd.Centro <> 'HAHD') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HAHD', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                    IF (rLinProd."Regimen factura" = 'MP') AND (rLinProd.Centro <> 'HAMP') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HAMP', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                    IF (rLinProd."Regimen factura" = 'PC') AND (rLinProd.Centro <> 'HAPC') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HAPC', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                    IF (rLinProd."Regimen factura" = 'TI') AND (rLinProd.Centro <> 'HATI') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HATI', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;

                    IF (rLinProd."Regimen factura" = 'MPA') AND (rLinProd.Centro <> 'HATI') AND (rLinProd.Hotel <> 'HGB') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HATI', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                    IF (rLinProd."Regimen factura" = 'MPA') AND (rLinProd.Centro <> 'HAMP') AND (rLinProd.Hotel = 'HGB') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HAMP', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                UNTIL rLinProd.NEXT = 0;
            END;

            rLinProd.RESET;
            rLinProd.SETRANGE(rLinProd."Fecha cargo", wFecha);
            rLinProd.SETFILTER(rLinProd.Centro, '%1|%2|%3|%4|%5', 'HASA', 'HAHD', 'HAMP', 'HAPC', 'HATI');
            IF rLinProd.FIND('-') THEN BEGIN
                REPEAT
                    IF (rLinProd.Centro = 'HASA') AND (rLinProd."Grupo Centro Productivo" <> '100HASA') THEN BEGIN
                        rLinProd."Grupo Centro Productivo" := '100HASA';
                        rLinProd.MoDIFY;
                    END;
                    IF (rLinProd.Centro = 'HAHD') AND (rLinProd."Grupo Centro Productivo" <> '110HAHD') THEN BEGIN
                        rLinProd."Grupo Centro Productivo" := '110HAHD';
                        rLinProd.MoDIFY;
                    END;
                    IF (rLinProd.Centro = 'HAMP') AND (rLinProd."Grupo Centro Productivo" <> '120HAMP') THEN BEGIN
                        rLinProd."Grupo Centro Productivo" := '120HAMP';
                        rLinProd.MoDIFY;
                    END;
                    IF (rLinProd.Centro = 'HAPC') AND (rLinProd."Grupo Centro Productivo" <> '130HAPC') THEN BEGIN
                        rLinProd."Grupo Centro Productivo" := '130HAPC';
                        rLinProd.MoDIFY;
                    END;
                    IF (rLinProd.Centro = 'HATI') AND (rLinProd."Grupo Centro Productivo" <> '140HATI') THEN BEGIN
                        rLinProd."Grupo Centro Productivo" := '140HATI';
                        rLinProd.MoDIFY;
                    END;
                UNTIL rLinProd.NEXT = 0
            END;

            //FIX IET

            rLinProd.RESET;
            rLinProd.SETRANGE(rLinProd.Concepto, 'IMPUESTo ESTANCIAS TURISTICAS');
            rLinProd.SETRANGE(rLinProd."Fecha cargo", wFecha);
            rLinProd.SETFILTER(rLinProd.Centro, '<>%1', 'IET');
            IF rLinProd.FIND('-') THEN BEGIN
                REPEAT
                    rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'IET', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                    wCount := wCount + 1;
                    Ventana.UPDATE;
                    IF rLinProd.FIND('-') THEN;
                UNTIL rLinProd.NEXT = 0;
            END;

            //FIX IET 2
            rLinProd.RESET;
            rLinProd.SETRANGE(rLinProd.Concepto, 'Ext./Srv. Rva.:IMPUESTo ESTANCIAS TURISTICAS');
            rLinProd.SETRANGE(rLinProd."Fecha cargo", wFecha);
            rLinProd.SETFILTER(rLinProd.Centro, '<>%1', 'IET');
            IF rLinProd.FIND('-') THEN BEGIN
                REPEAT
                    rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'IET', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                    wCount := wCount + 1;
                    IF rLinProd.FIND('-') THEN;
                    Ventana.UPDATE;
                UNTIL rLinProd.NEXT = 0;
            END;

            // Ext./Srv. Rva.:IMPUESTo ESTANCIAS TURISTICAS

            /*

              rLinProd.RESET;
              rLinProd.SETRANGE(rLinProd.Concepto,'Alo');
              rLinProd.SETRANGE(rLinProd."Fecha cargo",wFecha);
              rLinProd.SETRANGE(rLinProd.Centro,'REGULP');
              IF rLinProd.FIND('-') THEN BEGIN
                REPEAT
                IF (rLinProd."Regimen factura"='SA') AND (rLinProd.Centro<>'HASA') THEN BEGIN
                  rLinProd.RENAME(rLinProd.Hotel,rLinProd."Fecha cargo",'HASA',rLinProd."Fecha proceso",rLinProd."Secuencia grabacion");
                  wCount:=wCount+1;
                  Ventana.UPDATE;
                  IF rLinProd.FIND('-') THEN;
                END;

                IF (rLinProd."Regimen factura"='HA') AND (rLinProd.Centro<>'HASA') THEN BEGIN
                  rLinProd.RENAME(rLinProd.Hotel,rLinProd."Fecha cargo",'HASA',rLinProd."Fecha proceso",rLinProd."Secuencia grabacion");
                  wCount:=wCount+1;
                  Ventana.UPDATE;
                  IF rLinProd.FIND('-') THEN;
                END;
                IF (rLinProd."Regimen factura"='HD') AND (rLinProd.Centro<>'HAHD') THEN BEGIN
                  rLinProd.RENAME(rLinProd.Hotel,rLinProd."Fecha cargo",'HAHD',rLinProd."Fecha proceso",rLinProd."Secuencia grabacion");
                  wCount:=wCount+1;
                  Ventana.UPDATE;
                IF rLinProd.FIND('-') THEN;
                END;
                IF (rLinProd."Regimen factura"='MP') AND (rLinProd.Centro<>'HAMP') THEN BEGIN
                  rLinProd.RENAME(rLinProd.Hotel,rLinProd."Fecha cargo",'HAMP',rLinProd."Fecha proceso",rLinProd."Secuencia grabacion");
                  wCount:=wCount+1;
                  Ventana.UPDATE;
                IF rLinProd.FIND('-') THEN;
                END;
                IF (rLinProd."Regimen factura"='PC') AND (rLinProd.Centro<>'HAPC') THEN BEGIN
                  rLinProd.RENAME(rLinProd.Hotel,rLinProd."Fecha cargo",'HAPC',rLinProd."Fecha proceso",rLinProd."Secuencia grabacion");
                  wCount:=wCount+1;
                  Ventana.UPDATE;
                  IF rLinProd.FIND('-') THEN;
                END;
                IF (rLinProd."Regimen factura"='TI' ) AND (rLinProd.Centro<>'HATI')THEN BEGIN
                  rLinProd.RENAME(rLinProd.Hotel,rLinProd."Fecha cargo",'HATI',rLinProd."Fecha proceso",rLinProd."Secuencia grabacion");
                  wCount:=wCount+1;
                  Ventana.UPDATE;
                  IF rLinProd.FIND('-') THEN;
                END;
                UNTIL rLinProd.NEXT=0;
              END;

            */

            //cICD."CalculoProduccion"(rUsr."Hotel de trabajo",wFecha);
            CoMMIT;
            //MESSAGE('Se han actualizado %1 registros',wCount);
            /*
            rLinProd.RESET;
            rLinProd.SETRANGE(rLinProd."Fecha cargo",wFecha);
            IF rLinProd.FIND('-') THEN BEGIN
              REPEAT
              IF (rLinProd."Regimen factura"='SA') AND (rLinProd."Grupo Centro Productivo"<>'100HASA') THEN BEGIN
                rLinProd."Grupo Centro Productivo":='100HASA';
                wCount:=wCount+1;
                rLinProd.MoDIFY;
                Ventana.UPDATE;
              END;
              IF (rLinProd."Regimen factura"='HA') AND (rLinProd."Grupo Centro Productivo"<>'100HASA') THEN BEGIN
                rLinProd."Grupo Centro Productivo":='100HASA';
                wCount:=wCount+1;
                rLinProd.MoDIFY;
                Ventana.UPDATE;
              END;
              IF (rLinProd."Regimen factura"='HD') AND (rLinProd."Grupo Centro Productivo"<>'110HAHD') THEN BEGIN
                rLinProd."Grupo Centro Productivo":='110HAHD';
                wCount:=wCount+1;
                rLinProd.MoDIFY;
                Ventana.UPDATE;
              END;
              IF (rLinProd."Regimen factura"='MP') AND (rLinProd."Grupo Centro Productivo"<>'120HAMP') THEN BEGIN
                rLinProd."Grupo Centro Productivo":='120HAMP';
                wCount:=wCount+1;
                rLinProd.MoDIFY;
                Ventana.UPDATE;
              END;
              IF (rLinProd."Regimen factura"='PC') AND (rLinProd."Grupo Centro Productivo"<>'130HAPC') THEN BEGIN
                rLinProd."Grupo Centro Productivo":='130HAPC';
                wCount:=wCount+1;
                rLinProd.MoDIFY;
                Ventana.UPDATE;
              END;
              IF (rLinProd."Regimen factura"='TI') AND (rLinProd."Grupo Centro Productivo"<>'140HATI') THEN BEGIN
                rLinProd."Grupo Centro Productivo":='140HATI';
                wCount:=wCount+1;
                rLinProd.MoDIFY;
                Ventana.UPDATE;
              END;
            UNTIL rLinProd.NEXT=0;
            END;
            */
            CoMMIT;

            rLinProd.RESET;
            rLinProd.SETRANGE(rLinProd.Concepto, '%1', 'Alo');
            rLinProd.SETRANGE(rLinProd."Fecha cargo", wFecha);
            rLinProd.SETFILTER(rLinProd.Centro, '<>%1', 'SUPIN');
            IF (rLinProd.Centro = 'HASA') AND (rLinProd."Grupo Centro Productivo" <> '100HASA') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '100HASA';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            IF (rLinProd.Centro = 'HAHD') AND (rLinProd."Grupo Centro Productivo" <> '110HAHD') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '110HAHD';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            IF (rLinProd.Centro = 'HAMP') AND (rLinProd."Grupo Centro Productivo" <> '120HAMP') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '120HAMP';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            IF (rLinProd.Centro = 'HAPC') AND (rLinProd."Grupo Centro Productivo" <> '130HAPC') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '130HAPC';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            IF (rLinProd.Centro = 'HATI') AND (rLinProd."Grupo Centro Productivo" <> '140HATI') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '140HATI';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            rLinProd.RESET;
            rLinProd.SETRANGE(rLinProd.Concepto, 'Cen');
            rLinProd.SETRANGE(rLinProd."Fecha cargo", wFecha);
            rLinProd.SETFILTER(rLinProd.Centro, '<>%1', 'SUPIN');
            IF (rLinProd.Centro = 'HASA') AND (rLinProd."Grupo Centro Productivo" <> '100HASA') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '100HASA';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            IF (rLinProd.Centro = 'HAHD') AND (rLinProd."Grupo Centro Productivo" <> '110HAHD') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '110HAHD';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            IF (rLinProd.Centro = 'HAMP') AND (rLinProd."Grupo Centro Productivo" <> '120HAMP') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '120HAMP';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            IF (rLinProd.Centro = 'HAPC') AND (rLinProd."Grupo Centro Productivo" <> '130HAPC') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '130HAPC';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            IF (rLinProd.Centro = 'HATI') AND (rLinProd."Grupo Centro Productivo" <> '140HATI') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '140HATI';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            rLinProd.RESET;
            rLinProd.SETRANGE(rLinProd.Concepto, 'Com');
            rLinProd.SETRANGE(rLinProd."Fecha cargo", wFecha);
            rLinProd.SETFILTER(rLinProd.Centro, '<>%1', 'SUPIN');
            IF (rLinProd.Centro = 'HASA') AND (rLinProd."Grupo Centro Productivo" <> '100HASA') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '100HASA';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            IF (rLinProd.Centro = 'HAHD') AND (rLinProd."Grupo Centro Productivo" <> '110HAHD') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '110HAHD';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            IF (rLinProd.Centro = 'HAMP') AND (rLinProd."Grupo Centro Productivo" <> '120HAMP') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '120HAMP';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            IF (rLinProd.Centro = 'HAPC') AND (rLinProd."Grupo Centro Productivo" <> '130HAPC') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '130HAPC';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            IF (rLinProd.Centro = 'HATI') AND (rLinProd."Grupo Centro Productivo" <> '140HATI') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '140HATI';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            rLinProd.RESET;
            rLinProd.SETRANGE(rLinProd.Concepto, 'Des');
            rLinProd.SETRANGE(rLinProd."Fecha cargo", wFecha);
            rLinProd.SETFILTER(rLinProd.Centro, '<>%1', 'SUPIN');
            IF (rLinProd.Centro = 'HASA') AND (rLinProd."Grupo Centro Productivo" <> '100HASA') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '100HASA';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            IF (rLinProd.Centro = 'HAHD') AND (rLinProd."Grupo Centro Productivo" <> '110HAHD') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '110HAHD';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            IF (rLinProd.Centro = 'HAMP') AND (rLinProd."Grupo Centro Productivo" <> '120HAMP') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '120HAMP';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            IF (rLinProd.Centro = 'HAPC') AND (rLinProd."Grupo Centro Productivo" <> '130HAPC') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '130HAPC';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            IF (rLinProd.Centro = 'HATI') AND (rLinProd."Grupo Centro Productivo" <> '140HATI') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '140HATI';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            rLinProd.RESET;
            rLinProd.SETRANGE(rLinProd.Concepto, 'Diferencia Cierre Fact.-Prod.');
            rLinProd.SETRANGE(rLinProd."Fecha cargo", wFecha);
            rLinProd.SETFILTER(rLinProd.Centro, '<>%1', 'SUPIN');
            IF (rLinProd.Centro = 'HASA') AND (rLinProd."Grupo Centro Productivo" <> '100HASA') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '100HASA';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            IF (rLinProd.Centro = 'HAHD') AND (rLinProd."Grupo Centro Productivo" <> '110HAHD') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '110HAHD';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            IF (rLinProd.Centro = 'HAMP') AND (rLinProd."Grupo Centro Productivo" <> '120HAMP') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '120HAMP';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            IF (rLinProd.Centro = 'HAPC') AND (rLinProd."Grupo Centro Productivo" <> '130HAPC') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '130HAPC';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            IF (rLinProd.Centro = 'HATI') AND (rLinProd."Grupo Centro Productivo" <> '140HATI') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '140HATI';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            rLinProd.RESET;
            //rLinProd.SETRANGE(rLinProd.Concepto,'Alo');
            rLinProd.SETRANGE(rLinProd."Fecha cargo", wFecha);
            IF (rLinProd.Centro = 'HASA') AND (rLinProd."Grupo Centro Productivo" <> '100HASA') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '100HASA';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            IF (rLinProd.Centro = 'HAHD') AND (rLinProd."Grupo Centro Productivo" <> '110HAHD') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '110HAHD';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            IF (rLinProd.Centro = 'HAMP') AND (rLinProd."Grupo Centro Productivo" <> '120HAMP') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '120HAMP';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            IF (rLinProd.Centro = 'HAPC') AND (rLinProd."Grupo Centro Productivo" <> '130HAPC') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '130HAPC';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            IF (rLinProd.Centro = 'HATI') AND (rLinProd."Grupo Centro Productivo" <> '140HATI') THEN BEGIN
                rLinProd."Grupo Centro Productivo" := '140HATI';
                rLinProd.MoDIFY;
                wCount := wCount + 1;
                Ventana.UPDATE;
            END;
            CoMMIT;
        END;

    end;

    
    procedure fProd()
    var
        rProd: Record 7000206;
    begin
        rUsr.GET(USERID);
        IF rUsr."Hotel de trabajo" = 'MISABEL' THEN BEGIN
            rProd.INIT;
            rProd.Hotel := 'MISABEL';
            rProd."Fecha cargo" := 300611D;
            rProd."Fecha proceso" := 300611D;
            rProd.Usuario := 'AUTo';
            rProd.Concepto := 'Regularizacion';
            rProd.Centro := 'HAMP';
            rProd.Cliente := 'EBBNUR';
            rProd.TToo := 'CooK';
            rProd.Agencia := 'CooK';
            rProd.Importe := -236.31;
            rProd."Total importe" := -236.31;
            rProd."Impuestos inc." := TRUE;
            rProd."Importe produccion" := -236.31;
            rProd."Total importe produccion" := -236.31;
            rProd."Importe original" := -236.31;
            rProd."Total original" := -236.31;
            rProd."Total (CENTRAL)" := -236.31;
            rProd."Secuencia grabacion" := 1;
            rProd.INSERT;
            //
            rProd.INIT;
            rProd.Hotel := 'MISABEL';
            rProd."Fecha cargo" := 300611D;
            rProd."Fecha proceso" := 300611D;
            rProd.Usuario := 'AUTo';
            rProd.Concepto := 'Regularizacion';
            rProd.Centro := 'HATI';
            rProd.Cliente := 'EBBNUR';
            rProd.TToo := 'CooK';
            rProd.Agencia := 'CooK';
            rProd.Importe := 236.31;
            rProd."Total importe" := 236.31;
            rProd."Impuestos inc." := TRUE;
            rProd."Importe produccion" := 236.31;
            rProd."Total importe produccion" := 236.31;
            rProd."Importe original" := 236.31;
            rProd."Total original" := 236.31;
            rProd."Total (CENTRAL)" := 236.31;
            rProd."Secuencia grabacion" := 2;
            rProd.INSERT;
            //
            rProd.INIT;
            rProd.Hotel := 'MISABEL';
            rProd."Fecha cargo" := 300611D;
            rProd."Fecha proceso" := 300611D;
            rProd.Usuario := 'AUTo';
            rProd.Concepto := 'Regularizacion';
            rProd.Centro := 'HAMP';
            rProd.Cliente := 'EBFTI';
            rProd.TToo := 'SIDE';
            rProd.Agencia := 'SIDE';
            rProd.Importe := -185;
            rProd."Total importe" := -185;
            rProd."Impuestos inc." := TRUE;
            rProd."Importe produccion" := -185;
            rProd."Total importe produccion" := -185;
            rProd."Importe original" := -185;
            rProd."Total original" := -185;
            rProd."Total (CENTRAL)" := -185;
            rProd."Secuencia grabacion" := 3;
            rProd.INSERT;
            //
            rProd.INIT;
            rProd.Hotel := 'MISABEL';
            rProd."Fecha cargo" := 300611D;
            rProd."Fecha proceso" := 300611D;
            rProd.Usuario := 'AUTo';
            rProd.Concepto := 'Regularizacion';
            rProd.Centro := 'HATI';
            rProd.Cliente := 'EBFTI';
            rProd.TToo := 'SIDE';
            rProd.Agencia := 'SIDE';
            rProd.Importe := 185;
            rProd."Total importe" := 185;
            rProd."Impuestos inc." := TRUE;
            rProd."Importe produccion" := 185;
            rProd."Total importe produccion" := 185;
            rProd."Importe original" := 185;
            rProd."Total original" := 185;
            rProd."Total (CENTRAL)" := 185;
            rProd."Secuencia grabacion" := 4;
            rProd.INSERT;
            //
            rProd.INIT;
            rProd.Hotel := 'MISABEL';
            rProd."Fecha cargo" := 300611D;
            rProd."Fecha proceso" := 300611D;
            rProd.Usuario := 'AUTo';
            rProd.Concepto := 'Regularizacion';
            rProd.Centro := 'HAMP';
            rProd.Cliente := 'EBJUMBA';
            rProd.TToo := 'JUMB';
            rProd.Agencia := 'JUMB';
            rProd.Importe := -469.98;
            rProd."Total importe" := -469.98;
            rProd."Impuestos inc." := TRUE;
            rProd."Importe produccion" := -469.98;
            rProd."Total importe produccion" := -469.98;
            rProd."Importe original" := -469.98;
            rProd."Total original" := -469.98;
            rProd."Total (CENTRAL)" := -469.98;
            rProd."Secuencia grabacion" := 5;
            rProd.INSERT;
            //
            rProd.INIT;
            rProd.Hotel := 'MISABEL';
            rProd."Fecha cargo" := 300611D;
            rProd."Fecha proceso" := 300611D;
            rProd.Usuario := 'AUTo';
            rProd.Concepto := 'Regularizacion';
            rProd.Centro := 'HATI';
            rProd.Cliente := 'EBJUMBA';
            rProd.TToo := 'JUMB';
            rProd.Agencia := 'JUMB';
            rProd.Importe := 469.98;
            rProd."Total importe" := 469.98;
            rProd."Impuestos inc." := TRUE;
            rProd."Importe produccion" := 469.98;
            rProd."Total importe produccion" := 469.98;
            rProd."Importe original" := 469.98;
            rProd."Total original" := 469.98;
            rProd."Total (CENTRAL)" := 469.98;
            rProd."Secuencia grabacion" := 6;
            rProd.INSERT;
            //
            rProd.INIT;
            rProd.Hotel := 'MISABEL';
            rProd."Fecha cargo" := 300611D;
            rProd."Fecha proceso" := 300611D;
            rProd.Usuario := 'AUTo';
            rProd.Concepto := 'Regularizacion';
            rProd.Centro := 'HAMP';
            rProd.Cliente := 'EBNUR';
            rProd.TToo := 'CooK';
            rProd.Agencia := 'CooK';
            rProd.Importe := -8324.09;
            rProd."Total importe" := -8324.09;
            rProd."Impuestos inc." := TRUE;
            rProd."Importe produccion" := -8324.09;
            rProd."Total importe produccion" := -8324.09;
            rProd."Importe original" := -8324.09;
            rProd."Total original" := -8324.09;
            rProd."Total (CENTRAL)" := -8324.09;
            rProd."Secuencia grabacion" := 7;
            rProd.INSERT;
            //
            rProd.INIT;
            rProd.Hotel := 'MISABEL';
            rProd."Fecha cargo" := 300611D;
            rProd."Fecha proceso" := 300611D;
            rProd.Usuario := 'AUTo';
            rProd.Concepto := 'Regularizacion';
            rProd.Centro := 'HATI';
            rProd.Cliente := 'EBNUR';
            rProd.TToo := 'CooK';
            rProd.Agencia := 'CooK';
            rProd.Importe := 8324.09;
            rProd."Total importe" := 8324.09;
            rProd."Impuestos inc." := TRUE;
            rProd."Importe produccion" := 8324.09;
            rProd."Total importe produccion" := 8324.09;
            rProd."Importe original" := 8324.09;
            rProd."Total original" := 8324.09;
            rProd."Total (CENTRAL)" := 8324.09;
            rProd."Secuencia grabacion" := 8;
            rProd.INSERT;
            //
            rProd.INIT;
            rProd.Hotel := 'MISABEL';
            rProd."Fecha cargo" := 300611D;
            rProd."Fecha proceso" := 300611D;
            rProd.Usuario := 'AUTo';
            rProd.Concepto := 'Regularizacion';
            rProd.Centro := 'HAMP';
            rProd.Cliente := 'MTS';
            rProd.TToo := 'VDLL';
            rProd.Agencia := 'VDLL';
            rProd.Importe := -423.16;
            rProd."Total importe" := -423.16;
            rProd."Impuestos inc." := TRUE;
            rProd."Importe produccion" := -423.16;
            rProd."Total importe produccion" := -423.16;
            rProd."Importe original" := -423.16;
            rProd."Total original" := -423.16;
            rProd."Total (CENTRAL)" := -423.16;
            rProd."Secuencia grabacion" := 9;
            rProd.INSERT;
            //
            rProd.INIT;
            rProd.Hotel := 'MISABEL';
            rProd."Fecha cargo" := 300611D;
            rProd."Fecha proceso" := 300611D;
            rProd.Usuario := 'AUTo';
            rProd.Concepto := 'Regularizacion';
            rProd.Centro := 'HATI';
            rProd.Cliente := 'MTS';
            rProd.TToo := 'VDLL';
            rProd.Agencia := 'VDLL';
            rProd.Importe := 423.16;
            rProd."Total importe" := 423.16;
            rProd."Impuestos inc." := TRUE;
            rProd."Importe produccion" := 423.16;
            rProd."Total importe produccion" := 423.16;
            rProd."Importe original" := 423.16;
            rProd."Total original" := 423.16;
            rProd."Total (CENTRAL)" := 423.16;
            rProd."Secuencia grabacion" := 11;
            rProd.INSERT;
            //
            rProd.INIT;
            rProd.Hotel := 'MISABEL';
            rProd."Fecha cargo" := 300611D;
            rProd."Fecha proceso" := 300611D;
            rProd.Usuario := 'AUTo';
            rProd.Concepto := 'Regularizacion';
            rProd.Centro := 'HAMP';
            rProd.Cliente := 'NUR';
            rProd.TToo := 'CooK';
            rProd.Agencia := 'CooK';
            rProd.Importe := -175.04;
            rProd."Total importe" := -175.04;
            rProd."Impuestos inc." := TRUE;
            rProd."Importe produccion" := -175.04;
            rProd."Total importe produccion" := -175.04;
            rProd."Importe original" := -175.04;
            rProd."Total original" := -175.04;
            rProd."Total (CENTRAL)" := -175.04;
            rProd."Secuencia grabacion" := 12;
            rProd.INSERT;
            //
            rProd.INIT;
            rProd.Hotel := 'MISABEL';
            rProd."Fecha cargo" := 300611D;
            rProd."Fecha proceso" := 300611D;
            rProd.Usuario := 'AUTo';
            rProd.Concepto := 'Regularizacion';
            rProd.Centro := 'HATI';
            rProd.Cliente := 'NUR';
            rProd.TToo := 'CooK';
            rProd.Agencia := 'CooK';
            rProd.Importe := 175.04;
            rProd."Total importe" := 175.04;
            rProd."Impuestos inc." := TRUE;
            rProd."Importe produccion" := 175.04;
            rProd."Total importe produccion" := 175.04;
            rProd."Importe original" := 175.04;
            rProd."Total original" := 175.04;
            rProd."Total (CENTRAL)" := 175.04;
            rProd."Secuencia grabacion" := 13;
            rProd.INSERT;
            //
            rProd.INIT;
            rProd.Hotel := 'MISABEL';
            rProd."Fecha cargo" := 300611D;
            rProd."Fecha proceso" := 300611D;
            rProd.Usuario := 'AUTo';
            rProd.Concepto := 'Regularizacion';
            rProd.Centro := 'HAMP';
            rProd.Cliente := 'XDERTo';
            rProd.TToo := 'DERTo';
            rProd.Agencia := 'DERTo';
            rProd.Importe := -555.08;
            rProd."Total importe" := -555.08;
            rProd."Impuestos inc." := TRUE;
            rProd."Importe produccion" := -555.08;
            rProd."Total importe produccion" := -555.08;
            rProd."Importe original" := -555.08;
            rProd."Total original" := -555.08;
            rProd."Total (CENTRAL)" := -555.08;
            rProd."Secuencia grabacion" := 14;
            rProd.INSERT;
            //
            rProd.INIT;
            rProd.Hotel := 'MISABEL';
            rProd."Fecha cargo" := 300611D;
            rProd."Fecha proceso" := 300611D;
            rProd.Usuario := 'AUTo';
            rProd.Concepto := 'Regularizacion';
            rProd.Centro := 'HATI';
            rProd.Cliente := 'XDERTo';
            rProd.TToo := 'DERTo';
            rProd.Agencia := 'DERTo';
            rProd.Importe := 555.08;
            rProd."Total importe" := 555.08;
            rProd."Impuestos inc." := TRUE;
            rProd."Importe produccion" := 555.08;
            rProd."Total importe produccion" := 555.08;
            rProd."Importe original" := 555.08;
            rProd."Total original" := 555.08;
            rProd."Total (CENTRAL)" := 555.08;
            rProd."Secuencia grabacion" := 15;
            rProd.INSERT;
        END ELSE
            IF rUsr."Hotel de trabajo" = 'CID' THEN BEGIN
                rProd.INIT;
                rProd.Hotel := 'CID';
                rProd."Fecha cargo" := 300611D;
                rProd."Fecha proceso" := 300611D;
                rProd.Usuario := 'AUTo';
                rProd.Concepto := 'Regularizacion';
                rProd.Centro := 'HAMP';
                rProd.Cliente := 'ADRA';
                rProd.TToo := 'IBVSZ';
                rProd.Agencia := 'ADRAGTA';
                rProd.Importe := 583.33;
                rProd."Total importe" := 583.33;
                rProd."Impuestos inc." := TRUE;
                rProd."Importe produccion" := 583.33;
                rProd."Total importe produccion" := 583.33;
                rProd."Importe original" := 583.33;
                rProd."Total original" := 583.33;
                rProd."Total (CENTRAL)" := 583.33;
                rProd."Secuencia grabacion" := 1;
                rProd.INSERT;
                //
                rProd.INIT;
                rProd.Hotel := 'CID';
                rProd."Fecha cargo" := 300611D;
                rProd."Fecha proceso" := 300611D;
                rProd.Usuario := 'AUTo';
                rProd.Concepto := 'Regularizacion';
                rProd.Centro := 'GNoCUP';
                rProd.Cliente := 'ADRA';
                rProd.TToo := 'IBVSZ';
                rProd.Agencia := 'ADRAGTA';
                rProd.Importe := -583.33;
                rProd."Total importe" := -583.33;
                rProd."Impuestos inc." := TRUE;
                rProd."Importe produccion" := -583.33;
                rProd."Total importe produccion" := -583.33;
                rProd."Importe original" := -583.33;
                rProd."Total original" := -583.33;
                rProd."Total (CENTRAL)" := -583.33;
                rProd."Secuencia grabacion" := 2;
                rProd.INSERT;
                //
                rProd.INIT;
                rProd.Hotel := 'CID';
                rProd."Fecha cargo" := 300611D;
                rProd."Fecha proceso" := 300611D;
                rProd.Usuario := 'AUTo';
                rProd.Concepto := 'Regularizacion';
                rProd.Centro := 'REGULP';
                rProd.Cliente := 'ADRA';
                rProd.TToo := 'IBVSZ';
                rProd.Agencia := 'ADRAGTA';
                rProd.Importe := 291.66;
                rProd."Total importe" := 291.66;
                rProd."Impuestos inc." := TRUE;
                rProd."Importe produccion" := 291.66;
                rProd."Total importe produccion" := 291.66;
                rProd."Importe original" := 291.66;
                rProd."Total original" := 291.66;
                rProd."Total (CENTRAL)" := 291.66;
                rProd."Secuencia grabacion" := 17;
                rProd.INSERT;
                //
                rProd.INIT;
                rProd.Hotel := 'CID';
                rProd."Fecha cargo" := 300611D;
                rProd."Fecha proceso" := 300611D;
                rProd.Usuario := 'AUTo';
                rProd.Concepto := 'Regularizacion';
                rProd.Centro := 'SUPGTIA';
                rProd.Cliente := 'ADRA';
                rProd.TToo := 'IBVSZ';
                rProd.Agencia := 'ADRAGTA';
                rProd.Importe := -1000.07;
                rProd."Total importe" := -1000.07;
                rProd."Impuestos inc." := TRUE;
                rProd."Importe produccion" := -1000.07;
                rProd."Total importe produccion" := -1000.07;
                rProd."Importe original" := -1000.07;
                rProd."Total original" := -1000.07;
                rProd."Total (CENTRAL)" := -1000.07;
                rProd."Secuencia grabacion" := 3;
                rProd.INSERT;
                //
                rProd.INIT;
                rProd.Hotel := 'CID';
                rProd."Fecha cargo" := 300611D;
                rProd."Fecha proceso" := 300611D;
                rProd.Usuario := 'AUTo';
                rProd.Concepto := 'Regularizacion';
                rProd.Centro := 'HAMPG';
                rProd.Cliente := 'ADRA';
                rProd.TToo := 'IBVSZ';
                rProd.Agencia := 'ADRAGTA';
                rProd.Importe := 1541.59;
                rProd."Total importe" := 1541.59;
                rProd."Impuestos inc." := TRUE;
                rProd."Importe produccion" := 1541.59;
                rProd."Total importe produccion" := 1541.59;
                rProd."Importe original" := 1541.59;
                rProd."Total original" := 1541.59;
                rProd."Total (CENTRAL)" := 1541.59;
                rProd."Secuencia grabacion" := 5;
                rProd.INSERT;
                //
                rProd.INIT;
                rProd.Hotel := 'CID';
                rProd."Fecha cargo" := 300611D;
                rProd."Fecha proceso" := 300611D;
                rProd.Usuario := 'AUTo';
                rProd.Concepto := 'Regularizacion';
                rProd.Centro := 'HAMP';
                rProd.Cliente := 'ADRA';
                rProd.TToo := 'RoBIN';
                rProd.Agencia := 'ADRAGTA';
                rProd.Importe := 2083.33;
                rProd."Total importe" := 2083.33;
                rProd."Impuestos inc." := TRUE;
                rProd."Importe produccion" := 2083.33;
                rProd."Total importe produccion" := 2083.33;
                rProd."Importe original" := 2083.33;
                rProd."Total original" := 2083.33;
                rProd."Total (CENTRAL)" := 2083.33;
                rProd."Secuencia grabacion" := 6;
                rProd.INSERT;
                //
                rProd.INIT;
                rProd.Hotel := 'CID';
                rProd."Fecha cargo" := 300611D;
                rProd."Fecha proceso" := 300611D;
                rProd.Usuario := 'AUTo';
                rProd.Concepto := 'Regularizacion';
                rProd.Centro := 'SUPGTIA';
                rProd.Cliente := 'ADRA';
                rProd.TToo := 'RoBIN';
                rProd.Agencia := 'ADRAGTA';
                rProd.Importe := -2333.3;
                rProd."Total importe" := -2333.3;
                rProd."Impuestos inc." := TRUE;
                rProd."Importe produccion" := -2333.3;
                rProd."Total importe produccion" := -2333.3;
                rProd."Importe original" := -2333.3;
                rProd."Total original" := -2333.3;
                rProd."Total (CENTRAL)" := -2333.3;
                rProd."Secuencia grabacion" := 7;
                rProd.INSERT;
                //
                rProd.INIT;
                rProd.Hotel := 'CID';
                rProd."Fecha cargo" := 300611D;
                rProd."Fecha proceso" := 300611D;
                rProd.Usuario := 'AUTo';
                rProd.Concepto := 'Regularizacion';
                rProd.Centro := 'HAMPG';
                rProd.Cliente := 'ADRA';
                rProd.TToo := 'RoBIN';
                rProd.Agencia := 'ADRAGTA';
                rProd.Importe := 1833.33;
                rProd."Total importe" := 1833.33;
                rProd."Impuestos inc." := TRUE;
                rProd."Importe produccion" := 1833.33;
                rProd."Total importe produccion" := 1833.33;
                rProd."Importe original" := 1833.33;
                rProd."Total original" := 1833.33;
                rProd."Total (CENTRAL)" := 1833.33;
                rProd."Secuencia grabacion" := 8;
                rProd.INSERT;
                //
                rProd.INIT;
                rProd.Hotel := 'CID';
                rProd."Fecha cargo" := 300611D;
                rProd."Fecha proceso" := 300611D;
                rProd.Usuario := 'AUTo';
                rProd.Concepto := 'Regularizacion';
                rProd.Centro := 'GNoCUP';
                rProd.Cliente := 'MALU';
                rProd.TToo := 'GAMALU';
                rProd.Agencia := 'MALU';
                rProd.Importe := -2333.31;
                rProd."Total importe" := -2333.31;
                rProd."Impuestos inc." := TRUE;
                rProd."Importe produccion" := -2333.31;
                rProd."Total importe produccion" := -2333.31;
                rProd."Importe original" := -2333.31;
                rProd."Total original" := -2333.31;
                rProd."Total (CENTRAL)" := -2333.31;
                rProd."Secuencia grabacion" := 9;
                rProd.INSERT;
                //
                rProd.INIT;
                rProd.Hotel := 'CID';
                rProd."Fecha cargo" := 300611D;
                rProd."Fecha proceso" := 300611D;
                rProd.Usuario := 'AUTo';
                rProd.Concepto := 'Regularizacion';
                rProd.Centro := 'REGULP';
                rProd.Cliente := 'MALU';
                rProd.TToo := 'GAMALU';
                rProd.Agencia := 'MALU';
                rProd.Importe := 3664.38;
                rProd."Total importe" := 3664.38;
                rProd."Impuestos inc." := TRUE;
                rProd."Importe produccion" := 3664.38;
                rProd."Total importe produccion" := 3664.38;
                rProd."Importe original" := 3664.38;
                rProd."Total original" := 3664.38;
                rProd."Total (CENTRAL)" := 3664.38;
                rProd."Secuencia grabacion" := 11;
                rProd.INSERT;
                //
                rProd.INIT;
                rProd.Hotel := 'CID';
                rProd."Fecha cargo" := 300611D;
                rProd."Fecha proceso" := 300611D;
                rProd.Usuario := 'AUTo';
                rProd.Concepto := 'Regularizacion';
                rProd.Centro := 'SUPGTIA';
                rProd.Cliente := 'MALU';
                rProd.TToo := 'GAMALU';
                rProd.Agencia := 'MALU';
                rProd.Importe := -5310.3;
                rProd."Total importe" := -5310.3;
                rProd."Impuestos inc." := TRUE;
                rProd."Importe produccion" := -5310.3;
                rProd."Total importe produccion" := -5310.3;
                rProd."Importe original" := -5310.3;
                rProd."Total original" := -5310.3;
                rProd."Total (CENTRAL)" := -5310.3;
                rProd."Secuencia grabacion" := 12;
                rProd.INSERT;
                //
                rProd.INIT;
                rProd.Hotel := 'CID';
                rProd."Fecha cargo" := 300611D;
                rProd."Fecha proceso" := 300611D;
                rProd.Usuario := 'AUTo';
                rProd.Concepto := 'Regularizacion';
                rProd.Centro := 'HAMPG';
                rProd.Cliente := 'MALU';
                rProd.TToo := 'GAMALU';
                rProd.Agencia := 'MALU';
                rProd.Importe := 6249.66;
                rProd."Total importe" := 6249.66;
                rProd."Impuestos inc." := TRUE;
                rProd."Importe produccion" := 6249.66;
                rProd."Total importe produccion" := 6249.66;
                rProd."Importe original" := 6249.66;
                rProd."Total original" := 6249.66;
                rProd."Total (CENTRAL)" := 6249.66;
                rProd."Secuencia grabacion" := 12;
                rProd.INSERT;
                //
                rProd.INIT;
                rProd.Hotel := 'CID';
                rProd."Fecha cargo" := 300611D;
                rProd."Fecha proceso" := 300611D;
                rProd.Usuario := 'AUTo';
                rProd.Concepto := 'Regularizacion';
                rProd.Centro := 'REGULP';
                rProd.Cliente := 'MALU';
                rProd.TToo := 'GBMALU';
                rProd.Agencia := 'MALU';
                rProd.Importe := 875.07;
                rProd."Total importe" := 875.07;
                rProd."Impuestos inc." := TRUE;
                rProd."Importe produccion" := 875.07;
                rProd."Total importe produccion" := 875.07;
                rProd."Importe original" := 875.07;
                rProd."Total original" := 875.07;
                rProd."Total (CENTRAL)" := 875.07;
                rProd."Secuencia grabacion" := 13;
                rProd.INSERT;
                //
                rProd.INIT;
                rProd.Hotel := 'CID';
                rProd."Fecha cargo" := 300611D;
                rProd."Fecha proceso" := 300611D;
                rProd.Usuario := 'AUTo';
                rProd.Concepto := 'Regularizacion';
                rProd.Centro := 'SUPGTIA';
                rProd.Cliente := 'MALU';
                rProd.TToo := 'GBMALU';
                rProd.Agencia := 'MALU';
                rProd.Importe := -2375.19;
                rProd."Total importe" := -2375.19;
                rProd."Impuestos inc." := TRUE;
                rProd."Importe produccion" := -2375.19;
                rProd."Total importe produccion" := -2375.19;
                rProd."Importe original" := -2375.19;
                rProd."Total original" := -2375.19;
                rProd."Total (CENTRAL)" := -2375.19;
                rProd."Secuencia grabacion" := 14;
                rProd.INSERT;
                //
                rProd.INIT;
                rProd.Hotel := 'CID';
                rProd."Fecha cargo" := 300611D;
                rProd."Fecha proceso" := 300611D;
                rProd.Usuario := 'AUTo';
                rProd.Concepto := 'Regularizacion';
                rProd.Centro := 'HAMPG';
                rProd.Cliente := 'MALU';
                rProd.TToo := 'GBMALU';
                rProd.Agencia := 'MALU';
                rProd.Importe := 2374.81;
                rProd."Total importe" := 2374.81;
                rProd."Impuestos inc." := TRUE;
                rProd."Importe produccion" := 2374.81;
                rProd."Total importe produccion" := 2374.81;
                rProd."Importe original" := 2374.81;
                rProd."Total original" := 2374.81;
                rProd."Total (CENTRAL)" := 2374.81;
                rProd."Secuencia grabacion" := 16;
                rProd.INSERT;
            END;
    end;

    
    procedure focupantes()
    var
        rocupantes: Record 7000178;
        rCompocu: Record 7000178;
        wControl: Integer;
        wRepetidores: Integer;
    begin
        //Mira en la tabla ocupantes los clientes que han visitado el hotel y los marca como repetidores.

        Ventana.oPEN('Comprobando los nºs de documento #1########## \ ocupantes marcados #2#####', rocupantes.Documento, wRepetidores);
        rocupantes.SETCURRENTKEY(Hotel, "Pais residencia", Documento, "Check In", "Fecha entrada", "Fecha salida");
        rCompocu.SETCURRENTKEY(Hotel, "Pais residencia", Documento, "Check In", "Fecha entrada", "Fecha salida");
        rocupantes.SETFILTER(rocupantes."Titular Tarjeta", '<>%1', '');
        rocupantes.SETRANGE(rocupantes."Check In", TRUE);
        //rocupantes.SETRANGE(rocupantes."Check out",TRUE);
        IF rocupantes.FIND('-') THEN BEGIN
            REPEAT
                wControl := 2;
                rCompocu.SETRANGE(rCompocu."Titular Tarjeta", rocupantes."Titular Tarjeta");
                rCompocu.SETRANGE(rCompocu."Check In", TRUE);
                IF rCompocu.FIND('-') THEN BEGIN
                    REPEAT
                        wControl := wControl - 1;
                        //  IF (wControl<=0) AND (rocupantes.Repetidores=FALSE) THEN BEGIN
                        //    rocupantes.Repetidores:=TRUE;
                        rocupantes.MoDIFY;
                        wRepetidores := wRepetidores + 1;
                        //    END;
                    UNTIL rCompocu.NEXT = 0;
                END;
                Ventana.UPDATE;
            UNTIL rocupantes.NEXT = 0;
        END;
        IF wRepetidores <> 0 THEN
            MESSAGE('Se han marcado como Repetidores %1 ocupantes', wRepetidores)
        ELSE
            MESSAGE('No se ha marcado ningun ocupante como Repetidor');
    end;

    
    procedure fRepetidores(wDocumento: Code[20]) wVisitas: Integer
    var
        rocupantes: Record 7000178;
        rCompocu: Record 7000178;
        wControl: Integer;
        wRepetidores: Integer;
    begin
        //Mira en la tabla ocupantes si ya existe una ficha del cliente y nos devuelve True o False

        rocupantes.SETCURRENTKEY(Hotel, "Pais residencia", Documento, "Check In", "Fecha entrada", "Fecha salida");
        rocupantes.SETRANGE(rocupantes."Titular Tarjeta", wDocumento);
        rocupantes.SETRANGE(rocupantes."Check In", TRUE);
        rocupantes.SETRANGE(rocupantes."Check out", TRUE);
        IF rocupantes.FIND('-') THEN BEGIN
            REPEAT
                wVisitas := wVisitas + 1;
            UNTIL rocupantes.NEXT = 0;
        END;
    end;

    
    procedure fRepRollBack()
    var
        rocupantes: Record 7000178;
        wRestaurados: Integer;
    begin
        //Quita la marca de "Repetidor" a todos los ocupantes de la tabla.

        Ventana.oPEN('Comprobando los nºs de documento #1########## \ ocupantes restablecidos #2#####', rocupantes.Documento, wRestaurados);

        //rocupantes.SETCURRENTKEY(Repetidores);
        //rocupantes.SETRANGE(rocupantes.Repetidores,TRUE);
        IF rocupantes.FIND('-') THEN BEGIN
            REPEAT
                //rocupantes.Repetidores:=FALSE;
                rocupantes.MoDIFY;
                wRestaurados := wRestaurados + 1;
                Ventana.UPDATE;
            UNTIL rocupantes.NEXT = 0;
        END;

        IF wRestaurados <> 0 THEN
            MESSAGE('%1 ocupantes han sido restablecidos a "No repetidor"', wRestaurados)
        ELSE
            MESSAGE('No hay clientes repetidores que desmarcar');
    end;

    
    procedure focuDoc()
    var
        rocupantes: Record 7000178;
        wPunto: Text[50];
        wComa: Text[1];
        wGuion: Text[1];
        wGuion2: Text[1];
        wEspacio: Text[1];
        wNuevoValor: Text[1];
        wNuevo: Text[30];
        wEstandarizado: Integer;
        wAntiguo: Text[30];
    begin
        //Pone el nº de documento sin formato en el campo correspondiente.

        //Defino las variables

        wPunto := '.-_/\?,;´`çÇ+]*^[¡¿=)(&%$·#"@!|ºª\<>+';


        Ventana.oPEN('Comprobando los nºs de documento #1########## \ Nuevo nº de Documento #2######## \' +
                     'Modificados #3#######', rocupantes.Documento, wNuevo, wEstandarizado);

        rocupantes.SETCURRENTKEY(Hotel, "Pais residencia", Documento, "Check In", "Fecha entrada", "Fecha salida");
        rocupantes.SETFILTER(rocupantes.Documento, '<>%1', '');
        IF rocupantes.FIND('-') THEN BEGIN
            REPEAT
                wAntiguo := rocupantes.Documento;
                wNuevo := DELCHR(rocupantes.Documento, '=', wPunto);
                wNuevo := DELCHR(wNuevo);
                rocupantes."Titular Tarjeta" := wNuevo;
                rocupantes.MoDIFY;
                wEstandarizado := wEstandarizado + 1;
                Ventana.UPDATE;
            UNTIL rocupantes.NEXT = 0
        END;
        /*
        CoMMIT;
        rocupantes.RESET;
        rocupantes.SETFILTER(rocupantes.Documento,'<>%1','');
        IF rocupantes.FIND('-') THEN BEGIN
          REPEAT
          wAntiguo:=rocupantes."Documento Sin Formato";
          wNuevo:=DELCHR(wAntiguo);
          rocupantes."Documento Sin Formato":=wNuevo;
          rocupantes.MoDIFY;
          wEstandarizado:=wEstandarizado+1;
          Ventana.UPDATE;
          UNTIL rocupantes.NEXT=0
        END;
        */


        MESSAGE('Se han estandarizado %1 nºs de Documento', wEstandarizado);

    end;

    
    procedure fDocRollBack()
    var
        rocupantes: Record 7000178;
        wRestaurado: Integer;
    begin
        //INNECESARIA

        //Restaura los cambios realizados por la funcion anterior
        Ventana.oPEN('Comprobando los nºs de documento #1########## \Nuevo nº de Documento #2######## \' +
                     'Restaurados #3#######', rocupantes.Documento, rocupantes."Titular Tarjeta", wRestaurado);

        rocupantes.SETFILTER(rocupantes."Titular Tarjeta", '<>%1', '');
        IF rocupantes.FIND('-') THEN BEGIN
            REPEAT
                Ventana.UPDATE;
                rocupantes.Documento := rocupantes."Titular Tarjeta";
                rocupantes."Titular Tarjeta" := '';
                rocupantes.MoDIFY;
                wRestaurado := wRestaurado + 1;

            UNTIL rocupantes.NEXT = 0
        END;
        IF wRestaurado = 0 THEN
            MESSAGE('No hay documentos que restaurar')
        ELSE
            MESSAGE('Se han restaurado %1 ocupantes', wRestaurado);
    end;

    
    procedure fIva()
    var
        rGRIva: Record "324;
        rCuenta: Record "15;
        rConfig: Record "325;
        rGRCon: Record "251;
        rConfigGC: Record "252;
        w7: Integer;
        w16: Integer;
        rLinIva: Record "256;
        rGRConta: Record "250;
    begin


        /*
        rCuenta.RESET;
        rCuenta.SETRANGE(rCuenta."No.",'4720008');
        IF rCuenta.FIND('-') THEN BEGIN
          rCuenta."No.":='4720008';
          rCuenta."Income/Balance":=1;
          rCuenta."Consol. Debit Acc.":='4720008';
          rCuenta."Consol. Credit Acc.":='4720008';
          rCuenta.Indentation:=4;
          rCuenta.Name:='H.P. IVA SoPoRTADo 8%';
          rCuenta."Search Name":='H.P. IVA SoPoRTADo 8%';
          rCuenta.MoDIFY
        END ELSE BEGIN
          rCuenta.INIT;
          rCuenta."No.":='4720008';
          rCuenta."Income/Balance":=1;
          rCuenta."Consol. Debit Acc.":='4720008';
          rCuenta."Consol. Credit Acc.":='4720008';
          rCuenta.Name:='H.P. IVA SoPoRTADo 8%';
          rCuenta."Search Name":='H.P. IVA SoPoRTADo 8%';
          rCuenta.Indentation:=4;
          rCuenta.INSERT(TRUE)
        END;
        rCuenta.RESET;
        rCuenta.SETRANGE(rCuenta."No.",'4720018');
        IF rCuenta.FIND('-') THEN BEGIN
          rCuenta."No.":='4720018';
          rCuenta."Consol. Debit Acc.":='4720018';
          rCuenta."Consol. Credit Acc.":='4720018';
          rCuenta."Income/Balance":=1;
          rCuenta.Indentation:=4;
          rCuenta.Name:='H.P. IVA SoPoRTADo 18%';
          rCuenta."Search Name":='H.P. IVA SoPoRTADo 18%';
          rCuenta.MoDIFY
        END ELSE BEGIN
          rCuenta.INIT;
          rCuenta."No.":='4720018';
          rCuenta."Income/Balance":=1;
          rCuenta."Consol. Debit Acc.":='4720018';
          rCuenta."Consol. Credit Acc.":='4720018';
          rCuenta.Indentation:=4;
          rCuenta.Name:='H.P. IVA SoPoRTADo 18%';
          rCuenta."Search Name":='H.P. IVA SoPoRTADo 18%';
        
          rCuenta.INSERT(TRUE)
        END;
        
        rCuenta.RESET;
        rCuenta.SETRANGE(rCuenta."No.",'4770008');
        IF rCuenta.FIND('-') THEN BEGIN
          rCuenta."No.":='4770008';
          rCuenta."Income/Balance":=1;
          rCuenta."Consol. Debit Acc.":='4770008';
          rCuenta."Consol. Credit Acc.":='4770008';
          rCuenta.Indentation:=4;
          rCuenta.Name:='H.P. IVA REPERCUTIDo 8%';
          rCuenta."Search Name":='H.P. IVA REPERCUTIDo 8%';
          rCuenta.MoDIFY
        END ELSE BEGIN
          rCuenta.INIT;
          rCuenta."No.":='4770008';
          rCuenta."Income/Balance":=1;
          rCuenta."Consol. Debit Acc.":='4770008';
          rCuenta.Name:='H.P. IVA REPERCUTIDo 8%';
          rCuenta."Search Name":='H.P. IVA REPERCUTIDo 8%';
          rCuenta."Consol. Credit Acc.":='4770008';
          rCuenta.Indentation:=4;
          rCuenta.INSERT(TRUE)
        END;
        rCuenta.RESET;
        rCuenta.SETRANGE(rCuenta."No.",'4770018');
        IF rCuenta.FIND('-') THEN BEGIN
          rCuenta."No.":='4770018';
          rCuenta."Consol. Debit Acc.":='4770018';
          rCuenta."Consol. Credit Acc.":='4770018';
          rCuenta."Income/Balance":=1;
          rCuenta.Name:='H.P. IVA REPERCUTIDo 18%';
          rCuenta."Search Name":='H.P. IVA REPERCUTIDo 18%';
          rCuenta.Indentation:=4;
          rCuenta.MoDIFY
        END ELSE BEGIN
          rCuenta.INIT;
          rCuenta."No.":='4770018';
          rCuenta."Income/Balance":=1;
          rCuenta."Consol. Debit Acc.":='4770018';
          rCuenta.Name:='H.P. IVA REPERCUTIDo 18%';
          rCuenta."Search Name":='H.P. IVA REPERCUTIDo 18%';
          rCuenta."Consol. Credit Acc.":='4770018';
          rCuenta.Indentation:=4;
          rCuenta.INSERT(TRUE)
        END;
        
        
        CoMMIT;
        
        rGRIva.RESET;
        rGRIva.SETRANGE(rGRIva.Code,'8');
        IF rGRIva.FIND('-') THEN MESSAGE('El grupo de IVA 8 ya existe')
        ELSE BEGIN
          rGRIva.INIT;
          rGRIva.Code:='8';
          rGRIva.Description:='Iva al 8';
          rGRIva.INSERT(TRUE)
        END;
        
        rGRIva.RESET;
        rGRIva.SETRANGE(rGRIva.Code,'18');
        IF rGRIva.FIND('-') THEN MESSAGE('El grupo de IVA 18 ya existe')
        ELSE BEGIN
          rGRIva.INIT;
          rGRIva.Code:='18';
          rGRIva.Description:='Iva al 18';
          rGRIva.INSERT(TRUE)
        END;
        
        CoMMIT;
        
        rConfig.RESET;
        rConfig.SETRANGE(rConfig."VAT Bus. Posting Group",'GENERAL');
        rConfig.SETRANGE(rConfig."VAT Prod. Posting Group",'8');
        IF rConfig.FIND('-') THEN BEGIN
          rConfig."VAT Identifier":='8';
          rConfig."VAT %":=8;
          rConfig."% IRPF":=19;
          rConfig."VAT Prod. Posting Group":='8';
          rConfig."Sales VAT Account":='4770008';
          rConfig."Purchase VAT Account":='4720008';
          rConfig.MoDIFY
        END ELSE BEGIN
          rConfig.INIT;
          rConfig."VAT Bus. Posting Group":='GENERAL';
          rConfig."VAT+EC %":=8;
          rConfig."VAT Identifier":='8';
          rConfig."VAT %":=8;
          rConfig."% IRPF":=19;
          rConfig."VAT Prod. Posting Group":='8';
          rConfig."Sales VAT Account":='4770008';
          rConfig."Purchase VAT Account":='4720008';
          rConfig.INSERT(TRUE)
        END;
        
        
        
        rConfig.RESET;
        rConfig.SETRANGE(rConfig."VAT Bus. Posting Group",'GENERAL');
        rConfig.SETRANGE(rConfig."VAT Prod. Posting Group",'18');
        IF rConfig.FIND('-') THEN BEGIN
          rConfig."VAT Identifier":='18';
          rConfig."VAT %":=18;
          rConfig."% IRPF":=19;
          rConfig."VAT Prod. Posting Group":='18';
          rConfig."Sales VAT Account":='4770018';
          rConfig."Purchase VAT Account":='4720018';
          rConfig.MoDIFY
        END ELSE BEGIN
          rConfig.INIT;
          rConfig."VAT Bus. Posting Group":='GENERAL';
          rConfig."VAT+EC %":=18;
          rConfig."VAT Identifier":='18';
          rConfig."VAT %":=18;
          rConfig."% IRPF":=19;
          rConfig."VAT Prod. Posting Group":='18';
          rConfig."Sales VAT Account":='4770018';
          rConfig."Purchase VAT Account":='4720018';
          rConfig.INSERT(TRUE)
        END;
        
        rGRCon.RESET;
        rGRCon.SETRANGE(rGRCon.Code,'8');
        IF rGRCon.FIND('-') THEN BEGIN
          rGRCon.Code:='8';
          rGRCon."Def. VAT Prod. Posting Group":='8';
          rGRCon.Description:='Iva al 8';
          rGRCon.MoDIFY;
        END ELSE BEGIN
          rGRCon.INIT;
          rGRCon.Code:='8';
          rGRCon.Description:='Iva al 8';
          rGRCon.INSERT;
        END;
        
        rGRCon.RESET;
        rGRCon.SETRANGE(rGRCon.Code,'7');
        IF rGRCon.FIND('-') THEN BEGIN
          rGRCon.Code:='7';
          rGRCon."Def. VAT Prod. Posting Group":='7';
          rGRCon.Description:='Iva al 7';
          rGRCon.MoDIFY;
        END ELSE BEGIN
          rGRCon.INIT;
          rGRCon.Code:='7';
          rGRCon.Description:='Iva al 7';
          rGRCon.INSERT;
        END;
        
        rGRCon.RESET;
        rGRCon.SETRANGE(rGRCon.Code,'16');
        IF rGRCon.FIND('-') THEN BEGIN
          rGRCon.Code:='16';
          rGRCon."Def. VAT Prod. Posting Group":='16';
          rGRCon.Description:='Iva al 16';
          rGRCon.MoDIFY;
        END ELSE BEGIN
          rGRCon.INIT;
          rGRCon.Code:='16';
          rGRCon.Description:='Iva al 16';
          rGRCon.INSERT;
        END;
        
        rGRCon.RESET;
        rGRCon.SETRANGE(rGRCon.Code,'18');
        IF rGRCon.FIND('-') THEN BEGIN
          rGRCon.Code:='18';
          rGRCon."Def. VAT Prod. Posting Group":='18';
          rGRCon.Description:='Iva al 18';
          rGRCon.MoDIFY;
        END ELSE BEGIN
          rGRCon.INIT;
          rGRCon.Code:='18';
          rGRCon.Description:='Iva al 18';
          rGRCon.INSERT;
        END;
        
        CoMMIT;
        
        rConfigGC.RESET;
        rConfigGC.SETRANGE(rConfigGC."Gen. Bus. Posting Group",'GENERAL');
        rConfigGC.SETRANGE(rConfigGC."Gen. Prod. Posting Group",'8');
        IF rConfigGC.FIND('-') THEN MESSAGE('La configuracion del grupo 8 ya fue realizada anteriormente')
        ELSE BEGIN
          rConfigGC.INIT;
          rConfigGC."Gen. Bus. Posting Group":='GENERAL';
          rConfigGC."Gen. Prod. Posting Group":='8';
          rConfigGC.INSERT;
        END;
        
        rConfigGC.RESET;
        rConfigGC.SETRANGE(rConfigGC."Gen. Bus. Posting Group",'GENERAL');
        rConfigGC.SETRANGE(rConfigGC."Gen. Prod. Posting Group",'18');
        IF rConfigGC.FIND('-') THEN MESSAGE('La configuracion del grupo 18 ya fue realizada anteriormente')
        ELSE BEGIN
          rConfigGC.INIT;
          rConfigGC."Gen. Bus. Posting Group":='GENERAL';
          rConfigGC."Gen. Prod. Posting Group":='18';
          rConfigGC.INSERT;
        END;
        
        CoMMIT;
        
        rCuenta.RESET;
        rCuenta.SETRANGE(rCuenta."Gen. Prod. Posting Group",'7');
        IF rCuenta.FIND('-') THEN BEGIN
          REPEAT
          rCuenta."Gen. Prod. Posting Group":='8';
          rCuenta.MoDIFY;
        //w7:=w7+1;
          UNTIL rCuenta.NEXT=0
        END;
        
        rCuenta.RESET;
        rCuenta.SETRANGE(rCuenta."Gen. Prod. Posting Group",'16');
        IF rCuenta.FIND('-') THEN BEGIN
          REPEAT
          rCuenta."Gen. Prod. Posting Group":='18';
          rCuenta.MoDIFY;
        //w16:=w16+1;
          UNTIL rCuenta.NEXT=0
        END;
        */

        //PRoCESo INTRACoMUNITARIo

        rGRIva.SETRANGE(rGRIva.Code, 'INTRA');
        IF NoT rGRIva.FIND('-') THEN BEGIN
            rGRIva.Code := 'INTRA';
            rGRIva.Description := 'Iva Intracomunitario';
            rGRIva.INSERT(TRUE);
        END;
        CoMMIT;

        rGRCon.RESET;
        rGRCon.SETRANGE(rGRCon.Code, 'EU');
        IF rGRCon.FIND('-') THEN BEGIN
            rGRCon.Code := 'EU';
            rGRCon."Def. VAT Prod. Posting Group" := 'INTRA';
            rGRCon.Description := 'Iva Intracomunitario';
            rGRCon.MoDIFY;
        END ELSE BEGIN
            rGRCon.INIT;
            rGRCon.Code := 'EU';
            rGRCon.Description := 'Iva Intracomunitario';
            rGRCon.INSERT;
        END;

        CoMMIT;

        rGRConta.RESET;
        rGRConta.SETRANGE(rGRConta.Code, 'UE');
        IF rGRCon.FIND('-') THEN BEGIN
            rGRConta.Code := 'UE';
            rGRConta.Description := 'Iva Intracomunitario';
            rGRConta."Def. VAT Bus. Posting Group" := 'UE';
            rGRConta."Auto Insert Default" := TRUE;
            rGRCon.MoDIFY;
        END ELSE BEGIN
            rGRConta.INIT;
            rGRConta.Code := 'UE';
            rGRConta.Description := 'Iva Intracomunitario';
            rGRConta."Def. VAT Bus. Posting Group" := 'UE';
            rGRConta."Auto Insert Default" := TRUE;
            rGRConta.INSERT(TRUE);
        END;

        CoMMIT;

        rConfigGC.RESET;
        rConfigGC.SETRANGE(rConfigGC."Gen. Bus. Posting Group", 'UE');
        rConfigGC.SETRANGE(rConfigGC."Gen. Prod. Posting Group", 'INTRA');
        IF NoT rConfigGC.FIND('-') THEN BEGIN
            rConfigGC.INIT;
            rConfigGC."Gen. Bus. Posting Group" := 'UE';
            rConfigGC."Gen. Prod. Posting Group" := 'INTRA';
            rConfigGC.INSERT;
        END;

        CoMMIT;

        rCuenta.RESET;
        rCuenta.SETRANGE(rCuenta."No.", '4720110');
        IF rCuenta.FIND('-') THEN BEGIN
            rCuenta."No." := '4720110';
            rCuenta."Income/Balance" := 1;
            rCuenta."Consol. Debit Acc." := '4720110';
            rCuenta."Consol. Credit Acc." := '4720110';
            rCuenta.Indentation := 4;
            rCuenta.Name := 'H.P. IVA SoPoRT. BASE INTRA';
            rCuenta."Search Name" := 'H.P. IVA SoPoRT. BASE INTRA';
            rCuenta.MoDIFY
        END ELSE BEGIN
            rCuenta.INIT;
            rCuenta."No." := '4720110';
            rCuenta."Income/Balance" := 1;
            rCuenta."Consol. Debit Acc." := '4720110';
            rCuenta."Consol. Credit Acc." := '4720110';
            rCuenta.Name := 'H.P. IVA SoPoRT BASE INTRA';
            rCuenta."Search Name" := 'H.P. IVA SoPoRT. BASE INTRA';
            rCuenta.Indentation := 4;
            rCuenta.INSERT(TRUE)
        END;

        CoMMIT;

        rConfig.RESET;
        rConfig.SETRANGE(rConfig."VAT Bus. Posting Group", 'UE');
        rConfig.SETRANGE(rConfig."VAT Prod. Posting Group", 'INTRA');
        IF rConfig.FIND('-') THEN BEGIN
            rConfig."VAT Bus. Posting Group" := 'UE';
            rConfig."VAT Identifier" := 'INTRA';
            rConfig."VAT %" := 0;
            rConfig."% IRPF" := 19;
            rConfig."VAT Prod. Posting Group" := 'INTRA';
            rConfig."Sales VAT Account" := '';
            rConfig."Purchase VAT Account" := '4720110';
            rConfig.MoDIFY
        END ELSE BEGIN
            rConfig.INIT;
            rConfig."VAT Bus. Posting Group" := 'UE';
            rConfig."VAT+EC %" := 0;
            rConfig."VAT Identifier" := 'INTRA';
            rConfig."VAT %" := 0;
            rConfig."% IRPF" := 19;
            rConfig."VAT Prod. Posting Group" := 'INTRA';
            rConfig."Sales VAT Account" := '';
            rConfig."Purchase VAT Account" := '4720110';
            rConfig.INSERT(TRUE)
        END;

        CoMMIT;

    end;

    
    procedure fResFix()
    var
        rRes: Record 7000176;
        rResFIX: Record 7000176;
        wRes: Integer;
    begin
        Ventana.oPEN(' #1##### Reservas borradas', wRes);
        rRes.RESET;
        rRes.SETRANGE(rRes.Ano, 2009);

        rRes.SETRANGE(rRes."Fecha entrada", 010710D);
        IF rRes.FIND('-') THEN BEGIN
            REPEAT
                IF (rRes."Fecha entrada") >= (rRes."Fecha salida") THEN BEGIN
                    //  MESSAGE('%1/%2 fecha entrada %3 fecha salida %4',rRes.Reserva,rRes.Desglose,rRes."Fecha entrada",rRes."Fecha salida");
                    rRes.ValReservasLigadas2;
                    wRes := wRes + 1;
                    Ventana.UPDATE;
                END;
            UNTIL rRes.NEXT = 0
        END;
        MESSAGE('Se han borrado un total de %1 Reservas', wRes);
    end;

    
    procedure fIvaocu()
    var
        rocu: Record 7000178;
    begin

        rocu.SETRANGE(rocu."Fecha entrada", 010710D);
        rocu.SETRANGE(rocu."Tipo persona", 0);
        rocu.SETFILTER(rocu.Desglose, '<>%1', '1');
        IF rocu.FIND('-') THEN BEGIN
            REPEAT
                rocu."Nombre padre" := 'TUTUP';
                rocu.MoDIFY;
            UNTIL rocu.NEXT = 0
        END;

        CoMMIT;

        rocu.RESET;
        rocu.SETRANGE(rocu."Fecha entrada", 010710D);
        rocu.SETRANGE(rocu."Tipo persona", 0);
        rocu.SETFILTER(rocu.Desglose, '<>%1', '1');
        rocu.SETRANGE(rocu."Nombre padre", 'TUTUP');
        IF rocu.FIND('-') THEN BEGIN
            REPEAT
                rocu."Tipo persona" := 2;
                rocu.MoDIFY;
            UNTIL rocu.NEXT = 0;
        END;
    end;

    
    procedure fIvaocuRecupera()
    var
        rocu: Record 7000178;
    begin


        rocu.RESET;
        rocu.SETRANGE(rocu."Fecha entrada", 010710D);
        rocu.SETRANGE(rocu."Tipo persona", 2);
        rocu.SETFILTER(rocu.Desglose, '<>%1', '1');
        rocu.SETRANGE(rocu."Nombre padre", 'TUTUP');
        IF rocu.FIND('-') THEN BEGIN
            REPEAT
                rocu."Tipo persona" := 0;
                rocu.MoDIFY;
            UNTIL rocu.NEXT = 0
        END;
    end;

    
    procedure fEur()
    var
        rVendor: Record "23;
        wRegs: Integer;
        rDoc: Record 7000002;
        rMov: Record "25;
        rMovDet: Record "380;
        rCustomer: Record "18;
        rMovCli: Record "21;
    begin
        /*
        Ventana.oPEN('Cambiando divisa de #1########  nº de registros cambiados #2######',rVendor.Name,wRegs);
        IF rVendor.FIND('-') THEN BEGIN
          REPEAT
          IF rVendor."Currency Code"<>'EUR' THEN BEGIN
            rVendor."Currency Code":='EUR';
            rVendor.MoDIFY;
            wRegs:=wRegs+1;
            Ventana.UPDATE
          END;
          UNTIL rVendor.NEXT=0;
        END;
        MESSAGE('Se han modificado %1 Proveedores',wRegs);
        wRegs:=0;
        Ventana.oPEN('Lineas modificadas en Doc Cartera #1#######',wRegs);
        rDoc.SETRANGE(rDoc."Due Date",300710D,300810D);
        rDoc.SETRANGE(rDoc."Bill Gr./Pmt. order No.",'CoNF00034');
        IF rDoc.FIND('-') THEN BEGIN
          REPEAT
            rDoc."Currency Code":='EUR';
            rDoc.MoDIFY;
            wRegs:=wRegs+1;
          UNTIL rDoc.NEXT=0
        END;
        
        MESSAGE ('Se han modificado %1 lineas',wRegs);
        */

        Ventana.oPEN('Actualizando proveedor #1######### \ Proveedores actualizados #2######', rVendor."No.", wRegs);

        IF rVendor.FIND('-') THEN BEGIN
            REPEAT
                IF rVendor."Currency Code" = 'EUR' THEN BEGIN
                    rVendor."Currency Code" := '';
                    rVendor.MoDIFY;
                    wRegs := wRegs + 1;
                    Ventana.UPDATE;
                END;
            UNTIL rVendor.NEXT = 0;
        END;

        IF rCustomer.FIND('-') THEN BEGIN
            REPEAT
                IF rCustomer."Currency Code" = '' THEN BEGIN
                    rCustomer."Currency Code" := 'EUR';
                    rCustomer.MoDIFY;
                    wRegs := wRegs + 1;
                    Ventana.UPDATE;
                END;
            UNTIL rCustomer.NEXT = 0;
        END;
        CoMMIT;


        MESSAGE('Se han actualizado %1 proveedores', wRegs);
        wRegs := 0;
        IF CoNFIRM('Deseas continuar actualizando los movimientos?') THEN BEGIN
            Ventana.oPEN('Movimientos con cambio de divisa %1', wRegs);
            rMov.RESET;
            rMov.SETRANGE(rMov."Currency Code", 'EUR');
            IF rMov.FIND('-') THEN BEGIN
                REPEAT
                    rMov."Currency Code" := '';
                    rMov.MoDIFY;
                    wRegs := wRegs + 1;
                    Ventana.UPDATE;
                UNTIL rMov.NEXT = 0
            END;
            rMovDet.RESET;
            rMovDet.SETRANGE(rMovDet."Currency Code", 'EUR');
            IF rMovDet.FIND('-') THEN BEGIN
                REPEAT
                    rMovDet."Currency Code" := '';
                    rMovDet.MoDIFY;
                    wRegs := wRegs + 1;
                UNTIL rMovDet.NEXT = 0
            END;
        END;

        CoMMIT;

        rMovCli.RESET;
        rMovCli.SETRANGE(rMovCli."Currency Code", '');
        IF rMovCli.FIND('-') THEN BEGIN
            REPEAT
                rMovCli."Currency Code" := 'EUR';
                rMovCli.MoDIFY;
                wRegs := wRegs + 1;
            UNTIL rMovCli.NEXT = 0;
        END;

        CoMMIT;

        MESSAGE('Se ha cambiado la divisa de %1 movimientos', wRegs);


        CoMMIT;

    end;

    
    procedure fNacion(wFecha: Date)
    var
        rocu: Record 7000178;
    begin
        Ventana.oPEN('Reparando errores habituales de Pais para el dia #1########', wFecha);
        rocu.SETCURRENTKEY(Hotel, "Pais residencia", Documento, "Check In", "Fecha entrada", "Fecha salida");
        rocu.SETRANGE(rocu."Fecha entrada", wFecha);

        //rocu.SETRANGE(rocu."Tipo persona",0);
        IF rocu.FIND('-') THEN BEGIN
            REPEAT
                IF (rocu."Pais residencia" <> '') AND (rocu."Pais nacimiento" <> rocu."Pais residencia") THEN BEGIN
                    rocu."Pais nacimiento" := rocu."Pais residencia";
                    rocu.MoDIFY;
                END;
                CoMMIT;
                IF (rocu."Pais nacimiento" <> '') AND (rocu."Pais residencia" = '') THEN BEGIN
                    rocu."Pais residencia" := rocu."Pais nacimiento";
                    rocu.MoDIFY;
                END;
                CoMMIT;
                IF (rocu."Pais nacimiento" <> '') AND (rocu.Nacionalidad = '') THEN BEGIN
                    rocu.Nacionalidad := rocu."Pais nacimiento";
                    rocu.MoDIFY;
                END;
                CoMMIT;
                IF (rocu."Pais residencia" = 'SP') oR (rocu."Pais nacimiento" = 'SP') oR (rocu.Nacionalidad = 'SP') THEN BEGIN
                    rocu."Pais nacimiento" := 'ESP';
                    rocu."Pais residencia" := 'ESP';
                    rocu.Nacionalidad := 'ESP';
                    rocu.MoDIFY;
                END;
                CoMMIT;
                IF (rocu."Pais residencia" = 'ES') oR (rocu."Pais nacimiento" = 'ES') oR (rocu.Nacionalidad = 'ES') THEN BEGIN
                    rocu."Pais nacimiento" := 'ESP';
                    rocu."Pais residencia" := 'ESP';
                    rocu.Nacionalidad := 'ESP';
                    rocu.MoDIFY;
                END;
                CoMMIT;
            UNTIL rocu.NEXT = 0;
        END;
    end;

    
    procedure fCentro()
    var
        rLinProd: Record 7000206;
        WfECHA: Date;
        wCount: Integer;
    begin

        Ventana.oPEN('Comprobando Fecha #1######## \ Tipo de Registro #2####### \ ' +
                      'Registros Actualizados #3#######', WfECHA, rLinProd."Regimen factura", wCount);

        FoR WfECHA := 010111D To 311211D Do BEGIN
            rLinProd.SETRANGE(rLinProd.Centro, 'ALoJ');
            rLinProd.SETRANGE(rLinProd."Fecha cargo", WfECHA);
            CoMMIT;
            IF rLinProd.FIND('-') THEN BEGIN
                REPEAT

                    IF (rLinProd."Regimen factura" = 'HA') AND (rLinProd.Centro <> 'HASA') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HASA', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                    IF (rLinProd."Regimen factura" = 'HD') AND (rLinProd.Centro <> 'HAHD') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HAHD', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                    IF (rLinProd."Regimen factura" = 'MP') AND (rLinProd.Centro <> 'HAMP') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HAMP', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                    IF (rLinProd."Regimen factura" = 'PC') AND (rLinProd.Centro <> 'HAPC') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HAPC', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;
                    IF (rLinProd."Regimen factura" = 'TI') AND (rLinProd.Centro <> 'HATI') THEN BEGIN
                        rLinProd.RENAME(rLinProd.Hotel, rLinProd."Fecha cargo", 'HATI', rLinProd."Fecha proceso", rLinProd."Secuencia grabacion");
                        wCount := wCount + 1;
                        Ventana.UPDATE;
                        IF rLinProd.FIND('-') THEN;
                    END;


                UNTIL rLinProd.NEXT = 0;
            END;
        END;
        MESSAGE('Se han actualizado %1 registros', wCount);
    end;

    
    procedure fDesbloq()
    var
        rItem: Record "27;
    begin
        rItem.SETRANGE(rItem.Blocked, TRUE);
        IF rItem.FIND('-') THEN BEGIN
            REPEAT
                rItem.Blocked := FALSE;
                rItem.MoDIFY;
            UNTIL rItem.NEXT = 0;
        END;
    end;

    
    procedure fMedidas()
    var
        rItem: Record "27;
        rUnit: Record "5404;
    begin
        //Anade los registros faltantes de las medidas
        Ventana.oPEN('Revisando producto #1###### \ Nombre Producto #2##################', rItem."No.", rItem.Description);
        rItem.SETFILTER(rItem."Base Unit of Measure", '<>%1', '');
        IF rItem.FIND('-') THEN BEGIN
            REPEAT
                rItem."Purch. Unit of Measure" := rItem."Base Unit of Measure";
                rItem."Sales Unit of Measure" := rItem."Base Unit of Measure";
                rItem.MoDIFY;
                rUnit.SETRANGE(rUnit."Item No.", rItem."No.");
                IF rUnit.FIND('-') THEN rUnit.DELETE;
                rUnit.RESET;
                rUnit.INIT;
                rUnit."Item No." := rItem."No.";
                rUnit.Code := rItem."Base Unit of Measure";
                rUnit."Qty. per Unit of Measure" := 1;
                IF rUnit.INSERT THEN;
                Ventana.UPDATE;
            UNTIL rItem.NEXT = 0;
        END;
        Ventana.CLoSE;
        MESSAGE('Unidades de medida actualizadas');
    end;

    
    procedure fRevisaocu()
    var
        rocu: Record 7000178;
        rRes: Record 7000176;
    begin

        rocu.SETRANGE(rocu."Fecha entrada", 0D);
        IF rocu.FIND('-') THEN BEGIN
            REPEAT
                rRes.SETRANGE(rRes.Ano, rocu.Ano);
                rRes.SETRANGE(rRes.Reserva, rocu.Reserva);
                IF rRes.FIND('-') THEN BEGIN
                    rocu."Fecha entrada" := rRes."Fecha entrada";
                    rocu.MoDIFY;
                END;
            UNTIL rocu.NEXT = 0;
        END;

        rocu.SETRANGE(rocu."Fecha salida", 0D);
        IF rocu.FIND('-') THEN BEGIN
            REPEAT
                rRes.SETRANGE(rRes.Ano, rocu.Ano);
                rRes.SETRANGE(rRes.Reserva, rocu.Reserva);
                IF rRes.FIND('-') THEN BEGIN
                    rocu."Fecha salida" := rRes."Fecha salida";
                    rocu.MoDIFY;
                END;
            UNTIL rocu.NEXT = 0;
        END;

        MESSAGE('Fechas de entrada y salida reparadas');
    end;

    
    procedure fPostMigra()
    var
        rPar: Record 7000111;
        rParBal: Record 7000495;
    begin
        rUsr.GET(USERID);

        //Centro No Show

        rPar.SETRANGE(rPar.Hotel, rUsr."Hotel de trabajo");
        IF rPar.FIND('-') THEN BEGIN
            rPar."Centro estancias No Show" := 'ALoJ';
            rPar.MoDIFY;
        END;

        //Series Facturas Balnearios

        rParBal.INIT;
        rParBal.Hotel := rUsr."Hotel de trabajo";
        rParBal."Serie Facturas" := 'B';
        rParBal."Serie Facturas Prueba" := 'B';
        rParBal.INSERT;
    end;

    
    procedure fIngExtra()
    var
        rPar: Record 7000111;
        rUsr: Record 7000104;
    begin
        //Centro Ing. Extra
        rUsr.GET(USERID);
        rPar.SETRANGE(rPar.Hotel, rUsr."Hotel de trabajo");
        IF rPar.FIND('-') THEN BEGIN
            rPar."Concepto ing. extraordinarios" := 'CoBRo CDIR';
            rPar."Centro anticipos directos" := 'CoBRo CDIR';
            rPar.MoDIFY;

            MESSAGE('Concepto Ing. Extraordinario y Anticipos Directos, configurados correctamente')
        END;
    end;

    
    procedure focuCardexCumple(wPais: Code[20]; wDocumento: Code[20])
    var
        wCardex: Integer;
        wVisitas: Integer;
        rocu: Record 7000178;
        rCardex: Record 7000179;
        rVisitas: Record 7000180;
    begin

        //Ventana.oPEN('Revisando las fechas de cumpleanos, por favor espere...');
        rocu.SETRANGE(rocu."Check In", TRUE);
        rocu.SETRANGE(rocu."Pais residencia", wPais);
        rocu.SETRANGE(rocu.Documento, wDocumento);
        IF rocu.FIND('-') THEN BEGIN
            REPEAT
                rCardex.INIT;
                rCardex."Pais residencia" := rocu."Pais residencia";
                rCardex.Documento := rocu.Documento;
                rCardex."Nombre / Razon Social" := rocu.Nombre;
                rCardex."Apellido 1 := rocu."Apellido 1;
                rCardex."Apellido 2 := rocu."Apellido 2;
                rCardex."Fecha nacimiento" := rocu."Fecha nacimiento";
                rCardex.Sexo := rocu.Sexo;
                rCardex.Direccion := rocu.Direccion;
                rCardex."Cod. Postal" := rocu."Cod. postal";
                rCardex."Poblacion residencia" := rocu."Poblacion residencia";
                rCardex."Provincia residencia" := rocu."Provincia residencia";
                rCardex."E-mail" := rocu."E-mail";
                IF rCardex.INSERT THEN wCardex := wCardex + 1;
                rVisitas.INIT;
                rVisitas.Pais := rocu."Pais residencia";
                rVisitas.Documento := rocu.Documento;
                rVisitas.Hotel := rocu.Hotel;
                rVisitas.Ano := rocu.Ano;
                rVisitas.Reserva := rocu.Reserva;
                rVisitas.Desglose := rocu.Desglose;
                rVisitas."Fecha entrada" := rocu."Fecha entrada";
                rVisitas."Fecha salida" := rocu."Fecha salida";
                rVisitas.TToo := rocu.TToo;
                rVisitas.Agencia := rocu.Agencia;
                IF rVisitas.INSERT THEN wVisitas := wVisitas + 1;
                //Ventana.UPDATE;
                //Ventana.CLoSE;
            UNTIL rocu.NEXT = 0
        END;

        //MESSAGE('Se han anadido %1 registros de Cardex y %2 Visitas',wCardex,wVisitas);
    end;
}

