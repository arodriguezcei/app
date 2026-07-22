page 7012452 "Excel exportacion"
{
    PageType = Card;
    SourceTable = 2000000026;
    SourceTableView = SORTING(Number)
                      WHERE(Number = CONST(1));

    layout
    {
        area(content)
        {
            group(General)
            {
                field(Hotel; wFiltHotel)
                {

                    trigger OnAssistEdit()
                    begin
                        cProGen.SeleccionHoteles(wFiltHotel, TRUE);
                        CurrPage.SubProd.PAGE.ObtenerDatos(wFiltHotel, wFecha, wFechaApAact, wFechaApAant, FALSE, wArchivo, wDirec);
                        CurrPage.SubEst.PAGE.ObtenerDatos(wFiltHotel, wFecha, wFechaApAact, wFechaApAant);
                    end;
                }
                field(Fecha; wFecha)
                {

                    trigger OnValidate()
                    begin
                        CurrPage.SubProd.PAGE.ObtenerDatos(wFiltHotel, wFecha, wFechaApAact, wFechaApAant, FALSE, wArchivo, wDirec);
                        CurrPage.SubEst.PAGE.ObtenerDatos(wFiltHotel, wFecha, wFechaApAact, wFechaApAant);
                    end;
                }
                field("Apertura Año Act."; wFechaApAact)
                {

                    trigger OnValidate()
                    begin
                        CurrPage.SubProd.PAGE.ObtenerDatos(wFiltHotel, wFecha, wFechaApAact, wFechaApAant, FALSE, wArchivo, wDirec);
                        CurrPage.SubEst.PAGE.ObtenerDatos(wFiltHotel, wFecha, wFechaApAact, wFechaApAant);
                    end;
                }
                field("Apertura Año Ant."; wFechaApAant)
                {

                    trigger OnValidate()
                    begin
                        CurrPage.SubProd.PAGE.ObtenerDatos(wFiltHotel, wFecha, wFechaApAact, wFechaApAant, FALSE, wArchivo, wDirec);
                        CurrPage.SubEst.PAGE.ObtenerDatos(wFiltHotel, wFecha, wFechaApAact, wFechaApAant);
                    end;
                }
            }
            part(SubProd; 7012450)
            {
                Editable = false;
            }
            part(SubEst; 7012451)
            {
                Editable = false;
            }
            group(Archivo)
            {
                field(Ruta; wDirec)
                {
                }
                field(Plantilla; wArchivo)
                {
                }
            }
        }
    }

    actions
    {
        area(creation)
        {
            action(Exportar)
            {

                trigger OnAction()
                begin
                    CurrPage.SubProd.PAGE.ObtenerDatos(wFiltHotel, wFecha, wFechaApAact, wFechaApAant, TRUE, wArchivo, wDirec);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        rec.RESET;
        rec.FILTERGROUP(2);
        rec.SETRANGE(Number, 1);
        rec.FILTERGROUP(0);
        rec.FINDFIRST;
        wFecha := CALCDATE('-1D', WORKDATE);
        //Ponemos unos valores por defecto en las fechas de apertura:
        wFechaApAact := DMY2DATE(1, 1, DATE2DMY(wFecha, 3));
        wFechaApAant := DMY2DATE(1, 1, DATE2DMY(CALCDATE('-1A', wFecha), 3));
        //wFechaApAact:= TODAY ;
        //wFechaApAact := TODAY;
        cProGen.SeleccionHoteles(wFiltHotel, FALSE);
        CurrPage.SubProd.PAGE.ObtenerDatos(wFiltHotel, wFecha, wFechaApAact, wFechaApAant, FALSE, wArchivo, wDirec);
        CurrPage.SubEst.PAGE.ObtenerDatos(wFiltHotel, wFecha, wFechaApAact, wFechaApAant);
        rUsr.GET(USERID);
        rDatIn.RESET;
        IF rDatIn.FIND('-') THEN;
        //wDirec:=rDatIn."Directorio documentos";
        rHoteles.SETRANGE(rHoteles.Hotel, rUsr."Hotel de trabajo");
        IF rHoteles.FINDFIRST THEN
            wDirec := rHoteles."Ruta Exp Fichas Policia";
        /*
        rUser.SETRANGE(rUser."User Name",rUsr.Usuario);
        IF rUser.FIND('-') THEN BEGIN
          wXXX:=COPYSTR(rUser."User Name",1,3);
          IF wXXX='CEN' THEN wDirec:='\\TSCLIENT\c\ESTADISTICOS\'
          ELSE IF (rUsr."Hotel de trabajo"='GRP') OR (rUsr."Hotel de trabajo"='GPY') OR  (rUsr."Hotel de trabajo"='CLT') OR (rUsr."Hotel de trabajo"='DOS') OR (rUsr."Hotel de trabajo"='SCP') OR (rUsr."Hotel de trabajo"='FLP')
            OR (rUsr."Hotel de trabajo"='CID') OR (rUsr."Hotel de trabajo"='MIS') OR (rUsr."Hotel de trabajo"='SUR') OR (rUsr."Hotel de trabajo"='HGB') THEN wZona:='MALLORCA'
          ELSE IF (rUsr."Hotel de trabajo"='LML') OR (rUsr."Hotel de trabajo"='NAE') THEN wZona:='IBIZA'
          ELSE wZona:='LANZAROTE';
          wDirec:=rDatIn."Directorio documentos"+FORMAT(wZona)+'\THB'+FORMAT(rUsr."Hotel de trabajo")+'\Exportaciones\';
          IF rUsr."Hotel de trabajo"='CID' THEN wDirec:=rDatIn."Directorio documentos"+FORMAT(wZona)+'\THBECD'+'\Exportaciones\';
          IF rUsr."Hotel de trabajo"='GPY' THEN wDirec:=rDatIn."Directorio documentos"+FORMAT(wZona)+'\THBGUY'+'\Exportaciones\';
          IF rUsr."Hotel de trabajo"='OCB' THEN wDirec:=rDatIn."Directorio documentos"+'IBIZA\THBBAH'+'\Exportaciones\';
        END;
        */
        wArchivo := 'Estadístico.xls';

    end;

    var
        rHoteles: Record 7000110;
        wZona: Code[30];
        wXXX: Text[3];
        rUser: Record 2000000120;
        rUsr: Record 7000104;
        rDatIn: Record 7000100;
        rGruCen: Record 7000117;
        cProGen: Codeunit 7000105;
        wFiltHotel: Text[250];
        wArchivo: Text[250];
        wDirec: Text[250];
        wFecha: Date;
        wFechaApAact: Date;
        wFechaApAant: Date;
        Text000: Label 'Estadístico.xls';
        wDiasAbiertoAct: Integer;
        wDiasAbiertoAnt: Integer;
}

