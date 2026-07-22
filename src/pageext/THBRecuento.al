pageextension 60000 THBRecuento extends "QHT Recuento"
{

    actions
    {
        addafter("Copiar Stock Inicial")
        {
            action("ResetRecuento")
            {
                ApplicationArea = All;
                Caption = 'Reset Recuento';
                ToolTip = 'Reset Recuento';

                trigger OnAction()
                var
                    rRecDetAnt: Record 7000534;
                    rRecCabAnt: Record 7000533;
                    rDetRec: Record 7000534;
                begin
                    IF CONFIRM('Con esta pulsacion toda la columna recuento volvera a ser 0, ¨está seguro que desea continuar?') THEN BEGIN
                        rRecDetAnt.RESET;
                        rRecCabAnt.RESET;
                        rRecCabAnt.SETRANGE(rRecCabAnt."Cod. Hotel", Rec."Cod. Hotel");
                        rRecCabAnt.SETRANGE(rRecCabAnt."Cod. Almacen", Rec."Cod. Almacen");
                        rRecCabAnt.SETRANGE(rRecCabAnt.Estado, 1); // Estado 1=Cerrado
                        IF rRecCabAnt.FIND('+') THEN BEGIN
                            rDetRec.RESET;
                            rDetRec.SETRANGE(rDetRec."Cod. Hotel", Rec."Cod. Hotel");
                            rDetRec.SETRANGE(rDetRec."Num. Recuento", Rec."Num. Recuento");
                            IF rDetRec.FIND('-') THEN BEGIN
                                REPEAT
                                    rDetRec.CALCFIELDS(rDetRec."Stock (CC)");
                                    rDetRec.Recuento := 0;
                                    rDetRec.Consumo := rDetRec."Stock (CC)";
                                    rDetRec.MODIFY(TRUE)
                                UNTIL rDetRec.NEXT = 0;
                            END;
                        END;
                        rDatosRecuentos.SETRANGE(rDatosRecuentos.Hotel, Rec."Cod. Hotel");
                        rDatosRecuentos.SETRANGE(rDatosRecuentos.Fecha, Rec."Fecha Recuento");
                        rDatosRecuentos.SETRANGE(rDatosRecuentos.Recuento, Rec."Num. Recuento");
                        rDatosRecuentos.SETRANGE(rDatosRecuentos.Almacen, Rec."Cod. Almacen");
                        IF rDatosRecuentos.FIND('-') THEN BEGIN
                            REPEAT
                                rDatosRecuentos."Unidad Medida 1" := '';
                                rDatosRecuentos."Unidad Medida 2" := '';
                                rDatosRecuentos."Unidad Medida 3" := '';
                                rDatosRecuentos."Unidad Medida 4" := '';
                                rDatosRecuentos."Unidad 1" := 0;
                                rDatosRecuentos."Unidad 2" := 0;
                                rDatosRecuentos."Unidad 3" := 0;
                                rDatosRecuentos."Unidad 4" := 0;
                                IF rDatosRecuentos.MODIFY THEN;
                            UNTIL rDatosRecuentos.NEXT = 0
                        END;
                    END;
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    var

    begin
        //CREACIàN DE LINEAS TEMPORALES DE RECUENTOS

        rDatosRecuentos.SETRANGE(rDatosRecuentos.Hotel, Rec."Cod. Hotel");
        rDatosRecuentos.SETRANGE(rDatosRecuentos.Fecha, Rec."Fecha Recuento");
        rDatosRecuentos.SETRANGE(rDatosRecuentos.Recuento, Rec."Num. Recuento");
        rDatosRecuentos.SETRANGE(rDatosRecuentos.Almacen, Rec."Cod. Almacen");
        IF NOT rDatosRecuentos.FIND('-') THEN BEGIN
            rRecuentoDet.SETRANGE(rRecuentoDet."Cod. Hotel", Rec."Cod. Hotel");
            rRecuentoDet.SETRANGE(rRecuentoDet."Fecha Recuento", Rec."Fecha Recuento");
            rRecuentoDet.SETRANGE(rRecuentoDet."Num. Recuento", Rec."Num. Recuento");
            rRecuentoDet.SETRANGE(rRecuentoDet."Cod. Almacen", Rec."Cod. Almacen");
            IF rRecuentoDet.FIND('-') THEN BEGIN
                REPEAT
                    rDatosRecuentos.INIT;
                    rDatosRecuentos.Hotel := Rec."Cod. Hotel";
                    rDatosRecuentos.Fecha := Rec."Fecha Recuento";
                    rDatosRecuentos.Recuento := Rec."Num. Recuento";
                    rDatosRecuentos.Almacen := Rec."Cod. Almacen";
                    rDatosRecuentos.Producto := rRecuentoDet."Cod. Producto";
                    IF rDatosRecuentos.INSERT THEN;
                UNTIL rRecuentoDet.NEXT = 0
            END;
        END;
    end;


    var
        rRecuentoDet: Record 7000534;
        rDatosRecuentos: Record 50002;

}
