table 50001 "Controles THB"
{
    DataPerCompany = false;

    fields
    {
        field(1; "ID Tabla"; Code[12])
        {
            DataClassification = ToBeClassified;
            Description = 'Id de la tabla';
        }
        field(2; Control; Code[20])
        {
            DataClassification = ToBeClassified;
            Description = 'Tipo de control';
        }
        field(3; Campo; Text[30])
        {
            DataClassification = ToBeClassified;
            Description = 'Campo de la tabla controlado';
        }
        field(4; "Valor de campo"; Code[30])
        {
            DataClassification = ToBeClassified;
            Description = 'Valor del campo controlado';
        }
        field(5; "Integer"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(6; Integer2; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Code"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(8; Code2; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(9; Texto; Text[200])
        {
            DataClassification = ToBeClassified;
        }
        field(10; Texto2; Text[200])
        {
            DataClassification = ToBeClassified;
        }
        field(11; Boleana; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(12; Boleana2; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(13; Filtro1; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(14; Filtro2; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(15; Filtro3; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(16; "Campo Filtro 1"; Code[15])
        {
            DataClassification = ToBeClassified;
        }
        field(17; "Campo Filtro 2"; Code[15])
        {
            DataClassification = ToBeClassified;
        }
        field(18; "Campo Filtro 3"; Code[15])
        {
            DataClassification = ToBeClassified;
        }
        field(19; Inactivo; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(20; SourceCounter; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(21; Date1; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(22; Date2; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(23; Decimal; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(24; "Decimal 2"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(25; "Decimal 3"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(26; Integer3; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(27; Code3; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(28; Texto3; Text[200])
        {
            DataClassification = ToBeClassified;
        }
        field(29; Boleana3; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "ID Tabla", Control, Campo)
        {
            Clustered = true;
        }
        key(Key2; "ID Tabla", Campo, Control)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        SourceCounter := ActualizaSource;
    end;

    trigger OnInsert()
    begin
        SourceCounter := ActualizaSource;
    end;

    trigger OnModify()
    begin
        SourceCounter := ActualizaSource;
    end;

    var
        rControles: Record 50001;

    local procedure ActualizaSource() wValor: Integer
    begin
        rControles.RESET;
        rControles.SETCURRENTKEY(rControles.SourceCounter);
        IF rControles.FIND('+') THEN
            wValor := rControles.SourceCounter + 1
        ELSE
            wValor := 1;
    end;
}

