report 50006 "Hist. Ocupantes Repetidores"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/report/RDLC/HistOcupantesRepetidores.rdlc';

    dataset
    {
        dataitem(Ocupantes; 7000178)
        {
            DataItemTableView = SORTING(Hotel, Ano, Reserva, Desglose, Posicion);
            column(wFecha; wFecha)
            {
            }
            column(wRango; wRango)
            {
            }
            column(wVisitas; wVisitas)
            {
            }
            column(USERID; USERID)
            {
            }
            column(CompanyName; COMPANYNAME)
            {
            }
            column(Ocupantes_Hotel; Ocupantes.Hotel)
            {
            }
            column(wReserva; wReserva)
            {
            }
            column(Fecha_entrada; "Fecha entrada")
            {
            }
            column(Fecha_salida; "Fecha salida")
            {
            }
            column(Tipo_persona; "Tipo persona")
            {
            }
            column(Pais_residencia; "Pais residencia")
            {
            }
            column(Documento; Documento)
            {
            }
            column(Nombre; Nombre)
            {
            }
            column(Apellido_1; "Apellido 1")
            {
            }
            column(TTOO; TTOO)
            {
            }
            column(Agencia; Agencia)
            {
            }
            column(rCardex_Visitas; rCardex.Visitas)
            {
            }
            column(wTotAD; wTotAD)
            {
            }
            column(wTotJR; wTotJR)
            {
            }
            column(wTotCU; wTotCU)
            {
            }
            column(wTotal; wTotal)
            {
            }

            trigger OnAfterGetRecord()
            begin


                rCardex.SETRANGE(rCardex."Pais residencia", Ocupantes."Pais residencia");
                rCardex.SETRANGE(rCardex.Documento, Ocupantes.Documento);
                IF rCardex.FIND('-') THEN BEGIN
                    rCardex.CALCFIELDS(rCardex.Visitas);
                    IF rCardex.Visitas >= wMin + 1 THEN BEGIN
                        //  CurrReport.SHOWOUTPUT(TRUE);
                        wTotal := wTotal + 1;
                        IF "Tipo persona" = 0 THEN wTotAD := wTotAD + 1;
                        IF "Tipo persona" = 1 THEN wTotJR := wTotJR + 1;
                        IF "Tipo persona" = 2 THEN wTotCU := wTotCU + 1;
                        IF bDetalle = FALSE THEN CurrReport.SKIP;
                    END ELSE
                        CurrReport.SKIP;
                END;
                wReserva := FORMAT(Ano) + '/' + FORMAT(Reserva) + '-' + FORMAT(Desglose);
            end;

            trigger OnPreDataItem()
            begin
                wVisitas := 'Mínimo de visitas : ' + FORMAT(wMin);
                wRango := FORMAT(wFechaIni) + ' al ' + FORMAT(wFechaFin);

                //LastFieldNo := FIELDNO(Hotel);
                SETRANGE("Check In", TRUE);
                //SETRANGE(Repetidores, TRUE);
                SETRANGE("Fecha entrada", wFechaIni, wFechaFin);
                //SETFILTER("Fecha salida",'>=%1', wFechaIni);
                //SETFILTER("Fecha entrada",'<=%1',wFechaFin);
                wMin := wMin - 1;
                IF bEmails THEN SETFILTER("E-mail", '<>%1', '');
            end;
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
                    Caption = 'Fecha Inicial';
                }
                field("Fecha Final"; wFechaFin)
                {
                    Caption = 'Fecha Final';
                }
                field("Repeticiones Mínimas"; wMin)
                {
                    Caption = 'Repeticiones Mínimas';
                }
                field("Ver Detalle"; bDetalle)
                {
                    Caption = 'Ver Detalle';
                }
                field("Sólo con e-mails"; bEmails)
                {
                    Caption = 'Sólo con e-mails';
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
        bDetalle := TRUE;
    end;

    var
        wVisitas: Text;
        wHoy: Text;
        wMin: Integer;
        bDetalle: Boolean;
        bEmails: Boolean;
        wFechaIni: Date;
        wFechaFin: Date;
        wFecha: Text[30];
        wRango: Text[30];
        wReserva: Code[20];
        rCardex: Record 7000179;
        wTotAD: Integer;
        wTotJR: Integer;
        wTotCU: Integer;
        wTotal: Integer;
}

