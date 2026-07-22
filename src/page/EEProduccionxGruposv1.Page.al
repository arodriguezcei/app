page 7012450 "EE Produccion x Grupos v1"
{
    PageType = ListPart;
    SourceTable = 7000117;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Hotel; rec.Hotel)
                {
                }
                field("Grupo centros"; rec."Grupo centros")
                {
                }
                field("Mes (Año Actual)"; wMAct)
                {
                }
                field("Prec. Medio"; wMActPM)
                {
                }
                field("Mes (Año Anterior)"; wMAnt)
                {
                }
                field("Prec. Medio Ant"; wMAntPM)
                {
                    Caption = 'Prec. Medio Ant';
                }
                field("Variación Producción"; wMVarProd)
                {
                }
                field("% Var. Prod"; wMPVarProd)
                {
                }
                field("Var. Prom."; wMVarPM)
                {
                }
                field("% Var. Prom."; wMPVarPM)
                {
                }
                field("Año (Año Actual)"; wAAct)
                {
                }
                field("Año Prec. Medio"; wAActPM)
                {
                }
                field("Año (Año Anterior)"; wAAnt)
                {
                }
                field("Año Ant Prec. Medio"; wAAntPM)
                {
                }
                field("Variación Producción Año Ant"; wAVarProd)
                {
                }
                field("% Var. Prod."; wAPVarProd)
                {
                }
                field("Var. Prec. Medio"; wAVarPM)
                {
                }
                field("% Var. Prom. Ant"; wAPVarPM)
                {
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        IF wMiFecha <> 0D THEN Calcular(Rec, 0);
    end;

    var
        wDiasAbiertoAct: Integer;
        wDiasAbiertoAnt: Integer;
        //xlAplicacion: Automation;
        //xlLibro: Automation;
        //xlHoja: Automation;
        //xlConjuntoLibros: Automation;
        //xlRango: Automation;
        ExcelBuffer: record "Excel Buffer";
        cIFF: Codeunit 50001;
        rCen: Record 7000385;
        rBook: Record 7000189;
        rReg: Record 7000112;
        rUser: Record 7000104;
        cProgen: Codeunit 7000105;
        cFileM: Codeunit 419;
        wMiFecha: Date;
        "wApAñoAct": Date;
        "wApAñoAnt": Date;
        wMAct: Decimal;
        wMActPM: Decimal;
        wMAnt: Decimal;
        wMAntPM: Decimal;
        wMVarProd: Decimal;
        wMPVarProd: Decimal;
        wMVarPM: Decimal;
        wMPVarPM: Decimal;
        wSeparador: Text[30];
        wAAct: Decimal;
        wAActPM: Decimal;
        wAAnt: Decimal;
        wAAntPM: Decimal;
        wAVarProd: Decimal;
        wAPVarProd: Decimal;
        wAVarPM: Decimal;
        wAPVarPM: Decimal;
        wFiltHotel: Text[250];
        wEstMAct: Decimal;
        wEstMAnt: Decimal;
        wEstMVar: Decimal;
        wEstAAct: Decimal;
        wEstAAnt: Decimal;
        wEstAVar: Decimal;
        wExport: Boolean;
        wPorcen: Integer;
        wVentana: Dialog;
        wCelda: Text[4];
        wRango: Text[10];
        wFormula: Text[250];
        wListaCelda: array[16] of Text[1];
        wInd: Integer;
        wEMAct: Decimal;
        wTotEMAct: Decimal;
        wEPMAct: Decimal;
        wEMAnt: Decimal;
        wTotEMAnt: Decimal;
        wEPMAnt: Decimal;
        wEMVar: Decimal;
        wEAAct: Decimal;
        wTotEAAct: Decimal;
        wEPAAct: Decimal;
        wEAAnt: Decimal;
        wTotEAAnt: Decimal;
        wEPAAnt: Decimal;
        wEAVar: Decimal;
        wOcMes: Decimal;
        wPOcMes: Decimal;
        wOcMesAnt: Decimal;
        wPOcMesAnt: Decimal;
        "wOcAño": Decimal;
        "wPOcAño": Decimal;
        "wOcAñoAnt": Decimal;
        "wPOcAñoAnt": Decimal;
        wNumDias: Integer;
        wTotHabHotel: Decimal;
        wTotCamHotel: Decimal;
        wVacio: Text[250];
        wRedLoc: Decimal;
        Text000: Label 'Calculando Estancias';
        Text001: Label 'TOTAL';
        Text002: Label '-1A';
        Text003: Label 'Calculando Ocupacion';
        Text004: Label 'El directorio %1 no existe.¿Desea crearlo?';
        Text005: Label 'Proceso interrumpido por el usuario';
        Text006: Label 'Conectando Excel';
        Text007: Label 'No se encontro el archivo %1';
        Text008: Label 'El archivo %1 ya está abierto....';
        Text009: Label 'Principal';
        Text010: Label 'A4:AB4';
        Text011: Label 'A9:AB160';
        Text012: Label 'A4';
        Text013: Label 'Fecha Informe: ';
        Text014: Label 'C4';
        Text015: Label 'Hotel: ';
        Text016: Label '     Capacidad: ';
        Text017: Label ' Hab. ';
        Text018: Label ' camas.';
        Text019: Label 'Calculando Producción';
        Text020: Label 'El informe se generó con éxito.¿Desea imprimirlo?';
        Text021: Label 'No se pudo abrir Excel';
        Text022: Label 'A%1';
        Text023: Label 'B%1';
        Text024: Label 'C%1';
        Text025: Label 'D%1';
        Text026: Label 'E%1';
        Text027: Label 'F%1';
        Text028: Label 'G%1';
        Text029: Label 'H%1';
        Text030: Label 'I%1';
        Text031: Label 'K%1';
        Text032: Label 'L%1';
        Text033: Label 'M%1';
        Text034: Label 'N%1';
        Text035: Label 'O%1';
        Text036: Label 'P%1';
        Text037: Label 'Q%1';
        Text038: Label 'R%1';
        Text039: Label 'B';
        Text040: Label 'C';
        Text041: Label 'D';
        Text042: Label 'E';
        Text043: Label 'F';
        Text044: Label 'G';
        Text045: Label 'H';
        Text046: Label 'I';
        Text047: Label 'K';
        Text048: Label 'L';
        Text049: Label 'M';
        Text050: Label 'N';
        Text051: Label 'O';
        Text052: Label 'P';
        Text053: Label 'Q';
        Text054: Label 'R';
        Text055: Label 'A';
        Text056: Label 'TOTAL PRODUCTION';
        Text057: Label 'B9:I';
        Text058: Label 'K9:R';
        Text059: Label '=SUMA(';
        Text060: Label 'Estancias por Régimen';
        Text061: Label 'Stays';
        Text062: Label 'Variation';
        Text063: Label 'TOTAL OCUPACION';

    procedure CalcularEst(pRegimen: Text[30]; pPos: Integer)
    var
        rGruCen: Record 7000117;
        lFecIni: Date;
        lFecFin: Date;
    begin
        //CalcularEst
        //Para exportar

        CLEAR(wEMAct);
        CLEAR(wEPMAct);
        CLEAR(wEMAnt);
        CLEAR(wEPMAnt);
        CLEAR(wEMVar);
        CLEAR(wEAAct);
        CLEAR(wEPAAct);
        CLEAR(wEAAnt);
        CLEAR(wEPAAnt);
        CLEAR(wEAVar);

        CLEAR(wTotEMAct);
        CLEAR(wTotEMAnt);
        CLEAR(wTotEAAct);
        CLEAR(wTotEAAnt);

        IF wFiltHotel <> '' THEN
            rBook.SETFILTER(Hotel, wFiltHotel)
        ELSE
            rBook.SETRANGE(Hotel);

        rBook.SETFILTER(rBook."Rango Estado", '%1|%2|%3',
                rBook."Rango Estado"::Reserva, rBook."Rango Estado"::Entrada, rBook."Rango Estado"::Salida);

        Ventana(Text000, 25);

        IF rBook.FIND('-') THEN
            REPEAT
                //MES
                //Actual
                lFecIni := DMY2DATE(1, DATE2DMY(wMiFecha, 2), DATE2DMY(wMiFecha, 3));
                //   IF CALCDATE('+1M',wFechaApAact)<wMiFecha THEN lFecIni=wFechaApAact;
                lFecFin := wMiFecha;
                rBook.SETRANGE(rBook."Rango Fecha", lFecIni, lFecFin);

                Ventana(Text000, 50);

                rBook.SETRANGE(rBook."Rango Regimen fact.");
                rBook.CALCFIELDS(rBook.AD, rBook.JR, rBook.NI);
                wTotEMAct := wTotEMAct + (rBook.AD + rBook.JR + rBook.NI);

                IF pRegimen <> Text001 THEN rBook.SETRANGE(rBook."Rango Regimen fact.", pRegimen);
                rBook.CALCFIELDS(rBook.AD, rBook.JR, rBook.NI);
                wEMAct := wEMAct + (rBook.AD + rBook.JR + rBook.NI);

                IF wTotEMAct <> 0 THEN wEPMAct := ROUND((wEMAct * 100) / wTotEMAct);


                //Año Anterior
                lFecIni := DMY2DATE(1, DATE2DMY(wMiFecha, 2), DATE2DMY(CALCDATE('-1A', wMiFecha), 3));
                lFecFin := CALCDATE('-1A', wMiFecha);
                //     lFecFin:=DMY2DATE(DATE2DMY(wMiFecha,1),DATE2DMY(wMiFecha,2),DATE2DMY(CALCDATE('-1A',wMiFecha),3));
                rBook.SETRANGE(rBook."Rango Fecha", lFecIni, lFecFin);

                Ventana(Text000, 75);

                rBook.SETRANGE(rBook."Rango Regimen fact.");
                rBook.CALCFIELDS(rBook.AD, rBook.JR, rBook.NI);
                wTotEMAnt := wTotEMAnt + (rBook.AD + rBook.JR + rBook.NI);

                IF pRegimen <> Text001 THEN rBook.SETRANGE(rBook."Rango Regimen fact.", pRegimen);
                rBook.CALCFIELDS(rBook.AD, rBook.JR, rBook.NI);
                wEMAnt := wEMAnt + (rBook.AD + rBook.JR + rBook.NI);

                IF wTotEMAnt <> 0 THEN wEPMAnt := ROUND((wEMAnt * 100) / wTotEMAnt);

                //Variación
                wEMVar := wEMAct - wEMAnt;

                //AÑO
                //Actual
                lFecIni := wApAñoAct; //Apertura Año Actual
                lFecFin := DMY2DATE(DATE2DMY(wMiFecha, 1), DATE2DMY(wMiFecha, 2), DATE2DMY(wMiFecha, 3));
                rBook.SETRANGE(rBook."Rango Fecha", lFecIni, lFecFin);

                rBook.SETRANGE(rBook."Rango Regimen fact.");
                rBook.CALCFIELDS(rBook.AD, rBook.JR, rBook.NI);
                wTotEAAct := wTotEAAct + (rBook.AD + rBook.JR + rBook.NI);

                IF pRegimen <> Text001 THEN rBook.SETRANGE(rBook."Rango Regimen fact.", pRegimen);
                rBook.CALCFIELDS(rBook.AD, rBook.JR, rBook.NI);
                wEAAct := wEAAct + (rBook.AD + rBook.JR + rBook.NI);

                IF wTotEAAct <> 0 THEN wEPAAct := ROUND((wEAAct * 100) / wTotEAAct);

                //Año Anterior
                lFecIni := wApAñoAnt; //Apertura Año Anterior.
                lFecFin := CALCDATE('-1A', wMiFecha);
                //     lFecFin:=DMY2DATE(DATE2DMY(wMiFecha,1),DATE2DMY(wMiFecha,2),DATE2DMY(CALCDATE('-1A',wMiFecha),3));
                rBook.SETRANGE(rBook."Rango Fecha", lFecIni, lFecFin);

                rBook.SETRANGE(rBook."Rango Regimen fact.");
                rBook.CALCFIELDS(rBook.AD, rBook.JR, rBook.NI);
                wTotEAAnt := wTotEAAnt + (rBook.AD + rBook.JR + rBook.NI);

                IF pRegimen <> Text001 THEN rBook.SETRANGE(rBook."Rango Regimen fact.", pRegimen);
                rBook.CALCFIELDS(rBook.AD, rBook.JR, rBook.NI);
                wEAAnt := wEAAnt + (rBook.AD + rBook.JR + rBook.NI);

                IF wTotEAAnt <> 0 THEN wEPAAnt := ROUND((wEAAnt * 100) / wTotEAAnt);

                //Variación
                wEAVar := wEAAct - wEAAnt;

                IF wExport THEN BEGIN
                    //Exportamos la linea
                    InsertarConcepEst(pRegimen, pPos);
                    InsertarValorEst(pRegimen, pPos);
                END;

                Ventana(Text000, 100);


            UNTIL rBook.NEXT = 0;
    end;

    procedure Calcular(pGruCen: Record 7000117; pPos: Integer)
    var
        rGruCen: Record 7000117;
        lFecIni: Date;
        lFecFin: Date;
        lFecIniProd: Date;
    begin
        //Calcular

        CLEAR(wMAct);
        CLEAR(wMActPM);
        CLEAR(wMAnt);
        CLEAR(wMAntPM);
        CLEAR(wMVarProd);
        CLEAR(wMPVarProd);
        CLEAR(wMVarPM);
        CLEAR(wMPVarPM);

        CLEAR(wAAct);
        CLEAR(wAActPM);
        CLEAR(wAAnt);
        CLEAR(wAAntPM);
        CLEAR(wAVarProd);
        CLEAR(wAPVarProd);
        CLEAR(wAVarPM);
        CLEAR(wAPVarPM);

        IF rGruCen.GET(pGruCen."Grupo centros", pGruCen.Hotel) THEN BEGIN
            //MES
            //Actual
            lFecIni := DMY2DATE(1, DATE2DMY(wMiFecha, 2), DATE2DMY(wMiFecha, 3));
            lFecFin := wMiFecha;

            rGruCen.SETRANGE(rGruCen."Filtro Fechas", lFecIni, lFecFin);
            rGruCen.CALCFIELDS(rGruCen."QHTICD-Total produccion");
            wMAct := rGruCen."QHTICD-Total produccion";

            IF wEstMAct <> 0 THEN wMActPM := ROUND(wMAct / wEstMAct, wRedLoc);

            //Año Anterior
            lFecIni := DMY2DATE(1, DATE2DMY(wMiFecha, 2), DATE2DMY(CALCDATE(Text002, wMiFecha), 3));
            lFecFin := CALCDATE(Text002, wMiFecha);
            //   lFecFin:=DMY2DATE(DATE2DMY(wMiFecha,1),DATE2DMY(wMiFecha,2),DATE2DMY(CALCDATE(Text002,wMiFecha),3));

            rGruCen.SETRANGE(rGruCen."Filtro Fechas", lFecIni, lFecFin);
            rGruCen.CALCFIELDS(rGruCen."QHTICD-Total produccion");
            wMAnt := rGruCen."QHTICD-Total produccion";
            IF wEstMAnt <> 0 THEN wMAntPM := ROUND(wMAnt / wEstMAnt, wRedLoc);

            //Variaciones
            wMVarProd := wMAct - wMAnt;
            IF wMAnt <> 0 THEN wMPVarProd := ROUND((wMVarProd * 100) / wMAnt, wRedLoc);

            wMVarPM := wMActPM - wMAntPM;
            IF wMAntPM <> 0 THEN wMPVarPM := ROUND((wMVarPM * 100) / wMAntPM, wRedLoc);


            //AÑO
            //Actual
            lFecIni := wApAñoAct; //Apertura Año Actual.
            lFecIniProd := DMY2DATE(1, 1, DATE2DMY(lFecIni, 3));
            lFecFin := DMY2DATE(DATE2DMY(wMiFecha, 1), DATE2DMY(wMiFecha, 2), DATE2DMY(wMiFecha, 3));

            rGruCen.SETRANGE(rGruCen."Filtro Fechas", lFecIniProd, lFecFin);
            rGruCen.CALCFIELDS(rGruCen."QHTICD-Total produccion");
            wAAct := rGruCen."QHTICD-Total produccion";
            IF wEstAAct <> 0 THEN wAActPM := ROUND(wAAct / wEstAAct, wRedLoc);

            //Año Anterior
            lFecIni := wApAñoAnt; //Apertura Año Anterior.
            lFecIniProd := DMY2DATE(1, 1, DATE2DMY(lFecIni, 3));
            lFecFin := CALCDATE('-1A', wMiFecha);
            //   lFecFin:=DMY2DATE(DATE2DMY(wMiFecha,1),DATE2DMY(wMiFecha,2),DATE2DMY(CALCDATE('-1A',wMiFecha),3));

            rGruCen.SETRANGE(rGruCen."Filtro Fechas", lFecIniProd, lFecFin);
            rGruCen.CALCFIELDS(rGruCen."QHTICD-Total produccion");
            wAAnt := rGruCen."QHTICD-Total produccion";
            IF wEstAAnt <> 0 THEN wAAntPM := ROUND(wAAnt / wEstAAnt, wRedLoc);

            //Variaciones
            wAVarProd := wAAct - wAAnt;
            IF wAAnt <> 0 THEN wAPVarProd := ROUND((wAVarProd * 100) / wAAnt, wRedLoc);

            wAVarPM := wAActPM - wAAntPM;
            IF wAAntPM <> 0 THEN wAPVarPM := ROUND((wAVarPM * 100) / wAAntPM, wRedLoc);

            IF wExport THEN BEGIN
                //Exportamos la linea
                InsertarConcep(rGruCen, pPos);
                InsertarValor(pPos);
            END;
        END;
    end;

    procedure CalculaEst()
    var
        lFecIni: Date;
        lFecFin: Date;
    begin
        //CalculaEst

        CLEAR(wEstMAct);
        CLEAR(wEstMAnt);
        CLEAR(wEstAAct);
        CLEAR(wEstAAnt);


        IF wFiltHotel <> '' THEN
            rBook.SETFILTER(rBook.Hotel, wFiltHotel)
        ELSE
            rBook.SETRANGE(rBook.Hotel);

        rBook.SETFILTER(rBook."Rango Estado", '%1|%2|%3',
                rBook."Rango Estado"::Reserva, rBook."Rango Estado"::Entrada, rBook."Rango Estado"::Salida);

        IF rBook.FIND('-') THEN
            REPEAT

                //MES
                //Actual
                lFecIni := DMY2DATE(1, DATE2DMY(wMiFecha, 2), DATE2DMY(wMiFecha, 3)); //Mes actual
                lFecFin := wMiFecha;
                rBook.SETRANGE(rBook."Rango Fecha", lFecIni, lFecFin);
                rBook.CALCFIELDS(rBook.AD, rBook.JR, rBook.NI);
                wEstMAct := wEstMAct + (rBook.AD + rBook.JR + rBook.NI);

                //Año Anterior
                lFecIni := DMY2DATE(1, DATE2DMY(wMiFecha, 2), DATE2DMY(CALCDATE('-1A', wMiFecha), 3)); //Mes Año Anterior
                lFecFin := CALCDATE('-1A', wMiFecha);
                //   lFecFin:=DMY2DATE(DATE2DMY(wMiFecha,1),DATE2DMY(wMiFecha,2),DATE2DMY(CALCDATE('-1A',wMiFecha),3));
                rBook.SETRANGE(rBook."Rango Fecha", lFecIni, lFecFin);
                rBook.CALCFIELDS(rBook.AD, rBook.JR, rBook.NI);
                wEstMAnt := wEstMAnt + (rBook.AD + rBook.JR + rBook.NI);

                //Variacion entre años
                wEstMVar := wEstMAct - wEstMAnt;

                //AÑO
                //Actual
                lFecIni := wApAñoAct;   //Apertura Año Actual.
                lFecFin := DMY2DATE(DATE2DMY(wMiFecha, 1), DATE2DMY(wMiFecha, 2), DATE2DMY(wMiFecha, 3));
                rBook.SETRANGE(rBook."Rango Fecha", lFecIni, lFecFin);
                rBook.CALCFIELDS(rBook.AD, rBook.JR, rBook.NI);
                wEstAAct := wEstAAct + (rBook.AD + rBook.JR + rBook.NI);

                //Año Anterior
                lFecIni := wApAñoAnt; //Apertura Año Anterior.
                lFecFin := CALCDATE('-1A', wMiFecha);
                //   lFecFin:=DMY2DATE(DATE2DMY(wMiFecha,1),DATE2DMY(wMiFecha,2),DATE2DMY(CALCDATE('-1A',wMiFecha),3));
                rBook.SETRANGE(rBook."Rango Fecha", lFecIni, lFecFin);
                rBook.CALCFIELDS(rBook.AD, rBook.JR, rBook.NI);
                wEstAAnt := wEstAAnt + (rBook.AD + rBook.JR + rBook.NI);

                //Variacion entre años
                wEstAVar := wEstAAct - wEstAAnt;

            UNTIL rBook.NEXT = 0;
    end;

    procedure CalculaOcp()
    var
        lFecIni: Date;
        lFecFin: Date;
    begin
        //CalculaOcp

        CLEAR(wOcMes);
        CLEAR(wPOcMes);
        CLEAR(wOcMesAnt);
        CLEAR(wPOcMesAnt);
        CLEAR(wOcAño);
        CLEAR(wPOcAño);
        CLEAR(wOcAñoAnt);
        CLEAR(wPOcAñoAnt);

        IF wFiltHotel <> '' THEN
            rBook.SETFILTER(Hotel, '%1', wFiltHotel)
        ELSE
            rBook.SETRANGE(Hotel);

        rBook.SETFILTER(rBook."Rango Estado", '%1|%2|%3',
                rBook."Rango Estado"::Reserva, rBook."Rango Estado"::Entrada, rBook."Rango Estado"::Salida);

        //Obtenemos el Filtro de habitaciones de desplazados y los totales de habitaciones y camas
        cProgen.HabitacionCamas(wFiltHotel, TRUE, FALSE, TRUE, wVacio, wTotCamHotel, wTotHabHotel);

        wTotHabHotel := cIFF.fHab;
        wTotCamHotel := cIFF.fHabCamas;


        Ventana(Text003, 25);

        rBook.RESET;
        //IF rBook.FIND('-') THEN
        //   REPEAT
        //MES
        //Actual
        //THB020522 HACER AJUSTE PARA FECHAS DE APERTURA IFF
        lFecIni := DMY2DATE(1, DATE2DMY(wMiFecha, 2), DATE2DMY(wMiFecha, 3));
        IF lFecIni < wApAñoAct THEN lFecIni := wApAñoAct;
        //Mes actual
        lFecFin := wMiFecha;
        rBook.SETRANGE(rBook."Rango Fecha", lFecIni, lFecFin);
        rBook.CALCFIELDS(rBook.Ocupacion);
        wOcMes := wOcMes + (rBook.Ocupacion);

        wPOcMes := (wOcMes * 100) / (wTotHabHotel * ((lFecFin - lFecIni) + 1));

        Ventana(Text003, 50);

        //Mes Año Anterior
        lFecIni := DMY2DATE(1, DATE2DMY(wMiFecha, 2), DATE2DMY(CALCDATE('-1A', wMiFecha), 3)); //Mes Año Anterior
        IF lFecIni < wApAñoAnt THEN lFecIni := wApAñoAnt;
        lFecFin := CALCDATE('-1A', wMiFecha);
        //      lFecFin:=DMY2DATE(DATE2DMY(wMiFecha,1),DATE2DMY(wMiFecha,2),DATE2DMY(CALCDATE('-1A',wMiFecha),3));
        rBook.RESET;
        rBook.SETRANGE(rBook."Rango Fecha", lFecIni, lFecFin);
        //MESSAGE('%1 - %2',lFecIni,lFecFin);
        rBook.CALCFIELDS(rBook.Ocupacion);
        wOcMesAnt := wOcMesAnt + (rBook.Ocupacion);
        //wOcMesAnt:=rBook.Ocupacion;
        //    MESSAGE('%1',wOcMesAnt);
        IF wOcMesAnt * 100 <> 0 THEN
            wPOcMesAnt := (wOcMesAnt * 100) / (wTotHabHotel * ((lFecFin - lFecIni) + 1));

        Ventana(Text003, 75);

        //AÑO
        //Actual
        lFecIni := wApAñoAct;  // Apertura Año Actual.
        lFecFin := DMY2DATE(DATE2DMY(wMiFecha, 1), DATE2DMY(wMiFecha, 2), DATE2DMY(wMiFecha, 3));
        rBook.RESET;
        rBook.SETRANGE(rBook."Rango Fecha", lFecIni, lFecFin);
        rBook.CALCFIELDS(rBook.Ocupacion);
        wOcAño := wOcAño + (rBook.Ocupacion);

        wPOcAño := (wOcAño * 100) / (wTotHabHotel * ((lFecFin - lFecIni) + 1));

        //Año Anterior
        lFecIni := wApAñoAnt; //Apertura Año Anterior.
        lFecFin := CALCDATE('-1A', wMiFecha);
        //      lFecFin:=DMY2DATE(DATE2DMY(wMiFecha,1),DATE2DMY(wMiFecha,2),DATE2DMY(CALCDATE('-1A',wMiFecha),3));
        rBook.RESET;
        rBook.SETRANGE(rBook."Rango Fecha", lFecIni, lFecFin);
        rBook.CALCFIELDS(rBook.Ocupacion);
        wOcAñoAnt := wOcAñoAnt + (rBook.Ocupacion);

        IF wOcAñoAnt * 100 <> 0 THEN wPOcAñoAnt := (wOcAñoAnt * 100) / (wTotHabHotel * ((lFecFin - lFecIni) + 1));

        Ventana(Text003, 100);

        // UNTIL rBook.NEXT=0;
    end;

    procedure ObtenerDatos(pFiltHotel: Text[250]; pMiFecha: Date; pApAAct: Date; pApAant: Date; pExport: Boolean; vArchivo: Text[250]; vDirec: Text[250])
    begin
        //ObtenerDatos

        wFiltHotel := pFiltHotel;
        IF wFiltHotel <> '' THEN
            rec.SETFILTER(Hotel, wFiltHotel)
        ELSE
            rec.SETRANGE(Hotel);

        //Precisión de redondeo de la moneda local
        IF rUser.GET(USERID) THEN
            wRedLoc := cProgen.RedondeoDivisaLocal(rUser."Hotel de trabajo");


        wMiFecha := pMiFecha;   //Fecha del filtro.
        wApAñoAct := pApAAct;   //Fecha de apertura del año en curso.
        wApAñoAnt := pApAant;   //Fecha de apertura del año anterior.

        CalculaEst();

        wExport := pExport;

        IF wExport THEN BEGIN
            //Iniciamos exportacion;
            Excel(vArchivo, vDirec);
        END;

        CurrPage.UPDATE;
    end;

    procedure Excel(vArchivo: Text[250]; vDirec: Text[250])
    var
        rDocs: Record 7012719;
        rGruCen: Record 7000117;
        wNuevo: Boolean;
        //Directorio: Automation;
        wDir: Text[30];
        wText: Text[50];
        wEstaAbierta: Boolean;
        wNombre: Code[250];
        wPos: Integer;
        wNombreCli: Text;
    begin
        //Excel
        /*Hay crear los 3 objetos, uno de tipo Aplicacion, otro de tipo Libro
         y otro de tipo xlHoja. Se pueden crear añadiendo como nuevo o cargandolo
        si ya existe.
        Una vez creado se pueden manejar, con las propiedades sin problemas.*/

        ExcelBuffer.
                CLEAR(xlAplicacion);
        CLEAR(xlConjuntoLibros);
        CLEAR(xlLibro);
        CLEAR(xlHoja);

        //CREATE(Directorio,TRUE,TRUE);

        //wNombre:=vDirec+vArchivo;
        wNombre := cFileM.ServerTempFileName('xls');

        //THB IFF040814 EXPORTAMOS LA PLANTILLA SI ESTA NO EXISTE
        IF NOT rDocs.GET('ESTAD') THEN
            ERROR('No existe la plantilla para el report')
        ELSE BEGIN
            rDocs.CALCFIELDS(rDocs.Documento);
            rDocs.Documento.EXPORT(FORMAT(wNombre));
        END;

        wNombreCli := vDirec + vArchivo;
        IF NOT cFileM.ClientDirectoryExists(vDirec) THEN
            IF CONFIRM(Text004, TRUE, vDirec) THEN
                cFileM.CreateClientDirectory(vDirec)
            ELSE
                ERROR(Text005);

        cFileM.DeleteClientFile(wNombreCli);
        cFileM.DownloadToFile(wNombre, wNombreCli);
        wNombre := wNombreCli;

        //Par. FALSE. Si excel ya está abierto, usamos la instancia existente
        IF CREATE(xlAplicacion, FALSE, TRUE) THEN BEGIN

            xlAplicacion.ScreenUpdating(FALSE);
            xlAplicacion.Visible(FALSE);
            xlAplicacion.DisplayAlerts := FALSE;

            wPorcen := 0;
            wVentana.OPEN('#1##################### @2@@@@@@@@');

            Ventana(Text006, 25);

            xlConjuntoLibros := xlAplicacion.Workbooks;
            wEstaAbierta := FALSE; //Por defecto

            Ventana(Text006, 50);
            xlConjuntoLibros._Open(wNombreCli);
            /*
            IF NOT wEstaAbierta THEN BEGIN
               IF NOT FILE.EXISTS(wNombre) THEN BEGIN
                  Destruir();
                  ERROR(Text007,wNombre);
               END
               ELSE xlConjuntoLibros._Open(wNombre); // Abro la Hoja.

               Ventana(Text006,100);

            END
            ELSE BEGIN//Si está abierta
               Destruir();
               ERROR(Text008,wNombre);
            END;
            */
            xlLibro := xlAplicacion.ActiveWorkbook;


            //GENERAR DATOS
            rGruCen.RESET;
            IF wFiltHotel <> '' THEN
                rGruCen.SETFILTER(Hotel, '%1', wFiltHotel)
            ELSE
                rGruCen.SETRANGE(Hotel);
            wPos := 0;



            //Activamos la hoja principal
            xlHoja := xlLibro.Worksheets.Item('Principal');
            xlHoja.Activate;

            CalculaOcp();

            //Limpiamos
            xlHoja.Range('A4:AB4').Interior.ColorIndex := 0;
            xlHoja.Range('A4:AB4')._ClearContents;
            xlHoja.Range('A4:AB4').Borders.LineStyle(0);
            xlHoja.Range('A4:AB4').Font.Bold := FALSE;


            xlHoja.Range('A9:AB160').Interior.ColorIndex := 0;
            xlHoja.Range('A9:AB160')._ClearContents;
            xlHoja.Range('A9:AB160').Borders.LineStyle(0);
            xlHoja.Range('A9:AB160').Font.Bold := FALSE;


            //Insertamos la fecha del informe.
            //MODIFICADO IFF 230611
            xlHoja.Range('A4').Value := 'Fecha Informe:';
            xlHoja.Range('B4').Value := wMiFecha;
            xlHoja.Range('A4').Font.Bold := TRUE;
            xlHoja.Range('B4').Font.Bold := TRUE;
            xlHoja.Range('K4').Value := 'Apertura Ant.';
            xlHoja.Range('L4').Value := wApAñoAnt;
            xlHoja.Range('N4').Value := wApAñoAct;
            xlHoja.Range('M4').Value := 'Apertura Act.';
            //FIN MODIFICADO IFF 230611


            //Insertamos filtros
            xlHoja.Range('C4').Value := 'Hotel: ' + wFiltHotel + '     Capacidad: ' + FORMAT(wTotHabHotel) + ' Hab. ' + FORMAT(wTotCamHotel) + ' camas.'
         ;
            xlHoja.Range('C4').Font.Bold := TRUE;



            //P R O D U C C I O N

            Ventana(Text019, 25);

            IF rGruCen.FIND('-') THEN
                REPEAT
                    wPos := wPos + 1;
                    Calcular(rGruCen, wPos);
                UNTIL rGruCen.NEXT = 0;
            Ventana(Text019, 50);

            wPos := wPos + 1;

            InsertarTotal(wPos + 8);

            Ventana(Text019, 100);
            //R E G I M E N E S
            //Insertar cabecera
            wPos := wPos + 2;
            InsCabEst(wPos + 8);

            rReg.RESET;
            IF rReg.FIND('-') THEN
                REPEAT
                    wPos := wPos + 1;
                    CalcularEst(rReg.Régimen, wPos);
                UNTIL rReg.NEXT = 0;

            wPos := wPos + 1;
            CalcularEst('TOTAL', wPos);

            // O C U P A C I O N
            wPos := wPos + 2;
            InsCabOc(wPos + 8);

            wExport := FALSE;

            //Grabar
            xlLibro.Save;
            IF CONFIRM(Text020, TRUE) THEN BEGIN
                xlAplicacion.Visible(TRUE);
                xlHoja.PrintPreview();
            END;

            //xlAplicacion.Visible(TRUE);
            //xlAplicacion.UserControl(TRUE);
            //CLEAR(xlAplicacion);
            //Grabar
            //xlLibro.Save;

        END
        ELSE
            ERROR(Text021);

        Destruir();

    end;

    procedure Ventana(wTexto: Text[50]; wPorcen: Integer)
    begin
        //Ventana
        wVentana.UPDATE(1, wTexto);
        wVentana.UPDATE(2, wPorcen * 100);
    end;

    procedure Destruir()
    begin
        //Destruir

        //Destruimos objetos

        wVentana.CLOSE();
        xlAplicacion.Quit;
        CLEAR(xlHoja);
        CLEAR(xlLibro);
        CLEAR(xlConjuntoLibros);
        CLEAR(xlAplicacion);
    end;

    procedure InsertarConcep(pGruCen: Record 7000117; pPos: Integer)
    begin
        //InsertarConcep

        EVALUATE(wCelda, STRSUBSTNO('A%1', pPos + 8));
        xlHoja.Range(wCelda).Value := pGruCen.Descripcion;
        //xlHoja.Range(wCelda).Font.Bold:=TRUE;
        xlHoja.Range(wCelda)._BorderAround(1);
        xlHoja.Range(wCelda).Interior.ColorIndex := 40;
    end;

    procedure InsertarValor(pPos: Integer)
    begin
        //InsertarValor

        EVALUATE(wCelda, STRSUBSTNO('B%1', pPos + 8));
        xlHoja.Range(wCelda).Value := wMAct;

        //MESSAGE('%1 %2',xlHoja.Range(wCelda).Value,wMAct);

        EVALUATE(wCelda, STRSUBSTNO('C%1', pPos + 8));
        xlHoja.Range(wCelda).Value := wMActPM;
        EVALUATE(wCelda, STRSUBSTNO('D%1', pPos + 8));
        xlHoja.Range(wCelda).Value := wMAnt;
        EVALUATE(wCelda, STRSUBSTNO('E%1', pPos + 8));
        xlHoja.Range(wCelda).Value := wMAntPM;
        EVALUATE(wCelda, STRSUBSTNO('F%1', pPos + 8));
        xlHoja.Range(wCelda).Value := wMVarProd;
        EVALUATE(wCelda, STRSUBSTNO('G%1', pPos + 8));
        xlHoja.Range(wCelda).Value := wMPVarProd;
        EVALUATE(wCelda, STRSUBSTNO('H%1', pPos + 8));
        xlHoja.Range(wCelda).Value := wMVarPM;
        EVALUATE(wCelda, STRSUBSTNO('I%1', pPos + 8));
        xlHoja.Range(wCelda).Value := wMPVarPM;

        EVALUATE(wCelda, STRSUBSTNO('K%1', pPos + 8));
        xlHoja.Range(wCelda).Value := wAAct;
        EVALUATE(wCelda, STRSUBSTNO('L%1', pPos + 8));
        xlHoja.Range(wCelda).Value := wAActPM;
        EVALUATE(wCelda, STRSUBSTNO('M%1', pPos + 8));
        xlHoja.Range(wCelda).Value := wAAnt;
        EVALUATE(wCelda, STRSUBSTNO('N%1', pPos + 8));
        xlHoja.Range(wCelda).Value := wAAntPM;
        EVALUATE(wCelda, STRSUBSTNO('O%1', pPos + 8));
        xlHoja.Range(wCelda).Value := wAVarProd;
        EVALUATE(wCelda, STRSUBSTNO('P%1', pPos + 8));
        xlHoja.Range(wCelda).Value := wAPVarProd;
        EVALUATE(wCelda, STRSUBSTNO('Q%1', pPos + 8));
        xlHoja.Range(wCelda).Value := wAVarPM;
        EVALUATE(wCelda, STRSUBSTNO('R%1', pPos + 8));
        xlHoja.Range(wCelda).Value := wAPVarPM;
    end;

    procedure InsertarTotal(pPos: Integer)
    var
        wLetraCont: Text[30];
        wLetraIni: Text[1];
        wLetraFin: Text[1];
    begin
        //InsertarTotal

        //Cargamos la matriz de celdas
        wListaCelda[1] := 'B';
        wListaCelda[2] := 'C';
        wListaCelda[3] := 'D';
        wListaCelda[4] := 'E';
        wListaCelda[5] := 'F';
        wListaCelda[6] := 'G';
        wListaCelda[7] := 'H';
        wListaCelda[8] := 'I';

        wListaCelda[9] := 'K';
        wListaCelda[10] := 'L';
        wListaCelda[11] := 'M';
        wListaCelda[12] := 'N';
        wListaCelda[13] := 'O';
        wListaCelda[14] := 'P';
        wListaCelda[15] := 'Q';
        wListaCelda[16] := 'R';

        wCelda := 'A' + FORMAT(pPos);

        xlHoja.Range(wCelda).Value := 'TOTAL PRODUCCION';
        xlHoja.Range(wCelda).Font.Bold := TRUE;
        xlHoja.Range(wCelda)._BorderAround(1);

        wRango := 'B9:I' + FORMAT(pPos - 1);
        xlHoja.Range(wRango).Borders.LineStyle(1);
        wRango := 'K9:R' + FORMAT(pPos - 1);
        xlHoja.Range(wRango).Borders.LineStyle(1);
        wRango := 'S9:S' + FORMAT(pPos - 1);
        xlHoja.Range(wRango).Borders.LineStyle(1);


        //IFF FIJAR LAS SUMAS 250614

        FOR wInd := 1 TO 16 DO BEGIN
            //Realizamos la suma
            wRango := wListaCelda[wInd] + '9:' + wListaCelda[wInd] + FORMAT(pPos - 3);
            wCelda := wListaCelda[wInd] + FORMAT(pPos);
            wFormula := '=SUMA(' + wRango + ')';
            xlHoja.Range(wCelda).Formula := wFormula;
            xlHoja.Activate;
            xlHoja.Range(wCelda).Font.Bold := TRUE;
            xlHoja.Range(wCelda)._BorderAround(1);
        END;

        //IFF FIJAR LAS SUMAS 250614

        //IFF NUEVAS FÓRMULAS 2014

        xlHoja.Range('A' + FORMAT(pPos + 14)).Value := 'TOTAL PRODUCCIÓN ALO&PEN';
        xlHoja.Range('A' + FORMAT(pPos + 14)).Font.Bold := TRUE;
        xlHoja.Range('A' + FORMAT(pPos + 14))._BorderAround(1);
        xlHoja.Range('B' + FORMAT(pPos + 14)).Font.Bold := TRUE;
        xlHoja.Range('B' + FORMAT(pPos + 14))._BorderAround(1);
        xlHoja.Range('C' + FORMAT(pPos + 14))._BorderAround(1);
        xlHoja.Range('C' + FORMAT(pPos + 14)).Font.Bold := TRUE;
        xlHoja.Range('D' + FORMAT(pPos + 14))._BorderAround(1);
        xlHoja.Range('D' + FORMAT(pPos + 14)).Font.Bold := TRUE;
        xlHoja.Range('E' + FORMAT(pPos + 14))._BorderAround(1);
        xlHoja.Range('E' + FORMAT(pPos + 14)).Font.Bold := TRUE;
        xlHoja.Range('K' + FORMAT(pPos + 14))._BorderAround(1);
        xlHoja.Range('K' + FORMAT(pPos + 14)).Font.Bold := TRUE;
        xlHoja.Range('L' + FORMAT(pPos + 14))._BorderAround(1);
        xlHoja.Range('L' + FORMAT(pPos + 14)).Font.Bold := TRUE;
        xlHoja.Range('M' + FORMAT(pPos + 14))._BorderAround(1);
        xlHoja.Range('M' + FORMAT(pPos + 14)).Font.Bold := TRUE;
        xlHoja.Range('N' + FORMAT(pPos + 14))._BorderAround(1);
        xlHoja.Range('N' + FORMAT(pPos + 14)).Font.Bold := TRUE;



        xlHoja.Range('A' + FORMAT(pPos + 15)).Value := 'TOTAL PRODUCCIÓN RESTAURACIÓN';
        xlHoja.Range('A' + FORMAT(pPos + 15)).Font.Bold := TRUE;
        xlHoja.Range('A' + FORMAT(pPos + 15))._BorderAround(1);
        xlHoja.Range('B' + FORMAT(pPos + 15))._BorderAround(1);
        xlHoja.Range('B' + FORMAT(pPos + 15)).Font.Bold := TRUE;
        xlHoja.Range('C' + FORMAT(pPos + 15))._BorderAround(1);
        xlHoja.Range('C' + FORMAT(pPos + 15)).Font.Bold := TRUE;
        xlHoja.Range('D' + FORMAT(pPos + 15))._BorderAround(1);
        xlHoja.Range('D' + FORMAT(pPos + 15)).Font.Bold := TRUE;
        xlHoja.Range('E' + FORMAT(pPos + 15))._BorderAround(1);
        xlHoja.Range('E' + FORMAT(pPos + 15)).Font.Bold := TRUE;
        xlHoja.Range('K' + FORMAT(pPos + 15))._BorderAround(1);
        xlHoja.Range('K' + FORMAT(pPos + 15)).Font.Bold := TRUE;
        xlHoja.Range('L' + FORMAT(pPos + 15))._BorderAround(1);
        xlHoja.Range('L' + FORMAT(pPos + 15)).Font.Bold := TRUE;
        xlHoja.Range('M' + FORMAT(pPos + 15))._BorderAround(1);
        xlHoja.Range('M' + FORMAT(pPos + 15)).Font.Bold := TRUE;
        xlHoja.Range('N' + FORMAT(pPos + 15))._BorderAround(1);
        xlHoja.Range('N' + FORMAT(pPos + 15)).Font.Bold := TRUE;

        xlHoja.Range('A' + FORMAT(pPos + 16)).Value := 'TOTAL PRODUCCIÓN ALQUILERES';
        xlHoja.Range('A' + FORMAT(pPos + 16)).Font.Bold := TRUE;
        xlHoja.Range('A' + FORMAT(pPos + 16))._BorderAround(1);
        xlHoja.Range('B' + FORMAT(pPos + 16))._BorderAround(1);
        xlHoja.Range('B' + FORMAT(pPos + 16)).Font.Bold := TRUE;
        xlHoja.Range('C' + FORMAT(pPos + 16))._BorderAround(1);
        xlHoja.Range('C' + FORMAT(pPos + 16)).Font.Bold := TRUE;
        xlHoja.Range('D' + FORMAT(pPos + 16))._BorderAround(1);
        xlHoja.Range('D' + FORMAT(pPos + 16)).Font.Bold := TRUE;
        xlHoja.Range('E' + FORMAT(pPos + 16))._BorderAround(1);
        xlHoja.Range('E' + FORMAT(pPos + 16)).Font.Bold := TRUE;
        xlHoja.Range('K' + FORMAT(pPos + 16))._BorderAround(1);
        xlHoja.Range('K' + FORMAT(pPos + 16)).Font.Bold := TRUE;
        xlHoja.Range('L' + FORMAT(pPos + 16))._BorderAround(1);
        xlHoja.Range('L' + FORMAT(pPos + 16)).Font.Bold := TRUE;
        xlHoja.Range('M' + FORMAT(pPos + 16))._BorderAround(1);
        xlHoja.Range('M' + FORMAT(pPos + 16)).Font.Bold := TRUE;
        xlHoja.Range('N' + FORMAT(pPos + 16))._BorderAround(1);
        xlHoja.Range('N' + FORMAT(pPos + 16)).Font.Bold := TRUE;

        xlHoja.Range('A' + FORMAT(pPos + 17)).Value := 'TOTAL PRODUCCIÓN EXTRAS';
        xlHoja.Range('A' + FORMAT(pPos + 17)).Font.Bold := TRUE;
        xlHoja.Range('A' + FORMAT(pPos + 17))._BorderAround(1);
        xlHoja.Range('B' + FORMAT(pPos + 17))._BorderAround(1);
        xlHoja.Range('B' + FORMAT(pPos + 17)).Font.Bold := TRUE;
        xlHoja.Range('C' + FORMAT(pPos + 17))._BorderAround(1);
        xlHoja.Range('C' + FORMAT(pPos + 17)).Font.Bold := TRUE;
        xlHoja.Range('D' + FORMAT(pPos + 17))._BorderAround(1);
        xlHoja.Range('D' + FORMAT(pPos + 17)).Font.Bold := TRUE;
        xlHoja.Range('E' + FORMAT(pPos + 17))._BorderAround(1);
        xlHoja.Range('E' + FORMAT(pPos + 17)).Font.Bold := TRUE;
        xlHoja.Range('K' + FORMAT(pPos + 17))._BorderAround(1);
        xlHoja.Range('K' + FORMAT(pPos + 17)).Font.Bold := TRUE;
        xlHoja.Range('L' + FORMAT(pPos + 17))._BorderAround(1);
        xlHoja.Range('L' + FORMAT(pPos + 17)).Font.Bold := TRUE;
        xlHoja.Range('M' + FORMAT(pPos + 17))._BorderAround(1);
        xlHoja.Range('M' + FORMAT(pPos + 17)).Font.Bold := TRUE;
        xlHoja.Range('N' + FORMAT(pPos + 17))._BorderAround(1);
        xlHoja.Range('N' + FORMAT(pPos + 17)).Font.Bold := TRUE;


        FOR wInd := 9 TO pPos DO BEGIN
            wCelda := 'C' + FORMAT(wInd);
            xlHoja.Range(wCelda).Value := '=DATOS!' + FORMAT(wCelda);
        END;
        FOR wInd := 9 TO pPos DO BEGIN
            wCelda := 'E' + FORMAT(wInd);
            xlHoja.Range(wCelda).Value := '=DATOS!' + FORMAT(wCelda);
        END;
        FOR wInd := 9 TO pPos DO BEGIN
            wCelda := 'H' + FORMAT(wInd);
            xlHoja.Range(wCelda).Value := '=DATOS!' + FORMAT(wCelda);
        END;
        FOR wInd := 9 TO pPos DO BEGIN
            wCelda := 'L' + FORMAT(wInd);
            xlHoja.Range(wCelda).Value := '=DATOS!' + FORMAT(wCelda);
        END;
        FOR wInd := 9 TO pPos DO BEGIN
            wCelda := 'N' + FORMAT(wInd);
            xlHoja.Range(wCelda).Value := '=DATOS!' + FORMAT(wCelda);
        END;

        FOR wInd := 9 TO pPos DO BEGIN
            wCelda := 'P' + FORMAT(wInd);
            xlHoja.Range(wCelda).Value := '=DATOS!' + FORMAT(wCelda);
        END;


        xlHoja.Range('B' + FORMAT(pPos + 14)).Value := '=DATOS!B' + FORMAT(pPos + 14);
        xlHoja.Range('B' + FORMAT(pPos + 15)).Value := '=DATOS!B' + FORMAT(pPos + 15);
        xlHoja.Range('C' + FORMAT(pPos + 14)).Value := '=DATOS!C' + FORMAT(pPos + 14);
        xlHoja.Range('C' + FORMAT(pPos + 15)).Value := '=DATOS!C' + FORMAT(pPos + 15);
        xlHoja.Range('D' + FORMAT(pPos + 14)).Value := '=DATOS!D' + FORMAT(pPos + 14);
        xlHoja.Range('D' + FORMAT(pPos + 15)).Value := '=DATOS!D' + FORMAT(pPos + 15);
        xlHoja.Range('E' + FORMAT(pPos + 14)).Value := '=DATOS!E' + FORMAT(pPos + 14);
        xlHoja.Range('E' + FORMAT(pPos + 15)).Value := '=DATOS!E' + FORMAT(pPos + 15);
        xlHoja.Range('K' + FORMAT(pPos + 14)).Value := '=DATOS!K' + FORMAT(pPos + 14);
        xlHoja.Range('K' + FORMAT(pPos + 15)).Value := '=DATOS!K' + FORMAT(pPos + 15);
        xlHoja.Range('L' + FORMAT(pPos + 14)).Value := '=DATOS!L' + FORMAT(pPos + 14);
        xlHoja.Range('L' + FORMAT(pPos + 15)).Value := '=DATOS!L' + FORMAT(pPos + 15);
        xlHoja.Range('M' + FORMAT(pPos + 14)).Value := '=DATOS!M' + FORMAT(pPos + 14);
        xlHoja.Range('M' + FORMAT(pPos + 15)).Value := '=DATOS!M' + FORMAT(pPos + 15);
        xlHoja.Range('N' + FORMAT(pPos + 14)).Value := '=DATOS!N' + FORMAT(pPos + 14);
        xlHoja.Range('N' + FORMAT(pPos + 15)).Value := '=DATOS!N' + FORMAT(pPos + 15);

        xlHoja.Range('B' + FORMAT(pPos + 16)).Value := '=DATOS!B' + FORMAT(pPos + 16);
        xlHoja.Range('B' + FORMAT(pPos + 17)).Value := '=DATOS!B' + FORMAT(pPos + 17);
        xlHoja.Range('C' + FORMAT(pPos + 16)).Value := '=DATOS!C' + FORMAT(pPos + 16);
        xlHoja.Range('C' + FORMAT(pPos + 17)).Value := '=DATOS!C' + FORMAT(pPos + 17);
        xlHoja.Range('D' + FORMAT(pPos + 16)).Value := '=DATOS!D' + FORMAT(pPos + 16);
        xlHoja.Range('D' + FORMAT(pPos + 17)).Value := '=DATOS!D' + FORMAT(pPos + 17);
        xlHoja.Range('E' + FORMAT(pPos + 16)).Value := '=DATOS!E' + FORMAT(pPos + 16);
        xlHoja.Range('E' + FORMAT(pPos + 17)).Value := '=DATOS!E' + FORMAT(pPos + 17);
        xlHoja.Range('K' + FORMAT(pPos + 16)).Value := '=DATOS!K' + FORMAT(pPos + 16);
        xlHoja.Range('K' + FORMAT(pPos + 17)).Value := '=DATOS!K' + FORMAT(pPos + 17);
        xlHoja.Range('L' + FORMAT(pPos + 16)).Value := '=DATOS!L' + FORMAT(pPos + 16);
        xlHoja.Range('L' + FORMAT(pPos + 17)).Value := '=DATOS!L' + FORMAT(pPos + 17);
        xlHoja.Range('M' + FORMAT(pPos + 16)).Value := '=DATOS!M' + FORMAT(pPos + 16);
        xlHoja.Range('M' + FORMAT(pPos + 17)).Value := '=DATOS!M' + FORMAT(pPos + 17);
        xlHoja.Range('N' + FORMAT(pPos + 16)).Value := '=DATOS!N' + FORMAT(pPos + 16);
        xlHoja.Range('N' + FORMAT(pPos + 17)).Value := '=DATOS!N' + FORMAT(pPos + 17);

        //FIJACIÓN DE CRITERIO.

        xlHoja.Range('S' + FORMAT(9)).Value := 'ESTANCIAS';
        xlHoja.Range('S' + FORMAT(10)).Value := 'ESTANCIAS';
        xlHoja.Range('S' + FORMAT(11)).Value := 'ESTANCIAS';
        xlHoja.Range('S' + FORMAT(12)).Value := 'ESTANCIAS';
        xlHoja.Range('S' + FORMAT(13)).Value := 'ESTANCIAS';
        xlHoja.Range('S' + FORMAT(14)).Value := 'ESTANCIAS';
        xlHoja.Range('S' + FORMAT(15)).Value := 'ESTANCIAS';
        xlHoja.Range('S' + FORMAT(16)).Value := 'ESTANCIAS';
        xlHoja.Range('S' + FORMAT(17)).Value := 'EST. NO TI';
        xlHoja.Range('S' + FORMAT(18)).Value := 'EST. NO TI';
        xlHoja.Range('S' + FORMAT(19)).Value := 'EST. NO TI';
        xlHoja.Range('S' + FORMAT(20)).Value := 'EST. NO TI';
        xlHoja.Range('S' + FORMAT(21)).Value := 'EST. NO TI';
        xlHoja.Range('S' + FORMAT(22)).Value := 'EST. NO TI';
        xlHoja.Range('S' + FORMAT(23)).Value := 'EST. NO TI';
        xlHoja.Range('S' + FORMAT(24)).Value := 'EST. NO TI';
        xlHoja.Range('S' + FORMAT(25)).Value := 'EST. NO TI';
        xlHoja.Range('S' + FORMAT(26)).Value := 'EST. NO TI';
        xlHoja.Range('S' + FORMAT(27)).Value := 'ESTANCIAS';
        xlHoja.Range('S' + FORMAT(28)).Value := 'EST. NO TI';
        xlHoja.Range('S' + FORMAT(29)).Value := 'EST. NO TI';
        xlHoja.Range('S' + FORMAT(30)).Value := 'EST. NO TI';
        xlHoja.Range('S' + FORMAT(31)).Value := 'EST. NO TI';
        xlHoja.Range('S' + FORMAT(32)).Value := 'ESTANCIAS';
        xlHoja.Range('S' + FORMAT(33)).Value := 'ESTANCIAS';
        xlHoja.Range('S' + FORMAT(34)).Value := 'Ocupacion';
        xlHoja.Range('S' + FORMAT(35)).Value := 'Ocupacion';
        xlHoja.Range('S' + FORMAT(36)).Value := 'ESTANCIAS';
        xlHoja.Range('S' + FORMAT(37)).Value := 'ESTANCIAS';
        xlHoja.Range('S' + FORMAT(38)).Value := 'ESTANCIAS';
        xlHoja.Range('S' + FORMAT(39)).Value := 'ESTANCIAS';
        xlHoja.Range('S' + FORMAT(40)).Value := 'ESTANCIAS';
        xlHoja.Range('S' + FORMAT(41)).Value := 'S/P';
        xlHoja.Range('S' + FORMAT(42)).Value := 'S/P';
        xlHoja.Range('S' + FORMAT(43)).Value := 'S/P';
        xlHoja.Range('S' + FORMAT(44)).Value := 'S/P';
        xlHoja.Range('S' + FORMAT(45)).Value := 'S/P';
        xlHoja.Range('S' + FORMAT(46)).Value := 'S/P';
        xlHoja.Range('S' + FORMAT(47)).Value := 'ESTANCIAS';
        xlHoja.Range('S' + FORMAT(48)).Value := 'ESTANCIAS';
        xlHoja.Range('S' + FORMAT(49)).Value := 'ESTANCIAS';
        xlHoja.Range('S' + FORMAT(50)).Value := 'Ocupacion';
        xlHoja.Range('S' + FORMAT(51)).Value := 'Ocupacion';
        xlHoja.Range('S' + FORMAT(52)).Value := 'S/P';
        xlHoja.Range('S' + FORMAT(53)).Value := 'S/P';
        xlHoja.Range('S' + FORMAT(54)).Value := 'S/P';
        xlHoja.Range('S' + FORMAT(55)).Value := 'S/P';
        //xlHoja.Range('S'+FORMAT(56)).Value:='S/P';
        xlHoja.Range('S' + FORMAT(56))._BorderAround(1);
        xlHoja.Range('S' + FORMAT(56)).Value := 'ESTANCIAS';



        /*
        xlHoja.Range('C'+FORMAT(pPos)).Value:='';
        xlHoja.Range('E'+FORMAT(pPos)).Value:='';
        xlHoja.Range('G'+FORMAT(pPos)).Value:='';
        xlHoja.Range('H'+FORMAT(pPos)).Value:='';
        xlHoja.Range('I'+FORMAT(pPos)).Value:='';
        xlHoja.Range('L'+FORMAT(pPos)).Value:='';
        xlHoja.Range('N'+FORMAT(pPos)).Value:='';
        xlHoja.Range('P'+FORMAT(pPos)).Value:='';
        xlHoja.Range('Q'+FORMAT(pPos)).Value:='';
        */

    end;

    procedure InsCabEst(pPos: Integer)
    begin
        //InsCabEst

        wListaCelda[1] := 'B';
        wListaCelda[2] := 'D';
        wListaCelda[3] := 'K';
        wListaCelda[4] := 'M';

        wListaCelda[5] := 'C';
        wListaCelda[6] := 'E';
        wListaCelda[7] := 'L';
        wListaCelda[8] := 'N';

        wListaCelda[9] := 'F';
        wListaCelda[10] := 'O';

        wCelda := 'A' + FORMAT(pPos);
        xlHoja.Range(wCelda).Value := 'Estancias por Régimen';
        xlHoja.Range(wCelda).Font.Bold := TRUE;
        xlHoja.Range(wCelda)._BorderAround(1);
        xlHoja.Range(wCelda).Interior.ColorIndex := 40;

        wCelda := 'C' + FORMAT(pPos + 7);
        xlHoja.Range(wCelda).Value := '%';
        xlHoja.Range(wCelda).Font.Bold := TRUE;
        xlHoja.Range(wCelda)._BorderAround(1);
        xlHoja.Range(wCelda).Interior.ColorIndex := 40;

        wCelda := 'E' + FORMAT(pPos + 7);
        xlHoja.Range(wCelda).Value := '%';
        xlHoja.Range(wCelda).Font.Bold := TRUE;
        xlHoja.Range(wCelda)._BorderAround(1);
        xlHoja.Range(wCelda).Interior.ColorIndex := 40;

        wCelda := 'L' + FORMAT(pPos + 7);
        xlHoja.Range(wCelda).Value := '%';
        xlHoja.Range(wCelda).Font.Bold := TRUE;
        xlHoja.Range(wCelda)._BorderAround(1);
        xlHoja.Range(wCelda).Interior.ColorIndex := 40;

        wCelda := 'N' + FORMAT(pPos + 7);
        xlHoja.Range(wCelda).Value := '%';
        xlHoja.Range(wCelda).Font.Bold := TRUE;
        xlHoja.Range(wCelda)._BorderAround(1);
        xlHoja.Range(wCelda).Interior.ColorIndex := 40;

        wCelda := 'C' + FORMAT(pPos + 11);
        xlHoja.Range(wCelda).Value := '%';
        xlHoja.Range(wCelda).Font.Bold := TRUE;
        xlHoja.Range(wCelda)._BorderAround(1);
        xlHoja.Range(wCelda).Interior.ColorIndex := 40;

        wCelda := 'E' + FORMAT(pPos + 11);
        xlHoja.Range(wCelda).Value := '%';
        xlHoja.Range(wCelda).Font.Bold := TRUE;
        xlHoja.Range(wCelda)._BorderAround(1);
        xlHoja.Range(wCelda).Interior.ColorIndex := 40;

        wCelda := 'L' + FORMAT(pPos + 11);
        xlHoja.Range(wCelda).Value := '%';
        xlHoja.Range(wCelda).Font.Bold := TRUE;
        xlHoja.Range(wCelda)._BorderAround(1);
        xlHoja.Range(wCelda).Interior.ColorIndex := 40;

        wCelda := 'N' + FORMAT(pPos + 11);
        xlHoja.Range(wCelda).Value := '%';
        xlHoja.Range(wCelda).Font.Bold := TRUE;
        xlHoja.Range(wCelda)._BorderAround(1);
        xlHoja.Range(wCelda).Interior.ColorIndex := 40;


        /*
        
        // MODIFICACIONES IFF 230611 INSERTAMOS TEXTO PROMEDIO
        
        wCelda:='G'+FORMAT(pPos);
        xlHoja.Range(wCelda).Value:='Promedio';
        xlHoja.Range(wCelda).Font.Bold:=TRUE;
        xlHoja.Range(wCelda)._BorderAround(1);
        xlHoja.Range(wCelda).Interior.ColorIndex:=40;
        
        wCelda:='P'+FORMAT(pPos);
        xlHoja.Range(wCelda).Value:='Promedio';
        xlHoja.Range(wCelda).Font.Bold:=TRUE;
        xlHoja.Range(wCelda)._BorderAround(1);
        xlHoja.Range(wCelda).Interior.ColorIndex:=40;
        
        //MODIFICACIONES IFF 230611 INSERTAMOS TEXTO PROMEDIO
        */
        FOR wInd := 1 TO 4 DO BEGIN
            //INSERTAMOS EL TEXTO ESTANCIAS
            wCelda := wListaCelda[wInd] + FORMAT(pPos);
            xlHoja.Range(wCelda).Value := 'Estancias';
            xlHoja.Range(wCelda).Font.Bold := TRUE;
            xlHoja.Range(wCelda)._BorderAround(1);
            xlHoja.Range(wCelda).Interior.ColorIndex := 40;
        END;

        FOR wInd := 5 TO 8 DO BEGIN
            //INSERTAMOS EL TEXTO %
            wCelda := wListaCelda[wInd] + FORMAT(pPos);
            xlHoja.Range(wCelda).Value := '%';
            xlHoja.Range(wCelda).Font.Bold := TRUE;
            xlHoja.Range(wCelda)._BorderAround(1);
            xlHoja.Range(wCelda).Interior.ColorIndex := 40;
        END;

        FOR wInd := 9 TO 10 DO BEGIN
            //INSERTAMOS EL TEXTO VARIACION
            wCelda := wListaCelda[wInd] + FORMAT(pPos);
            xlHoja.Range(wCelda).Value := 'Variación';
            xlHoja.Range(wCelda).Font.Bold := TRUE;
            xlHoja.Range(wCelda)._BorderAround(1);
            xlHoja.Range(wCelda).Interior.ColorIndex := 40;

        END;

    end;

    procedure InsCabOc(pPos: Integer)
    begin
        //InsCabOc

        wCelda := 'M5';
        xlHoja.Range(wCelda).Value := 'Abierto Act.';
        wCelda := 'L5';
        xlHoja.Range(wCelda).Value := 0;
        wCelda := 'K5';
        xlHoja.Range(wCelda).Value := 'Abierto Ant.';
        wCelda := 'N5';
        xlHoja.Range(wCelda).Value := 0;
        wCelda := 'A' + FORMAT(pPos);
        xlHoja.Range(wCelda).Value := 'TOTAL OCUPACION';
        xlHoja.Range(wCelda).Font.Bold := TRUE;
        xlHoja.Range(wCelda)._BorderAround(1);

        EVALUATE(wCelda, STRSUBSTNO('B%1', pPos));
        xlHoja.Range(wCelda).Value := wOcMes;
        xlHoja.Range(wCelda).Borders.LineStyle(1);
        xlHoja.Range(wCelda).Font.Bold := TRUE;

        EVALUATE(wCelda, STRSUBSTNO('C%1', pPos));
        xlHoja.Range(wCelda).Value := wPOcMes;
        xlHoja.Range(wCelda).Borders.LineStyle(1);
        //xlHoja.Range(wCelda).Value:='=(B'+FORMAT(pPos)+'/((B4-N4+1)*'+FORMAT(wTotHabHotel)+'))*100';
        xlHoja.Range(wCelda).Font.Bold := TRUE;

        EVALUATE(wCelda, STRSUBSTNO('D%1', pPos));
        xlHoja.Range(wCelda).Value := wOcMesAnt;
        xlHoja.Range(wCelda).Borders.LineStyle(1);
        xlHoja.Range(wCelda).Font.Bold := TRUE;

        EVALUATE(wCelda, STRSUBSTNO('E%1', pPos));
        xlHoja.Range(wCelda).Value := wPOcMesAnt;
        xlHoja.Range(wCelda).Borders.LineStyle(1);
        xlHoja.Range(wCelda).Font.Bold := TRUE;

        EVALUATE(wCelda, STRSUBSTNO('K%1', pPos));
        xlHoja.Range(wCelda).Value := wOcAño;
        xlHoja.Range(wCelda).Borders.LineStyle(1);
        xlHoja.Range(wCelda).Font.Bold := TRUE;

        EVALUATE(wCelda, STRSUBSTNO('L%1', pPos));
        //MODIFICACIONES IFF 230611
        xlHoja.Range(wCelda).Value := '=(K' + FORMAT(pPos) + '/((B4-N4+1)*' + FORMAT(wTotHabHotel) + '))*100';
        //xlHoja.Range(wCelda).Value:='=SI(N5<1;(K66/(B4-N4+1)*216)*100;K66/(N5*216/100))';
        // (K66/((B4-N4+1)*216))*100
        xlHoja.Range(wCelda).Value := '=SI(N5=0;(K' + FORMAT(pPos) + '/((B4-N4+1)*' + FORMAT(wTotHabHotel) + ')*100);K' + FORMAT(pPos) + '/(N5*' + FORMAT(wTotHabHotel) + '/100))';
        xlHoja.Range(wCelda).Borders.LineStyle(1);
        //FIN MODIFICACIONES IFF 230611

        //LINEA ORIGINAL
        //xlHoja.Range(wCelda).Value:=wPOcAño; xlHoja.Range(wCelda).Borders.LineStyle(1);
        //FIN LINEA ORIGINAL
        xlHoja.Range(wCelda).Font.Bold := TRUE;

        EVALUATE(wCelda, STRSUBSTNO('M%1', pPos));
        xlHoja.Range(wCelda).Value := wOcAñoAnt;
        xlHoja.Range(wCelda).Borders.LineStyle(1);
        xlHoja.Range(wCelda).Font.Bold := TRUE;

        EVALUATE(wCelda, STRSUBSTNO('N%1', pPos));
        //xlHoja.Range(wCelda).Value:='=SI(L5<=1;(M'+FORMAT(pPos)+'/(B4-N4+1)*'+FORMAT(wTotHabHotel)+')*100;M'+FORMAT(pPos)+'/(L5*'+FORMAT(wTotHabHotel)+'/100))';
        xlHoja.Range(wCelda).Value := '=SI(L5=0;(M' + FORMAT(pPos) + '/((B4-N4+1)*' + FORMAT(wTotHabHotel) + ')*100);M' + FORMAT(pPos) + '/(L5*' + FORMAT(wTotHabHotel) + '/100))';
        //xlHoja.Range(wCelda).Value:=wPOcAñoAnt;
        xlHoja.Range(wCelda).Borders.LineStyle(1);
        xlHoja.Range(wCelda).Font.Bold := TRUE;

        //MODIFICACIONES IFF
        //INSERTAMOS FÓRMULAS PARA CÁLCULO DE PROMEDIOS
        /*
        pPos:=pPos-7;
        EVALUATE(wCelda,STRSUBSTNO('G%1',pPos));
        //xlHoja.Range(wCelda).Value:='=B10/B'+FORMAT(pPos);
        xlHoja.Range(wCelda).Value:='=SI(B10/B'+FORMAT(pPos)+'<>0;B10/B'+FORMAT(pPos)+';0)';
        xlHoja.Range(wCelda).Borders.LineStyle(1);
        EVALUATE(wCelda,STRSUBSTNO('P%1',pPos));
        //xlHoja.Range(wCelda).Value:='=K10/K'+FORMAT(pPos);
        xlHoja.Range(wCelda).Value:='=SI(K10/K'+FORMAT(pPos)+'<>0;K10/K'+FORMAT(pPos)+';0)';
        xlHoja.Range(wCelda).Borders.LineStyle(1);
        pPos:=pPos+1;
        EVALUATE(wCelda,STRSUBSTNO('G%1',pPos));
        //xlHoja.Range(wCelda).Value:='=B11/B'+FORMAT(pPos);;
        xlHoja.Range(wCelda).Value:='=SI(B11/B'+FORMAT(pPos)+'<>0;B11/B'+FORMAT(pPos)+';0)';
        xlHoja.Range(wCelda).Borders.LineStyle(1);
        EVALUATE(wCelda,STRSUBSTNO('P%1',pPos));
        //xlHoja.Range(wCelda).Value:='=K11/K'+FORMAT(pPos);
        xlHoja.Range(wCelda).Value:='=SI(K11/K'+FORMAT(pPos)+'<>0;K11/K'+FORMAT(pPos)+';0)';
        xlHoja.Range(wCelda).Borders.LineStyle(1);
        pPos:=pPos+1;
        EVALUATE(wCelda,STRSUBSTNO('G%1',pPos));
        //xlHoja.Range(wCelda).Value:='=B12/B'+FORMAT(pPos);;
        xlHoja.Range(wCelda).Value:='=SI(B12/B'+FORMAT(pPos)+'<>0;B12/B'+FORMAT(pPos)+';0)';
        xlHoja.Range(wCelda).Borders.LineStyle(1);
        EVALUATE(wCelda,STRSUBSTNO('P%1',pPos));
        //xlHoja.Range(wCelda).Value:='=K12/K'+FORMAT(pPos);
        xlHoja.Range(wCelda).Value:='=SI(K12/K'+FORMAT(pPos)+'<>0;K12/K'+FORMAT(pPos)+';0)';
        xlHoja.Range(wCelda).Borders.LineStyle(1);
        pPos:=pPos+1;
        EVALUATE(wCelda,STRSUBSTNO('G%1',pPos));
        //xlHoja.Range(wCelda).Value:='=B13/B'+FORMAT(pPos);;
        xlHoja.Range(wCelda).Value:='=SI(B13/B'+FORMAT(pPos)+'<>0;B13/B'+FORMAT(pPos)+';0)';
        xlHoja.Range(wCelda).Borders.LineStyle(1);
        EVALUATE(wCelda,STRSUBSTNO('P%1',pPos));
        //xlHoja.Range(wCelda).Value:='=K13/K'+FORMAT(pPos);
        xlHoja.Range(wCelda).Value:='=SI(K13/K'+FORMAT(pPos)+'<>0;K13/K'+FORMAT(pPos)+';0)';
        xlHoja.Range(wCelda).Borders.LineStyle(1);
        pPos:=pPos+1;
        EVALUATE(wCelda,STRSUBSTNO('G%1',pPos));
        //xlHoja.Range(wCelda).Value:='=B14/B'+FORMAT(pPos);;
        xlHoja.Range(wCelda).Value:='=SI(B14/B'+FORMAT(pPos)+'<>0;B14/B'+FORMAT(pPos)+';0)';
        xlHoja.Range(wCelda).Borders.LineStyle(1);
        EVALUATE(wCelda,STRSUBSTNO('P%1',pPos));
        //xlHoja.Range(wCelda).Value:='=K14/K'+FORMAT(pPos);
        xlHoja.Range(wCelda).Value:='=SI(K14/K'+FORMAT(pPos)+'<>0;K14/K'+FORMAT(pPos)+';0)';
        xlHoja.Range(wCelda).Borders.LineStyle(1);
        */
        //FIN MODIFICACIONES IFF 230611 INSERTAR FÓRMULAS PROMEDIOS

    end;

    procedure InsertarConcepEst(pRegimen: Text[30]; pPos: Integer)
    begin
        //InsertarConcepEst

        EVALUATE(wCelda, STRSUBSTNO('A%1', pPos + 8));
        xlHoja.Range(wCelda).Value := pRegimen;

        xlHoja.Range(wCelda)._BorderAround(1);

        IF pRegimen <> 'TOTAL' THEN
            xlHoja.Range(wCelda).Interior.ColorIndex := 40
        ELSE
            xlHoja.Range(wCelda).Font.Bold := TRUE;
    end;

    procedure InsertarValorEst(pRegimen: Text[30]; pPos: Integer)
    begin
        //InsertarValorEst

        EVALUATE(wCelda, STRSUBSTNO('B%1', pPos + 8));
        xlHoja.Range(wCelda).Value := wEMAct;
        xlHoja.Range(wCelda).Borders.LineStyle(1);
        IF pRegimen = 'TOTAL' THEN xlHoja.Range(wCelda).Font.Bold := TRUE;

        EVALUATE(wCelda, STRSUBSTNO('C%1', pPos + 8));
        xlHoja.Range(wCelda).Value := wEPMAct;
        xlHoja.Range(wCelda).Borders.LineStyle(1);
        IF pRegimen = 'TOTAL' THEN xlHoja.Range(wCelda).Font.Bold := TRUE;
        EVALUATE(wCelda, STRSUBSTNO('D%1', pPos + 8));
        xlHoja.Range(wCelda).Value := wEMAnt;
        xlHoja.Range(wCelda).Borders.LineStyle(1);
        IF pRegimen = 'TOTAL' THEN xlHoja.Range(wCelda).Font.Bold := TRUE;
        EVALUATE(wCelda, STRSUBSTNO('E%1', pPos + 8));
        xlHoja.Range(wCelda).Value := wEPMAnt;
        xlHoja.Range(wCelda).Borders.LineStyle(1);
        IF pRegimen = 'TOTAL' THEN xlHoja.Range(wCelda).Font.Bold := TRUE;
        EVALUATE(wCelda, STRSUBSTNO('F%1', pPos + 8));
        xlHoja.Range(wCelda).Value := wEMVar;
        xlHoja.Range(wCelda).Borders.LineStyle(1);
        IF pRegimen = 'TOTAL' THEN xlHoja.Range(wCelda).Font.Bold := TRUE;

        EVALUATE(wCelda, STRSUBSTNO('K%1', pPos + 8));
        xlHoja.Range(wCelda).Value := wEAAct;
        xlHoja.Range(wCelda).Borders.LineStyle(1);
        IF pRegimen = 'TOTAL' THEN xlHoja.Range(wCelda).Font.Bold := TRUE;
        EVALUATE(wCelda, STRSUBSTNO('L%1', pPos + 8));
        //xlHoja.Range(wCelda).Value:='tutup';
        xlHoja.Range(wCelda).Value := wEPAAct;
        xlHoja.Range(wCelda).Borders.LineStyle(1);
        IF pRegimen = 'TOTAL' THEN xlHoja.Range(wCelda).Font.Bold := TRUE;
        EVALUATE(wCelda, STRSUBSTNO('M%1', pPos + 8));
        xlHoja.Range(wCelda).Value := wEAAnt;
        xlHoja.Range(wCelda).Borders.LineStyle(1);
        IF pRegimen = 'TOTAL' THEN xlHoja.Range(wCelda).Font.Bold := TRUE;
        EVALUATE(wCelda, STRSUBSTNO('N%1', pPos + 8));
        xlHoja.Range(wCelda).Value := wEPAAnt;
        xlHoja.Range(wCelda).Borders.LineStyle(1);
        IF pRegimen = 'TOTAL' THEN xlHoja.Range(wCelda).Font.Bold := TRUE;
        EVALUATE(wCelda, STRSUBSTNO('O%1', pPos + 8));
        xlHoja.Range(wCelda).Value := wEAVar;
        xlHoja.Range(wCelda).Borders.LineStyle(1);
        IF pRegimen = 'TOTAL' THEN xlHoja.Range(wCelda).Font.Bold := TRUE;
    end;
}

