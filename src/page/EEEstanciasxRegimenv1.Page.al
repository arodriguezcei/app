page 7012451 "EE Estancias x Régimen v1"
{
    PageType = ListPart;
    SourceTable = 2000000026;
    SourceTableView = SORTING(Number)
                      WHERE(Number = FILTER(> 0));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Régimen"; wReg[rec.Number])
                {
                }
                field("Estancias (Mes Actual)"; wEMAct)
                {
                }
                field("%_1"; wEPMAct)
                {
                    Caption = '%';
                }
                field("Estancias (Mes Anterior)"; wEMAnt)
                {
                }
                field("%_2"; wEPMAnt)
                {
                    Caption = '%';
                }
                field("Variación"; wEMVar)
                {
                }
                field("Estancias (Año Actual)_1"; wEAAct)
                {
                    Caption = 'Estancias (Año Actual)';
                }
                field("%_3"; wEPAAct)
                {
                    Caption = '%';
                }
                field("Estancias (Año Anterior)_1"; wEAAnt)
                {
                    Caption = 'Estancias (Año Anterior)';
                }
                field("%_4"; wEPAAnt)
                {
                    Caption = '%';
                }
                field("Variación_1"; wEAVar)
                {
                    Caption = 'Variación';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        IF wMiFecha <> 0D THEN Calcular(wReg[rec.Number]);
    end;

    var
        rReg: Record 7000112;
        rBook: Record 7000189;
        wInd: Integer;
        wNumReg: Integer;
        wReg: array[30] of Text[30];
        wFiltHotel: Text[250];
        wMiFecha: Date;
        "wApAñoAct": Date;
        "wApAñoAnt": Date;
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
        lFecIni: Date;
        lFecFin: Date;
        Text000: Label 'TOTAL';
        Text001: Label '-1A';

    procedure Calcular(pRegimen: Text[30])
    var
        rGruCen: Record 7000117;
        lFecIni: Date;
        lFecFin: Date;
    begin
        //Calcular

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

        IF rBook.FIND('-') THEN
            REPEAT
                //MES
                //Actual
                lFecIni := DMY2DATE(1, DATE2DMY(wMiFecha, 2), DATE2DMY(wMiFecha, 3));
                lFecFin := wMiFecha;
                rBook.SETRANGE(rBook."Rango Fecha", lFecIni, lFecFin);

                rBook.SETRANGE(rBook."Rango Regimen fact.");
                rBook.CALCFIELDS(rBook.AD, rBook.JR, rBook.NI);
                wTotEMAct := wTotEMAct + (rBook.AD + rBook.JR + rBook.NI);

                IF pRegimen <> Text000 THEN rBook.SETRANGE(rBook."Rango Regimen fact.", pRegimen);
                rBook.CALCFIELDS(rBook.AD, rBook.JR, rBook.NI);
                wEMAct := wEMAct + (rBook.AD + rBook.JR + rBook.NI);

                IF wTotEMAct <> 0 THEN wEPMAct := ROUND((wEMAct * 100) / wTotEMAct);


                //Año Anterior
                lFecIni := DMY2DATE(1, DATE2DMY(wMiFecha, 2), DATE2DMY(CALCDATE('-1A', wMiFecha), 3));
                lFecFin := CALCDATE('-1A', wMiFecha);
                //     lFecFin:=DMY2DATE(DATE2DMY(wMiFecha,1),DATE2DMY(wMiFecha,2),DATE2DMY(CALCDATE('-1A',wMiFecha),3));
                rBook.SETRANGE(rBook."Rango Fecha", lFecIni, lFecFin);

                rBook.SETRANGE(rBook."Rango Regimen fact.");
                rBook.CALCFIELDS(rBook.AD, rBook.JR, rBook.NI);
                wTotEMAnt := wTotEMAnt + (rBook.AD + rBook.JR + rBook.NI);

                IF pRegimen <> Text000 THEN rBook.SETRANGE(rBook."Rango Regimen fact.", pRegimen);
                rBook.CALCFIELDS(rBook.AD, rBook.JR, rBook.NI);
                wEMAnt := wEMAnt + (rBook.AD + rBook.JR + rBook.NI);

                IF wTotEMAnt <> 0 THEN wEPMAnt := ROUND((wEMAnt * 100) / wTotEMAnt);

                //Variación
                wEMVar := wEMAct - wEMAnt;



                //AÑO
                //Actual
                lFecIni := wApAñoAct; //Apertura año actual.
                lFecFin := DMY2DATE(DATE2DMY(wMiFecha, 1), DATE2DMY(wMiFecha, 2), DATE2DMY(wMiFecha, 3));
                rBook.SETRANGE(rBook."Rango Fecha", lFecIni, lFecFin);

                rBook.SETRANGE(rBook."Rango Regimen fact.");
                rBook.CALCFIELDS(rBook.AD, rBook.JR, rBook.NI);
                wTotEAAct := wTotEAAct + (rBook.AD + rBook.JR + rBook.NI);

                IF pRegimen <> Text000 THEN rBook.SETRANGE(rBook."Rango Regimen fact.", pRegimen);
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

                IF pRegimen <> Text000 THEN rBook.SETRANGE(rBook."Rango Regimen fact.", pRegimen);
                rBook.CALCFIELDS(rBook.AD, rBook.JR, rBook.NI);
                wEAAnt := wEAAnt + (rBook.AD + rBook.JR + rBook.NI);

                IF wTotEAAnt <> 0 THEN wEPAAnt := ROUND((wEAAnt * 100) / wTotEAAnt);

                //Variación
                wEAVar := wEAAct - wEAAnt;


            UNTIL rBook.NEXT = 0;
    end;

    procedure ObtenerDatos(pFiltHotel: Text[250]; pMiFecha: Date; pApAAct: Date; pApAant: Date)
    begin
        //ObtenerDatos

        wFiltHotel := pFiltHotel;
        wMiFecha := pMiFecha;
        wApAñoAct := pApAAct; //Fecha de apertura del año en curso.
        wApAñoAnt := pApAant; //Fecha de apertura del año pasado.

        rec.SETRANGE(Number, 1, rReg.COUNT + 1);

        wNumReg := rReg.COUNT;

        wInd := 1;

        //montar Matriz
        IF rReg.FIND('-') THEN
            REPEAT
                wReg[wInd] := rReg.Regimen;
                wInd := wInd + 1;
            UNTIL rReg.NEXT = 0;

        wReg[wInd] := Text000;


        CurrPage.UPDATE;
    end;
}

