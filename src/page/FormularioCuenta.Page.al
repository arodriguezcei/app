page 50025 "THB Formulario Cuenta"
{

    layout
    {
        area(content)
        {
            field("Núm. Cta."; wNo)
            {
                TableRelation = "G/L Account"."No.";
            }
        }
    }

    actions
    {
    }

    var
        wNo: Code[20];

    procedure GetParams(var wNovar: Code[20])
    begin
        wNovar := wNo;
        //wFechaFinvar := wFechaFin;
    end;
}

