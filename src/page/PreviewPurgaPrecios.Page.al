page 50034 "Preview Purga Precios"
{
    Caption = 'Registros huérfanos a purgar';
    Editable = false;
    PageType = List;
    SourceTable = 50034;

    layout
    {
        area(content)
        {
            repeater(Grupo)
            {
                field("Empresa Destino"; Rec."Empresa Destino")
                {
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                }
                field("Item No."; Rec."Item No.")
                {
                }
                field("Tipo Agrupacion"; Rec."Tipo Agrupacion")
                {
                }
                field("Cód. Zona"; Rec."Cód. Zona")
                {
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                }
                field("Direct Unit Cost"; Rec."Direct Unit Cost")
                {
                }
                field("Starting Date"; Rec."Starting Date")
                {
                }
                field("Ending Date"; Rec."Ending Date")
                {
                }
                field("Minimum Quantity"; Rec."Minimum Quantity")
                {
                }
                field("Currency Code"; Rec."Currency Code")
                {
                }
                field("Variant Code"; Rec."Variant Code")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
        }
    }

    var
        Aplicar: Boolean;
}

