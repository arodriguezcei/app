table 50037 "Booking THB"
{
    //  CAT 30/10/08 HTT-146: Modificacion del Calcformula del campo Ocupacion, inclusion del filtro Rango Tarifa
    // 
    // 001 RRT 26.05.09, SGI-130: Creacion de la tabla "Ocupantes - Desglose diario". El campo.
    //     "Regimen factura" pasa a depender del ocupante pudiendo cambiar a diario, en lugar de la
    //     reserva.
    //     Para calcular los campos AD,JR,NI,CU,"AD Reservado", "NI Reservado", "JR Reservado",
    //     "CU Reservado", "AD Bkg. x Hab.", "NI Bkg. x Hab.", "JR Bkg. x Hab.",
    //     "CU Bkg. x Hab." se usara dicha tabla en lugar de "Reservas diarias".
    //     Campos como 3AD, 3AD gratis, etc. seguiran igual ya que su valor depende de toda la reserva.
    // 
    // 002 AHA 06/05/10 MIG-NH6.0, Para calcular los campos "AD Reservado", "NI Reservado", "JR Reservado" y "CU Reservado" se usara la
    //     tabla "Reservas diarias", ya que para las reservas de grupo no desglosadas no se generaban los datos en la tabla
    //     "Ocupantes - Desglose diario".
    // EAJ - 050710 : Se modifica la condicion de filtro en los campos FlowField "AD", "JR", "NI", "CU", "AD Bkg. x Hab.",
    //                "JR Bkg. x Hab.", "NI Bkg. x Hab.", "CU Bkg. x Hab.", incorporando la condicion para filtrar por el campo
    //                de tipo flowfilter "Rango Nacionalidad", de esta manera se corrige el error que se produce actualmente al
    //                listar el informe de Ocupacion x nacionalidad desde el apartado de front office > recepcion.
    // 
    // 999 05-07-10 LIS: E13, sustutuir llamadas a tablas Duplicadas
    // 
    // 100 AHA 20/12/10 E14: Se cambia el texto "Tarifa" por "Oferta" en el nombre de campos y text constants.
    // 101 AHA 21/12/10 E14: Se anade l campo "Ocupacion contratos". Se aplican los mismos filtros que el campo Ocupacion y ademas se
    //                       filtraran las reservas diarias con tipo Precio = Contratos.
    // INC-54714 CPJ - 08/04/11 : Se modifica la condicion de filtro en los campos FlowField "AD", "JR", "NI", "CU", "AD Bkg. x Hab.",
    //                "JR Bkg. x Hab.", "NI Bkg. x Hab.", "CU Bkg. x Hab.", incorporando la condicion para filtrar por el campo
    //                de tipo flowfilter "Rango Trato", de esta manera se corrige el error que se produce actualmente en
    //                el informe de Balance de Produccion al mostrar los pax por trato.
    // 
    // 1501 04-06-15 LIS: QUO-OC-14012, anadir nuevo campo Ocupacion Tarifa
    // 1502 08-06-15 LIS: QUO-OC-14012, anadir nuevos campos Cupo contrato y cupo tarifa
    // 1601 09-01-17 ARM: RPD-OC-16004B, Nuevo campo Rango tentativas y anadir el filtro en campos AD, NI y JR y y en AD, NI y JU Reservado
    // 1801 31-01-18 LIS: Anadir filtro cliente en los campos AD,NI,JR,CU
    // 
    // 1601 16-11-16 MCF: barcelo RSV72 - Se anade el nuevo estado Tentativa, en el flowfilter Rango Estado.
    //                                  - Se modifica los campos Ocupacion tentativas y Ocupacion comercial tentativas con el filtro Estado reserva: Tentativa
    // 1602 16-12-16 APC: barcelo INF89-FPC170 - Anadidos campos "Ocupantes fecha entrada", "Ocupantes fecha salida"
    // 1801 31-01-18 LIS: Anadir filtro cliente en los campos AD,NI,JR,CU
    // 1802 12/04/18 XAP : FMX P37 Se cambia la longitud del campo "Oferta de contrato" de 10 a 20
    // 2000 12-06-20 LIS: BUG15450, modificamos filtro para ocupancion tentativa
    // 2001 18-08-20 LIS: BUG15870, eliminar campo Rango tentativa, (ahora se utiliza un estado) modificar campos AD, NI, JR, AD Reservado, NI Reservado y JR Reservado.
    // 2101 10/06/21 CHP: TEQ-OC-20011, se anade el rango de DayUse.

    Caption = 'Booking';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Hotel; Code[10])
        {
            Caption = 'Hotel';
            TableRelation = "QHT Hoteles".Hotel;
            DataClassification = CustomerContent;
        }
        field(2; "Rango Fecha"; Date)
        {
            Caption = 'Range Date';
            FieldClass = FlowFilter;
        }
        field(3; "Rango Tipo Habitacion"; Code[10])
        {
            Caption = 'Room Type Range';
            FieldClass = FlowFilter;
            TableRelation = "QHT Tipos de habitacion"."Tipo habitacion";
        }
        field(4; "Rango TTOO"; Code[30])
        {
            Caption = 'TTOO Range';
            FieldClass = FlowFilter;
            TableRelation = "QHT TTOOs/Agencias"."Codigo";
        }
        field(5; "Rango Agencia"; Code[30])
        {
            Caption = 'Agency Range';
            FieldClass = FlowFilter;
            TableRelation = "QHT TTOOs/Agencias"."Codigo";
        }
        field(6; "Rango Cliente"; Code[20])
        {
            Caption = 'Client Range';
            FieldClass = FlowFilter;
            TableRelation = Customer."No.";
        }
        field(7; "Rango Regimen fact."; Code[10])
        {
            Caption = 'Invoice Board Range';
            FieldClass = FlowFilter;
            TableRelation = "QHT Regimenes"."Regimen";
        }
        field(8; "Rango Nacionalidad"; Code[10])
        {
            Caption = 'Nationality Range';
            FieldClass = FlowFilter;
            TableRelation = "Country/Region".Code;
        }
        field(9; "Rango Estado"; Option)
        {
            Caption = 'Status Range';
            Description = 'Reserva,Anulada,Entrada,Salida,No Show,Tentativa';
            FieldClass = FlowFilter;
            OptionCaption = 'Booking,Cancelled,Check In,Check Out,No Show,Tentativa';
            OptionMembers = Reserva,Anulada,Entrada,Salida,"No Show",Tentativa;
        }
        field(10; "Rango Tipo Habitacion fact."; Code[10])
        {
            Caption = 'Invoice Room Type Range';
            FieldClass = FlowFilter;
            TableRelation = "QHT Tipos de habitacion"."Tipo habitacion";
        }
        field(11; Cupo; Decimal)
        {
            CalcFormula = Sum("QHT Cupos diarios".Cupo WHERE(Hotel = FIELD(Hotel),
                                                              Fecha = FIELD("Rango Fecha"),
                                                              "Tipo habitacion" = FIELD("Rango Tipo Hab. Gral."),
                                                              TTOO = FIELD("Rango TTOO"),
                                                              Agencia = FIELD("Rango Agencia"),
                                                              Cliente = FIELD("Rango Cliente")));
            Caption = 'Allotment';
            FieldClass = FlowField;
        }
        field(12; Ocupacion; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = Sum("QHT Reservas diarias"."Ocupacion" WHERE(Hotel = FIELD(Hotel),
                                                                        Fecha = FIELD("Rango Fecha"),
                                                                        "Estado reserva" = FIELD("Rango Estado"),
                                                                        TTOO = FIELD("Rango TTOO"),
                                                                        Agencia = FIELD("Rango Agencia"),
                                                                        Cliente = FIELD("Rango Cliente"),
                                                                        "Tipo hab. uso" = FIELD("Rango Tipo Habitacion"),
                                                                        "Tipo hab. fra." = FIELD("Rango Tipo Habitacion fact."),
                                                                        "Regimen factura" = FIELD("Rango Regimen fact."),
                                                                        Bloque = FIELD("Rango Bloques"),
                                                                        Planta = FIELD("Rango Plantas"),
                                                                        Rango = FIELD("Rango Rangos Hab."),
                                                                        "Pais" = FIELD("Rango Nacionalidad"),
                                                                        Trato = FIELD("Rango Trato"),
                                                                        "Canal/Origen" = FIELD("Rango Canal/Origen"),
                                                                        Segmento = FIELD("Rango Segmento"),
                                                                        Oferta = FIELD("Rango Oferta"),
                                                                        "Day Use" = FIELD("Rango DayUse")));
            Caption = 'Occupation';
        }
        field(13; "Ocupacion Garantia"; Decimal)
        {
            CalcFormula = Sum("QHT Reservas diarias"."Ocupacion" WHERE(Hotel = FIELD(Hotel),
                                                                        Fecha = FIELD("Rango Fecha"),
                                                                        "Estado reserva" = FIELD("Rango Estado"),
                                                                        TTOO = FIELD("Rango TTOO"),
                                                                        Agencia = FIELD("Rango Agencia"),
                                                                        Cliente = FIELD("Rango Cliente"),
                                                                        "Tipo hab. uso" = FIELD("Rango Tipo Habitacion"),
                                                                        "Tipo hab. fra." = FIELD("Rango Tipo Habitacion fact."),
                                                                        "Regimen factura" = FIELD("Rango Regimen fact."),
                                                                        "Pais" = FIELD("Rango Nacionalidad"),
                                                                        "Contrato garantia" = CONST(true)));
            Caption = 'Guarantee Occupation';
            FieldClass = FlowField;
        }
        field(14; "Ocupacion No Garantia"; Decimal)
        {
            CalcFormula = Sum("QHT Reservas diarias"."Ocupacion" WHERE(Hotel = FIELD(Hotel),
                                                                        Fecha = FIELD("Rango Fecha"),
                                                                        "Estado reserva" = FIELD("Rango Estado"),
                                                                        TTOO = FIELD("Rango TTOO"),
                                                                        Agencia = FIELD("Rango Agencia"),
                                                                        Cliente = FIELD("Rango Cliente"),
                                                                        "Tipo hab. uso" = FIELD("Rango Tipo Habitacion"),
                                                                        "Tipo hab. fra." = FIELD("Rango Tipo Habitacion fact."),
                                                                        "Regimen factura" = FIELD("Rango Regimen fact."),
                                                                        "Pais" = FIELD("Rango Nacionalidad"),
                                                                        "Contrato garantia" = CONST(false)));
            Caption = 'No Guarantee occupation ';
            FieldClass = FlowField;
        }
        field(15; "Cupo Garantizado"; Decimal)
        {
            CalcFormula = Sum("QHT Garantias diarias"."Cupo garantizado" WHERE(Hotel = FIELD(Hotel),
                                                                                Fecha = FIELD("Rango Fecha"),
                                                                                "Cod. tipo habitacion" = FIELD("Rango Tipo Hab. Gral."),
                                                                                "Cod. cliente" = FIELD("Rango Cliente"),
                                                                                "Cod. TTOO" = FIELD("Rango TTOO"),
                                                                                "Cod. agencia" = FIELD("Rango Agencia")));
            Caption = 'Guaranteed allotment';
            FieldClass = FlowField;
        }
        field(16; AD; Decimal)
        {
            CalcFormula = Sum("QHT Ocupantes-Desglose diario"."Ocupacion" WHERE(Hotel = FIELD(Hotel),
                                                                                 Fecha = FIELD("Rango Fecha"),
                                                                                 "Tipo persona" = CONST(AD),
                                                                                 TTOO = FIELD("Rango TTOO"),
                                                                                 Agencia = FIELD("Rango Agencia"),
                                                                                 "Tipo habitacion uso" = FIELD("Rango Tipo Habitacion"),
                                                                                 "Tipo habitacion factura" = FIELD("Rango Tipo Habitacion fact."),
                                                                                 "Regimen factura" = FIELD("Rango Regimen fact."),
                                                                                 "Regimen uso" = FIELD("Rango Regimen Uso"),
                                                                                 "Estado reserva" = FIELD("Rango Estado"),
                                                                                 "Canal/Origen" = FIELD("Rango Canal/Origen"),
                                                                                 Segmento = FIELD("Rango Segmento"),
                                                                                 Trato = FIELD("Rango Trato"),
                                                                                 Nacionalidad = FIELD("Rango Nacionalidad"),
                                                                                 Cliente = FIELD("Rango Cliente"),
                                                                                                                  Trato = FILTER(<> Invitado)));
            Caption = 'AD';
            Description = '001 Incluye Reg. Uso';
            FieldClass = FlowField;
        }
        field(17; JR; Decimal)
        {
            CalcFormula = Sum("QHT Ocupantes-Desglose diario"."Ocupacion" WHERE(Hotel = FIELD(Hotel),
                                                                                 Fecha = FIELD("Rango Fecha"),
                                                                                 "Tipo persona" = CONST(JR),
                                                                                 TTOO = FIELD("Rango TTOO"),
                                                                                 Agencia = FIELD("Rango Agencia"),
                                                                                 "Tipo habitacion uso" = FIELD("Rango Tipo Habitacion"),
                                                                                 "Tipo habitacion factura" = FIELD("Rango Tipo Habitacion fact."),
                                                                                 "Regimen factura" = FIELD("Rango Regimen fact."),
                                                                                 "Regimen uso" = FIELD("Rango Regimen Uso"),
                                                                                 "Estado reserva" = FIELD("Rango Estado"),
                                                                                 "Canal/Origen" = FIELD("Rango Canal/Origen"),
                                                                                 Segmento = FIELD("Rango Segmento"),
                                                                                 Trato = FIELD("Rango Trato"),
                                                                                 Nacionalidad = FIELD("Rango Nacionalidad"),
                                                                                 Cliente = FIELD("Rango Cliente"),
                                                                                                                  Trato = FILTER(<> Invitado)));
            Caption = 'JR';
            Description = '001 Incluye Reg. Uso';
            FieldClass = FlowField;
        }
        field(18; NI; Decimal)
        {
            CalcFormula = Sum("QHT Ocupantes-Desglose diario"."Ocupacion" WHERE(Hotel = FIELD(Hotel),
                                                                                 Fecha = FIELD("Rango Fecha"),
                                                                                 "Tipo persona" = CONST(NI),
                                                                                 TTOO = FIELD("Rango TTOO"),
                                                                                 Agencia = FIELD("Rango Agencia"),
                                                                                 "Tipo habitacion uso" = FIELD("Rango Tipo Habitacion"),
                                                                                 "Tipo habitacion factura" = FIELD("Rango Tipo Habitacion fact."),
                                                                                 "Regimen factura" = FIELD("Rango Regimen fact."),
                                                                                 "Regimen uso" = FIELD("Rango Regimen Uso"),
                                                                                 "Estado reserva" = FIELD("Rango Estado"),
                                                                                 "Canal/Origen" = FIELD("Rango Canal/Origen"),
                                                                                 Segmento = FIELD("Rango Segmento"),
                                                                                 Trato = FIELD("Rango Trato"),
                                                                                 Nacionalidad = FIELD("Rango Nacionalidad"),
                                                                                 Cliente = FIELD("Rango Cliente"),
                                                                                                                  Trato = FILTER(<> Invitado)));
            Caption = 'CH';
            Description = '001 Incluye Reg. Uso';
            FieldClass = FlowField;
        }
        field(19; CU; Decimal)
        {
            CalcFormula = Sum("QHT Ocupantes-Desglose diario"."Ocupacion" WHERE(Hotel = FIELD(Hotel),
                                                                                 Fecha = FIELD("Rango Fecha"),
                                                                                 "Tipo persona" = CONST(CU),
                                                                                 TTOO = FIELD("Rango TTOO"),
                                                                                 Agencia = FIELD("Rango Agencia"),
                                                                                 "Tipo habitacion uso" = FIELD("Rango Tipo Habitacion"),
                                                                                 "Tipo habitacion factura" = FIELD("Rango Tipo Habitacion fact."),
                                                                                 "Regimen factura" = FIELD("Rango Regimen fact."),
                                                                                 "Regimen uso" = FIELD("Rango Regimen Uso"),
                                                                                 "Estado reserva" = FIELD("Rango Estado"),
                                                                                 "Canal/Origen" = FIELD("Rango Canal/Origen"),
                                                                                 Segmento = FIELD("Rango Segmento"),
                                                                                 Trato = FIELD("Rango Trato"),
                                                                                 Nacionalidad = FIELD("Rango Nacionalidad"),
                                                                                 Cliente = FIELD("Rango Cliente"),
                                                                                                                  Trato = FILTER(<> Invitado)));
            Caption = 'BA';
            Description = '001';
            FieldClass = FlowField;
        }
        field(20; "Rango Regimen Uso"; Code[10])
        {
            Caption = 'Use Board Range';
            FieldClass = FlowFilter;
            TableRelation = "QHT Regimenes"."Regimen";
        }
        field(31; "Rango Bloques"; Code[10])
        {
            Caption = 'Blocks Range';
            FieldClass = FlowFilter;
            TableRelation = "QHT Agrupacion habitaciones"."Agrupacion" WHERE(Hotel = FIELD(Hotel),
                                                                          "Tipo Agrupacion" = CONST(Bloque));
        }
        field(32; "Rango Plantas"; Code[10])
        {
            Caption = 'Floors Range';
            FieldClass = FlowFilter;
            TableRelation = "QHT Agrupacion habitaciones"."Agrupacion" WHERE(Hotel = FIELD(Hotel),
                                                                          "Tipo Agrupacion" = CONST(Planta));
        }
        field(33; "Rango Rangos Hab."; Code[10])
        {
            Caption = 'Room Ranges Range';
            FieldClass = FlowFilter;
            TableRelation = "QHT Agrupacion habitaciones"."Agrupacion" WHERE(Hotel = FIELD(Hotel),
                                                                          "Tipo Agrupacion" = CONST(Rango));
        }
        field(34; "Rango Real"; Boolean)
        {
            Caption = 'Real range';
            FieldClass = FlowFilter;
        }
        field(40; "Rango Usuario"; Code[50])
        {
            Caption = 'User Range';
            FieldClass = FlowFilter;
        }
        field(41; "Rango Tipo Hab. Gral."; Code[10])
        {
            Caption = 'General Room Type Range';
            FieldClass = FlowFilter;
        }
        field(42; "Ocupacion Bkg. x Hab."; Decimal)
        {
            CalcFormula = Sum("QHT Reservas diarias"."Ocupacion" WHERE(Hotel = FIELD(Hotel),
                                                                        Fecha = FIELD("Rango Fecha"),
                                                                        TTOO = FIELD("Rango TTOO"),
                                                                        Agencia = FIELD("Rango Agencia"),
                                                                        "Tipo hab. uso" = FIELD("Rango Tipo Habitacion"),
                                                                        "Regimen factura" = FIELD("Rango Regimen fact."),
                                                                        Bloque = FIELD("Rango Bloques"),
                                                                        Planta = FIELD("Rango Plantas"),
                                                                        Rango = FIELD("Rango Rangos Hab.")));
            Caption = 'Bkg. x Room Occupation';
            FieldClass = FlowField;
        }
        field(43; "AD Bkg. x Hab."; Decimal)
        {
            CalcFormula = Sum("QHT Ocupantes-Desglose diario"."Ocupacion" WHERE(Hotel = FIELD(Hotel),
                                                                                 Fecha = FIELD("Rango Fecha"),
                                                                                 "Tipo persona" = CONST(AD),
                                                                                 TTOO = FIELD("Rango TTOO"),
                                                                                 Agencia = FIELD("Rango Agencia"),
                                                                                 "Tipo habitacion uso" = FIELD("Rango Tipo Habitacion"),
                                                                                 "Regimen factura" = FIELD("Rango Regimen fact."),
                                                                                 Bloque = FIELD("Rango Bloques"),
                                                                                 Planta = FIELD("Rango Plantas"),
                                                                                 Rango = FIELD("Rango Rangos Hab."),
                                                                                 Trato = FIELD("Rango Trato"),
                                                                                 Nacionalidad = FIELD("Rango Nacionalidad")));
            Caption = 'AD Bkg. x Room';
            Description = '001';
            FieldClass = FlowField;
        }
        field(44; "JR Bkg. x Hab."; Decimal)
        {
            CalcFormula = Sum("QHT Ocupantes-Desglose diario"."Ocupacion" WHERE(Hotel = FIELD(Hotel),
                                                                                 Fecha = FIELD("Rango Fecha"),
                                                                                 "Tipo persona" = CONST(JR),
                                                                                 TTOO = FIELD("Rango TTOO"),
                                                                                 Agencia = FIELD("Rango Agencia"),
                                                                                 "Tipo habitacion uso" = FIELD("Rango Tipo Habitacion"),
                                                                                 "Regimen factura" = FIELD("Rango Regimen fact."),
                                                                                 Bloque = FIELD("Rango Bloques"),
                                                                                 Planta = FIELD("Rango Plantas"),
                                                                                 Rango = FIELD("Rango Rangos Hab."),
                                                                                 Trato = FIELD("Rango Trato"),
                                                                                 Nacionalidad = FIELD("Rango Nacionalidad")));
            Caption = 'JR Bkg. x Room.';
            Description = '001';
            FieldClass = FlowField;
        }
        field(45; "NI Bkg. x Hab."; Decimal)
        {
            CalcFormula = Sum("QHT Ocupantes-Desglose diario"."Ocupacion" WHERE(Hotel = FIELD(Hotel),
                                                                                 Fecha = FIELD("Rango Fecha"),
                                                                                 "Tipo persona" = CONST(NI),
                                                                                 TTOO = FIELD("Rango TTOO"),
                                                                                 Agencia = FIELD("Rango Agencia"),
                                                                                 "Tipo habitacion uso" = FIELD("Rango Tipo Habitacion"),
                                                                                 "Regimen factura" = FIELD("Rango Regimen fact."),
                                                                                 Bloque = FIELD("Rango Bloques"),
                                                                                 Planta = FIELD("Rango Plantas"),
                                                                                 Rango = FIELD("Rango Rangos Hab."),
                                                                                 Trato = FIELD("Rango Trato"),
                                                                                 Nacionalidad = FIELD("Rango Nacionalidad")));
            Caption = 'NI Bkg. x Room';
            Description = '001';
            FieldClass = FlowField;
        }
        field(46; "CU Bkg. x Hab."; Decimal)
        {
            CalcFormula = Sum("QHT Ocupantes-Desglose diario"."Ocupacion" WHERE(Hotel = FIELD(Hotel),
                                                                                 Fecha = FIELD("Rango Fecha"),
                                                                                 "Tipo persona" = CONST(CU),
                                                                                 TTOO = FIELD("Rango TTOO"),
                                                                                 Agencia = FIELD("Rango Agencia"),
                                                                                 "Tipo habitacion uso" = FIELD("Rango Tipo Habitacion"),
                                                                                 "Regimen factura" = FIELD("Rango Regimen fact."),
                                                                                 Bloque = FIELD("Rango Bloques"),
                                                                                 Planta = FIELD("Rango Plantas"),
                                                                                 Rango = FIELD("Rango Rangos Hab."),
                                                                                 Trato = FIELD("Rango Trato"),
                                                                                 Nacionalidad = FIELD("Rango Nacionalidad")));
            Caption = 'CO Bkg. x Hab.';
            Description = '001';
            FieldClass = FlowField;
        }
        field(47; "Ocupacion Comercial"; Integer)
        {
            CalcFormula = Count("QHT Reservas diarias" WHERE(Hotel = FIELD(Hotel),
                                                              Fecha = FIELD("Rango Fecha"),
                                                              Cliente = FIELD("Rango Cliente"),
                                                              TTOO = FIELD("Rango TTOO"),
                                                              Agencia = FIELD("Rango Agencia"),
                                                              "Tipo hab. uso" = FIELD("Rango Tipo Habitacion"),
                                                              "Regimen factura" = FIELD("Rango Regimen fact."),
                                                              Segmento = FIELD("Rango Segmento"),
                                                              "Pais" = FIELD("Rango Nacionalidad"),
                                                              "Estado reserva" = FIELD("Rango Estado"),
                                                              "Tipo hab. fra." = FIELD("Rango Tipo Habitacion fact."),
                                                              Bloque = FIELD("Rango Bloques"),
                                                              Planta = FIELD("Rango Plantas"),
                                                              Rango = FIELD("Rango Rangos Hab."),
                                                              Oferta = FIELD("Rango Oferta"),
                                                              "Canal/Origen" = FIELD("Rango Canal/Origen")));
            Caption = 'Commercialising Occupancy';
            FieldClass = FlowField;
        }
        field(48; "Ocupacion Comercial Gtia."; Integer)
        {
            CalcFormula = Count("QHT Reservas diarias" WHERE(Hotel = FIELD(Hotel),
                                                              Fecha = FIELD("Rango Fecha"),
                                                              Cliente = FIELD("Rango Cliente"),
                                                              TTOO = FIELD("Rango TTOO"),
                                                              Agencia = FIELD("Rango Agencia"),
                                                              "Tipo hab. uso" = FIELD("Rango Tipo Habitacion"),
                                                              "Contrato garantia" = CONST(true),
                                                              "Regimen factura" = FIELD("Rango Regimen fact."),
                                                              "Pais" = FIELD("Rango Nacionalidad"),
                                                              "Estado reserva" = FIELD("Rango Estado"),
                                                              "Tipo hab. fra." = FIELD("Rango Tipo Habitacion fact.")));
            Caption = 'Guarantee Commercialising Occupancy';
            FieldClass = FlowField;
        }
        field(49; "AD Reservado"; Decimal)
        {
            CalcFormula = Sum("QHT Reservas diarias"."AD Reservado" WHERE(Hotel = FIELD(Hotel),
                                                                           Fecha = FIELD("Rango Fecha"),
                                                                           Cliente = FIELD("Rango Cliente"),
                                                                           TTOO = FIELD("Rango TTOO"),
                                                                           Agencia = FIELD("Rango Agencia"),
                                                                           "Tipo hab. uso" = FIELD("Rango Tipo Habitacion"),
                                                                           "Regimen factura" = FIELD("Rango Regimen fact."),
                                                                           "Pais" = FIELD("Rango Nacionalidad"),
                                                                           "Estado reserva" = FIELD("Rango Estado"),
                                                                           "Tipo hab. fra." = FIELD("Rango Tipo Habitacion fact."),
                                                                           Bloque = FIELD("Rango Bloques"),
                                                                           Planta = FIELD("Rango Plantas"),
                                                                           Rango = FIELD("Rango Rangos Hab."),
                                                                           Trato = FIELD("Rango Trato"),
                                                                           "Regimen uso" = FIELD("Rango Regimen Uso"),
                                                                           "Canal/Origen" = FIELD("Rango Canal/Origen"),
                                                                           Segmento = FIELD("Rango Segmento")));
            Caption = 'AD Booked';
            Description = '001 Incluye Reg. Uso';
            FieldClass = FlowField;
        }
        field(50; "JR Reservado"; Decimal)
        {
            CalcFormula = Sum("QHT Reservas diarias"."JR Reservado" WHERE(Hotel = FIELD(Hotel),
                                                                           Fecha = FIELD("Rango Fecha"),
                                                                           Cliente = FIELD("Rango Cliente"),
                                                                           TTOO = FIELD("Rango TTOO"),
                                                                           Agencia = FIELD("Rango Agencia"),
                                                                           "Tipo hab. uso" = FIELD("Rango Tipo Habitacion"),
                                                                           "Regimen factura" = FIELD("Rango Regimen fact."),
                                                                           "Pais" = FIELD("Rango Nacionalidad"),
                                                                           "Estado reserva" = FIELD("Rango Estado"),
                                                                           "Tipo hab. fra." = FIELD("Rango Tipo Habitacion fact."),
                                                                           Bloque = FIELD("Rango Bloques"),
                                                                           Planta = FIELD("Rango Plantas"),
                                                                           Rango = FIELD("Rango Rangos Hab."),
                                                                           Trato = FIELD("Rango Trato"),
                                                                           "Regimen uso" = FIELD("Rango Regimen Uso"),
                                                                           "Canal/Origen" = FIELD("Rango Canal/Origen"),
                                                                            Segmento = FIELD("Rango Segmento")));
            Caption = 'JR Booked';
            Description = '001 Incluye Reg. Uso';
            FieldClass = FlowField;
        }
        field(51; "NI Reservado"; Decimal)
        {
            CalcFormula = Sum("QHT Reservas diarias"."NI Reservado" WHERE(Hotel = FIELD(Hotel),
                                                                           Fecha = FIELD("Rango Fecha"),
                                                                           Cliente = FIELD("Rango Cliente"),
                                                                           TTOO = FIELD("Rango TTOO"),
                                                                           Agencia = FIELD("Rango Agencia"),
                                                                           "Tipo hab. uso" = FIELD("Rango Tipo Habitacion"),
                                                                           "Regimen factura" = FIELD("Rango Regimen fact."),
                                                                           "Pais" = FIELD("Rango Nacionalidad"),
                                                                           "Estado reserva" = FIELD("Rango Estado"),
                                                                           "Tipo hab. fra." = FIELD("Rango Tipo Habitacion fact."),
                                                                           Bloque = FIELD("Rango Bloques"),
                                                                           Planta = FIELD("Rango Plantas"),
                                                                           Rango = FIELD("Rango Rangos Hab."),
                                                                           Trato = FIELD("Rango Trato"),
                                                                           "Regimen uso" = FIELD("Rango Regimen Uso"),
                                                                           "Canal/Origen" = FIELD("Rango Canal/Origen"),
                                                                           Segmento = FIELD("Rango Segmento")));
            Caption = 'CH Booked';
            Description = '001 Incluye Reg. Uso';
            FieldClass = FlowField;
        }
        field(52; "CU Reservado"; Decimal)
        {
            CalcFormula = Sum("QHT Reservas diarias"."CU Reservado" WHERE(Hotel = FIELD(Hotel),
                                                                           Fecha = FIELD("Rango Fecha"),
                                                                           Cliente = FIELD("Rango Cliente"),
                                                                           TTOO = FIELD("Rango TTOO"),
                                                                           Agencia = FIELD("Rango Agencia"),
                                                                           "Tipo hab. uso" = FIELD("Rango Tipo Habitacion"),
                                                                           "Regimen factura" = FIELD("Rango Regimen fact."),
                                                                           "Pais" = FIELD("Rango Nacionalidad"),
                                                                           "Estado reserva" = FIELD("Rango Estado"),
                                                                           "Tipo hab. fra." = FIELD("Rango Tipo Habitacion fact."),
                                                                           Bloque = FIELD("Rango Bloques"),
                                                                           Planta = FIELD("Rango Plantas"),
                                                                           Rango = FIELD("Rango Rangos Hab."),
                                                                           Trato = FIELD("Rango Trato"),
                                                                           "Regimen uso" = FIELD("Rango Regimen Uso"),
                                                                           "Canal/Origen" = FIELD("Rango Canal/Origen"),
                                                                           Segmento = FIELD("Rango Segmento")));
            Caption = 'BA Booked';
            Description = '001';
            FieldClass = FlowField;
        }
        field(53; "AD Gratis"; Decimal)
        {
            CalcFormula = Sum("QHT Reservas diarias"."AD free" WHERE(Hotel = FIELD(Hotel),
                                                                      Fecha = FIELD("Rango Fecha"),
                                                                      TTOO = FIELD("Rango TTOO"),
                                                                      "Tipo hab. uso" = FIELD("Rango Tipo Habitacion"),
                                                                      Cliente = FIELD("Rango Cliente"),
                                                                      Agencia = FIELD("Rango Agencia"),
                                                                      "Estado reserva" = FIELD("Rango Estado"),
                                                                      "Regimen factura" = FIELD("Rango Regimen fact."),
                                                                      "Tipo hab. fra." = FIELD("Rango Tipo Habitacion fact."),
                                                                      "Pais" = FIELD("Rango Nacionalidad"),
                                                                      Bloque = FIELD("Rango Bloques"),
                                                                      Planta = FIELD("Rango Plantas"),
                                                                      Rango = FIELD("Rango Rangos Hab.")));
            Caption = 'AD free';
            FieldClass = FlowField;
        }
        field(54; "JR Gratis"; Decimal)
        {
            CalcFormula = Sum("QHT Reservas diarias"."JR free" WHERE(Hotel = FIELD(Hotel),
                                                                      Fecha = FIELD("Rango Fecha"),
                                                                      TTOO = FIELD("Rango TTOO"),
                                                                      "Tipo hab. uso" = FIELD("Rango Tipo Habitacion"),
                                                                      Cliente = FIELD("Rango Cliente"),
                                                                      Agencia = FIELD("Rango Agencia"),
                                                                      "Estado reserva" = FIELD("Rango Estado"),
                                                                      "Regimen factura" = FIELD("Rango Regimen fact."),
                                                                      "Tipo hab. fra." = FIELD("Rango Tipo Habitacion fact."),
                                                                      "Pais" = FIELD("Rango Nacionalidad"),
                                                                      Bloque = FIELD("Rango Bloques"),
                                                                      Planta = FIELD("Rango Plantas"),
                                                                      Rango = FIELD("Rango Rangos Hab.")));
            Caption = 'JR free';
            FieldClass = FlowField;
        }
        field(55; "NI Gratis"; Decimal)
        {
            CalcFormula = Sum("QHT Reservas diarias"."NI free" WHERE(Hotel = FIELD(Hotel),
                                                                      Fecha = FIELD("Rango Fecha"),
                                                                      TTOO = FIELD("Rango TTOO"),
                                                                      "Tipo hab. uso" = FIELD("Rango Tipo Habitacion"),
                                                                      Cliente = FIELD("Rango Cliente"),
                                                                      Agencia = FIELD("Rango Agencia"),
                                                                      "Estado reserva" = FIELD("Rango Estado"),
                                                                      "Regimen factura" = FIELD("Rango Regimen fact."),
                                                                      "Tipo hab. fra." = FIELD("Rango Tipo Habitacion fact."),
                                                                      "Pais" = FIELD("Rango Nacionalidad"),
                                                                      Bloque = FIELD("Rango Bloques"),
                                                                      Planta = FIELD("Rango Plantas"),
                                                                      Rango = FIELD("Rango Rangos Hab.")));
            Caption = 'CH free';
            FieldClass = FlowField;
        }
        field(56; "3AD"; Decimal)
        {
            CalcFormula = Sum("QHT Reservas diarias".AD3 WHERE(Hotel = FIELD(Hotel),
                                                                Fecha = FIELD("Rango Fecha"),
                                                                TTOO = FIELD("Rango TTOO"),
                                                                "Tipo hab. uso" = FIELD("Rango Tipo Habitacion"),
                                                                Cliente = FIELD("Rango Cliente"),
                                                                Agencia = FIELD("Rango Agencia"),
                                                                "Estado reserva" = FIELD("Rango Estado"),
                                                                "Regimen factura" = FIELD("Rango Regimen fact."),
                                                                "Tipo hab. fra." = FIELD("Rango Tipo Habitacion fact."),
                                                                "Pais" = FIELD("Rango Nacionalidad"),
                                                                Bloque = FIELD("Rango Bloques"),
                                                                Planta = FIELD("Rango Plantas"),
                                                                Rango = FIELD("Rango Rangos Hab.")));
            Caption = '3AD';
            FieldClass = FlowField;
        }
        field(57; "3JR"; Decimal)
        {
            CalcFormula = Sum("QHT Reservas diarias".JR3 WHERE(Hotel = FIELD(Hotel),
                                                                Fecha = FIELD("Rango Fecha"),
                                                                TTOO = FIELD("Rango TTOO"),
                                                                "Tipo hab. uso" = FIELD("Rango Tipo Habitacion"),
                                                                Cliente = FIELD("Rango Cliente"),
                                                                Agencia = FIELD("Rango Agencia"),
                                                                "Estado reserva" = FIELD("Rango Estado"),
                                                                "Regimen factura" = FIELD("Rango Regimen fact."),
                                                                "Tipo hab. fra." = FIELD("Rango Tipo Habitacion fact."),
                                                                "Pais" = FIELD("Rango Nacionalidad"),
                                                                Bloque = FIELD("Rango Bloques"),
                                                                Planta = FIELD("Rango Plantas"),
                                                                Rango = FIELD("Rango Rangos Hab.")));
            Caption = '3JR';
            FieldClass = FlowField;
        }
        field(58; "3NI"; Decimal)
        {
            CalcFormula = Sum("QHT Reservas diarias".NI3 WHERE(Hotel = FIELD(Hotel),
                                                                Fecha = FIELD("Rango Fecha"),
                                                                TTOO = FIELD("Rango TTOO"),
                                                                "Tipo hab. uso" = FIELD("Rango Tipo Habitacion"),
                                                                Cliente = FIELD("Rango Cliente"),
                                                                Agencia = FIELD("Rango Agencia"),
                                                                "Estado reserva" = FIELD("Rango Estado"),
                                                                "Regimen factura" = FIELD("Rango Regimen fact."),
                                                                "Tipo hab. fra." = FIELD("Rango Tipo Habitacion fact."),
                                                                "Pais" = FIELD("Rango Nacionalidad"),
                                                                Bloque = FIELD("Rango Bloques"),
                                                                Planta = FIELD("Rango Plantas"),
                                                                Rango = FIELD("Rango Rangos Hab.")));
            Caption = '3CH';
            FieldClass = FlowField;
        }
        field(59; "3AD Gratis"; Decimal)
        {
            CalcFormula = Sum("QHT Reservas diarias"."AD3 free" WHERE(Hotel = FIELD(Hotel),
                                                                       Fecha = FIELD("Rango Fecha"),
                                                                       TTOO = FIELD("Rango TTOO"),
                                                                       "Tipo hab. uso" = FIELD("Rango Tipo Habitacion"),
                                                                       Cliente = FIELD("Rango Cliente"),
                                                                       Agencia = FIELD("Rango Agencia"),
                                                                       "Estado reserva" = FIELD("Rango Estado"),
                                                                       "Regimen factura" = FIELD("Rango Regimen fact."),
                                                                       "Tipo hab. fra." = FIELD("Rango Tipo Habitacion fact."),
                                                                       "Pais" = FIELD("Rango Nacionalidad"),
                                                                       Bloque = FIELD("Rango Bloques"),
                                                                       Planta = FIELD("Rango Plantas"),
                                                                       Rango = FIELD("Rango Rangos Hab.")));
            Caption = '3AD free';
            FieldClass = FlowField;
        }
        field(60; "3JR Gratis"; Decimal)
        {
            CalcFormula = Sum("QHT Reservas diarias"."JR3 free" WHERE(Hotel = FIELD(Hotel),
                                                                       Fecha = FIELD("Rango Fecha"),
                                                                       TTOO = FIELD("Rango TTOO"),
                                                                       "Tipo hab. uso" = FIELD("Rango Tipo Habitacion"),
                                                                       Cliente = FIELD("Rango Cliente"),
                                                                       Agencia = FIELD("Rango Agencia"),
                                                                       "Estado reserva" = FIELD("Rango Estado"),
                                                                       "Regimen factura" = FIELD("Rango Regimen fact."),
                                                                       "Tipo hab. fra." = FIELD("Rango Tipo Habitacion fact."),
                                                                       "Pais" = FIELD("Rango Nacionalidad"),
                                                                       Bloque = FIELD("Rango Bloques"),
                                                                       Planta = FIELD("Rango Plantas"),
                                                                       Rango = FIELD("Rango Rangos Hab.")));
            Caption = '3JR Free';
            FieldClass = FlowField;
        }
        field(61; "3NI Gratis"; Decimal)
        {
            CalcFormula = Sum("QHT Reservas diarias"."NI3 free" WHERE(Hotel = FIELD(Hotel),
                                                                       Fecha = FIELD("Rango Fecha"),
                                                                       TTOO = FIELD("Rango TTOO"),
                                                                       "Tipo hab. uso" = FIELD("Rango Tipo Habitacion"),
                                                                       Cliente = FIELD("Rango Cliente"),
                                                                       Agencia = FIELD("Rango Agencia"),
                                                                       "Estado reserva" = FIELD("Rango Estado"),
                                                                       "Regimen factura" = FIELD("Rango Regimen fact."),
                                                                       "Tipo hab. fra." = FIELD("Rango Tipo Habitacion fact."),
                                                                       "Pais" = FIELD("Rango Nacionalidad"),
                                                                       Bloque = FIELD("Rango Bloques"),
                                                                       Planta = FIELD("Rango Plantas"),
                                                                       Rango = FIELD("Rango Rangos Hab.")));
            Caption = '3CH free';
            FieldClass = FlowField;
        }
        field(62; "Habitaciones Hotel"; Integer)
        {
            CalcFormula = Count("QHT Habitaciones" WHERE(Hotel = FIELD(Hotel),
                                                    "Tipo habitacion" = FIELD("Rango Tipo Habitacion"),
                                                    Real = CONST(true),
                                                    Bloque = FIELD("Rango Bloques"),
                                                    Planta = FIELD("Rango Plantas"),
                                                    Rango = FIELD("Rango Rangos Hab.")));
            Caption = 'Hotel rooms';
            Description = 'SOLO Reales. NO ESTA OPTIMIZADO Y RALENTIZA LOS PROCESOS.';
            FieldClass = FlowField;
        }
        field(63; "Bloques Hotel"; Integer)
        {
            CalcFormula = Count("QHT Agrupacion habitaciones" WHERE(Hotel = FIELD(Hotel),
                                                                 "Tipo Agrupacion" = CONST(Bloque),
                                                                 "Agrupacion" = FIELD("Rango Bloques")));
            Caption = 'Hotel Buildings';
            FieldClass = FlowField;
        }
        field(64; "Bloques Hotel libres"; Integer)
        {
            CalcFormula = Count("QHT Agrupacion habitaciones" WHERE(Hotel = FIELD(Hotel),
                                                                 "Tipo Agrupacion" = CONST(Bloque),
                                                                 "Agrupacion" = FIELD("Rango Bloques"),
                                                                 "QHTOcupacion x Bloque" = CONST(0),
                                                                 "Rango Fechas" = FIELD("Rango Fecha"),
                                                                 "Rango Tipo Habitacion Uso" = FIELD("Rango Tipo Habitacion"),
                                                                 "Rango TTOO" = FIELD("Rango TTOO"),
                                                                 "Rango Agencia" = FIELD("Rango Agencia"),
                                                                 "Rango Cliente" = FIELD("Rango Cliente"),
                                                                 "Rango Regimen" = FIELD("Rango Regimen fact."),
                                                                 "Rango Nacionalidad" = FIELD("Rango Nacionalidad"),
                                                                 "Rango Tipo Habitacion Fra." = FIELD("Rango Tipo Habitacion fact."),
                                                                 "Rango Plantas" = FIELD("Rango Plantas"),
                                                                 "Rango Rangos" = FIELD("Rango Rangos Hab.")));
            Caption = 'Free Hotel Buildings';
            FieldClass = FlowField;
        }
        field(65; "Rango Trato"; Option)
        {
            Caption = 'Treatment Range';
            Description = 'Nuevo campo. SOLO se aplica a Ocupacion y Pax';
            FieldClass = FlowFilter;
            OptionCaption = 'Client,Invited,Staff,VIP,FixedTS,FloatingTS,OwnerRentalTS,Com.Rent.TS,TSInterval,TSPoints';
            OptionMembers = Cliente,Invitado,Personal,VIP,"TS Fijo","TS Flotante","TS Alq.Prop.","TS Alq.Emp.","TS Interval","TS Puntos";
        }
        field(66; "Cantidad habitaciones"; Integer)
        {
            CalcFormula = Count("QHT Habitaciones" WHERE(Hotel = FIELD(Hotel),
                                                    "Habitacion" = FIELD("Rango Tipo Hab. Gral."),
                                                    "Tipo habitacion" = FIELD("Rango Tipo Habitacion"),
                                                    Bloque = FIELD("Rango Bloques"),
                                                    Planta = FIELD("Rango Plantas"),
                                                    Rango = FIELD("Rango Rangos Hab.")));
            Caption = 'Number of rooms';
            FieldClass = FlowField;
        }
        field(70; "Calc Habitaciones"; Integer)
        {
            CalcFormula = Count("QHT Habitaciones" WHERE(Hotel = FIELD(Hotel),
                                                    "Tipo habitacion" = FIELD("Rango Tipo Habitacion"),
                                                    Bloque = FIELD("Rango Bloques"),
                                                    Planta = FIELD("Rango Plantas"),
                                                    Rango = FIELD("Rango Rangos Hab."),
                                                    Real = FIELD("Rango Real")));
            Caption = 'Calc Room';
            Description = 'SE RECOMIENDA SU USO EN VEZ DE "Habitaciones Hotel"';
            FieldClass = FlowField;
        }
        field(80; "Rango Canal/Origen"; Code[15])
        {
            Caption = 'Range Channel / Source';
            FieldClass = FlowFilter;
            TableRelation = "QHT Canales/Origenes"."Canal/Origen";
        }
        field(90; "Rango Segmento"; Code[15])
        {
            Caption = 'Range Segment';
            FieldClass = FlowFilter;
            TableRelation = "QHT Segmentos".Segmento;
        }
        field(91; "Rango Oferta"; Code[20])
        {
            Caption = 'Offer range';
            Description = 'FMX37';
            FieldClass = FlowFilter;
            TableRelation = "QHT Ofertas de contrato".Oferta;
        }
        field(92; "Ocupacion Contratos"; Decimal)
        {
            CalcFormula = Sum("QHT Reservas diarias"."Ocupacion" WHERE(Hotel = FIELD(Hotel),
                                                                        Fecha = FIELD("Rango Fecha"),
                                                                        "Estado reserva" = FIELD("Rango Estado"),
                                                                        TTOO = FIELD("Rango TTOO"),
                                                                        Agencia = FIELD("Rango Agencia"),
                                                                        Cliente = FIELD("Rango Cliente"),
                                                                        "Tipo hab. uso" = FIELD("Rango Tipo Habitacion"),
                                                                        "Tipo hab. fra." = FIELD("Rango Tipo Habitacion fact."),
                                                                        "Regimen factura" = FIELD("Rango Regimen fact."),
                                                                        Bloque = FIELD("Rango Bloques"),
                                                                        Planta = FIELD("Rango Plantas"),
                                                                        Rango = FIELD("Rango Rangos Hab."),
                                                                        "Pais" = FIELD("Rango Nacionalidad"),
                                                                        Trato = FIELD("Rango Trato"),
                                                                        "Canal/Origen" = FIELD("Rango Canal/Origen"),
                                                                        Segmento = FIELD("Rango Segmento"),
                                                                        Oferta = FIELD("Rango Oferta"),
                                                                        "Tipo Precio" = CONST(Contratos)));
            Caption = 'Contracts Occupation';
            FieldClass = FlowField;
        }
        field(100; "Ocupacion Tarifas"; Decimal)
        {
            CalcFormula = Sum("QHT Reservas diarias"."Ocupacion" WHERE(Hotel = FIELD(Hotel),
                                                                        Fecha = FIELD("Rango Fecha"),
                                                                        "Estado reserva" = FIELD("Rango Estado"),
                                                                        TTOO = FIELD("Rango TTOO"),
                                                                        Agencia = FIELD("Rango Agencia"),
                                                                        Cliente = FIELD("Rango Cliente"),
                                                                        "Tipo hab. uso" = FIELD("Rango Tipo Habitacion"),
                                                                        "Tipo hab. fra." = FIELD("Rango Tipo Habitacion fact."),
                                                                        "Regimen factura" = FIELD("Rango Regimen fact."),
                                                                        Bloque = FIELD("Rango Bloques"),
                                                                        Planta = FIELD("Rango Plantas"),
                                                                        Rango = FIELD("Rango Rangos Hab."),
                                                                        "Pais" = FIELD("Rango Nacionalidad"),
                                                                        Trato = FIELD("Rango Trato"),
                                                                        "Canal/Origen" = FIELD("Rango Canal/Origen"),
                                                                        Segmento = FIELD("Rango Segmento"),
                                                                        Oferta = FIELD("Rango Oferta"),
                                                                        "Tipo Precio" = CONST(Tarifas)));
            Caption = 'Contracts Occupancy';
            Description = '1501';
            FieldClass = FlowField;
        }
        field(110; "Cupo contrato"; Decimal)
        {
            CalcFormula = Sum("QHT Cupos diarios".Cupo WHERE(Hotel = FIELD(Hotel),
                                                              Fecha = FIELD("Rango Fecha"),
                                                              "Tipo habitacion" = FIELD("Rango Tipo Hab. Gral."),
                                                              TTOO = FIELD("Rango TTOO"),
                                                              Agencia = FIELD("Rango Agencia"),
                                                              Cliente = FIELD("Rango Cliente"),
                                                              "Cod. Tarifa" = FILTER(= '')));
            Caption = 'allotment';
            Description = '1502';
            FieldClass = FlowField;
        }
        field(120; "Cupo tarifa"; Decimal)
        {
            CalcFormula = Sum("QHT Cupos diarios".Cupo WHERE(Hotel = FIELD(Hotel),
                                                              Fecha = FIELD("Rango Fecha"),
                                                              "Tipo habitacion" = FIELD("Rango Tipo Hab. Gral."),
                                                              TTOO = FIELD("Rango TTOO"),
                                                              Agencia = FIELD("Rango Agencia"),
                                                              Cliente = FIELD("Rango Cliente"),
                                                              "Cod. Tarifa" = FILTER(<> '')));
            Caption = 'allotment';
            Description = '1502';
            FieldClass = FlowField;
        }
        field(130; "Ocupacion tentativas"; Decimal)
        {
            CalcFormula = Sum("QHT Reservas diarias"."Ocupacion" WHERE(Hotel = FIELD(Hotel),
                                                                        Fecha = FIELD("Rango Fecha"),
                                                                        "Estado reserva" = CONST(Tentativa),
                                                                        TTOO = FIELD("Rango TTOO"),
                                                                        Agencia = FIELD("Rango Agencia"),
                                                                        Cliente = FIELD("Rango Cliente"),
                                                                        "Tipo hab. uso" = FIELD("Rango Tipo Habitacion"),
                                                                        "Tipo hab. fra." = FIELD("Rango Tipo Habitacion fact."),
                                                                        "Regimen factura" = FIELD("Rango Regimen fact."),
                                                                        Bloque = FIELD("Rango Bloques"),
                                                                        Planta = FIELD("Rango Plantas"),
                                                                        Rango = FIELD("Rango Rangos Hab."),
                                                                        "Pais" = FIELD("Rango Nacionalidad"),
                                                                        Trato = FIELD("Rango Trato"),
                                                                        "Canal/Origen" = FIELD("Rango Canal/Origen"),
                                                                        Segmento = FIELD("Rango Segmento"),
                                                                        Oferta = FIELD("Rango Oferta"),
                                                                        "Day Use" = FIELD("Rango DayUse")));
            Caption = 'Occupancy';
            Description = 'RPD-OC-16004,2000';
            FieldClass = FlowField;
        }
        field(131; "Ocupacion comercial tentativas"; Integer)
        {
            CalcFormula = Count("QHT Reservas diarias" WHERE(Hotel = FIELD(Hotel),
                                                              Fecha = FIELD("Rango Fecha"),
                                                              Cliente = FIELD("Rango Cliente"),
                                                              TTOO = FIELD("Rango TTOO"),
                                                              Agencia = FIELD("Rango Agencia"),
                                                              "Tipo hab. uso" = FIELD("Rango Tipo Habitacion"),
                                                              "Regimen factura" = FIELD("Rango Regimen fact."),
                                                              Segmento = FIELD("Rango Segmento"),
                                                              "Pais" = FIELD("Rango Nacionalidad"),
                                                              "Estado reserva" = CONST(Tentativa),
                                                              "Tipo hab. fra." = FIELD("Rango Tipo Habitacion fact."),
                                                              Bloque = FIELD("Rango Bloques"),
                                                              Planta = FIELD("Rango Plantas"),
                                                              Rango = FIELD("Rango Rangos Hab."),
                                                              Oferta = FIELD("Rango Oferta"),
                                                              "Canal/Origen" = FIELD("Rango Canal/Origen")));
            Caption = 'Reselling Occupancy';
            Description = 'RPD-OC-16004,2000';
            FieldClass = FlowField;
        }
        field(7196651; "Ocupantes Fecha Entrada"; Integer)
        {
            CalcFormula = Count("QHT Ocupantes" WHERE(Hotel = FIELD(Hotel),
                                                       "Fecha entrada" = FIELD("Rango Fecha"),
                                                       "Pais residencia" = FIELD("Rango Nacionalidad"),
                                                       "Check In" = CONST(true),
                                                       "Tipo persona" = FILTER(<> CU)));
            Caption = 'Occupants Arrival Date';
            Description = 'BARCELO,INF89,FPC170';
            FieldClass = FlowField;
        }
        field(7196652; "Ocupantes Fecha Salida"; Integer)
        {
            CalcFormula = Count("QHT Ocupantes" WHERE(Hotel = FIELD(Hotel),
                                                       "Fecha salida" = FIELD("Rango Fecha"),
                                                       "Pais residencia" = FIELD("Rango Nacionalidad"),
                                                       "Check In" = CONST(true),
                                                       "Tipo persona" = FILTER(<> CU)));
            Caption = 'Occupants Departure Date';
            Description = 'BARCELO,INF89,FPC170';
            FieldClass = FlowField;
        }
        field(7196653; "Rango DayUse"; Boolean)
        {
            Caption = 'DayUse range';
            Description = '2101 TEQ-OC-20011';
            FieldClass = FlowFilter;
        }
    }

    keys
    {
        key(Key1; Hotel)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}
