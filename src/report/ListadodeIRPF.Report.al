report 50002 "Listado de IRPF"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/report/RDLC/ListadodeIRPF.rdlc';

    dataset
    {
        dataitem(Vendor; 23)
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.";
            column(rCompany_Name; rCompany.Name)
            {
            }
            column(Text001_FORMAT_wFechaIni_; Text001 + ' : ' + FORMAT(wFechaIni))
            {
            }
            column(Text002_FORMAT_wFechaFin_; Text002 + ' : ' + FORMAT(wFechaFin))
            {
            }
            column(Vendor_Name; Vendor.Name)
            {
            }
            column(Vendor__VAT_Registration_No_; Vendor."VAT Registration No.")
            {
            }
            column(Vendor_City; Vendor.City)
            {
            }
            column(Vendor_Post_Code; Vendor."Post Code")
            {
            }
            column(wFootProv; wFootProv)
            {
            }
            dataitem("G/L Entry"; 17)
            {
                DataItemTableView = SORTING("Entry No.");
                column(Document_No; "G/L Entry"."Document No.")
                {
                }
                column(wIRPF; wIRPF)
                {
                }
                column(wBaseImp; wBaseImp)
                {
                }
                column(wCuotaIRPF; wCuotaIRPF)
                {
                }
                column(wBaseImpProv; wBaseImpProv)
                {
                }
                column(wCuotaIRPFProv; wCuotaIRPFProv)
                {
                }

                trigger OnAfterGetRecord()
                begin

                    wBaseImp := ((Amount * -1) / 15) * 100;
                    wBaseImpProv := wBaseImp + wBaseImpProv;
                    wBaseImpTot := wBaseImpTot + Amount;
                    wCuotaIRPF := 0;

                    rMovConta.RESET;
                    rMovConta.SETRANGE(rMovConta."G/L Account No.", '4751005');
                    rMovConta.SETRANGE(rMovConta."Posting Date", wFechaIni, wFechaFin);
                    rMovConta.SETRANGE(rMovConta."Source Code", 'DIAGEN');
                    rMovConta.SETRANGE(rMovConta."Source No.", '');
                    rMovConta.SETRANGE(rMovConta."Bal. Account No.", Vendor."No.");
                    rMovConta.SETRANGE(rMovConta."Document No.", "G/L Entry"."Document No.");
                    IF rMovConta.FIND('-') THEN BEGIN
                        wCuotaIRPF := Amount * -1;
                        wIRPF := (wCuotaIRPF * 100) / Amount
                    END ELSE BEGIN
                        wCuotaIRPF := Amount * -1;
                        wIRPF := 15;
                        wRevisar := 'X';
                    END;


                    wCuotaIRPFProv := wCuotaIRPFProv + wCuotaIRPF;
                    wCuotaIRPFTot := wCuotaIRPFTot + wCuotaIRPF;
                end;

                trigger OnPreDataItem()
                begin

                    SETRANGE("G/L Account No.", '4751005');
                    SETRANGE("Posting Date", wFechaIni, wFechaFin);
                    SETRANGE("Source Code", 'DIAGEN');
                    SETRANGE("Source No.", Vendor."No.");
                    //SETRANGE("Bal. Account No.",Vendor."No.");
                end;
            }

            trigger OnAfterGetRecord()
            begin

                rMovConta.RESET;
                //rMovConta.SETRANGE(rMovConta."G/L Account No.",'6227001');
                rMovConta.SETRANGE(rMovConta."G/L Account No.", '4751005');
                rMovConta.SETRANGE(rMovConta."Posting Date", wFechaIni, wFechaFin);
                //rMovConta.SETRANGE(rMovConta."Source Code",'COMPRAS');
                rMovConta.SETRANGE(rMovConta."Source Code", 'DIAGEN');
                rMovConta.SETRANGE(rMovConta."Source No.", "No.");
                rMovConta.SETRANGE(rMovConta."Bal. Account No.", "No.");
                IF NOT rMovConta.FIND('-') THEN CurrReport.SKIP;
                //IF NOT rMovConta.FIND('-') THEN ERROR('No se encuentra movimientos');


                // if bMostrar=FALSE THEN CurrReport.SKIP;

                wBaseImpProv := 0;
                wCuotaIRPFProv := 0;
                wImporteProv := 0;
                wFootProv := 'Total Proveedor ' + FORMAT(Vendor.Name);
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                field(wFechaIni; wFechaIni)
                {

                    trigger OnValidate()
                    begin
                        IF wFechaIni >= 20190101D THEN
                            wTipo := 1 ELSE
                            wTipo := 0;
                    end;
                }
                field(wFechaFin; wFechaFin)
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

        rUsr.GET(USERID);
        IF rCompany.FIND('-') THEN;
    end;

    var
        wFootProv: Code[150];
        rHistCab2: Record 122;
        rHistLin3: Record 123;
        wImporte: Decimal;
        wImporteTot: Decimal;
        wRevisar: Code[10];
        rUsr: Record 7000104;
        rCompany: Record 79;
        bMostrar: Boolean;
        wTipo: Option;
        rHistLin: Record 123;
        rHistCab: Record 122;
        wFechaIni: Date;
        wFechaFin: Date;
        rMovConta: Record 17;
        wBaseImpProv: Decimal;
        wCuotaIRPFProv: Decimal;
        wImporteProv: Decimal;
        Text001: Label 'Fecha Inicial';
        Text002: Label 'Fecha Final';
        wIRPF: Decimal;
        wBaseImp: Decimal;
        wCuotaIRPF: Decimal;
        wBaseImpTot: Decimal;
        wCuotaIRPFTot: Decimal;
}

