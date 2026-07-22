pageextension 50003 THBGeneralLedgerEntries extends "General Ledger Entries"
{
    actions
    {
        addafter(SetPeriodTransNos)
        {
            group(Personalizaciones)
            {
                caption = 'Personaloizaciones';
                action("CambiarCuenta")
                {
                    ApplicationArea = All;
                    Caption = 'Cambiar Cuenta';
                    ToolTip = 'Cambiar Cuenta';

                    trigger OnAction()
                    begin
                        //THB-140426-IFF
                        //CurrPage.EDITABLE:=TRUE;
                        IF (UPPERCASE(USERID) <> 'THBASPCEN\APP') AND (UPPERCASE(USERID) <> 'THBASPCEN\JPS') AND (UPPERCASE(USERID) <> 'THBASPCEN\JRD') AND (UPPERCASE(USERID) <> 'THBASPCEN\SHR') AND (UPPERCASE(USERID) <> 'THBASPCEN\IFF') AND (UPPERCASE(USERID) <> 'THBASPCEN\CPS')
AND (UPPERCASE(USERID) <> 'THBASPCEN\MSB') AND (UPPERCASE(USERID) <> 'THBASPCEN\VFS') AND (UPPERCASE(USERID) <> 'THBASPCEN\MPC') AND (UPPERCASE(USERID) <> 'THBASPCEN\MAF') AND (UPPERCASE(USERID) <> 'THBASPCEN\CMB') THEN
                            ERROR('No tiene permisos para usar esta función') ELSE BEGIN
                            //FIN THB-140426-IFF
                            CLEAR(pGetCTA);
                            IF pGetCTA.RUNMODAL = ACTION::OK THEN
                                pGetCTA.GetParams(wNo);


                            IF STRLEN(wNo) <> 7 THEN
                                ERROR('Sólo se pueden asignar números de cuenta auxiliares.') ELSE BEGIN
                                IF CONFIRM('¿Esta seguro de que desea cambiar el número de cuenta a ' + FORMAT(wNo) + ' para el movimiento ' + FORMAT("Entry No."))
                                  THEN BEGIN
                                    IF CONFIRM('El número anterior era ' + FORMAT(Rec."G/L Account No.") + ' y ahora va a ser ' + FORMAT(wNo) + ' lo cambiamos?')
                                      THEN BEGIN

                                        Rec."G/L Account No." := wNo;
                                        IF Rec.MODIFY THEN MESSAGE('Se ha cambiado satisfactoriamente, el nuevo número de cuenta es ' + FORMAT(wNo));

                                    END;
                                END;
                            END;
                        END;
                    END;

                }
            }
        }
    }
    var
        pGetCTA: page "THB Formulario cuenta";
        wNo: code[20];
}
