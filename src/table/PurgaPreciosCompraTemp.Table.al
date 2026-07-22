table 50034 "Purga Precios Compra Temp"
{
    Caption = 'Purga Precios Compra';
    DataPerCompany = false;

    fields
    {
        field(1; "No. Linea"; Integer)
        {
            AutoIncrement = true;
            Caption = 'No. Linea';
        }
        field(2; "Empresa Destino"; Text[30])
        {
            Caption = 'Empresa Destino';
        }
        field(3; "Vendor No."; Code[20])
        {
            Caption = 'Nº Proveedor';
        }
        field(4; "Item No."; Code[20])
        {
            Caption = 'Nº Producto';
        }
        field(5; "Starting Date"; Date)
        {
            Caption = 'Fecha Inicial';
        }
        field(6; "Ending Date"; Date)
        {
            Caption = 'Fecha Final';
        }
        field(7; "Currency Code"; Code[10])
        {
            Caption = 'Cód. Divisa';
        }
        field(8; "Variant Code"; Code[10])
        {
            Caption = 'Cód. Variante';
        }
        field(9; "Cód. Zona"; Code[20])
        {
            Caption = 'Cód. Zona';
        }
        field(10; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Cód. Unidad de Medida';
        }
        field(11; "Minimum Quantity"; Decimal)
        {
            Caption = 'Cantidad Mínima';
        }
        field(12; "Direct Unit Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Coste Unit. Directo';
        }
        field(13; "Tipo Agrupacion"; Text[30])
        {
            Caption = 'Tipo Agrupación';
        }
    }

    keys
    {
        key(Key1; "No. Linea")
        {
            Clustered = true;
        }
        key(Key2; "Empresa Destino", "Vendor No.", "Item No.")
        {
        }
    }

    fieldgroups
    {
    }
}

