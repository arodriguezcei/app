report 50001 "Ocupación y Producción x TTOO"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/report/RDLC/OcupacionyProduccionxTTOO.rdlc';

    dataset
    {
        dataitem("Composicion clientes"; 7000120)
        {
            column(wReg; wReg[wPos])
            {
            }
            column(wEstReg; wEstReg[wPos])
            {
            }
            column(wEstRegTot; wEstRegTot[wPos])
            {
            }
            column(wTipHab; wTipHab[wPos])
            {
            }
            column(wTipHabEst; wTipHabEst[wPos])
            {
            }
            column(wTipHabEstTot; wTipHabEstTot[wPos])
            {
            }
            column(wTipHabOcup; wTipHabOcup[wPos])
            {
            }
            column(wTipHabOcupTot; wTipHabOcupTot[wPos])
            {
            }
            column(wEst; wEst)
            {
            }
            column(wEstTot; wEstTot)
            {
            }
            column(wOcup; wOcup)
            {
            }
            column(wOcupTot; wOcupTot)
            {
            }
            column(wProd; wProd)
            {
            }
            column(wProdTot; wProdTot)
            {
            }
            column(wProm; wProm)
            {
            }
            column(wPromTot; wPromTot)
            {
            }
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                field("Fecha Inicial"; wFechaIni)
                {
                }
                field("Fecha Final"; wFechaFin)
                {
                }
                field("Grupo Centros"; wCentro)
                {
                    TableRelation = "QHT Grupos centros productivos"."Grupo centros";
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnInitReport()
    begin
        rUsr.GET(USERID);
        IF rUsr.FIND('-') THEN wHotel := rUsr."Hotel de trabajo";
    end;

    var
        rGrupos: Record 7000117;
        wHotel: Code[10];
        rUsr: Record 7000104;
        wReg: array[7] of Code[10];
        wEstReg: array[7] of Integer;
        wEstRegTot: array[7] of Integer;
        wTipHab: array[7] of Code[10];
        wTipHabEst: array[7] of Integer;
        wTipHabEstTot: array[7] of Integer;
        wTipHabOcup: array[7] of Integer;
        wTipHabOcupTot: array[7] of Integer;
        wEst: Integer;
        wEstTot: Integer;
        wOcup: Integer;
        wOcupTot: Integer;
        wProd: Decimal;
        wProdTot: Decimal;
        wProm: Integer;
        wPromTot: Integer;
        wPos: Integer;
        wFechaIni: Date;
        wFechaFin: Date;
        wCentro: Code[10];
}

