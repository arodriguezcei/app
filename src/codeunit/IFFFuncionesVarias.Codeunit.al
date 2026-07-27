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
        rControlsTHB: Record 50001;
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

                rControlesTHB.SETRANGE(rControlesTHB."Id Tabla", 'REPCABCoB');
                rControlesTHB.SETRANGE(rControlesTHB.Control, rUsr."Hotel de trabajo");
                IF NoT rControlesTHB.FINDFIRST THEN BEGIN
                    rControlesTHB.INIT;
                    rControlesTHB."Id tabla" := 'REPCABCoB';
                    rControlesTHB.Control := rUsr."Hotel de trabajo";
                    rControlesTHB.INSERT;
                    wSourceCounterGes := 0;
                    CoMMIT;
                END ELSE
                    wSourceCounter := rControlesTHB.Integer + 1;

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
                rControlesTHB.SETRANGE(rControlesTHB."Id tabla", 'REPCABCoB');
                rControlesTHB.SETRANGE(rControlesTHB.Control, rUsr."Hotel de trabajo");
                IF rControlesTHB.FINDFIRST THEN BEGIN
                    rControlesTHB.Integer := wSourceCounter;
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
        rCab.SETRANGE(rCab."No. Remesa Fact. Electronica", 0);
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

}

