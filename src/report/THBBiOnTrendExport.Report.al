report 50050 "THB BiOnTrend Export"
{
    // THB-130426-IFF: Report lanzador para exportación BiOnTrend.
    // Llama al Codeunit 50050 con los parámetros del request page.

    Caption = 'BiOnTrend Export';
    ProcessingOnly = true;

    dataset
    {
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(gRuta; gRuta)
                    {
                        Caption = 'Output Path';
                    }
                    field(gModoCompleto; gModoCompleto)
                    {
                        Caption = 'Full Load (from 2019)';
                    }
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

        cExport.ExportarDatos(gModoCompleto, gRuta);
        CurrReport.QUIT;
    end;

    var
        gRuta: Text[250];
        gModoCompleto: Boolean;
        cExport: Codeunit 50050;
}

