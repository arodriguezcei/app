report 50003 "Ocupantes por Nacionalidad THB"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/report/RDLC/OcupantesporNacionalidadTHB.rdlc';

    dataset
    {
        dataitem("Country/Region"; 9)
        {
            column(Nombre; "Country/Region".Name)
            {
            }
            column(Booking; "Country/Region"."QHTTotal ocupacion")
            {
            }
            column(Estancias_AD; "Country/Region"."QHTTotal estancias AD")
            {
            }
            column(Estancias_JR; "Country/Region"."QHTTotal estancias JR")
            {
            }
            column(Estancias_NI; "Country/Region"."QHTTotal estancias NI")
            {
            }
            column(Estancias_CU; "Country/Region"."QHTTotal estancias CU")
            {
            }
            column("Total_Est_País"; wTotalDia)
            {
            }
            column(Total_Booking; wTotBo)
            {
            }
            column(Total_AD; wTotAD)
            {
            }
            column(Total_JR; wTotJR)
            {
            }
            column(Total_NI; wTotNI)
            {
            }
            column(Total_CU; wTotCU)
            {
            }
            column(Total; wTotal)
            {
            }
            column(Linea_Totales; wLineaTot)
            {
            }

            trigger OnAfterGetRecord()
            begin
                wTotalDia := 0;
                SETRANGE("QHTFiltro fechas", wFecIni, wFecFin);
                CALCFIELDS("QHTTotal ocupacion", "QHTTotal estancias AD", "QHTTotal estancias JR", "Country/Region"."QHTTotal estancias CU", "QHTTotal estancias NI");

                //wTotalDia:="Total estancias AD"+"Total estancias JR"+"Country/Region"."Total estancias CU"+"Total estancias NI";
                //IF wTotalDia=0 THEN CurrReport.SKIP;
                //CALCFIELDS("Total ocupación");
                //wAD:=0;
                //wJR:=0;
                //wNI:=0;
                //wCU:=0;

                wTotBo := "QHTTotal ocupacion" + wTotBo;

                wTotAD := "QHTTotal estancias AD" + wTotAD;
                wTotJR := "QHTTotal estancias JR" + wTotJR;
                wTotNI := "QHTTotal estancias NI" + wTotNI;
                wTotCU := "QHTTotal estancias CU" + wTotCU;

                wTotalDia := "QHTTotal estancias AD" + "QHTTotal estancias JR" + "QHTTotal estancias NI" + "QHTTotal estancias CU";

                //LAS ESTANCIAS SE SACAN DE OCUPANTES, ES MÁS FIABLE QUE LAS RESERVAS
                /*
                rOcup.SETRANGE(rOcup."Fecha entrada",wFecIni,wFecFin);
                rOcup.SETRANGE(rOcup.Nacionalidad,"Country/Region".Code);
                rOcup.SETRANGE(rOcup."Check In",TRUE);
                IF rOcup.FIND('-') THEN BEGIN
                  REPEAT
                  IF rOcup."Tipo persona"=0 THEN BEGIN
                    wTotAD:=1+wTotAD;
                    wAD:=wAD+1
                  END;
                  IF rOcup."Tipo persona"=2 THEN BEGIN
                    wTotNI:=1+wTotNI;
                    wNi:=wNi+1
                  END;
                  IF rOcup."Tipo persona"=3 THEN BEGIN
                    wTotCU:=1+wTotCU;
                    wCU:=wCU+1
                  END;
                  IF rOcup."Tipo persona"=1 THEN BEGIN
                    wTotJR:=1+wTotJR;
                    wJR:=wJR+1
                  END;
                  UNTIL rOcup.NEXT=0
                END;
                */
                //LA OCUPACIÓN SÓLO PUEDE SALIR DE BOOKING

            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                field(Fecha_Inicial; wFecIni)
                {
                }
                field(Fecha_Final; wFecFin)
                {
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

    trigger OnPreReport()
    begin
        wLineaTot := 'Totales período';
        Ventana.OPEN('REVISANDO RESERVA #1#########', rResDia.Reserva);
        rOcup.RESET;
        rOcup.SETFILTER(rOcup."Fecha entrada", '..%1', wFecFin);
        rOcup.SETFILTER(rOcup."Fecha salida", '%1..', wFecIni);
        //rOcup.SETFILTER(rOcup."País residencia",'<>%1','');
        //rOcup.SETRANGE(rOcup.Posición,1);
        rOcup.SETFILTER(rOcup."Pais residencia", '<>%1', '');
        rOcup.SETRANGE(rOcup."Check In", TRUE);
        IF rOcup.FIND('-') THEN BEGIN
            REPEAT
                //rResDia.RESET;
                //rResDia.SETRANGE(rResDia.Fecha,wFecIni,wFecFin);
                rResDia.SETRANGE(rResDia.Hotel, rOcup.Hotel);
                rResDia.SETRANGE(rResDia.Ano, rOcup.Ano);
                rResDia.SETRANGE(rResDia.Reserva, rOcup.Reserva);
                rResDia.SETRANGE(rResDia.Desglose, rOcup.Desglose);
                //rResDia.SETRANGE(rResDia.País,'');
                IF rResDia.FIND('-') THEN BEGIN
                    REPEAT
                        rResDia.Pais := rOcup."Pais residencia";
                        rResDia.MODIFY;
                        Ventana.UPDATE;
                    UNTIL rResDia.NEXT = 0;
                END;
            UNTIL rOcup.NEXT = 0;
        END;
        Ventana.CLOSE;

        COMMIT;
    end;

    var
        wLineaTot: Text[20];
        wAD: Integer;
        wJR: Integer;
        wNI: Integer;
        wCU: Integer;
        wFecIni: Date;
        wFecFin: Date;
        Ventana: Dialog;
        rOcup: Record 7000178;
        rResDia: Record 7000186;
        wTotalDia: Integer;
        wTotBo: Integer;
        wTotAD: Integer;
        wTotJR: Integer;
        wTotNI: Integer;
        wTotCU: Integer;
        wTotal: Integer;
}

