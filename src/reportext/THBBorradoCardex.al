reportextension 50000 THBBorradoCardex extends "QHT Borrado Cardex"
{
    dataset
    {
        modify(Cardex)
        {
            trigger OnBeforeAfterGetRecord()
            begin
                if Cardex."Excluir Borrado Cardex" then
                    CurrReport.SKIP;
            end;
        }
    }
}
