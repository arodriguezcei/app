pageextension 60001 THBRecuentosSF extends "QHT Recuentos SF"
{
    layout
    {
        addLast("Control1")
        {
            Field("UnidadMedida1"; wunidadMedida1)
            {
                ApplicationArea = All;
                Caption = 'Unidad Medida 1';
                ToolTip = 'Especifica el código de unidad de medida que se usa al comprar el artículo.';
                TableRelation = "Item Unit of Measure".Code WHERE("item No." = FIELD("Cod. Producto"));
                trigger OnValidate()
                BEGIN

                    rDatosRecuentos.SETRANGE(rDatosRecuentos.Hotel, rec."Cod. Hotel");
                    rDatosRecuentos.SETRANGE(rDatosRecuentos.Fecha, rec."Fecha Recuento");
                    rDatosRecuentos.SETRANGE(rDatosRecuentos.Recuento, rec."Num. Recuento");
                    rDatosRecuentos.SETRANGE(rDatosRecuentos.Almacen, rec."Cod. Almacen");
                    rDatosRecuentos.SETRANGE(rDatosRecuentos.Producto, rec."Cod. Producto");
                    IF rDatosRecuentos.FINDFIRST THEN BEGIN
                        rDatosRecuentos."Unidad Medida 1" := wUnidadMedida1;
                        rDatosRecuentos.MODIFY;
                    END;

                    IF wUnidadMedida1 = '' THEN wUnidad1 := 0;
                    fCalculoRecuento;
                END;
            }
            Field("Unidad1"; wunidad1)
            {
                ApplicationArea = All;
                Caption = 'Unidad Medida 1';
                trigger OnValidate()
                BEGIN

                    rDatosRecuentos.SETRANGE(rDatosRecuentos.Hotel, rec."Cod. Hotel");
                    rDatosRecuentos.SETRANGE(rDatosRecuentos.Fecha, rec."Fecha Recuento");
                    rDatosRecuentos.SETRANGE(rDatosRecuentos.Recuento, rec."Num. Recuento");
                    rDatosRecuentos.SETRANGE(rDatosRecuentos.Almacen, rec."Cod. Almacen");
                    rDatosRecuentos.SETRANGE(rDatosRecuentos.Producto, rec."Cod. Producto");
                    IF rDatosRecuentos.FINDFIRST THEN BEGIN
                        rDatosRecuentos."Unidad 1" := wUnidad1;
                        rDatosRecuentos.MODIFY;
                    END;

                    IF wUnidadMedida1 = '' THEN ERROR('Introduzca primero la Unidad Medida 1 y luego la cantidad.');
                    fCalculoRecuento;
                END;
            }
            Field("UnidadMedida2"; wunidadMedida2)
            {
                ApplicationArea = All;
                Caption = 'Unidad Medida 2';
                TableRelation = "Item Unit of Measure".Code WHERE("item No." = FIELD("Cod. Producto"));
                trigger OnValidate()
                BEGIN

                    rDatosRecuentos.SETRANGE(rDatosRecuentos.Hotel, rec."Cod. Hotel");
                    rDatosRecuentos.SETRANGE(rDatosRecuentos.Fecha, rec."Fecha Recuento");
                    rDatosRecuentos.SETRANGE(rDatosRecuentos.Recuento, rec."Num. Recuento");
                    rDatosRecuentos.SETRANGE(rDatosRecuentos.Almacen, rec."Cod. Almacen");
                    rDatosRecuentos.SETRANGE(rDatosRecuentos.Producto, rec."Cod. Producto");
                    IF rDatosRecuentos.FINDFIRST THEN BEGIN
                        rDatosRecuentos."Unidad Medida 2" := wUnidadMedida2;
                        rDatosRecuentos.MODIFY;
                    END;

                    IF wUnidadMedida2 = '' THEN wUnidad2 := 0;
                    fCalculoRecuento;
                END;
            }
            Field("Unidad2"; wunidad2)
            {
                ApplicationArea = All;
                Caption = 'Unidad Medida 2';
                trigger OnValidate()
                BEGIN

                    rDatosRecuentos.SETRANGE(rDatosRecuentos.Hotel, rec."Cod. Hotel");
                    rDatosRecuentos.SETRANGE(rDatosRecuentos.Fecha, rec."Fecha Recuento");
                    rDatosRecuentos.SETRANGE(rDatosRecuentos.Recuento, rec."Num. Recuento");
                    rDatosRecuentos.SETRANGE(rDatosRecuentos.Almacen, rec."Cod. Almacen");
                    rDatosRecuentos.SETRANGE(rDatosRecuentos.Producto, rec."Cod. Producto");
                    IF rDatosRecuentos.FINDFIRST THEN BEGIN
                        rDatosRecuentos."Unidad 2" := wUnidad2;
                        rDatosRecuentos.MODIFY;
                    END;

                    IF wUnidadMedida2 = '' THEN ERROR('Introduzca primero la Unidad Medida 2 y luego la cantidad.');
                    fCalculoRecuento;
                END;
            }
            Field("UnidadMedida3"; wunidadMedida3)
            {
                ApplicationArea = All;
                Caption = 'Unidad Medida 3';
                TableRelation = "Item Unit of Measure".Code WHERE("item No." = FIELD("Cod. Producto"));
                trigger OnValidate()
                BEGIN

                    rDatosRecuentos.SETRANGE(rDatosRecuentos.Hotel, rec."Cod. Hotel");
                    rDatosRecuentos.SETRANGE(rDatosRecuentos.Fecha, rec."Fecha Recuento");
                    rDatosRecuentos.SETRANGE(rDatosRecuentos.Recuento, rec."Num. Recuento");
                    rDatosRecuentos.SETRANGE(rDatosRecuentos.Almacen, rec."Cod. Almacen");
                    rDatosRecuentos.SETRANGE(rDatosRecuentos.Producto, rec."Cod. Producto");
                    IF rDatosRecuentos.FINDFIRST THEN BEGIN
                        rDatosRecuentos."Unidad Medida 3" := wUnidadMedida3;
                        rDatosRecuentos.MODIFY;
                    END;

                    IF wUnidadMedida3 = '' THEN wUnidad3 := 0;
                    fCalculoRecuento;
                END;
            }
            Field("Unidad3"; wunidad3)
            {
                ApplicationArea = All;
                Caption = 'Unidad Medida 3';
                trigger OnValidate()
                BEGIN

                    rDatosRecuentos.SETRANGE(rDatosRecuentos.Hotel, rec."Cod. Hotel");
                    rDatosRecuentos.SETRANGE(rDatosRecuentos.Fecha, rec."Fecha Recuento");
                    rDatosRecuentos.SETRANGE(rDatosRecuentos.Recuento, rec."Num. Recuento");
                    rDatosRecuentos.SETRANGE(rDatosRecuentos.Almacen, rec."Cod. Almacen");
                    rDatosRecuentos.SETRANGE(rDatosRecuentos.Producto, rec."Cod. Producto");
                    IF rDatosRecuentos.FINDFIRST THEN BEGIN
                        rDatosRecuentos."Unidad 3" := wUnidad3;
                        rDatosRecuentos.MODIFY;
                    END;

                    IF wUnidadMedida3 = '' THEN ERROR('Introduzca primero la Unidad Medida 3 y luego la cantidad.');
                    fCalculoRecuento;
                END;
            }
            Field("UnidadMedida4"; wunidadMedida4)
            {
                ApplicationArea = All;
                Caption = 'Unidad Medida 4';
                TableRelation = "Item Unit of Measure".Code WHERE("item No." = FIELD("Cod. Producto"));
                trigger OnValidate()
                BEGIN

                    rDatosRecuentos.SETRANGE(rDatosRecuentos.Hotel, rec."Cod. Hotel");
                    rDatosRecuentos.SETRANGE(rDatosRecuentos.Fecha, rec."Fecha Recuento");
                    rDatosRecuentos.SETRANGE(rDatosRecuentos.Recuento, rec."Num. Recuento");
                    rDatosRecuentos.SETRANGE(rDatosRecuentos.Almacen, rec."Cod. Almacen");
                    rDatosRecuentos.SETRANGE(rDatosRecuentos.Producto, rec."Cod. Producto");
                    IF rDatosRecuentos.FINDFIRST THEN BEGIN
                        rDatosRecuentos."Unidad Medida 4" := wUnidadMedida4;
                        rDatosRecuentos.MODIFY;
                    END;

                    IF wUnidadMedida4 = '' THEN wUnidad4 := 0;
                    fCalculoRecuento;
                END;
            }
            Field("Unidad4"; wunidad4)
            {
                ApplicationArea = All;
                Caption = 'Unidad Medida 4';
                trigger OnValidate()
                BEGIN

                    rDatosRecuentos.SETRANGE(rDatosRecuentos.Hotel, rec."Cod. Hotel");
                    rDatosRecuentos.SETRANGE(rDatosRecuentos.Fecha, rec."Fecha Recuento");
                    rDatosRecuentos.SETRANGE(rDatosRecuentos.Recuento, rec."Num. Recuento");
                    rDatosRecuentos.SETRANGE(rDatosRecuentos.Almacen, rec."Cod. Almacen");
                    rDatosRecuentos.SETRANGE(rDatosRecuentos.Producto, rec."Cod. Producto");
                    IF rDatosRecuentos.FINDFIRST THEN BEGIN
                        rDatosRecuentos."Unidad 4" := wUnidad4;
                        rDatosRecuentos.MODIFY;
                    END;

                    IF wUnidadMedida4 = '' THEN ERROR('Introduzca primero la Unidad Medida 4 y luego la cantidad.');
                    fCalculoRecuento;
                END;
            }

        }
    }

    LOCAL PROCEDURE fCalculoRecuento();
    BEGIN
        rec.Consumo := rec."Stock (CC)";
        wConsumo1 := 0;
        wConsumo2 := 0;
        wConsumo3 := 0;
        wConsumo4 := 0;

        rItemUnit1.SETRANGE(rItemUnit1."Item No.", rec."Cod. Producto");
        rItemUnit1.SETRANGE(rItemUnit1.Code, wUnidadMedida1);
        IF rItemUnit1.FINDFIRST THEN wConsumo1 := wUnidad1 * rItemUnit1."Qty. per Unit of Measure";

        rItemUnit1.SETRANGE(rItemUnit1."Item No.", rec."Cod. Producto");
        rItemUnit1.SETRANGE(rItemUnit1.Code, wUnidadMedida2);
        IF rItemUnit1.FINDFIRST THEN wConsumo2 := wUnidad2 * rItemUnit1."Qty. per Unit of Measure";

        rItemUnit1.SETRANGE(rItemUnit1."Item No.", rec."Cod. Producto");
        rItemUnit1.SETRANGE(rItemUnit1.Code, wUnidadMedida3);
        IF rItemUnit1.FINDFIRST THEN wConsumo3 := wUnidad3 * rItemUnit1."Qty. per Unit of Measure";

        rItemUnit1.SETRANGE(rItemUnit1."Item No.", rec."Cod. Producto");
        rItemUnit1.SETRANGE(rItemUnit1.Code, wUnidadMedida4);
        IF rItemUnit1.FINDFIRST THEN wConsumo4 := wUnidad4 * rItemUnit1."Qty. per Unit of Measure";

        rec.Recuento := wConsumo1 + wConsumo2 + wConsumo3 + wConsumo4;
        rec.Consumo := rec.Consumo - rec.Recuento;
        IF rec.Consumo < 0 THEN MESSAGE('­ATENCIÓN!, Está introduciendo un consumo negativo, revise si las cantidades e unidades son correctas antes de continuar.');
    END;

    var
        wConsumo1: Decimal;
        wConsumo2: Decimal;
        wConsumo3: Decimal;
        wConsumo4: Decimal;
        rUnidades: Record 50002;
        wUnidadMedida3: Code[10];
        wUnidadMedida4: Code[10];
        wUnidad3: Decimal;
        wUnidad4: Decimal;
        rItemUnit1: Record 5404;
        rItemUnit2: Record 5404;
        wUnidadMedida1: Code[10];
        wUnidad2: Decimal;
        wUnidad1: Decimal;
        wUnidadMedida2: Code[10];
        rMovProd: Record 32;
        rDatosRecuentos: Record 50002;
}
