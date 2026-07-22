page 50001 "Info Productos"
{
    Editable = true;
    PageType = List;
    SourceTable = Item;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Fecha Inicial"; wFechaIni)
                {

                    trigger OnValidate()
                    begin
                        bPend := TRUE;
                        CurrPage.UPDATE(FALSE);
                    end;
                }
                field("Fecha Final"; wFechaFin)
                {

                    trigger OnValidate()
                    begin
                        fEjecutarCalculo;
                    end;
                }
                field("No Mostrar sin consumo"; bNoMostrar)
                {

                    trigger OnValidate()
                    begin
                        IF bNoMostrar THEN
                            Rec.SETFILTER("QHTConsumo (DL)", '<>0')
                        ELSE
                            Rec.SETRANGE("QHTConsumo (DL)");
                        CurrPage.UPDATE(FALSE);
                    end;
                }
            }
            repeater(Group)
            {
                Editable = false;
                field("No."; rec."No.")
                {
                }
                field(Description; rec.Description)
                {
                }
                field("Base Unit of Measure"; rec."Base Unit of Measure")
                {
                }
                //field("Sub-Familia"; rec."QHTSub-Familia")
                // {
                //}
                field("Description 2"; rec."Description 2")
                {
                }
                field(Clasificacion; rec.QHTClasificacion)
                {
                }
                field("Consumo (DL)"; rec."QHTConsumo (DL)")
                {
                }
                field("Uds. Consumo"; wUdsConsumo)
                {
                }
                field("Imp. Stock Inicial"; wImpStockIni)
                {
                }
                field("Uds. Stock Inicial"; wStockIni)
                {
                }
                field("Purchases (LCY)"; rec."Purchases (LCY)")
                {
                }
                field("Compras (cantidad) REC"; rec."QHTCompras (cantidad) REC")
                {
                }
                field("Imp. Stock Final"; wImpStockFin)
                {
                }
                field("Uds. Stock Final"; wStockFin)
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(wFechaIni)
            {
            }
            action(wFechaFin)
            {
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        //THB-090819-IFF
        fCalcular;
    end;

    trigger OnInit()
    begin
        //FilterPageBuilder.AddRecord('Item Table', Item);
        //FILTERPAGEBUILDER.addrecord('Item', Rec)
        //FILTERPAGEBUILDER.ADDfield(Rec."Filtro hotel");
        //FilterPageBuilder.PageCaption := 'Item Filter Page';
        //FilterPagebuilder.RunModal;
        //Item.SetView( filterPagebuilder.Getview('Item Table'));
    end;

    trigger OnOpenPage()
    begin
        wFechaIni := TODAY;
        wFechaFin := TODAY;
    end;

    var
        wUdsConsumo: Decimal;
        wImpStockIni: Decimal;
        wStockIni: Decimal;
        wImpStockFin: Decimal;
        wStockFin: Decimal;
        wFechaIni: Date;
        wFechaFin: Date;
        rMovVal: Record 5802;
        bPend: Boolean;
        bNoMostrar: Boolean;

    local procedure fCalcular()
    begin
        //THB-090819-IFF

        wStockIni := 0;
        wStockFin := 0;
        wUdsConsumo := 0;
        wImpStockIni := 0;
        wImpStockFin := 0;


        /*
        rGrCon.SETRANGE(rGrCon.Code,"Sub-Familia");
        IF rGrCon.FIND('-') THEN wSubFam:=rGrCon.Description;
        rPrice.SETRANGE(rPrice."Item No.","No.");
        IF rPrice.FIND('+') THEN BEGIN
          wPrice:=rPrice."Direct Unit Cost";
          rProv.SETRANGE(rProv."No.",rPrice."Vendor No.");
          IF rProv.FIND('-') THEN wProv:=rProv.Name;
        END;
        */
        rec.SETFILTER("Date Filter", '..%1', wFechaIni);
        rec.CALCFIELDS(rec."QHTStock Actual", rec."QHTImporte (DL)");
        wStockIni := rec."QHTStock Actual";
        wImpStockIni := rec."QHTImporte (DL)";
        rec.SETFILTER("Date Filter", '..%1', wFechaFin);
        rec.CALCFIELDS(rec."QHTStock Actual", rec."QHTImporte (DL)");
        wStockFin := rec."QHTStock Actual";
        wImpStockFin := rec."QHTImporte (DL)";
        rec.SETRANGE("Date Filter", wFechaIni, wFechaFin);
        rec.CALCFIELDS(rec."QHTConsumo (DL)", rec."QHTCompras (DL)", rec."QHTCompras (cantidad) REC");

        rMovVal.SETRANGE(rMovVal."Item Ledger Entry Type", 3);
        rMovVal.SETRANGE(rMovVal."Posting Date", wFechaIni, wFechaFin);
        rMovVal.SETRANGE(rMovVal."Item No.", rec."No.");
        rMovVal.SETRANGE(rMovVal.QHTSubtipo, 3, 4);
        rMovVal.SETRANGE(rMovVal."QHTValorable inventario", TRUE);
        IF rMovVal.FIND('-') THEN BEGIN
            REPEAT
                wUdsConsumo := wUdsConsumo + rMovVal."Valued Quantity";
            UNTIL rMovVal.NEXT = 0;
        END;

        wUdsConsumo := wUdsConsumo * -1;

    end;

    local procedure fEjecutarCalculo()
    var
        Ventana: Dialog;
    begin
        IF CONFIRM('¿Deseas ver sólo los productos con consumo?', FALSE) THEN BEGIN
            bNoMostrar := TRUE;
        END ELSE BEGIN
            bNoMostrar := FALSE;
        END;

        Ventana.OPEN('Calculando datos, por favor espere...');
        // Aplicar filtro de fecha en la tabla principal
        Rec.SETRANGE("Date Filter", wFechaIni, wFechaFin);
        // Aplicar filtro de consumo si corresponde
        IF bNoMostrar THEN
            Rec.SETFILTER("QHTConsumo (DL)", '<>0')
        ELSE
            Rec.SETRANGE("QHTConsumo (DL)");
        // Forzar actualizaci¾n de todos los registros
        IF Rec.FINDFIRST THEN BEGIN
            REPEAT
            // El OnAfterGetRecord se ejecutarß para cada registro
            UNTIL Rec.NEXT = 0;
        END;

        // Volver al primer registro y actualizar
        IF Rec.FINDFIRST THEN;
        CurrPage.UPDATE(FALSE);
        Ventana.CLOSE;
    end;
}

