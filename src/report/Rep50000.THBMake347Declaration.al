report 50000 "THB Make 347 Declaration"
{

    ApplicationArea = Basic, Suite;
    Caption = 'Make 347 Declaration';
    ProcessingOnly = true;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(ControlDatos; "Integer")
        {
            DataItemTableView = SORTING(Number);
            MaxIteration = 1;

            trigger OnAfterGetRecord()
            var
                rMovClieDir1: Record "Cust. Ledger Entry";
                rCustomer: Record Customer;
                CustomerDirects: Record "QHT 347 Direct Customers";
                rCabFac1: Record "QHT Cabecera de factura";
                rHotel: Record "QHT Hoteles";
                rLogDatos: Record "QHT Log Control Datos";
                rPFO: Record "QHT Parametros Front Office";
                rUser: Record "QHT Usuarios";
                rVendor: Record Vendor;
                cduRutinas: Codeunit "QHT Compulsory Data";
                rRecRef: RecordRef;
                DatosOK: Boolean;
                TextL0001: Label '¿Desea continuar o solucionar los mensajes mostrados?';
                TipoProceso: Option " ","Datos Obligatorios 347"," Policia";
            begin


                if wDatosObligatorios = false then
                    CurrReport.Skip();
                //001+
                rLogDatos.Reset();
                rLogDatos.SetRange(Usuario, UserId);
                if rLogDatos.Find('-') then
                    rLogDatos.DeleteAll();

                rUser.Get(UserId);


                rCustomer.Reset();
                rCustomer.SetRange("Date Filter", FromDate, ToDate);
                //rCustomer.SETFILTER("VAT Registration No.",'<> %1','');
                rCustomer.SetFilter("Country/Region Code", ESCountryCode);
                if rCustomer.Find('-') then
                    repeat
                        Clear(rRecRef);
                        rRecRef.GetTable(rCustomer);
                        cduRutinas.CheckCompulsoryData(rRecRef, rUser."Hotel de trabajo", DatosOK, true);
                    until rCustomer.Next() = 0;


                rVendor.Reset();
                rVendor.SetRange("Date Filter", FromDate, ToDate);
                //rVendor.SETFILTER("VAT Registration No.",'<> %1','');
                rVendor.SetFilter("Country/Region Code", ESCountryCode);
                if rVendor.Find('-') then
                    repeat
                        Clear(rRecRef);
                        rRecRef.GetTable(rVendor);
                        cduRutinas.CheckCompulsoryData(rRecRef, rUser."Hotel de trabajo", DatosOK, true);
                    until rVendor.Next() = 0;



                if wIncluirDirectos and (wEmpresaGestion = '') then
                    Error(Text020);

                if wIncluirDirectos then begin
                    rHotel.ChangeCompany(wEmpresaGestion);
                    rHotel.SetRange("Empresa Fiscal", CompanyName);
                    wMovCliDir := 0;
                    if rHotel.Find('-') then
                        repeat
                            rPFO.ChangeCompany(wEmpresaGestion);
                            if rPFO.Get(rHotel.Hotel) then
                                if rPFO."Cliente directos" <> '' then
                                    if not TempCust2.Get(rPFO."Cliente directos") then begin
                                        // +1799
                                        /*
                                        rClientesTMP_1."No." := rPFO."Cliente directos";
                                        rClientesTMP_1.INSERT;
                                        */
                                        TempCust2."No." := rPFO."Cliente directos";
                                        TempCust2.Insert();
                                        // -1799
                                    end;
                        until rHotel.Next() = 0;

                    CustomerDirects.Reset();
                    CustomerDirects.SetFilter("Cust No.", '<>%1', '');
                    if CustomerDirects.FindSet() then
                        repeat
                            TempCust2."No." := CustomerDirects."Cust No.";
                            if TempCust2.Insert() then;
                        until CustomerDirects.Next() = 0;



                end;

                // +1799
                // IF rClientesTMP_1.FIND('-') THEN
                if TempCust2.Find('-') then
                    // -1799
                    repeat
                        rMovClieDir1.Reset();
                        // +1799
                        // rMovClieDir1.SETRANGE("Customer No.", rClientesTMP_1."No.");
                        rMovClieDir1.SetRange("Customer No.", TempCust2."No.");
                        // -1799
                        rMovClieDir1.SetRange("Vat Reporting Date", FromDate, ToDate);
                        rMovClieDir1.SetRange("Document Type", rMovClieDir1."Document Type"::Invoice, rMovClieDir1."Document Type"::"Credit Memo");
                        if rMovClieDir1.Find('-') then
                            repeat
                                rCabFac1.Reset();
                                rCabFac1.ChangeCompany(wEmpresaGestion);
                                rCabFac1.SetRange(Factura, rMovClieDir1."Document No.");
                                if not rCabFac1.Find('-') then
                                    CurrReport.Skip()
                                else begin
                                    rCARDEX.Reset();
                                    rCARDEX.ChangeCompany(wEmpresaGestion);
                                    if rCARDEX.Get(rCabFac1.Pais, rCabFac1."C.I.F./N.I.F.") then begin
                                        Clear(rRecRef);
                                        rRecRef.GetTable(rCabFac1);
                                        cduRutinas.CheckCompulsoryData(rRecRef, rUser."Hotel de trabajo", DatosOK, true);
                                    end
                                    else begin
                                        Clear(rRecRef);
                                        rRecRef.GetTable(rCabFac1);
                                        cduRutinas.CheckCompulsoryData(rRecRef, rUser."Hotel de trabajo", DatosOK, true);
                                    end;
                                end;
                            until rMovClieDir1.Next() = 0;
                    // +1799
                    // UNTIL rClientesTMP_1.NEXT = 0;
                    until TempCust2.Next() = 0;
                // -1799



                rLogDatos.Reset();
                rLogDatos.SetRange(Usuario, UserId);
                rLogDatos.SetRange("Tipo Mensaje", rLogDatos."Tipo Mensaje"::Error);
                if rLogDatos.Find('-') then begin
                    Commit();
                    PAGE.RunModal(7043349, rLogDatos);
                    CurrReport.Quit();
                end;


                rLogDatos.Reset();
                rLogDatos.SetRange(Usuario, UserId);
                rLogDatos.SetRange("Tipo Mensaje", rLogDatos."Tipo Mensaje"::Mensaje);
                if rLogDatos.Find('-') then begin
                    Commit();
                    PAGE.RunModal(7043349, rLogDatos);
                    if Confirm(TextL0001, false) then
                        CurrReport.Quit();
                end;

                //001-

            end;
        }
        dataitem("Integer"; "Integer")
        {
            DataItemTableView = SORTING(Number) ORDER(Ascending) WHERE(Number = CONST(1));

            trigger OnAfterGetRecord()
            var
                rMovClie: Record "Cust. Ledger Entry";
                rHotel: Record "QHT Hoteles";
                rPFO: Record "QHT Parametros Front Office";
            begin
                Evaluate(NumFiscalYear, FiscalYear);
                if NumFiscalYear = 0 then
                    Error(IncorrectFiscalYearErr);
                FromDate := DMY2Date(1, 1, NumFiscalYear);
                ToDate := DMY2Date(31, 12, NumFiscalYear);
                NotIn347Amt := 0;


                //AppendLine(PadStr('', 500, ' '));

                if wIncluirDirectos and (wEmpresaGestion = '') then
                    Error(Text020);

                if wIncluirDirectos then begin
                    rHotel.ChangeCompany(wEmpresaGestion);
                    rHotel.SetRange("Empresa Fiscal", CompanyName);
                    wMovCliDir := 0;
                    rMovClie.SetCurrentKey("Customer No.");
                    if rHotel.Find('-') then
                        repeat
                            rPFO.ChangeCompany(wEmpresaGestion);
                            if rPFO.Get(rHotel.Hotel) then
                                if rPFO."Cliente directos" <> '' then
                                    if not TempCust2.Get(rPFO."Cliente directos") then begin
                                        TempCust2."No." := rPFO."Cliente directos";
                                        TempCust2.Insert();
                                        rMovClie.SetRange("Customer No.", rPFO."Cliente directos");
                                        rMovClie.SetRange("Vat Reporting Date", FromDate, ToDate);
                                        rMovClie.SetRange("Document Type", rMovClie."Document Type"::Invoice, rMovClie."Document Type"::"Credit Memo");
                                        wMovCliDir += rMovClie.Count;
                                    end;
                        until rHotel.Next() = 0;
                end;
            end;

            trigger OnPreDataItem()
            begin

                // MIG FH6.0
                // PLB 03/06/2003
                if wEmpresaGestion <> '' then
                    Ventana.Open(Text000 +
                                 Text019 +
                                 Text002 +
                                 Text003)
                else
                    // Añadido por SGB
                    Ventana.Open(Text000 +
                               Text002 +
                               Text003);
                // MIG FH6.0
            end;
        }
        dataitem(ClieDir; "Integer")
        {
            DataItemTableView = SORTING(Number);
            dataitem(MovClieDir; "Cust. Ledger Entry")
            {
                DataItemTableView = SORTING("Document Type", "Customer No.", "Posting Date", "Currency Code");
                dataitem(MovConDir; "G/L Entry")
                {
                    DataItemLink = "Document No." = FIELD("Document No."), "Vat Reporting Date" = FIELD("Vat Reporting Date");
                    DataItemTableView = SORTING("Document No.", "Vat Reporting Date") WHERE("Gen. Posting Type" = CONST(Sale));

                    trigger OnAfterGetRecord()
                    begin
                        GLAccount.Get("G/L Account No.");
                        if GLAccount."Ignore in 347 Report" then begin
                            TempInvoices."Additional-Currency Amount" += (Amount + "VAT Amount");
                            TempInvoices.Modify();
                        end;
                    end;
                }

                trigger OnAfterGetRecord()
                var
                    rCabFac: Record "QHT Cabecera de factura";
                    wNIF: Code[20];
                begin

                    wCt3 += 1;
                    if wMovCliDir <> 0 then                                          //+001
                        Ventana.Update(6, Round((wCt3 / wMovCliDir) * 10000, 1));

                    rCabFac.ChangeCompany(wEmpresaGestion);
                    if StrLen(MovClieDir."Document No.") > MaxStrLen(rCabFac.Factura) then
                        CurrReport.Skip();

                    // Si no existe la factura no podemos seguir
                    //
                    //rCabFac.SETRANGE(Factura, MovConDir."Document No."); //-801
                    rCabFac.SetRange(Factura, "Document No."); //+801
                    // PLB 23/02/2007
                    //+010

                    if not rCabFac.Find('-') then
                        CurrReport.Skip();

                    if not IsCountryCodeInSpainOrOutsideEU(rCabFac.pais) then
                        CurrReport.Skip();
                    // Si la factura no tiene NIF no se acumula
                    //
                    //+007
                    //IF DELCHR(rCabFac."C.I.F./N.I.F.",'=',' ,.-/*') = '' THEN
                    rCabFac."C.I.F./N.I.F." := DelChr(rCabFac."C.I.F./N.I.F.", '=', ' ,.-/*');
                    if rCabFac."C.I.F./N.I.F." = '' then
                        CurrReport.Skip();
                    //-007


                    MovClieDir.CalcFields("Original Amt. (LCY)");

                    // PLB 29/03/2007
                    if TempCust.RecordLevelLocking then
                        wNIF := CopyStr('_' + rCabFac."C.I.F./N.I.F.", 1, MaxStrLen(wNIF))
                    else
                        wNIF := CopyStr(rCabFac."C.I.F./N.I.F.", 1, MaxStrLen(wNIF));

                    if not TempCust.Get(wNIF) then begin
                        rCARDEX.ChangeCompany(wEmpresaGestion);
                        if rCARDEX.Get(rCabFac.Pais, rCabFac."C.I.F./N.I.F.") then begin
                            TempCust."No." := wNIF;
                            TempCust.Name := CopyStr(rCARDEX."Nombre / Razon Social" + ' ' + rCARDEX."Apellido 1" + ' ' + rCARDEX."Apellido 2",
                               1, MaxStrLen(TempCust.Name));
                            TempCust."Name 2" := Text017;
                            TempCust."Country/Region Code" := rCARDEX."Pais residencia";
                            TempCust."Post Code" := rCARDEX."Cod. Postal";
                            TempCust."VAT Registration No." := CopyStr(rCARDEX.Documento, 1, MaxStrLen(TempCust."VAT Registration No."));
                            TempCust.Blocked := TempCust.Blocked::All;
                            TempCust.Insert();
                        end
                        else begin
                            TempCust."No." := wNIF;
                            TempCust.Name := CopyStr(rCabFac."Nombre cliente", 1, MaxStrLen(TempCust.Name));
                            TempCust."Name 2" := Text017;
                            TempCust."Country/Region Code" := rCabFac.Pais;
                            TempCust."Post Code" := rCabFac."Cod. postal";
                            TempCust."VAT Registration No." := CopyStr(rCabFac."C.I.F./N.I.F.", 1, MaxStrLen(TempCust."VAT Registration No."));
                            TempCust.Blocked := TempCust.Blocked::All;
                            TempCust.Insert();
                        end;

                        Clear(TempInvoices);
                        TempInvoices."Account No." := wNIF;
                        TempInvoices.Amount := MovClieDir."Original Amt. (LCY)";
                        TempInvoices."Additional-Currency Amount" := 0;


                        ImporteTrimestre(TempInvoices, MovClieDir."Original Amt. (LCY)", MovClieDir."VAT Reporting Date"); //+010
                                                                                                                           //-1601
                        TempInvoices.Insert();
                    end
                    else begin
                        if (TempCust."Post Code" = '') and (rCabFac."Cod. postal" <> '') then begin
                            TempCust."Post Code" := rCabFac."Cod. postal";
                            TempCust.Modify();
                        end;
                        if not TempInvoices.Get(wNIF) then
                            Error(Text021 + Text022, wNIF);
                        TempInvoices.Amount += MovClieDir."Original Amt. (LCY)";

                        ImporteTrimestre(TempInvoices, MovClieDir."Original Amt. (LCY)", MovClieDir."VAT Reporting Date"); //+010
                                                                                                                           // -008

                        TempInvoices.Modify();
                    end;

                end;

                trigger OnPreDataItem()
                begin

                    MovClieDir.SetRange("Customer No.", TempCust2."No.");
                    MovClieDir.SetRange("Vat Reporting Date", FromDate, ToDate);
                    MovClieDir.SetRange("Document Type", MovClieDir."Document Type"::Invoice, MovClieDir."Document Type"::"Credit Memo");
                end;
            }

            trigger OnAfterGetRecord()
            begin

                if not wPrimero then begin
                    if TempCust2.Next() = 0 then
                        CurrReport.Break();
                end
                else
                    wPrimero := false;

                Ventana.Update(5, TempCust2."No.");

                IdentifyCashPaymentsNH(TempCust2."No.", true); //+004
            end;

            trigger OnPreDataItem()
            begin

                if not wIncluirDirectos or not TempCust2.Find('-') then
                    CurrReport.Break();

                wPrimero := true;
            end;
        }
        dataitem(Customer; Customer)
        {
            DataItemTableView = SORTING("VAT Registration No.");
            UseTemporary = true;
            dataitem("Cust. Ledger Entry"; "Cust. Ledger Entry")
            {
                CalcFields = Amount;
                DataItemLink = "Customer No." = FIELD("No."), "VAT Reporting Date" = FIELD("Date Filter");
                DataItemTableView = SORTING("Document Type", "Customer No.", "Global Dimension 1 Code", "Global Dimension 2 Code", "VAT Reporting Date", "Currency Code");
                dataitem(GLEntry1; "G/L Entry")
                {
                    DataItemLink = "Document No." = FIELD("Document No."), "VAT Reporting Date" = FIELD("VAT Reporting Date");
                    DataItemTableView = SORTING("Document No.", "VAT Reporting Date") WHERE("Gen. Posting Type" = CONST(Sale));
                    PrintOnlyIfDetail = true;

                    trigger OnAfterGetRecord()
                    begin
                        UpdateNotIn347Amount(GLEntry1, 1);
                    end;

                    trigger OnPreDataItem()
                    begin
                        if SIICollectionsInCash then
                            CurrReport.Break();
                    end;
                }

                trigger OnAfterGetRecord()
                var
                    VATEntry: Record "VAT Entry";
                begin
                    NoTaxVATFound := false;
                    FromJournal := false;

                    FilterVATEntry(VATEntry, "VAT Reporting Date", "Document Type", "Document No.", true);

                    if not VATEntry.FindFirst() then begin
                        case "Document Type" of
                            "Document Type"::Invoice:
                                CheckCustDocTypeInvoice("Cust. Ledger Entry", Customer);
                            "Document Type"::"Credit Memo":
                                CheckCustDocTypeCrMemo("Cust. Ledger Entry", Customer);
                        end;

                        if not NoTaxVATFound and not FromJournal then
                            CurrReport.Skip();
                    end;

                    if not UpdateSalesAmountsAndFlagsForCustomer(SalesAmt, CustomerMaxAmount, "Cust. Ledger Entry", VATEntry, AmountType::Sales) then
                        EmptyVATRegNo := true;
                end;

                trigger OnPostDataItem()
                var
                    wNIF: Code[20];
                    AmtSameVATRegNo: Decimal;
                    CashAmountToExport: Decimal;
                    YearText: Text[4];
                    CashAmtText: Text[15];
                    AmountText: Text[16];
                    OutText: Text[500];
                begin
                    if SIICollectionsInCash then
                        exit;

                    if UpperCase(Customer."VAT Registration No.") <> UpperCase(PrevVATRegNo) then begin
                        AmtSameVATRegNo := CheckSameVATRegNoCust();
                        if Customer."VAT Registration No." <> '' then begin
                            if Customer.RecordLevelLocking then
                                wNIF := CopyStr('_' + Customer."VAT Registration No.", 1, MaxStrLen(wNIF))
                            else
                                wNIF := CopyStr(Customer."VAT Registration No.", 1, MaxStrLen(wNIF));
                            TotalNotIn347Amt := TotalNotIn347Amt + NotIn347Amt;

                            SalesAmt := SalesAmt + NotIn347Amt + AmtSameVATRegNo;

                            // PLB 05/03/2004
                            // Puede que algunos clientes tengan facturas de directos y ficha de cliente
                            //
                            if TempInvoices.Get(wNIF) then begin
                                SalesAmt += TempInvoices.Amount + TempInvoices."Additional-Currency Amount";
                                TempInvoices.Delete();

                                if Abs(SalesAmt) >= MinAmount then
                                    if CountyCode = '  ' then
                                        if rCARDEX.Get(Customer."Country/Region Code", Customer."VAT Registration No.") then
                                            rCARDEX.TestField("Cod. Postal")
                                        else
                                            Error(Text018, Customer."VAT Registration No.");

                                // +008
                                RellenaArrayTrimestres(TempInvoices);  // +1799
                                                                       // -008

                            end;
                            // fin PLB			    
                            if Abs(SalesAmt) >= MinAmount then begin
                                if PostCode347 = '     ' then
                                    Error(MissingCustomerPostalCodeErr, Customer."No.");
                                Clear(OutText);
                                AmountText := FormatAmount(SalesAmt);
                                if CustomerCashBuffer.Get(Customer."VAT Registration No.", FiscalYear) then
                                    CashAmountToExport := CustomerCashBuffer."Operation Amount";
                                if CashAmountToExport >= MinAmountCash then begin
                                    CashAmtText := AmtEuro(CashAmountToExport);
                                    YearText := FiscalYear;
                                end else begin
                                    CashAmtText := PadStr('', 15, '0');
                                    YearText := PadStr('', 4, '0');
                                end;

                                OutText :=
                                  '2347' + FiscalYear + UpperCase(VATRegNo) + UpperCase(VATRegNo347) + PadStr('', 9, ' ') +
                                  UpperCase(Name347) + LetterDTxt +
                                  CountyCode + CVCountryCode + PadStr('', 1, ' ') + LetterBTxt + AmountText + PadStr('', 2, ' ') +
                                  CashAmtText + FormatAmount(0) + YearText + GetSalesQuarterAmountsText() + PadStr('', 17, ' ') +
                                  GetVATCashRegimeText(AnnualAmountVATCashRegime, OperationsCashAccountingCriteria, ReverseChargeOperation);
                                OutText := PadStr(OutText, 500, ' ');

                                AppendLine(OutText);

                                TotalAmount := TotalAmount + SalesAmt;
                                Acum := Acum + 1;
                            end;
                            NotIn347Amt := 0;

                            CustomerCashBuffer.Reset();
                            CustomerCashBuffer.SetRange("VAT Registration No.", Customer."VAT Registration No.");
                            CustomerCashBuffer.SetFilter("Operation Year", '<>%1', FiscalYear);
                            if CustomerCashBuffer.FindSet() then
                                repeat
                                    CashAmountToExport := CustomerCashBuffer."Operation Amount";
                                    if CashAmountToExport >= MinAmountCash then begin
                                        CashAmtText := AmtEuro(CashAmountToExport);
                                        YearText := CustomerCashBuffer."Operation Year";
                                        AmountText := FormatAmount(0);
                                        OutText :=
                                          '2347' + FiscalYear + UpperCase(VATRegNo) + UpperCase(VATRegNo347) + PadStr('', 9, ' ') + UpperCase(Name347) +
                                          LetterDTxt + CountyCode + CVCountryCode + PadStr('', 1, ' ') + LetterBTxt + AmountText + PadStr('', 2, ' ') +
                                          CashAmtText + FormatAmount(0) + YearText + GetQuarterZeroAmountsText() + PadStr('', 17, ' ') +
                                          GetVATCashRegimeText(AnnualAmountVATCashRegime, OperationsCashAccountingCriteria, ReverseChargeOperation);
                                        OutText := PadStr(OutText, 500, ' ');
                                        AppendLine(OutText);
                                        // Increase RecordCount
                                        Acum := Acum + 1;
                                    end;
                                until CustomerCashBuffer.Next() = 0;
                        end;

                        PrevVATRegNo := Customer."VAT Registration No.";
                    end;
                end;

                trigger OnPreDataItem()
                var
                    TempCustLedgerEntry: Record "Cust. Ledger Entry" temporary;
                begin
                    if SIICollectionsInCash then
                        CurrReport.Break();
                    if TempCust2.Get(Customer."No.") then //+011
                        CurrReport.Break();

                    //SetCurrentKey("Customer No.", "Vat Reporting Date");
                    //SetRange("Vat Reporting Date", FromDate, ToDate);

                    "Cust. Ledger Entry".SetRange("Document Type", "Cust. Ledger Entry"."Document Type"::Invoice, "Document Type"::"Credit Memo");
                    SetRange("Date Filter", FromDate, ToDate);

                    ReverseChargeOperation := '';
                    OperationsCashAccountingCriteria := '';
                    AnnualAmountVATCashRegime := 0;

                    GetPaidVATCashSalesInvoicesOutOfPeriod(TempCustLedgerEntry, Customer."No.");
                    ProcessPaidVATCashSalesInvoicesOutOfPeriod(TempCustLedgerEntry);
                end;
            }

            trigger OnAfterGetRecord()
            var
                SIIDocUploadState: Record "SII Doc. Upload State";
                CashBufferFound: Boolean;
            begin
                // Añadido por SGB
                ct1 := ct1 + 1;
                Ventana.Update(1, "No.");

                if ct2 <> 0 then                                //+001
                    Ventana.Update(2, Round((ct1 / ct2) * 10000, 1));
                // fin SGB

                SalesAmt := 0;

                if SIICollectionsInCash then begin
                    if "VAT Registration No." = '' then
                        CashBufferFound := CustomerCashBuffer.Get("No.", FiscalYear)
                    else
                        CashBufferFound := CustomerCashBuffer.Get("VAT Registration No.", FiscalYear);
                    if CashBufferFound then
                        if CustomerCashBuffer."Operation Amount" > MinAmountCash then
                            if SIIDocUploadState.CreateNewCollectionsInCashRequest("No.", FromDate, CustomerCashBuffer."Operation Amount") then
                                CollectionsGenerated += 1;
                    exit;
                end;

                VATRegNo347 := CopyStr(DelChr("VAT Registration No.", '=', '.-/'), 1, 9);
                IF ("Country/Region Code" = ESCountryCode) OR ("Country/Region Code" = 'ES') THEN //2200+
                                                                                                  //if "Country/Region Code" = ESCountryCode then
                    while StrLen(VATRegNo347) < 9 do
                        VATRegNo347 := '0' + VATRegNo347
                else
                    VATRegNo347 := '         ';
                Name347 := PadStr(FormatTextName(Name, false), 40, ' ');

                GetCountyCode(true);
                NotIn347Amt := 0;
                CustomerMaxAmount := 0;
                ClearQuarterAmounts();

                // +004
                IdentifyCashPaymentsBank(Customer."No.", Customer."VAT Registration No.");
                IdentifyCashPaymentsNH(Customer."No.", false);
                // -004		
            end;

            trigger OnPreDataItem()
            var
                Cust: Record Customer;
                CustomerLoc: Record Customer;
                VATRegistrationNo: Text[20];
            begin
                TempCust.reset();
                if TempCust.FindSet() then
                    repeat
                        Customer.TransferFields(TempCust);
                        Customer.Insert();
                    until TempCust.next() = 0;

                Cust.Reset();
                if Cust.FindSet() then
                    repeat
                        Customer.TransferFields(Cust);
                        Customer.insert();
                    until Cust.next() = 0;

                NoOfAccounts := RetrieveGLAccount(FilterString);

                //+005
                ct1 := 0;
                ct2 := Count;
                //-005

                Clear(SalesAmt);
                SetRange("Date Filter", FromDate, ToDate);
                SetFilter("Country/Region Code", '<> %1', '');
                PrevVATRegNo := Customer."VAT Registration No.";
                if FilterString <> '' then begin
                    CustomerCashBuffer.Reset();
                    CustomerCashBuffer.DeleteAll();
                    CustomerLoc.Reset();
                    CustomerLoc.SetCurrentKey("VAT Registration No.");
                    if not SIICollectionsInCash then
                        CustomerLoc.SetFilter("VAT Registration No.", '<>%1', '');
                    if CustomerLoc.FindSet() then
                        repeat
                            if CustomerLoc."VAT Registration No." = '' then
                                VATRegistrationNo := CustomerLoc."No."
                            else
                                VATRegistrationNo := CustomerLoc."VAT Registration No.";
                            IdentifyCashPayments(CustomerLoc."No.", VATRegistrationNo);
                        until CustomerLoc.Next() = 0;
                end;
            end;
        }
        dataitem(Vendor; Vendor)
        {
            DataItemTableView = SORTING("VAT Registration No.");
            dataitem("Vendor Ledger Entry"; "Vendor Ledger Entry")
            {
                CalcFields = Amount;
                DataItemLink = "Vendor No." = FIELD("No."), "VAT Reporting Date" = FIELD("Date Filter");
                DataItemTableView = SORTING("Document Type", "Vendor No.", "Global Dimension 1 Code", "Global Dimension 2 Code", "VAT Reporting Date", "Currency Code");
                dataitem(GLEntry2; "G/L Entry")
                {
                    DataItemLink = "Document No." = FIELD("Document No."), "VAT Reporting Date" = FIELD("VAT Reporting Date");
                    DataItemTableView = SORTING("Document No.", "VAT Reporting Date") WHERE("Gen. Posting Type" = CONST(Purchase));
                    PrintOnlyIfDetail = true;

                    trigger OnAfterGetRecord()
                    begin
                        UpdateNotIn347Amount(GLEntry2, OperationTypeIdx);
                    end;
                }

                trigger OnAfterGetRecord()
                var
                    VATEntry: Record "VAT Entry";
                begin
                    NoTaxVATFound := false;
                    FromJournal := false;
                    OperationTypeIdx := 1;

                    FilterVATEntry(VATEntry, "VAT Reporting Date", "Document Type", "Document No.", false);
                    if not VATEntry.FindFirst() then begin
                        case "Document Type" of
                            "Document Type"::Invoice:
                                CheckVendDocTypeInvoice("Vendor Ledger Entry", Vendor);
                            "Document Type"::"Credit Memo":
                                CheckVendDocTypeCrMemo("Vendor Ledger Entry", Vendor);
                        end;

                        if not NoTaxVATFound and not FromJournal then
                            CurrReport.Skip();
                    end;

                    if not UpdatePurchAmountsAndFlagsForVendor(
                         PurchasesAmt, ISPPurchasesAmt, VendorMaxAmount, "Vendor Ledger Entry", VATEntry, AmountType::Purchase)
                    then
                        EmptyVATRegNo := true;

                    OperationTypeIdx := GetOperationTypeIdx(VATEntry);
                end;

                trigger OnPostDataItem()
                var
                    AmtSameVATRegNo: Decimal;
                    ISPAmtSameVATRegNo: Decimal;
                    AmountText: Text[16];
                    OutText: Text[500];
                begin
                    if UpperCase(Vendor."VAT Registration No.") <> UpperCase(PrevVATRegNo) then begin
                        CheckSameVATRegNoVend(AmtSameVATRegNo, ISPAmtSameVATRegNo);
                        if Vendor."VAT Registration No." <> '' then begin
                            TotalNotIn347Amt := TotalNotIn347Amt + NotIn347Amt + ISPNotIn347Amt + AmtSameVATRegNo + ISPAmtSameVATRegNo;
                            PurchasesAmt += -NotIn347Amt + AmtSameVATRegNo;
                            ISPPurchasesAmt += -ISPNotIn347Amt + ISPAmtSameVATRegNo;

                            if Abs(PurchasesAmt + ISPPurchasesAmt) >= MinAmount then begin
                                //IF PostCode347 = '     ' THEN //-010
                                if CountyCode = '  ' then //+010
                                    Error(MissingVendorPostalCodeErr, Vendor."No.");

                                if PurchasesAmt <> 0 then begin
                                    Clear(OutText);
                                    AmountText := FormatAmount(PurchasesAmt);
                                    OutText :=
                                      '2347' + FiscalYear + UpperCase(VATRegNo) + UpperCase(VATRegNo347) + PadStr('', 9, ' ') +
                                      UpperCase(Name347) + LetterDTxt + CountyCode + CVCountryCode + PadStr('', 1, ' ') + LetterATxt +
                                      AmountText + PadStr('', 2, ' ') + PadStr('', 15, '0') + ' ' + PadStr('', 15, '0') + PadStr('', 4, '0') +
                                      GetPurchQuarterAmountsText(1) + PadStr('', 17, ' ') +
                                      GetVATCashRegimeText(AnnualAmountVATCashRegime, OperationsCashAccountingCriteria, '');
                                    OutText := PadStr(OutText, 500, ' ');

                                    AppendLine(OutText);
                                    Acum := Acum + 1;
                                end;

                                if ISPPurchasesAmt <> 0 then begin
                                    Clear(OutText);
                                    AmountText := FormatAmount(ISPPurchasesAmt);
                                    OutText :=
                                      '2347' + FiscalYear + UpperCase(VATRegNo) + UpperCase(VATRegNo347) + PadStr('', 9, ' ') +
                                      UpperCase(Name347) + LetterDTxt + CountyCode + CVCountryCode + PadStr('', 1, ' ') + LetterATxt +
                                      AmountText + PadStr('', 2, ' ') + PadStr('', 15, '0') + ' ' + PadStr('', 15, '0') + PadStr('', 4, '0') +
                                      GetPurchQuarterAmountsText(2) + PadStr('', 17, ' ') +
                                      GetVATCashRegimeText(0, '', ReverseChargeOperation);
                                    OutText := PadStr(OutText, 500, ' ');

                                    AppendLine(OutText);
                                    Acum := Acum + 1;
                                end;

                                TotalAmount := TotalAmount + PurchasesAmt + ISPPurchasesAmt;
                            end;
                            NotIn347Amt := 0;
                        end;

                        PrevVATRegNo := Vendor."VAT Registration No.";
                    end;
                end;

                trigger OnPreDataItem()
                var
                    TempVendorLedgerEntry: Record "Vendor Ledger Entry" temporary;
                begin


                    //SetCurrentKey("Vendor No.", "Vat Reporting Date");
                    //SetRange("Vat Reporting Date", FromDate, ToDate);

                    "Vendor Ledger Entry".SetRange("Document Type", "Vendor Ledger Entry"."Document Type"::Invoice, "Document Type"::"Credit Memo");
                    SetRange("Date Filter", FromDate, ToDate);
                    ReverseChargeOperation := '';
                    OperationsCashAccountingCriteria := '';
                    AnnualAmountVATCashRegime := 0;

                    GetPaidVATCashPurchInvoicesOutOfPeriod(TempVendorLedgerEntry, Vendor."No.");
                    ProcessPaidVATCashPurchInvoicesOutOfPeriod(TempVendorLedgerEntry);
                end;
            }

            trigger OnAfterGetRecord()
            begin
                PurchasesAmt := 0;
                ISPPurchasesAmt := 0;

                VATRegNo347 := CopyStr(DelChr("VAT Registration No.", '=', '.-/'), 1, 9);
                IF ("Country/Region Code" = ESCountryCode) OR ("Country/Region Code" = 'ES') THEN //2200+
                                                                                                  //if "Country/Region Code" = ESCountryCode then
                    while StrLen(VATRegNo347) < 9 do
                        VATRegNo347 := '0' + VATRegNo347
                else
                    VATRegNo347 := '         ';
                Name347 := PadStr(FormatTextName(Name, false), 40, ' ');

                GetCountyCode(false);
                NotIn347Amt := 0;
                ISPNotIn347Amt := 0;
                VendorMaxAmount := 0;
                ClearQuarterAmounts();

                //+005
                ct1 := ct1 + 1;
                Ventana.Update(3, "No.");

                if ct2 <> 0 then
                    Ventana.Update(4, Round((ct1 / ct2) * 10000, 1));
                //-005		
            end;

            trigger OnPreDataItem()
            begin
                if SIICollectionsInCash then
                    CurrReport.Break();

                SetRange("Date Filter", FromDate, ToDate);
                SetFilter("Country/Region Code", '<> %1', '');
                PrevVATRegNo := Vendor."VAT Registration No.";

                // MIG FH6.0
                // PLB 23/02/2007
                ct1 := 0;
                ct2 := Count;
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(FiscalYear; FiscalYear)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Fiscal Year';
                        Numeric = true;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the year of the reporting period. It must be 4 digits without spaces or special characters.';

                        trigger OnValidate()
                        begin
                            if StrLen(FiscalYear) <> MaxStrLen(FiscalYear) then
                                Error(WrongFiscalYearErr, MaxStrLen(FiscalYear));
                        end;
                    }
                    field(MinAmount; MinAmount)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Min. Amount';
                        ShowMandatory = true;
                        ToolTip = 'Specifies the minimum amount for the operations declaration.';
                        Visible = NOT SIICollectionsInCash;
                    }
                    field(MinAmountInCash; MinAmountCash)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Min. Amount in Cash';
                        ToolTip = 'Specifies the minimum amount in payments in cash received from customers for the operations declaration.';
                    }
                    field(GLAccForPaymentsInCash; ColumnGLAcc)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'GL Acc. for Payments in Cash';
                        Editable = false;
                        ToolTip = 'Specifies one or more on general ledger accounts for cash payments. When you export the data to a declaration file, the Amount Received in Cash field in the file contains the accumulated value for the selected general ledger accounts. If you do not select any general ledger accounts, then type 2 lines for payments in cash will not be created.';

                        trigger OnAssistEdit()
                        var
                            GLAccSelectionBuf: Record "G/L Account Buffer";
                        begin
                            GLAccSelectionBuf.SetGLAccSelectionMultiple(ColumnGLAcc, FilterString);
                        end;
                    }
                    field(ContactName; ContactName)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Contact Name';
                        ShowMandatory = true;
                        ToolTip = 'Specifies the name of the person making the declaration.';
                        Visible = NOT SIICollectionsInCash;
                    }
                    field(TelephoneNumber; ContactTelephone)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Telephone Number';
                        Numeric = true;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the phone number as 9 digits without spaces or special characters.';
                        Visible = NOT SIICollectionsInCash;

                        trigger OnValidate()
                        begin
                            if (StrLen(ContactTelephone) <> MaxStrLen(ContactTelephone)) or (StrPos(ContactTelephone, ' ') <> 0) then
                                Error(WrongTelephoneNoErr, MaxStrLen(ContactTelephone));
                        end;
                    }
                    field(DeclarationNumber; DeclarationNum)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Declaration Number';
                        Numeric = true;
                        ShowMandatory = true;
                        ToolTip = 'Specifies a number to identify the operations declaration.';
                        Visible = NOT SIICollectionsInCash;
                    }
                    field(CountryRegionCode; CountryCode)
                    {
                        ApplicationArea = All;
                        Caption = 'Country/Region Code';
                        ObsoleteReason = 'Old field';
                        ObsoleteState = Pending;
                        ObsoleteTag = '24.0.6.0';
                        TableRelation = "Country/Region";
                        ToolTip = 'Specifies the value of the Country/Region Code field.';
                        Visible = false;
                    }
                    field(CountryRegCode; ESCountryCode)
                    {
                        ApplicationArea = All;
                        Caption = 'Country/Region Code';
                        TableRelation = "Country/Region";
                        ToolTip = 'Specifies the value of the Country/Region Code field.';
                        Visible = false;

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            Country: Record "Country/Region";
                        begin
                            if PAGE.RunModal(10, Country) = ACTION::LookupOK then
                                ESCountryCode := Country.Code;
                        end;
                    }
                    field(DeclarationMediaType; DeclarationMediaType)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Declaration Media Type';
                        ToolTip = 'Specifies the media type for the declaration. To submit the declaration electronically, select Telematic. To submit the declaration on a CD-ROM, select Physical support.';
                        Visible = NOT SIICollectionsInCash;
                    }
                    field(ReplacementDeclaration; ReplacementDeclaration)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Replacement Declaration';
                        ToolTip = 'Specifies if this is a replacement of a previously sent declaration.';
                        Visible = NOT SIICollectionsInCash;

                        trigger OnValidate()
                        begin
                            ReplacementDeclarationOnPush();
                        end;
                    }
                    field(PreDeclarationNum; PreDeclarationNum)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Previous Declaration Number';
                        Editable = PreDeclarationNumEditable;
                        Numeric = true;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the number as 13 digits without spaces or special characters.';
                        Visible = NOT SIICollectionsInCash;

                        trigger OnValidate()
                        begin
                            if (StrLen(PreDeclarationNum) <> MaxStrLen(PreDeclarationNum)) or (StrPos(PreDeclarationNum, ' ') <> 0) then
                                Error(WrongPreviousDeclarationNoErr, MaxStrLen(PreDeclarationNum));
                        end;
                    }
                    field(wIncluirDirectos; wIncluirDirectos)
                    {
                        ApplicationArea = All;
                        Caption = 'Incluir directos';
                        ToolTip = 'Specifies the value of the Incluir directos field.';
                    }
                    field(ListDirectClientes; ListDirectClientes)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        showCaption = false;
                        Tooltip = 'Specifies the Direct Customers, is included the Direct customer set up in FO Setup';
                        trigger OnDrillDown()
                        var
                            PageDirectClientes: page "QHT 347 Direct Customers";
                        begin
                            if not wIncluirDirectos then
                                exit;

                            Clear(PageDirectClientes);
                            PageDirectClientes.RUNMODAL();
                        end;
                    }
                    field(wEmpresaGestion; wEmpresaGestion)
                    {
                        ApplicationArea = All;
                        Caption = 'Empresa de Gestión';
                        TableRelation = Company;
                        ToolTip = 'Si desea incluir los directos en el 347 debe especifiar la empresa de gestion (se precisa que las facturas de hotel estén en la empresa de gestión y tengan NIF asignado y se recomienda tener el cárdex activado)';
                    }
                    field(wDatosObligatorios; wDatosObligatorios)
                    {
                        ApplicationArea = All;
                        Caption = 'Ctrol. Datos Obligatorios';
                        ToolTip = 'Specifies the value of the Ctrol. Datos Obligatorios field.';
                    }
                }
            }
        }



        trigger OnInit()
        begin
            PreDeclarationNumEditable := true;
            if FiscalYear = '' then
                FiscalYear := Format(Date2DMY(WorkDate(), 3) - 1);
            DeclarationNum := '3470000000000';
        end;

        trigger OnOpenPage()
        begin
            if MinAmount = 0 then
                MinAmount := 3005.06;
            if MinAmountCash = 0 then
                MinAmountCash := 6000;
            if ReplacementDeclaration then
                PreDeclarationNumEditable := true
            else
                PreDeclarationNumEditable := false;
        end;
    }

    labels
    {
    }

    trigger OnInitReport()
    begin
        CompanyInfo.Get();
        if CopyStr(CompanyInfo."VAT Registration No.", 1, StrLen(CompanyInfo."Country/Region Code")) =
           CompanyInfo."Country/Region Code"
        then
            CompanyInfo."VAT Registration No." :=
              CopyStr(CompanyInfo."VAT Registration No.", StrLen(CompanyInfo."Country/Region Code") + 1,
                MaxStrLen(CompanyInfo."VAT Registration No."));
        VATRegNo := CopyStr(DelChr(CompanyInfo."VAT Registration No.", '=', '.-/'), 1, 9);
        while StrLen(VATRegNo) < 9 do
            VATRegNo := '0' + VATRegNo;
    end;

    trigger OnPostReport()
    var
        SIIJobManagement: Codeunit "SII Job Management";
        JobType: Option HandlePending,HandleCommError,InitialUpload;
    begin
        if SIICollectionsInCash then begin
            Message(CollectionsGeneratedMsg, CollectionsGenerated);
            SIIJobManagement.RenewJobQueueEntry(JobType::HandlePending);
            exit;
        end;


        if TextList.Count <> 0 then begin
            if EmptyVATRegNo then begin
                if Confirm(StrSubstNo(DoYouWantToContinueQst, Customer.TableCaption(), Vendor.TableCaption(),
                       Customer.FieldCaption("VAT Registration No.")), false)
                then begin
                    CreateFileHeader();
                    WriteLinesToFile();

                    TempBlob.CreateInStream(inStr, TextEncoding::Windows);

                    DownloadFromStream(InStr, '', '', '', ToFile);
                end
                else
                    Message(ProcessAbortedMsg);
            end else begin
                CreateFileHeader();
                WriteLinesToFile();

                TempBlob.CreateInStream(inStr, TextEncoding::Windows);

                DownloadFromStream(InStr, '', '', '', ToFile);
            end;
        end
        else
            Message(NothingToExportMsg);

        FeatureTelemetry.LogUsage('1000HV5', ESReport347Tok, 'ES-QHT 347 Reports Created');
    end;

    trigger OnPreReport()
    var
        SIISetup: Record "SII Setup";
        FileMgt: Codeunit "File Management";
    begin
        if FiscalYear = '' then
            Error(MissingFiscalYearErr);
        if FilterString = '' then
            GetFilterStringFromColumnGLAcc();
        if CheckExcludedGLAccount() and (FilterString <> '') then
            Error(AccountsWillBeIgnoredErr);
        if not SIICollectionsInCash then begin
            if MinAmount = 0 then
                Error(MissingMinAmountErr);
            if ContactName = '' then
                Error(MissingContactNameErr);
            if ContactTelephone = '' then
                Error(MissingTelephoneNoErr);
            if DeclarationNum = '' then
                Error(MissingDeclarationNoErr);
            if ReplacementDeclaration and (PreDeclarationNum = '') then
                Error(MissingPrevDeclarationNoErr);
        end else
            if not SIISetup.IsEnabled() then
                Error(SIINotEnabledToSendCollInCashErr);

        tempblob.createoutstream(Outstr, TextEncoding::Windows);
        ToFile := StrSubstNo('MOD347 Año %1.txt', FiscalYear);

        EmptyVATRegNo := false;
        CreateCountryRegionFilter();

        if ESCountryCode = '' then
            ESCountryCode := 'ESP';
    end;

    var
        CompanyInfo: Record "Company Information";
        TempCust: Record Customer temporary;
        TempCust2: Record Customer temporary;
        CustomerCashBuffer: Record "Customer Cash Buffer" temporary;
        GLAccount: Record "G/L Account";
        TempInvoices: Record "Inc. Stmt. Clos. Buffer" temporary;
        rCARDEX: Record "QHT Cardex";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        FileManagement: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        EmptyVATRegNo: Boolean;
        FromJournal: Boolean;
        IsSilentMode: Boolean;
        NoTaxVATFound: Boolean;
        PreDeclarationNumEditable: Boolean;
        ReplacementDeclaration: Boolean;
        SIICollectionsInCash: Boolean;
        wDatosObligatorios: Boolean;
        wIncluirDirectos: Boolean;
        wPrimero: Boolean;
        OperationsCashAccountingCriteria: Code[1];
        ReverseChargeOperation: Code[1];
        FiscalYear: Code[4];
        CountryCode: Code[10];
        ESCountryCode: Code[10];
        FromDate: Date;
        ToDate: Date;
        wFechaFactura: Date;
        AnnualAmountVATCashRegime: Decimal;
        CustomerMaxAmount: Decimal;
        ISPNotIn347Amt: Decimal;
        ISPPurchasesAmt: Decimal;
        MinAmount: Decimal;
        MinAmountCash: Decimal;
        NotIn347Amt: Decimal;
        PurchasesAmt: Decimal;
        QuarterNotIn347Amt: array[2, 4] of Decimal;
        QuarterPurchAmt: array[2, 4] of Decimal;
        QuarterSalesAmt: array[4] of Decimal;
        QuarterSameVATRegNoAmt: array[2, 4] of Decimal;
        SalesAmt: Decimal;
        TotalAmount: Decimal;
        TotalNotIn347Amt: Decimal;
        VendorMaxAmount: Decimal;
        Ventana: Dialog;
        Instr: InStream;
        Acum: Integer;
        CollectionsGenerated: Integer;
        ct1: Integer;
        ct2: Integer;
        i: Integer;
        NoOfAccounts: Integer;
        NumFiscalYear: Integer;
        OperationTypeIdx: Integer;
        wCt3: Integer;
        wMovCliDir: Integer;
        AccountsWillBeIgnoredErr: Label 'At least one of the G/L Accounts selected for payments in cash is set up to be ignored in 347 report.';
        CollectionsGeneratedMsg: Label '%1 collection(-s) in cash were created.', Comment = '%1 = 3 collection(-s) in cash were created';
        DoYouWantToContinueQst: Label 'At least one %1/%2 does not have any value in the %3 field. \Only customers or vendors with a value for %3 will be included in the file. \\Do you still want to create the 347 Declaration file?', Comment = '%1=Customer,%2=Vendor,%3=VAT Registration No.';
        ESReport347Tok: Label 'ES Create Report 347', Locked = true;
        FileFilterTxt: Label 'Txt Files|*.txt|All Files|*.*''', Comment = 'Please translate only "Txt Files" and "All Files". The rest of the characters should remain unchanged.';
        FileNameTxt: Label 'Declaration 347 year %1.txt', Comment = '%1=declaration year';
        GenerateCollectionsInCashLbl: Label 'Generate collections in cash';
        IncorrectFiscalYearErr: Label 'Incorrect Fiscal Year.';
        IntegerTypeTxt: Label '<Integer>', Locked = true;
        Iso88591Lbl: Label 'ISO-8859-1';
        LetterATxt: Label 'A', Locked = true;
        LetterBTxt: Label 'B', Locked = true;
        LetterDTxt: Label 'D', Locked = true;
        ListDirectClientes: Label 'List of Direct Customers';
        MissingContactNameErr: Label 'Contact Name must be entered.';
        MissingCustomerPostalCodeErr: Label 'Postal Code is missing on customer card %1.', Comment = '%1=Customer No.';
        MissingDeclarationNoErr: Label 'Declaration Number must be entered.';
        MissingFiscalYearErr: Label 'Fiscal Year must be entered.';
        MissingMinAmountErr: Label 'Minimum Amount must be entered.';
        MissingPrevDeclarationNoErr: Label 'Please specify the Previous Declaration No. if this is a replacement declaration.';
        MissingTelephoneNoErr: Label 'Telephone Number must be entered.';
        MissingVendorPostalCodeErr: Label 'Postal Code is missing on vendor card %1.', Comment = '%1=Vendor No.';
        NothingToExportMsg: Label 'No records were found to be included in the declaration. The process has been aborted. No file will be created.';
        ProcessAbortedMsg: Label 'The process has been aborted. No file will be generated.';
        SIINotEnabledToSendCollInCashErr: Label 'The SII setup is not enabled to send collections in cash. Specify end points in the SII Setup window and import the certificate.';
        Text000: Label 'Running\';
        Text002: Label 'Customers      #1######## @2@@@@@@@@@@@@@@@@@@@@@@@@@@@\';
        Text003: Label 'Suppliers   #3######## @4@@@@@@@@@@@@@@@@@@@@@@@@@@@';
        Text017: Label 'BLOQUEADO POR PROCESO 347';
        Text018: Label 'Falta especificar C.P. en alguna factura hotel del cliente con CIF %1';
        Text019: Label 'Clientes dir. #5###### @6@@@@@@\';
        Text020: Label 'Debe especificar Empresa gestión si desea incluir los directos.';
        Text021: Label 'Existe un cliente con Codigo %1 y existe, al menos, una factura de directos que tiene el NIF %1. ';
        Text022: Label 'Si se activa la opción de Incluir directos no puede haber ninguna ficha de clientes';
        Text1100023: Label '347 Declaration has been exported successfully under %1.';
        Text1100026: Label 'Txt Files|*.txt|All Files|*.*''';
        Utf8Lbl: Label 'Utf-8';
        WrongFiscalYearErr: Label 'Fiscal Year must be %1 digits without spaces or digital characters.', Comment = '%1=number of digits';
        WrongPreviousDeclarationNoErr: Label 'Previous Declaration Number must be %1 digits without spaces or special characters.', Comment = '%1=number of digits';
        WrongTelephoneNoErr: Label 'Telephone Number must be %1 digits without spaces or special characters.', Comment = '%1=number of digits';
        TextList: List of [Text];
        AmountType: Option Sales,Purchase,SameVATNo,NotIn347Report;
        DeclarationMediaType: Option Telematic,"CD-R";
        OutStr: OutStream;
        CountryRegionFilter: Text;
        ToTestFileName: Text;
        DeclrationMT: Text[1];
        ReplacementDecText: Text[1];
        CVCountryCode: Text[2];
        CountyCode: Text[5];
        PostCode347: Text[5];
        ContactTelephone: Text[9];
        VATRegNo: Text[9];
        VATRegNo347: Text[9];
        DeclarationNum: Text[13];
        PreDeclarationNum: Text[13];
        FilterArray: array[50] of Text[30];
        PrevVATRegNo: Text[30];
        wCIF: Text[30];
        wEmpresaGestion: Text[30];
        ContactName: Text[40];
        Name347: Text[100];
        ColumnGLAcc: Text[250];
        FilterString: Text[250];
        FileName: Text[1024];
        ToFile: Text[1024];


    procedure StatementNo(FullText: Text[30]) NumberR: Text[5]
    var
        Found: Boolean;
        IsDigit: Boolean;
        i: Integer;
        Position: Integer;
        Character: Text[1];
    begin
        Character := '';
        Position := 0;
        Found := false;
        NumberR := '';

        repeat
            Position := Position + 1;
            Character := CopyStr(FullText, Position, 1);
            Found := Character in ['0' .. '9'];
        until Found or (Position >= StrLen(FullText));

        if not Found then
            exit(NumberR);

        i := 1;
        IsDigit := false;
        repeat
            IsDigit := CopyStr(FullText, Position, 1) in ['0' .. '9'];
            if IsDigit then begin
                NumberR := NumberR + CopyStr(FullText, Position, 1);
                FullText := DelStr(FullText, Position, 1);
                i := i + 1;
            end;
        until (i > 5) or not IsDigit;

        exit(NumberR);
    end;


    procedure AmtEuro(Amount: Decimal): Text[15]
    var
        AmtText: Text[15];
    begin
        Amount := Amount * 100;
        AmtText := ConvertStr(Format(Amount), ' ', '0');
        AmtText := DelChr(AmtText, '=', '.,');

        while StrLen(AmtText) < 15 do
            AmtText := '0' + AmtText;
        exit(AmtText);
    end;

    local procedure FormatAmount(Amount: Decimal): Text[16]
    begin
        if Amount < 0 then
            exit('N' + AmtEuro(-Amount));

        exit(' ' + AmtEuro(Amount));
    end;

    procedure CreateFileHeader()
    var
        AmountText: Text[16];
        OutText: Text[500];
    begin
        Clear(OutText);

        OutText :=
          '1347' + FiscalYear + VATRegNo +
          PadStr(FormatTextName(CompanyInfo.Name), 40, ' ');

        if DeclarationMediaType = DeclarationMediaType::Telematic then
            DeclrationMT := 'T'
        else
            if DeclarationMediaType = DeclarationMediaType::"CD-R" then
                DeclrationMT := 'C';

        if ReplacementDeclaration then
            ReplacementDecText := 'S'
        else begin
            ReplacementDecText := ' ';
            PreDeclarationNum := '0000000000000';
        end;

        OutText := OutText + DeclrationMT;
        OutText := OutText + ContactTelephone;
        OutText := OutText + PadStr(FormatTextName(ContactName), 40, ' ');

        OutText := OutText + PadStr(DeclarationNum, 13, '0');

        AmountText := FormatAmount(TotalAmount);

        OutText :=
          OutText + PadStr('', 1, ' ') + ReplacementDecText + PreDeclarationNum +
          ConvertStr(Format(Acum, 9, IntegerTypeTxt), ' ', '0') + AmountText +
          PadStr('', 9, '0') + ' ' + PadStr('', 15, '0') + PadStr('', 315, ' ');

        InsertFirstLine(OutText);
    end;

    local procedure WriteLinesToFile()
    var
        TextLine: Text;
        CRLF: Text[2];
        TextToWrite: Text[500];
    begin

        CRLF[1] := 13;
        CRLF[2] := 10;

        foreach TextLine in TextList do begin
            TextToWrite := CopyStr(TextLine, 1, MaxStrLen(TextToWrite));
            OutStr.WriteText(TextToWrite + CRLF);
        end;
    end;


    procedure GetFilterStringFromColumnGLAcc()
    var
        Position: Integer;
        GLAccCode: Text[250];
    begin
        GLAccCode := ColumnGLAcc;
        repeat
            Position := StrPos(GLAccCode, ';');
            if GLAccCode <> '' then begin
                if Position <> 0 then begin
                    FilterString := FilterString + CopyStr(GLAccCode, 1, Position - 1);
                    GLAccCode := CopyStr(GLAccCode, Position + 1);
                end else begin
                    FilterString := FilterString + CopyStr(GLAccCode, 1);
                    GLAccCode := '';
                end;
                if GLAccCode <> '' then
                    FilterString := FilterString + '|';
            end;
        until GLAccCode = '';
    end;


    procedure CheckExcludedGLAccount(): Boolean
    var
        GLAcc: Record "G/L Account";
    begin
        GLAcc.Reset();
        GLAcc.SetFilter("No.", FilterString);
        GLAcc.SetRange("Ignore in 347 Report", true);
        if GLAcc.FindFirst() then
            exit(true);

        exit(false);
    end;


    procedure RetrieveGLAccount(StringFilter: Text[250]) NoOfAcc: Integer
    var
        CommaPos: Integer;
        j: Integer;
    begin
        CommaPos := 1;
        j := 1;
        while CommaPos <> 0 do begin
            CommaPos := StrPos(StringFilter, '|');
            if CommaPos = 0 then begin
                FilterArray[j] := StringFilter;
            end else begin
                FilterArray[j] := CopyStr(StringFilter, 1, CommaPos - 1);
                StringFilter := DelStr(StringFilter, 1, CommaPos);
            end;
            j += 1;
        end;
        NoOfAcc := j - 1;
    end;


    procedure FormatTextName(NameString: Text[100]; ClearNumerico: Boolean) Result: Text[100]
    var
        TempString1: Text[1];
        TempString: Text[100];
    begin
        Clear(Result);

        TempString := UpperCase(NameString);
        if StrLen(TempString) > 0 then
            repeat
                TempString1 := CopyStr(TempString, 1, 1);
                if (TempString1 in ['A' .. 'Z', '-']) or
                   (not ClearNumerico and (TempString1 in ['0' .. '9']))
                then
                    Result := Result + TempString1
                else
                    Result := Result + ' ';
                TempString := DelStr(TempString, 1, 1);
            until StrLen(TempString) = 0;

        exit(Result);
    end;


    procedure FormatTextName(InputString: Text[100]): Text[100];
    begin
        exit(FormatTextName(InputString, true));
    end;


    procedure GetCountyCode(IsCustomer: Boolean)
    var
        CountryReg: Record "Country/Region";
        PostCode: Record "Post Code";
    begin
        CVCountryCode := PadStr('', 2, ' ');
        if IsCustomer then begin
            if not CountryReg.get(Customer."Country/Region Code") then
                clear(CountryReg);

            PostCode347 := PadStr(StatementNo(Customer."Post Code"), 5, ' ');
            if PostCode347 = '     ' then
                PostCode347 := '99999';
            //if (Customer."Country/Region Code" <> ESCountryCode) then begin
            IF (Customer."Country/Region Code" <> ESCountryCode) AND (Customer."Country/Region Code" <> 'ES') THEN BEGIN //+803
                if CountryReg."ISO Code" = '' then
                    CVCountryCode := CopyStr(Customer."Country/Region Code", 1, 2)
                else
                    CVCountryCode := CountryReg."ISO Code";
                CountyCode := '99';
            end else begin
                CountyCode := CopyStr(PostCode347, 1, 2);
            end;
        end else begin
            if not CountryReg.get(Vendor."Country/Region Code") then
                clear(CountryReg);

            PostCode347 := PadStr(StatementNo(Vendor."Post Code"), 5, ' ');
            if PostCode347 = '     ' then
                PostCode347 := '99999';
            //if (Vendor."Country/Region Code" <> ESCountryCode) then begin
            IF (Vendor."Country/Region Code" <> ESCountryCode) AND (Vendor."Country/Region Code" <> 'ES') THEN BEGIN //+2200
                if CountryReg."ISO Code" = '' then
                    CVCountryCode := CopyStr(Vendor."Country/Region Code", 1, 2)
                else
                    CVCountryCode := CountryReg."ISO Code";
                CountyCode := '99';
            end else begin
                CountyCode := CopyStr(PostCode347, 1, 2);
            end;
        end;
    end;


    procedure CheckSameVATRegNoCust() Amt: Decimal
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
        Customer2: Record Customer;
        VATEntry3: Record "VAT Entry";
        CustomerAmount: Decimal;
    begin
        Customer2.SetCurrentKey("VAT Registration No.");
        Customer2.SetFilter("No.", '<>%1', Customer."No.");
        Customer2.SetRange("VAT Registration No.", UpperCase(Customer."VAT Registration No."));
        if Customer2.FindSet() then
            repeat
                CustomerAmount := 0;
                CustLedgEntry.SetCurrentKey("Customer No.", "Document Type");
                CustLedgEntry.SetRange("Customer No.", Customer2."No.");
                CustLedgEntry.SetRange("VAT Reporting Date", FromDate, ToDate);
                CustLedgEntry.SetRange(
                  "Document Type", CustLedgEntry."Document Type"::Invoice, CustLedgEntry."Document Type"::"Credit Memo");
                if CustLedgEntry.FindSet() then
                    repeat
                        // +010
                        if not TempCust2.Get(VATEntry3."Bill-to/Pay-to No.") then begin
                            // -010		    
                            FilterVATEntry(VATEntry3, CustLedgEntry."VAT Reporting Date", CustLedgEntry."Document Type", CustLedgEntry."Document No.", true);
                            if not VATEntry3.FindSet() then
                                case CustLedgEntry."Document Type" of
                                    CustLedgEntry."Document Type"::Invoice:
                                        CheckCustDocTypeInvoice(CustLedgEntry, Customer2);
                                    CustLedgEntry."Document Type"::"Credit Memo":
                                        CheckCustDocTypeCrMemo(CustLedgEntry, Customer2);
                                end
                            else
                                CheckVatEntryNotIn347(VATEntry3, 1);
                            UpdateSalesAmountsAndFlagsForCustomer(Amt, CustomerAmount, CustLedgEntry, VATEntry3, AmountType::SameVATNo);
                            // +010
                        end;
                    // -010
                    until CustLedgEntry.Next() = 0;
                if CustomerMaxAmount < CustomerAmount then begin
                    CustomerMaxAmount := CustomerAmount;
                    Name347 := Customer2.Name;
                end;
            until Customer2.Next() = 0;
        Name347 := PadStr(FormatTextName(Name347, false), 40, ' ');

        exit(Amt);
    end;


    procedure CheckSameVATRegNoVend(var Amt: Decimal; var ISPAmt: Decimal)
    var
        VATEntry3: Record "VAT Entry";
        Vendor2: Record Vendor;
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        VendorAmount: Decimal;
    begin
        Amt := 0;
        ISPAmt := 0;
        Vendor2.SetCurrentKey("VAT Registration No.");
        Vendor2.SetFilter("No.", '<>%1', Vendor."No.");
        Vendor2.SetRange("VAT Registration No.", UpperCase(Vendor."VAT Registration No."));
        if Vendor2.FindSet() then
            repeat
                VendorAmount := 0;
                VendorLedgerEntry.SetCurrentKey("Vendor No.", "Document Type");
                VendorLedgerEntry.SetRange("Vendor No.", Vendor2."No.");
                VendorLedgerEntry.SetRange("VAT Reporting Date", FromDate, ToDate);
                VendorLedgerEntry.SetRange("Document Type", VendorLedgerEntry."Document Type"::Invoice,
                  VendorLedgerEntry."Document Type"::"Credit Memo");
                if VendorLedgerEntry.FindSet() then
                    repeat
                        FilterVATEntry(VATEntry3, VendorLedgerEntry."VAT Reporting Date", VendorLedgerEntry."Document Type",
                          VendorLedgerEntry."Document No.", false);
                        if not VATEntry3.FindSet() then
                            case VendorLedgerEntry."Document Type" of
                                VendorLedgerEntry."Document Type"::Invoice:
                                    CheckVendDocTypeInvoice(VendorLedgerEntry, Vendor2);
                                VendorLedgerEntry."Document Type"::"Credit Memo":
                                    CheckVendDocTypeCrMemo(VendorLedgerEntry, Vendor2);
                            end
                        else begin
                            OperationTypeIdx := GetOperationTypeIdx(VATEntry3);
                            CheckVatEntryNotIn347(VATEntry3, OperationTypeIdx);
                        end;
                        UpdatePurchAmountsAndFlagsForVendor(Amt, ISPAmt, VendorAmount, VendorLedgerEntry, VATEntry3, AmountType::SameVATNo);
                    until VendorLedgerEntry.Next() = 0;
                if VendorMaxAmount < VendorAmount then begin
                    VendorMaxAmount := VendorAmount;
                    Name347 := Vendor2.Name;
                end;
            until Vendor2.Next() = 0;
        Name347 := PadStr(FormatTextName(Name347, false), 40, ' ');
    end;

    local procedure IdentifyCashPayments(CustomerNo: Code[20]; VATRegistrationNo: Text[20])
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        DocumentPostingDate: Date;
    begin
        CustLedgerEntry.SetCurrentKey("Document Type", "Customer No.", "Posting Date", "Currency Code");
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Payment);
        CustLedgerEntry.SetRange("Customer No.", CustomerNo);
        if CustLedgerEntry.FindSet() then
            repeat
                DocumentPostingDate := GetPaymentDocumentPostingDate(CustLedgerEntry);
                if CheckCashTotalsPossibility(CustLedgerEntry, DocumentPostingDate) then
                    CreateCashTotals(CustLedgerEntry."Entry No.", VATRegistrationNo, DocumentPostingDate);
            until CustLedgerEntry.Next() = 0;

    end;

    local procedure CreateCashTotals(CustLedgerEntryNo: Integer; VATRegistrationNo: Text[20]; DocumentPostingDate: Date)
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        DtldCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        DtldCustLedgEntry2: Record "Detailed Cust. Ledg. Entry";
    begin
        DtldCustLedgEntry.SetCurrentKey("Cust. Ledger Entry No.");
        DtldCustLedgEntry.SetRange("Cust. Ledger Entry No.", CustLedgerEntryNo);
        DtldCustLedgEntry.SetRange(Unapplied, false);
        DtldCustLedgEntry.SetRange("Entry Type", DtldCustLedgEntry."Entry Type"::Application);
        if DtldCustLedgEntry.FindSet() then
            repeat
                if DtldCustLedgEntry."Cust. Ledger Entry No." = DtldCustLedgEntry."Applied Cust. Ledger Entry No." then begin
                    DtldCustLedgEntry2.Reset();
                    DtldCustLedgEntry2.SetCurrentKey("Applied Cust. Ledger Entry No.", "Entry Type");
                    DtldCustLedgEntry2.SetRange("Applied Cust. Ledger Entry No.", DtldCustLedgEntry."Applied Cust. Ledger Entry No.");
                    DtldCustLedgEntry2.SetRange("Entry Type", DtldCustLedgEntry2."Entry Type"::Application);
                    DtldCustLedgEntry2.SetRange("Transaction No.", DtldCustLedgEntry."Transaction No.");
                    DtldCustLedgEntry2.SetRange(Unapplied, false);
                    if DtldCustLedgEntry2.FindSet() then
                        repeat
                            if DtldCustLedgEntry2."Cust. Ledger Entry No." <>
                               DtldCustLedgEntry2."Applied Cust. Ledger Entry No."
                            then begin
                                if CustLedgerEntry.Get(DtldCustLedgEntry2."Cust. Ledger Entry No.") then
                                    UpdateCustomerCashBuffer(VATRegistrationNo,
                                      Date2DMY(CustLedgerEntry."VAT Reporting Date", 3),
                                      -(DtldCustLedgEntry2."Amount (LCY)"));
                            end;
                        until DtldCustLedgEntry2.Next() = 0;
                end else begin
                    if CustLedgerEntry.Get(DtldCustLedgEntry."Applied Cust. Ledger Entry No.") then
                        UpdateCustomerCashBuffer(VATRegistrationNo,
                                        Date2DMY(CustLedgerEntry."VAT Reporting Date", 3),
                          DtldCustLedgEntry."Amount (LCY)");
                end;
            until DtldCustLedgEntry.Next() = 0;
    end;

    local procedure IsCashAccount(GLAccountNo: Text[20]): Boolean
    var
        i: Integer;
    begin
        for i := 1 to NoOfAccounts do begin
            if GLAccountNo = FilterArray[i] then
                exit(true);
        end;
        exit(false);
    end;

    local procedure UpdateCustomerCashBuffer(VATRegistrationNo: Text[20]; OperationYear: Integer; OperationAmount: Decimal)
    begin
        // We do not need years before 2008
        if OperationYear < 2008 then
            exit;

        if CustomerCashBuffer.Get(VATRegistrationNo, Format(OperationYear)) then begin
            // Update Record
            CustomerCashBuffer."Operation Amount" += OperationAmount;
            CustomerCashBuffer.Modify();
        end else begin
            // Add a New Record
            CustomerCashBuffer.Init();
            CustomerCashBuffer."VAT Registration No." := VATRegistrationNo;
            CustomerCashBuffer."Operation Year" := Format(OperationYear);
            CustomerCashBuffer."Operation Amount" := OperationAmount;
            CustomerCashBuffer.Insert();
        end;
    end;

    local procedure IdentifyCashPaymentsFromGL(CustLedgerEntryParam: Record "Cust. Ledger Entry"): Boolean
    var
        GLEntryLoc: Record "G/L Entry";
    begin
        GLEntryLoc.Reset();
        GLEntryLoc.SetCurrentKey("Transaction No.");
        GLEntryLoc.SetRange("Transaction No.", CustLedgerEntryParam."Transaction No.");
        GLEntryLoc.SetRange("Document No.", CustLedgerEntryParam."Document No.");
        GLEntryLoc.SetRange("Document Type", GLEntryLoc."Document Type"::Payment);
        GLEntryLoc.SetFilter("Bal. Account Type", '<>%1', GLEntryLoc."Bal. Account Type"::"Bank Account");
        if GLEntryLoc.FindSet() then
            repeat
                if IsCashAccount(GLEntryLoc."G/L Account No.") then
                    exit(true);
            until GLEntryLoc.Next() = 0;
        exit(false);
    end;

    local procedure IdentifyCashPaymentsNH(CustomerNo: Code[20]; pDirecto: Boolean)
    var
        rLocCabCobros: Record "QHT Cobros Cabecera";
        rLocLinCobros: Record "QHT Cobros Detalle";
    begin
        // +004
        if wEmpresaGestion = '' then
            exit;

        rLocCabCobros.ChangeCompany(wEmpresaGestion);
        rLocLinCobros.ChangeCompany(wEmpresaGestion);

        rLocCabCobros.SetCurrentKey(Hotel, Cliente, Divisa, Registrado, "Fecha Cobro");
        rLocCabCobros.SetRange(Cliente, CustomerNo);
        rLocCabCobros.SetFilter(rLocCabCobros.Banco, '<>%1', '');
        rLocCabCobros.SetRange(rLocCabCobros.Contabilizado, true);
        rLocCabCobros.SetRange(rLocCabCobros."Fecha Cobro", FromDate, ToDate);
        if rLocCabCobros.Find('-') then
            repeat
                if IsCashBank(rLocCabCobros.Banco) then begin
                    rLocLinCobros.SetRange(Hotel, rLocCabCobros.Hotel);
                    rLocLinCobros.SetRange("Num. Cobro", rLocCabCobros."Num. Cobro");
                    if rLocLinCobros.FindSet() then
                        repeat
                            if rLocLinCobros."Tipo Linea" = rLocLinCobros."Tipo Linea"::Factura then
                                if FacturaRegistrada(rLocLinCobros."Num. Relacion") then
                                    if pDirecto then
                                        UpdateCustomerCashBuffer(wCIF,
                                          Date2DMY(wFechaFactura, 3), rLocLinCobros."Importe a cobrar (LOCAL)")
                                    else
                                        UpdateCustomerCashBuffer(rLocCabCobros.Cliente,
                                          Date2DMY(wFechaFactura, 3), rLocLinCobros."Importe a cobrar (LOCAL)");
                        until rLocLinCobros.Next() = 0;
                end;
            until rLocCabCobros.Next() = 0;

        // -004
    end;

    local procedure GetQuarterIndex(Date: Date): Integer
    begin
        exit(Round((Date2DMY(Date, 2) - 1) / 3, 1, '<') + 1);
    end;

    local procedure UpdateQuarterAmount(AmtType: Option; Amount: Decimal; Date: Date; idx: Integer)
    begin
        case AmtType of
            AmountType::Sales:
                QuarterSalesAmt[GetQuarterIndex(Date)] += Amount;
            AmountType::Purchase:
                QuarterPurchAmt[idx, GetQuarterIndex(Date)] += Amount;
            AmountType::SameVATNo:
                QuarterSameVATRegNoAmt[idx, GetQuarterIndex(Date)] += Amount;
            AmountType::NotIn347Report:
                QuarterNotIn347Amt[idx, GetQuarterIndex(Date)] += Amount;
        end;
    end;

    local procedure ClearQuarterAmounts()
    begin
        Clear(QuarterSalesAmt);
        Clear(QuarterPurchAmt);
        Clear(QuarterSameVATRegNoAmt);
        Clear(QuarterNotIn347Amt);
    end;

    local procedure GetQuarterZeroAmountsText() QuarterAmountsText: Text[128]
    var
        i: Integer;
    begin
        for i := 1 to 8 do
            QuarterAmountsText += ' ' + PadStr('', 15, '0');
    end;

    local procedure GetSalesQuarterAmountsText() QuarterAmountsText: Text[128]
    var
        i: Integer;
    begin
        for i := 1 to 4 do begin
            QuarterAmountsText += FormatAmount(QuarterSalesAmt[i] + QuarterNotIn347Amt[1, i] + QuarterSameVATRegNoAmt[1, i]);
            QuarterAmountsText += FormatAmount(0); // unsupported real state transmission operations
        end;
    end;

    local procedure GetPurchQuarterAmountsText(idx: Integer) QuarterAmountsText: Text[128]
    var
        i: Integer;
    begin
        for i := 1 to 4 do begin
            QuarterAmountsText += FormatAmount(QuarterPurchAmt[idx, i] - QuarterNotIn347Amt[idx, i] + QuarterSameVATRegNoAmt[idx, i]);
            QuarterAmountsText += FormatAmount(0); // unsupported real state transmission operations
        end;
    end;

    local procedure UpdateNotIn347Amount(GLEntry: Record "G/L Entry"; idx: Integer)
    var
        GLAccount: Record "G/L Account";
    begin
        GLAccount.Get(GLEntry."G/L Account No.");
        if GLAccount."Ignore in 347 Report" then begin
            if idx = 1 then
                NotIn347Amt := NotIn347Amt + GLEntry.Amount + GLEntry."VAT Amount"
            else
                ISPNotIn347Amt := GLEntry.Amount + GLEntry."VAT Amount";
            UpdateQuarterAmount(AmountType::NotIn347Report, GLEntry.Amount + GLEntry."VAT Amount", GLEntry."VAT Reporting Date", idx);
        end;
    end;

    local procedure ReplacementDeclarationOnPush()
    begin
        if ReplacementDeclaration then
            PreDeclarationNumEditable := true
        else
            PreDeclarationNumEditable := false;
    end;

    local procedure CheckVatEntryNotIn347(var VATEntry: Record "VAT Entry"; idx: Integer)
    var
        GLEntry: Record "G/L Entry";
        TempInteger: Record "Integer" temporary;
    begin
        repeat
            if not TempInteger.Get(VATEntry."Transaction No.") then begin
                GLEntry.SetRange("Transaction No.", VATEntry."Transaction No.");
                if GLEntry.FindSet() then
                    repeat
                        UpdateNotIn347Amount(GLEntry, idx);
                    until GLEntry.Next() = 0;
                TempInteger.Number := VATEntry."Transaction No.";
                TempInteger.Insert();
            end;
        until VATEntry.Next() = 0;
    end;

    local procedure FilterVATEntry(var VATEntry: Record "VAT Entry"; VATReportingDate: Date; DocumentType: Enum "Gen. Journal Document Type"; DocumentNo: Code[20]; IsCustomer: Boolean)
    begin
        VATEntry.Reset();
        VATEntry.SetCurrentKey(Type, "VAT Reporting Date", "Document No.", "Country/Region Code");
        if IsCustomer then
            VATEntry.SetRange(Type, VATEntry.Type::Sale)
        else
            VATEntry.SetRange(Type, VATEntry.Type::Purchase);
        VATEntry.SetRange("VAT Reporting Date", VATReportingDate);
        VATEntry.SetRange("Document Type", DocumentType);
        VATEntry.SetRange("Document No.", DocumentNo);

        // +010
        if ESCountryCode <> '' then
            // -010
            VATEntry.SetRange("Country/Region Code", ESCountryCode);
    end;

    local procedure CheckCustDocTypeInvoice(CustLedgEntry: Record "Cust. Ledger Entry"; Customer: Record Customer)
    begin
        NoTaxVATFound :=
          CheckSalesNoTaxableEntriesExist(
            CustLedgEntry."Customer No.", CustLedgEntry."Document Type", CustLedgEntry."Document No.", CustLedgEntry."VAT Reporting Date") and
          IsCountryCodeInSpainOrOutsideEU(Customer."Country/Region Code");

        if IsCountryCodeInSpainOrOutsideEU(Customer."Country/Region Code") then
            FromJournal := true;
    end;


    procedure CheckCustDocTypeCrMemo(CustLedgEntry: Record "Cust. Ledger Entry"; Customer: Record Customer)
    begin
        NoTaxVATFound :=
          CheckSalesNoTaxableEntriesExist(
            CustLedgEntry."Customer No.", CustLedgEntry."Document Type", CustLedgEntry."Document No.", CustLedgEntry."VAT Reporting Date") and
          IsCountryCodeInSpainOrOutsideEU(Customer."Country/Region Code");

        if IsCountryCodeInSpainOrOutsideEU(Customer."Country/Region Code") then
            FromJournal := true;
    end;


    procedure CheckVendDocTypeInvoice(VendorLedgerEntry: Record "Vendor Ledger Entry"; Vendor: Record Vendor)
    begin
        NoTaxVATFound :=
          CheckPurchNoTaxableEntriesExist(
            VendorLedgerEntry."Vendor No.", VendorLedgerEntry."Document Type", VendorLedgerEntry."Document No.",
            VendorLedgerEntry."VAT Reporting Date") and
          IsCountryCodeInSpainOrOutsideEU(Vendor."Country/Region Code");

        if IsCountryCodeInSpainOrOutsideEU(Vendor."Country/Region Code") then
            FromJournal := true;
    end;


    procedure CheckVendDocTypeCrMemo(VendorLedgerEntry: Record "Vendor Ledger Entry"; Vendor: Record Vendor)
    begin
        NoTaxVATFound :=
          CheckPurchNoTaxableEntriesExist(
            VendorLedgerEntry."Vendor No.", VendorLedgerEntry."Document Type", VendorLedgerEntry."Document No.",
            VendorLedgerEntry."VAT Reporting Date") and
          IsCountryCodeInSpainOrOutsideEU(Vendor."Country/Region Code");

        if IsCountryCodeInSpainOrOutsideEU(Vendor."Country/Region Code") then
            FromJournal := true;
    end;

    local procedure GetPaymentDocumentPostingDate(CustLedgerEntry: Record "Cust. Ledger Entry") PostingDate: Date
    var
        CustLedgerEntryRelated: Record "Cust. Ledger Entry";
    begin

        CustLedgerEntry.TestField("Document Type", CustLedgerEntry."Document Type"::Payment);
        PostingDate := CustLedgerEntry."Posting Date";

        // If payment for Bill then we need get Posting Date of the Document related to the Bill        
        CustLedgerEntryRelated.SetRange("Closed by Entry No.", CustLedgerEntry."Entry No.");
        CustLedgerEntryRelated.SetRange("Document Type", CustLedgerEntryRelated."Document Type"::Bill);
        if CustLedgerEntryRelated.FindFirst() then begin
            CustLedgerEntryRelated.Reset();
            CustLedgerEntryRelated.SetRange("Document No.", CustLedgerEntryRelated."Document No.");
            CustLedgerEntryRelated.SetFilter("Document Type", '%1|%2', CustLedgerEntryRelated."Document Type"::Invoice, CustLedgerEntryRelated."Document Type"::"Credit Memo");
            if CustLedgerEntryRelated.FindFirst() then
                PostingDate := CustLedgerEntryRelated."Posting Date";
        end;

        exit(PostingDate);
    end;

    local procedure CheckCashTotalsPossibility(CustLedgerEntry: Record "Cust. Ledger Entry"; DocumentPostingDate: Date): Boolean
    begin
        if (DocumentPostingDate < FromDate) or (DocumentPostingDate > ToDate) then
            exit(false);

        if (CustLedgerEntry."Bal. Account Type" = CustLedgerEntry."Bal. Account Type"::"G/L Account") and (CustLedgerEntry."Bal. Account No." <> '') then begin
            if IsCashAccount(CustLedgerEntry."Bal. Account No.") then
                exit(true);
        end else
            if (CustLedgerEntry."Bal. Account No." = '') or (CustLedgerEntry."Bal. Account Type" <> CustLedgerEntry."Bal. Account Type"::"G/L Account") then
                if IdentifyCashPaymentsFromGL(CustLedgerEntry) then
                    exit(true);

        exit(false);
    end;

    local procedure CheckSalesNoTaxableEntriesExist(CustomerNo: Code[20]; DocumentType: Enum "Gen. Journal Document Type"; DocumentNo: Code[20]; VATReportingDate: Date): Boolean
    var
        NoTaxableEntry: Record "No Taxable Entry";
    begin
        NoTaxableEntry.SetRange(Type, "General Posting Type"::Sale.AsInteger());
        NoTaxableEntry.SetRange("Source No.", CustomerNo);
        NoTaxableEntry.SetRange("Document Type", DocumentType.AsInteger());
        NoTaxableEntry.SetRange("Document No.", DocumentNo);
        NoTaxableEntry.SetRange("VAT Reporting Date", VATReportingDate);
        NoTaxableEntry.SetRange(Reversed, false);
        exit(not NoTaxableEntry.IsEmpty);
    end;

    local procedure CheckPurchNoTaxableEntriesExist(VendorNo: Code[20]; DocumentType: Enum "Gen. Journal Document Type"; DocumentNo: Code[20]; VATReportingDate: Date): Boolean
    var
        NoTaxableEntry: Record "No Taxable Entry";
    begin
        NoTaxableEntry.SetRange(Type, "General Posting Type"::Purchase.AsInteger());
        NoTaxableEntry.SetRange("Source No.", VendorNo);
        NoTaxableEntry.SetRange("Document Type", DocumentType.AsInteger());
        NoTaxableEntry.SetRange("Document No.", DocumentNo);
        NoTaxableEntry.SetRange("VAT Reporting Date", VATReportingDate);
        NoTaxableEntry.SetRange(Reversed, false);
        exit(not NoTaxableEntry.IsEmpty);
    end;


    local procedure GetVATCashRegimeText(AnnualVATCashAmount: Decimal; OperationsCashAccountingCriteriaFlag: Code[1]; ReverseChargeOperationFlag: Code[1]) Text: Text[19]
    var
        AnnualAmountVATCashRegimeText: Text[16];
    begin
        AnnualAmountVATCashRegimeText := FormatAmount(AnnualVATCashAmount);
        Text := ' ' + AnnualAmountVATCashRegimeText;
        if ReverseChargeOperationFlag = '' then
            Text := ' ' + Text
        else
            Text := ReverseChargeOperationFlag + Text;
        if OperationsCashAccountingCriteriaFlag = '' then
            Text := ' ' + Text
        else
            Text := OperationsCashAccountingCriteriaFlag + Text;
    end;

    local procedure GetPaidVATCashSalesInvoicesOutOfPeriod(var TempCustLedgerEntry: Record "Cust. Ledger Entry" temporary; CustNo: Code[20])
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        DtldCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        VATEntry: Record "VAT Entry";
    begin
        DtldCustLedgEntry.SetRange("Customer No.", CustNo);
        DtldCustLedgEntry.SetRange("VAT Reporting Date", FromDate, ToDate);
        DtldCustLedgEntry.SetRange("Entry Type", DtldCustLedgEntry."Entry Type"::Application);
        DtldCustLedgEntry.SetRange("Initial Document Type", DtldCustLedgEntry."Initial Document Type"::Invoice);
        DtldCustLedgEntry.SetRange(Unapplied, false);
        if DtldCustLedgEntry.FindSet() then
            repeat
                if CustLedgerEntry.Get(DtldCustLedgEntry."Cust. Ledger Entry No.") then
                    if (CustLedgerEntry."VAT Reporting Date" < FromDate) or (CustLedgerEntry."VAT Reporting Date" > ToDate) then begin
                        FilterVATEntry(
                          VATEntry, CustLedgerEntry."VAT Reporting Date", CustLedgerEntry."Document Type", CustLedgerEntry."Document No.", true);
                        VATEntry.SetRange("VAT Cash Regime", true);
                        VATEntry.SetFilter("VAT Registration No.", '<>%1', '');
                        if VATEntry.FindFirst() then begin
                            TempCustLedgerEntry := CustLedgerEntry;
                            if TempCustLedgerEntry.Insert() then;
                        end;
                    end;
            until DtldCustLedgEntry.Next() = 0;
    end;

    local procedure ProcessPaidVATCashSalesInvoicesOutOfPeriod(var TempCustLedgerEntry: Record "Cust. Ledger Entry" temporary)
    begin
        if TempCustLedgerEntry.FindSet() then
            repeat
                TempCustLedgerEntry.SetRange("Date Filter");
                TempCustLedgerEntry.CalcFields("Amount (LCY)");
                SalesAmt += TempCustLedgerEntry."Amount (LCY)";
                CustomerMaxAmount := SalesAmt;
                OperationsCashAccountingCriteria := 'X';
                TempCustLedgerEntry.SetFilter("Date Filter", '%1..%2', FromDate, ToDate);
                TempCustLedgerEntry.CalcFields("Remaining Amt. (LCY)");
                AnnualAmountVATCashRegime -= TempCustLedgerEntry."Remaining Amt. (LCY)";
            until TempCustLedgerEntry.Next() = 0;
    end;

    local procedure GetPaidVATCashPurchInvoicesOutOfPeriod(var TempVendorLedgerEntry: Record "Vendor Ledger Entry" temporary; VendNo: Code[20])
    var
        DtldVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
        VATEntry: Record "VAT Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        DtldVendorLedgEntry.SetRange("Vendor No.", VendNo);
        DtldVendorLedgEntry.SetRange("VAT Reporting Date", FromDate, ToDate);
        DtldVendorLedgEntry.SetRange("Entry Type", DtldVendorLedgEntry."Entry Type"::Application);
        DtldVendorLedgEntry.SetRange("Initial Document Type", DtldVendorLedgEntry."Initial Document Type"::Invoice);
        DtldVendorLedgEntry.SetRange(Unapplied, false);
        if DtldVendorLedgEntry.FindSet() then
            repeat
                if VendorLedgerEntry.Get(DtldVendorLedgEntry."Vendor Ledger Entry No.") then
                    if (VendorLedgerEntry."VAT Reporting Date" < FromDate) or (VendorLedgerEntry."VAT Reporting Date" > ToDate) then begin
                        FilterVATEntry(
                          VATEntry, VendorLedgerEntry."VAT Reporting Date", VendorLedgerEntry."Document Type", VendorLedgerEntry."Document No.", false);
                        VATEntry.SetRange("VAT Cash Regime", true);
                        VATEntry.SetFilter("VAT Registration No.", '<>%1', '');
                        if VATEntry.FindFirst() then begin
                            TempVendorLedgerEntry := VendorLedgerEntry;
                            if TempVendorLedgerEntry.Insert() then;
                        end;
                    end;
            until DtldVendorLedgEntry.Next() = 0;
    end;

    local procedure ProcessPaidVATCashPurchInvoicesOutOfPeriod(var TempVendorLedgerEntry: Record "Vendor Ledger Entry" temporary)
    begin
        if TempVendorLedgerEntry.FindSet() then
            repeat
                TempVendorLedgerEntry.SetRange("Date Filter");
                TempVendorLedgerEntry.CalcFields("Amount (LCY)");
                PurchasesAmt -= TempVendorLedgerEntry."Amount (LCY)";
                VendorMaxAmount := PurchasesAmt;
                OperationsCashAccountingCriteria := 'X';
                TempVendorLedgerEntry.SetFilter("Date Filter", '%1..%2', FromDate, ToDate);
                TempVendorLedgerEntry.CalcFields("Remaining Amt. (LCY)");
                AnnualAmountVATCashRegime += TempVendorLedgerEntry."Remaining Amt. (LCY)";
            until TempVendorLedgerEntry.Next() = 0;
    end;

    local procedure UpdateSalesAmountsAndFlagsForCustomer(var SalesAmt: Decimal; var CustAmt: Decimal; var CustLedgerEntry: Record "Cust. Ledger Entry"; VATEntry: Record "VAT Entry"; QuarterAmtType: Option Sales,Purchase,SameVATNo,NotIn347Report): Boolean
    begin
        if not ((VATEntry."VAT Registration No." <> '') or NoTaxVATFound or FromJournal) then
            exit(false);

        CustLedgerEntry.CalcFields("Amount (LCY)");
        SalesAmt += CustLedgerEntry."Amount (LCY)";
        CustAmt += CustLedgerEntry."Amount (LCY)";
        if not VATEntry."VAT Cash Regime" then
            UpdateQuarterAmount(QuarterAmtType, CustLedgerEntry."Amount (LCY)", CustLedgerEntry."VAT Reporting Date", 1);

        if VATEntry."VAT Cash Regime" then begin
            OperationsCashAccountingCriteria := 'X';
            CustLedgerEntry.CalcFields("Remaining Amt. (LCY)");
            AnnualAmountVATCashRegime += CustLedgerEntry."Amount (LCY)" - CustLedgerEntry."Remaining Amt. (LCY)";
        end;
        exit(true);
    end;

    local procedure UpdatePurchAmountsAndFlagsForVendor(var PurchAmt: Decimal; var ISPPurchAmt: Decimal; var VendAmt: Decimal; var VendLedgerEntry: Record "Vendor Ledger Entry"; VATEntry: Record "VAT Entry"; QuarterAmtType: Option Sales,Purchase,SameVATNo,NotIn347Report): Boolean
    begin
        if not ((VATEntry."VAT Registration No." <> '') or NoTaxVATFound or FromJournal) then
            exit(false);

        VendLedgerEntry.CalcFields("Amount (LCY)");

        if VATEntry."VAT Calculation Type" = VATEntry."VAT Calculation Type"::"Reverse Charge VAT" then begin
            ISPPurchAmt -= VendLedgerEntry."Amount (LCY)";
            UpdateQuarterAmount(QuarterAmtType, -VendLedgerEntry."Amount (LCY)", VendLedgerEntry."VAT Reporting Date", 2);
            ReverseChargeOperation := 'X';
        end else begin
            PurchAmt -= VendLedgerEntry."Amount (LCY)";
            if VATEntry."VAT Cash Regime" then begin
                OperationsCashAccountingCriteria := 'X';
                VendLedgerEntry.CalcFields("Remaining Amt. (LCY)");
                AnnualAmountVATCashRegime -= VendLedgerEntry."Amount (LCY)" - VendLedgerEntry."Remaining Amt. (LCY)";
            end else
                UpdateQuarterAmount(QuarterAmtType, -VendLedgerEntry."Amount (LCY)", VendLedgerEntry."VAT Reporting Date", 1);
        end;

        VendAmt -= VendLedgerEntry."Amount (LCY)";

        exit(true);
    end;

    local procedure GetOperationTypeIdx(VATEntry: Record "VAT Entry"): Integer
    begin
        if VATEntry."VAT Calculation Type" = VATEntry."VAT Calculation Type"::"Reverse Charge VAT" then
            exit(2);

        exit(1);
    end;

    local procedure CreateCountryRegionFilter()
    var
        CountryRegion: Record "Country/Region";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCreateCountryRegionFilter(CountryRegionFilter, IsHandled);
        if IsHandled then
            exit;

        CountryRegion.SetRange("EU Country/Region Code", '');
        CountryRegionFilter := ESCountryCode;
        if CountryRegion.FindSet() then
            repeat
                CountryRegionFilter += StrSubstNo('|%1', CountryRegion.Code);
            until CountryRegion.Next() = 0;
    end;

    local procedure IsCountryCodeInSpainOrOutsideEU(CountryCode: Code[10]) Result: Boolean
    var
        CountryRegion: Record "Country/Region";
    begin
        CountryRegion.SetRange(Code, CountryCode);
        CountryRegion.SetFilter("EU Country/Region Code", '%1|%2', CountryCode, '');
        Result := not CountryRegion.IsEmpty();
        OnAfterIsCountryCodeInSpainOrOutsideEU(CountryCode, Result);
    end;

    local procedure AppendLine(Content: Text)
    begin
        TextList.Add(Content);
    end;

    local procedure InsertFirstLine(Content: Text)
    begin
        TextList.Insert(1, Content);
    end;

    local procedure IsCashBank(BankAccountNo: Text[20]): Boolean
    var
        rLocBanco: Record "Bank Account";
    begin
        // +004
        if rLocBanco.Get(BankAccountNo) then
            exit(rLocBanco."QHTEfectivo 347");

        exit(false);
    end;


    procedure FacturaRegistrada(pNumFac: Code[10]): Boolean
    var
        rLocHistCabAbo: Record "Sales Cr.Memo Header";
        rLocHistCabFac: Record "Sales Invoice Header";
    begin
        if rLocHistCabFac.Get(pNumFac) then begin
            wCIF := rLocHistCabFac."VAT Registration No.";
            wFechaFactura := rLocHistCabFac."Posting Date";
            exit(true);
        end
        else
            if rLocHistCabAbo.Get(pNumFac) then begin
                wCIF := rLocHistCabAbo."VAT Registration No.";
                wFechaFactura := rLocHistCabAbo."Posting Date";
                exit(true);
            end
            else
                exit(false);
    end;


    procedure ImporteTrimestre(var pFacturasTMP: Record "Inc. Stmt. Clos. Buffer" temporary; pImporte: Decimal; pFechaFactura: Date)
    var
        NumTrimestre: Integer;
    begin
        // +008

        NumTrimestre := GetQuarterIndex(pFechaFactura);

        case NumTrimestre of
            1:
                pFacturasTMP."QHTAmount First Quarter" += pImporte;
            2:
                pFacturasTMP."QHTAmount Second Quarter" += pImporte;
            3:
                pFacturasTMP."QHTAmount Third Quarter" += pImporte;
            4:
                pFacturasTMP."QHTAmount Fourth Quarter" += pImporte;
        end;
    end;


    procedure RellenaArrayTrimestres(var pFacturasTMP: Record "Inc. Stmt. Clos. Buffer" temporary)
    begin
        // -008

        Clear(QuarterSalesAmt);
        QuarterSalesAmt[1] := pFacturasTMP."QHTAmount First Quarter";
        QuarterSalesAmt[2] := pFacturasTMP."QHTAmount Second Quarter";
        QuarterSalesAmt[3] := pFacturasTMP."QHTAmount Third Quarter";
        QuarterSalesAmt[4] := pFacturasTMP."QHTAmount Fourth Quarter";
    end;




    local procedure IdentifyCashPaymentsBank(CustomerNo: Code[20]; VATRegistrationNo: Text[20])
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        DocumentPostingDate: Date;
    begin

        // Tratamiento de los cobros STD contra Banco
        CustLedgerEntry.SetCurrentKey("Document Type", "Customer No.", "Vat Reporting Date", "Currency Code");
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Payment);
        CustLedgerEntry.SetRange("Customer No.", CustomerNo);
        CustLedgerEntry.SetRange("vat reporting date", FromDate, ToDate);
        CustLedgerEntry.SetRange("Bal. Account Type", CustLedgerEntry."Bal. Account Type"::"Bank Account");

        //DocumentPostingDate := GetPaymentDocumentPostingDate(CustLedgerEntry); //-802

        if CustLedgerEntry.FindSet() then
            repeat
                if IsCashBank(CustLedgerEntry."Bal. Account No.") then begin
                    DocumentPostingDate := GetPaymentDocumentPostingDate(CustLedgerEntry); //+802
                    CreateCashTotals(CustLedgerEntry."Entry No.", VATRegistrationNo, DocumentPostingDate);
                end;
            until CustLedgerEntry.Next() = 0;

        // -004
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterIsCountryCodeInSpainOrOutsideEU(CountryCode: Code[10]; var Result: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateCountryRegionFilter(var CountryRegionFilter: Text; var IsHandled: Boolean)
    begin
    end;
}



