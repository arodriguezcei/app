table 50002 "Unidades de Recuentos"
{
    DataPerCompany = false;

    fields
    {
        field(1; Hotel; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(2; Fecha; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(3; Recuento; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(4; Producto; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Almacen"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Unidad Medida 1"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Unidad 1"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Unidad Medida 2"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Unidad 2"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Unidad Medida 3"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Unidad 3"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(12; "Unidad Medida 4"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(13; "Unidad 4"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; Hotel, Fecha, Recuento, Producto, "Almacen")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

