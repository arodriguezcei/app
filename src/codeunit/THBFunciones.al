codeunit 50000 "THB Funciones"
{

    [EventSubscriber(ObjectType::codeunit, 1221, 'OnFillExportBufferOnBeforeInsertPaymentExportData', '', false, false)]
    local procedure OnFillExportBufferOnBeforeInsertPaymentExportData_C1221(var PaymentExportData: Record "Payment Export Data")
    begin
        PaymentExportData."SEPA Batch Booking" := true;
    end;

    [EventSubscriber(ObjectType::codeunit, 1222, 'OnCreateTempJnlLinesOnBeforeTempGenJnlLineInsert', '', false, false)]
    local procedure OnCreateTempJnlLinesOnBeforeTempGenJnlLineInsert_C1222(var TempGenJnlLine: Record "Gen. Journal Line"; CarteraDoc: Record "Cartera Doc.")
    var
        PaymentOrder: Record "Payment Order";
        Text001: Label 'Pago factura %1';
    begin
        //$001-
        if PaymentOrder.Get(CarteraDoc."Bill Gr./Pmt. Order No.") then
            TempGenJnlLine."Posting Date" := PaymentOrder."Posting Date";
        //$001+
        //2001-
        CarteraDoc.CALCFIELDS("QHTExternal Doc. No.");
        TempGenJnlLine.Description := STRSUBSTNO(Text001, CarteraDoc."QHTExternal Doc. No.");
        //2001+
    end;

    [EventSubscriber(ObjectType::codeunit, 7000005, 'OnSplitPurchInvOnCreateBillsOnBeforePostGenJnlLine', '', false, false)]
    local procedure OnSplitPurchInvOnCreateBillsOnBeforePostGenJnlLine_C7000005(var GenJournalLine: Record "Gen. Journal Line"; PurchaseHeader: Record "Purchase Header")
    var
        Vendor: Record Vendor;
        Text7000100: Label 'Efecto %1/%2 %3';
    begin
        //-001
        Vendor.GET(purchaseHeader."Pay-to Vendor No.");
        //+001
        GenJournalLine.Description :=
            //-001
            COPYSTR(STRSUBSTNO(Text7000100, GenJournalLine."External Document No.", GenJournalLine."Document No.", Vendor.Name),
            1,
            MAXSTRLEN(GenJournalLine.Description));
        //+001
    end;

    [EventSubscriber(ObjectType::codeunit, 90, 'OnBeforePostPurchaseDoc', '', false, false)]
    local procedure OnBeforePostPurchaseDoc_C90(var PurchaseHeader: Record "Purchase Header")
    var
        SIISetup: Record "SII Setup";
        err001: Label 'No se pueden registrar facturas con más de 6 días de antigüedad';
        err002: Label 'No se pueden registrar facturas con fecha posterior a la emisión de las mismas.';
        err003: Label 'No se pueden registrar facturas con fecha posterior a la fecha de hoy';
    begin
        if PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Invoice then begin
            IF (SIISetup.FINDFIRST) AND (SIISetup.Enabled = TRUE) AND (SIISetup."Starting Date" <= PurchaseHeader."Posting Date") THEN BEGIN
                IF CALCDATE('+5D', PurchaseHeader."Posting Date") < TODAY THEN
                    ERROR(err001)
            END;

            IF PurchaseHeader."Posting Date" < PurchaseHeader."Document Date" THEN ERROR(err002);
            IF PurchaseHeader."Posting Date" > TODAY THEN ERROR(err003);
        end;
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnBeforeOnInsert', '', false, false)]
    local procedure OnBeforeOnInsert_T27(var Item: Record Item)
    begin
        IF (COMPANYNAME <> 'THB Gestión') AND (COMPANYNAME <> 'INV. TUR. PLAYA BLANCA, S.L.') AND (COMPANYNAME <> 'HOTEL ROYAL PLAYABLANCA, S.L.U') AND (COMPANYNAME <> 'INVER. FINAN. PONENT, S.A.') THEN
            ERROR('No se pueden modificar los productos desde aquí, consulte con el departamento de compras');
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnModifyOnBeforePlanningAssignmentItemChange', '', false, false)]
    local procedure OnBeforeOnModify_T27(var Item: Record Item)
    begin
        IF (COMPANYNAME <> 'THB Gestión') AND (COMPANYNAME <> 'INV. TUR. PLAYA BLANCA, S.L.') AND (COMPANYNAME <> 'HOTEL ROYAL PLAYABLANCA, S.L.U') AND (COMPANYNAME <> 'INVER. FINAN. PONENT, S.A.') THEN
            ERROR('No se pueden modificar los productos desde aquí, consulte con el departamento de compras');
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnBeforeOnDelete', '', false, false)]
    local procedure OnBeforeOnDelete_T27(var Item: Record Item)
    begin
        IF (COMPANYNAME <> 'THB Gestión') AND (COMPANYNAME <> 'INV. TUR. PLAYA BLANCA, S.L.') AND (COMPANYNAME <> 'HOTEL ROYAL PLAYABLANCA, S.L.U') AND (COMPANYNAME <> 'INVER. FINAN. PONENT, S.A.') THEN
            ERROR('No se pueden modificar los productos desde aquí, consulte con el departamento de compras');
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnBeforeRenameEvent', '', false, false)]
    local procedure OnBeforeRename_T27()
    begin
        IF (COMPANYNAME <> 'THB Gestión') AND (COMPANYNAME <> 'INV. TUR. PLAYA BLANCA, S.L.') AND (COMPANYNAME <> 'HOTEL ROYAL PLAYABLANCA, S.L.U') AND (COMPANYNAME <> 'INVER. FINAN. PONENT, S.A.')
  THEN
            ERROR('No puede introducir nuevos precios, consulte con el departamento de compras');
    end;

    [EventSubscriber(ObjectType::Table, 39, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsert_T39(var Rec: Record "Purchase Line"; RunTrigger: Boolean)
    begin
        //THB-030326-IFF
        IF (Rec."Document Type" = Rec."Document Type"::Invoice) AND (Rec.Type = Rec.Type::Item) AND (Rec."Receipt No." = '') THEN ERROR('No se pueden introducir productos en las facturas, introduzca un albarán de compra.');
        IF (Rec."Document Type" = Rec."Document Type"::"Credit Memo") AND (Rec.Type = Rec.Type::Item) AND (Rec."Receipt No." = '') THEN ERROR('No se pueden introducir productos en los abonos, introduzca un abono de compra.');
        IF (Rec."Document Type" = Rec."Document Type"::Order) AND (Rec.Type = Rec.Type::"G/L Account") THEN ERROR('No se pueden introducir líneas de cuenta en los albaranes.');
        // FIN THB-030326-IFF
    end;

    [EventSubscriber(ObjectType::Table, 39, 'OnBeforeModifyEvent', '', false, false)]
    local procedure OnBeforeModify_T39(var Rec: Record "Purchase Line"; RunTrigger: Boolean)
    begin
        //THB-030326-IFF
        IF Rec."Receipt No." <> '' THEN ERROR('No se pueden modificar las líneas que vienen de albaranes, modifique el albarán.');
        //FIN THB-030326-IFF
    end;

    [EventSubscriber(ObjectType::Table, 99, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsert_T99(var Rec: Record "Item Vendor"; RunTrigger: Boolean)
    begin
        //THB-030226-IFF
        IF (COMPANYNAME <> 'THB Gestión') AND (COMPANYNAME <> 'INV. TUR. PLAYA BLANCA, S.L.') AND (COMPANYNAME <> 'HOTEL ROYAL PLAYABLANCA, S.L.U') AND (COMPANYNAME <> 'INVER. FINAN. PONENT, S.A.') AND (COMPANYNAME <> 'INMOBILIARIA AGAR, S.A.')
          THEN
            ERROR('No puede introducir nuevos precios, consulte con el departamento de compras');
        //FIN THB-030226-IFF
    end;

    [EventSubscriber(ObjectType::Table, 99, 'OnBeforeModifyEvent', '', false, false)]
    local procedure OnBeforeModify_T99(var Rec: Record "Item Vendor"; RunTrigger: Boolean)
    begin
        //THB-030226-IFF
        IF (COMPANYNAME <> 'THB Gestión') AND (COMPANYNAME <> 'INV. TUR. PLAYA BLANCA, S.L.') AND (COMPANYNAME <> 'HOTEL ROYAL PLAYABLANCA, S.L.U') AND (COMPANYNAME <> 'INVER. FINAN. PONENT, S.A.') AND (COMPANYNAME <> 'INMOBILIARIA AGAR, S.A.')
          THEN
            ERROR('No puede introducir nuevos precios, consulte con el departamento de compras');
        //FIN THB-030226-IFF
    end;

    [EventSubscriber(ObjectType::Table, 99, 'OnBeforeDeleteEvent', '', false, false)]
    local procedure OnBeforeDelete_T99(var Rec: Record "Item Vendor"; RunTrigger: Boolean)
    begin
        //THB-030226-IFF
        IF (COMPANYNAME <> 'THB Gestión') AND (COMPANYNAME <> 'INV. TUR. PLAYA BLANCA, S.L.') AND (COMPANYNAME <> 'HOTEL ROYAL PLAYABLANCA, S.L.U') AND (COMPANYNAME <> 'INVER. FINAN. PONENT, S.A.') AND (COMPANYNAME <> 'INMOBILIARIA AGAR, S.A.')
          THEN
            ERROR('No puede introducir nuevos precios, consulte con el departamento de compras');
        //FIN THB-030226-IFF
    end;

    [EventSubscriber(ObjectType::Table, 99, 'OnBeforeRenameEvent', '', false, false)]
    local procedure OnBeforeRename_T99(var Rec: Record "Item Vendor"; RunTrigger: Boolean)
    begin
        //THB-030226-IFF
        IF (COMPANYNAME <> 'THB Gestión') AND (COMPANYNAME <> 'INV. TUR. PLAYA BLANCA, S.L.') AND (COMPANYNAME <> 'HOTEL ROYAL PLAYABLANCA, S.L.U') AND (COMPANYNAME <> 'INVER. FINAN. PONENT, S.A.') AND (COMPANYNAME <> 'INMOBILIARIA AGAR, S.A.')
          THEN
            ERROR('No puede introducir nuevos precios, consulte con el departamento de compras');
        //FIN THB-030226-IFF
    end;

    [EventSubscriber(ObjectType::Table, 204, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsert_T204(var Rec: Record "Unit of Measure"; RunTrigger: Boolean)
    begin
        //THB-030226-IFF
        IF (COMPANYNAME <> 'THB Gestión') AND (COMPANYNAME <> 'INV. TUR. PLAYA BLANCA, S.L.') AND (COMPANYNAME <> 'HOTEL ROYAL PLAYABLANCA, S.L.U') AND (COMPANYNAME <> 'INVER. FINAN. PONENT, S.A.')
          THEN
            ERROR('No puede introducir nuevos precios, consulte con el departamento de compras');
        //FIN THB-030226-IFF
    end;

    [EventSubscriber(ObjectType::Table, 204, 'OnBeforeModifyEvent', '', false, false)]
    local procedure OnBeforeModify_T204(var Rec: Record "Unit of Measure"; RunTrigger: Boolean)
    begin
        //THB-030226-IFF
        IF (COMPANYNAME <> 'THB Gestión') AND (COMPANYNAME <> 'INV. TUR. PLAYA BLANCA, S.L.') AND (COMPANYNAME <> 'HOTEL ROYAL PLAYABLANCA, S.L.U') AND (COMPANYNAME <> 'INVER. FINAN. PONENT, S.A.')
          THEN
            ERROR('No puede introducir nuevos precios, consulte con el departamento de compras');
        //FIN THB-030226-IFF
    end;

    [EventSubscriber(ObjectType::Table, 204, 'OnBeforeDeleteEvent', '', false, false)]
    local procedure OnBeforeDelete_T204(var Rec: Record "Unit of Measure"; RunTrigger: Boolean)
    begin
        //THB-030226-IFF
        IF (COMPANYNAME <> 'THB Gestión') AND (COMPANYNAME <> 'INV. TUR. PLAYA BLANCA, S.L.') AND (COMPANYNAME <> 'HOTEL ROYAL PLAYABLANCA, S.L.U') AND (COMPANYNAME <> 'INVER. FINAN. PONENT, S.A.')
          THEN
            ERROR('No puede introducir nuevos precios, consulte con el departamento de compras');
        //FIN THB-030226-IFF
    end;

    [EventSubscriber(ObjectType::Table, 204, 'OnBeforeRenameEvent', '', false, false)]
    local procedure OnBeforeRename_T204(var Rec: Record "Unit of Measure"; RunTrigger: Boolean)
    begin
        //THB-030226-IFF
        IF (COMPANYNAME <> 'THB Gestión') AND (COMPANYNAME <> 'INV. TUR. PLAYA BLANCA, S.L.') AND (COMPANYNAME <> 'HOTEL ROYAL PLAYABLANCA, S.L.U') AND (COMPANYNAME <> 'INVER. FINAN. PONENT, S.A.')
          THEN
            ERROR('No puede introducir nuevos precios, consulte con el departamento de compras');
        //FIN THB-030226-IFF
    end;

}
