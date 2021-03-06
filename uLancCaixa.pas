unit uLancCaixa;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DynamicSkinForm, spdbctrls, SkinCtrls, StdCtrls, Mask,
  SkinBoxCtrls, DB, HintBalloon, ppPrnabl, ppClass, ppCtrls, ppBands,
  ppCache, ppDB, ppProd, ppReport, ppComm, ppRelatv, ppDBPipe, ppStrtch,
  ppMemo, IBCustomDataSet, IBQuery;

type
  TfLancCaixa = class(TForm)
    spDynamicSkinForm1: TspDynamicSkinForm;
    btNovo: TspSkinButton;
    btSalvar: TspSkinButton;
    btAlterar: TspSkinButton;
    btCancelar: TspSkinButton;
    btExcluir: TspSkinButton;
    btSair: TspSkinButton;
    label101: TspSkinLabel;
    GroupBox1: TspSkinGroupBox;
    dbeCodigo: TspSkinDBEdit;
    spSkinLabel1: TspSkinLabel;
    dbeHistorico: TspSkinDBMemo;
    spSkinLabel8: TspSkinLabel;
    dbeDtMov: TspSkinDBEdit;
    spSkinLabel16: TspSkinLabel;
    dsLancCaixa: TDataSource;
    HintBalloon1: THintBalloon;
    StatusBar: TspSkinStatusBar;
    StatusPanel1: TspSkinStatusPanel;
    spSkinLabel4: TspSkinLabel;
    DBECONTA: TspSkinDBEdit;
    Edit1: TspSkinEdit;
    DBETIPOMOV: TspSkinDBEdit;
    edit3: TspSkinEdit;
    spSkinLabel2: TspSkinLabel;
    edit2: TspSkinEdit;
    spSkinLabel3: TspSkinLabel;
    DBEVALORMOV: TspSkinDBEdit;
    StatusPanel2: TspSkinStatusPanel;
    IBQuery1: TIBQuery;
    IBQuery1VALORMOV: TIBBCDField;
    DataSource1: TDataSource;
    lbVl: TLabel;
    procedure btNovoClick(Sender: TObject);
    procedure btSalvarClick(Sender: TObject);
    procedure btAlterarClick(Sender: TObject);
    procedure btCancelarClick(Sender: TObject);
    procedure btExcluirClick(Sender: TObject);
    procedure btSairClick(Sender: TObject);
    procedure dsLancCaixaStateChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure btNovoMouseEnter(Sender: TObject);
    procedure btSalvarMouseEnter(Sender: TObject);
    procedure btAlterarMouseEnter(Sender: TObject);
    procedure btCancelarMouseEnter(Sender: TObject);
    procedure btExcluirMouseEnter(Sender: TObject);
    procedure btSairMouseEnter(Sender: TObject);
    procedure DBECONTAEnter(Sender: TObject);
    procedure DBECONTAExit(Sender: TObject);
    procedure DBECONTAKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure CarregaEdits;
    procedure DBETIPOMOVEnter(Sender: TObject);
    procedure DBETIPOMOVExit(Sender: TObject);
    procedure DBETIPOMOVKeyDown(Sender: TObject; var Key: Word;   Shift: TShiftState);
    procedure LimparEdits;
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
    fRetorno : TForm;
    Entrando,xBuscar,xOrigemConsulta : Boolean;
    xNumDevolucao : Integer;
    xTipo : String;
    xValorMov : Real;
  end;

var
  fLancCaixa: TfLancCaixa;

implementation

uses uDM1, uDMDados, Sistools, uPrincipal , uConsultaContas,
  uConsultaTipoPgto, uConsultaLancCaixa;



{$R *.dfm}

procedure TfLancCaixa.btNovoClick(Sender: TObject);
begin
 { if not (fPrincipal.TemPermissao(DM1.mUsuario,2,'fLancCaixa')) then
    Begin
      Application.MessageBox('Voc� n�o Tem Permiss�o Para essa Opera��o','Aten��o',MB_OK+ MB_ICONINFORMATION);
      Exit;
    End;
  }
  HabilitaForm(fLancCaixa,true);
  AbreTabela(DM1.tCaixa ,'pParoquia','pCodigo',-1,-1);
  NovoRegistro(DM1.tCaixa,nil);
  LimparEdits;
  DM1.tCaixaPAROQUIA.AsInteger := DM1.mParoquia;
  DM1.tCaixaDATAMOV.AsDateTime := Date;
  DM1.tCaixaDTLANC.AsDateTime  := Date ;
  DM1.tCaixaUSERLANC.AsInteger := DM1.mUsuario;
  dbeDtMov.SetFocus;

end;

procedure TfLancCaixa.btSalvarClick(Sender: TObject);
Var nome:string;
begin
  ActiveControl := nil;


  if not DataValida (DM1.tCaixa.FieldByName('DataMov').AsString)  Then
    Begin
      MsgValida('Informe a Data do Movimento antes de salvar!',nil,nil);
      dbeDtMov.SetFocus;
      Exit;
    End;

  if (DM1.tCaixa.FieldByName('CONTA').AsString  ='')  Then
    Begin
      MsgValida('Informe a CONTA antes de salvar!',nil,nil);
      DBECONTA.SetFocus;
      Exit;
    End;
  if (DM1.tCaixa.FieldByName('TIPOMOV').AsString  ='')  Then
    Begin
      MsgValida('Informe O TIPO DE MOVIMENTA��O  antes de salvar!',nil,nil);
      DBETIPOMOV.SetFocus;
      Exit;
    End;
  if (DM1.tCaixa.FieldByName('VALORMOV').AsFloat    <=0)  Then
    Begin
      MsgValida('Informe O VALOR DO MOVIMENTO  antes de salvar!',nil,nil);
      DBEVALORMOV.SetFocus;
      Exit;
    End;

  if (DM1.tCaixa.FieldByName('HISTORICO').AsString  ='')  Then
    Begin
      MsgValida('Informe O HIST�RICO  antes de salvar!',nil,nil);
      dbeHistorico.SetFocus;
      Exit;
    End;


  if dsLancCaixa.State = dsInsert then
    DM1.tCaixa.FieldByName('CODIGO').asInteger:=   AutoIncremento(dmDados.db,'CODIGO','PAROQUIA','MOVCAIXA',DM1.mParoquia)
  else
    begin
       DM1.tCaixaDTALT.AsDateTime := Date;
       DM1.tCaixaUSERALT.AsInteger := DM1.mUsuario;
    end;

  Grava(dsLancCaixa);
  //---//
   xTipo := DBETIPOMOV.Text;
   IBQuery1.Close;
   //IBQuery1.SQL.Clear;
   //IBQuery1.SQL.Add('SELECT SUM(VALORMOV)VALORMOV FROM MOVCAIXA LEFT JOIN TIPOPGTO ON MOVCAIXA.TIPOMOV=TIPOPGTO.CODIGO WHERE TIPOPGTO.OPERACAO='+#39+'C+#39);
   IBQuery1.ParamByName('PTIPOCODIGO').AsString := xTipo;
   IBQuery1.ParamByName('pparoquia').AsInteger := DM1.mParoquia;
   IBQuery1.Open;
   xValorMov := IBQuery1VALORMOV.Value;
   lbVl.Caption:= IBQuery1VALORMOV.AsString;
   //--//
  HabilitaForm(fLancCaixa,False) ;

end;

procedure TfLancCaixa.btAlterarClick(Sender: TObject);
begin
 { if not (fPrincipal.TemPermissao(DM1.mUsuario,3,'fLancCaixa')) then
    Begin
      Application.MessageBox('Voc� n�o Tem Permiss�o Para essa Opera��o','Aten��o',MB_OK+ MB_ICONINFORMATION);
      Exit;
    End;
  }
  ModificaRegistro(DM1.tCaixa);
  HabilitaForm(fLancCaixa,True);
  dbeDtMov.SetFocus;
end;

procedure TfLancCaixa.btCancelarClick(Sender: TObject);
begin
  CancelaEdicao(DM1.tCaixa);
  HabilitaForm(fLancCaixa, False);
  AbreTabela(DM1.tCaixa ,'pParoquia','PCODIGO',DM1.mParoquia ,UltimoRegistro('MOVCAIXA','Codigo','Paroquia',DM1.mParoquia));
  CarregaEdits;
end;

procedure TfLancCaixa.btExcluirClick(Sender: TObject);
begin
 { if not (fPrincipal.TemPermissao(DM1.mUsuario,4,'fLancCaixa')) then
    Begin
      Application.MessageBox('Voc� n�o Tem Permiss�o Para essa Opera��o','Aten��o',MB_OK+ MB_ICONINFORMATION);
      Exit;
    End;
  }
  if ApagarRegistro(DM1.tCaixa ,'Lan�amento de Caixa' ) then
   AbreTabela(DM1.tCaixa,'pParoquia','PCODIGO',DM1.mParoquia,UltimoRegistro('MOVCAIXA','Codigo','Paroquia',DM1.mParoquia));
   CarregaEdits;
   //-----------//
   xTipo := DBETIPOMOV.Text;
   IBQuery1.Close;
   //IBQuery1.SQL.Clear;
   //IBQuery1.SQL.Add('SELECT SUM(VALORMOV)VALORMOV FROM MOVCAIXA LEFT JOIN TIPOPGTO ON MOVCAIXA.TIPOMOV=TIPOPGTO.CODIGO WHERE TIPOPGTO.OPERACAO='+#39+'C+#39);
   IBQuery1.ParamByName('PTIPOCODIGO').AsString := xTipo;
   IBQuery1.ParamByName('pparoquia').AsInteger := DM1.mParoquia;
   IBQuery1.Open;
   xValorMov := IBQuery1VALORMOV.Value;
   lbVl.Caption:= IBQuery1VALORMOV.AsString;
end;

procedure TfLancCaixa.btSairClick(Sender: TObject);
begin
  fLancCaixa.Close;
end;

procedure TfLancCaixa.dsLancCaixaStateChange(Sender: TObject);
begin
   Estado(dsLancCaixa,btNovo,btAlterar, btSalvar, BtCancelar, btExcluir, btSair, nil, nil, nil, nil);
end;

procedure TfLancCaixa.FormActivate(Sender: TObject);
begin
   xTipo := DBETIPOMOV.Text;
   IBQuery1.Close;
   //IBQuery1.SQL.Clear;
   //IBQuery1.SQL.Add('SELECT SUM(VALORMOV)VALORMOV FROM MOVCAIXA LEFT JOIN TIPOPGTO ON MOVCAIXA.TIPOMOV=TIPOPGTO.CODIGO WHERE TIPOPGTO.OPERACAO='+#39+'C+#39);
   IBQuery1.ParamByName('PTIPOCODIGO').AsString := xTipo;
   IBQuery1.ParamByName('pparoquia').AsInteger := DM1.mParoquia;
   IBQuery1.Open;
   xValorMov := IBQuery1VALORMOV.Value;
   lbVl.Caption:= IBQuery1VALORMOV.AsString;

   
  if (xBuscar)  and (xNumDevolucao = 0 ) then
    Begin
      if fPrincipal.ValorRetornoInteger > 0 then
        Begin
          AbreTabela(DM1.tCaixa ,'pParoquia','pCodigo',DM1.mParoquia ,fPrincipal.ValorRetornoInteger);
          fPrincipal.ValorRetornoInteger := 0;
        End
    End
  else if (xBuscar) and (xNumDevolucao = 1) then
    Begin
      DBECONTA.Text := IntToStr( fPrincipal.ValorRetornoInteger);
      fPrincipal.ValorRetornoInteger := 0;
    end
  else if (xBuscar) and (xNumDevolucao = 2) then
    Begin
      DBETIPOMOV.Text := IntToStr( fPrincipal.ValorRetornoInteger);
      fPrincipal.ValorRetornoInteger := 0;
    end;
  CarregaEdits  ;
  xBuscar := False
End;


procedure TfLancCaixa.FormClose(Sender: TObject;  var Action: TCloseAction);
begin
  DM1.tCaixa.Close;
  if not  xOrigemConsulta then
    Begin
      fRetorno.Enabled := True;
      fRetorno.Show;
    end
  else
    begin
       //fConsultaMinistrosPadres.Enabled := True;
       //fConsultaMinistrosPadres.RefazerSQL;
       //fConsultaMinistrosPadres.Show;

    end;
  xOrigemConsulta := False;
end;

procedure TfLancCaixa.FormCloseQuery(Sender: TObject;   var CanClose: Boolean);
begin
  if (dsLancCaixa.State = dsEdit) or (dsLancCaixa.State = dsInsert) then
    Begin
      If Application.MessageBox('Deseja Sair e  Cancelar as Altera��es ?','Aten��o',MB_YESNO+ MB_ICONQUESTION)= IDNO then
        Begin
          CanClose := False
        End
      Else
        Begin
          CancelaEdicao(DM1.tCaixa);
          CanClose := True;
        End;
    End
end;

procedure TfLancCaixa.FormCreate(Sender: TObject);
begin
   

   {formulario � criado}
  dmDados.mTabela := 'MOVCAIXA';
  DeleteMenu(GetSystemMenu(Handle, False), SC_MOVE, MF_BYCOMMAND);
  Entrando := True;
  xBuscar  := False;
  Edit1.Clear;
  Edit2.Clear;
end;

procedure TfLancCaixa.FormKeyDown(Sender: TObject; var Key: Word;  Shift: TShiftState);
begin
  If (Shift = []) and (Key = VK_F2 ) then
    Begin
    if btNovo.Enabled then
      btNovo.OnClick(Self); ;
    End
  else if (Shift = []) and (Key = VK_F3 ) then
    Begin
      if btSalvar.Enabled then
        btSalvar.OnClick(Self) ;
    End
  else if (Shift = []) and (Key = VK_F4 ) then
    Begin
      if btAlterar.Enabled then
        btAlterar.OnClick(Self);
    End
  else if (Shift = []) and (Key = VK_F5 ) then
    Begin
      if btCancelar .Enabled then
        btCancelar.OnClick(Self);
    End
  else if (Shift = []) and (Key = VK_F6 ) then
    Begin
      if btExcluir.Enabled then
        btExcluir.OnClick(Self);
    End
  else if (Shift = []) and (Key = VK_ESCAPE  ) then
    Begin
      if btSair.Enabled then
        btSair.OnClick(Self);
    End
  else If (Shift = []) and (Key = VK_F7 ) then
    Begin
      xBuscar := True;
      fLancCaixa.Enabled := False;
      fPrincipal.ValorRetornoInteger := 0;
      fConsultaLancCaixa.fRetorno := fLancCaixa ;
      fConsultaLancCaixa.Show;

    End;

end;

procedure TfLancCaixa.FormShow(Sender: TObject);
begin
  

  DM1.TLancIntencao.Close;
  AbreTabela(DM1.tCaixa ,'pParoquia','PCODIGO',DM1.mParoquia ,UltimoRegistro('MOVCAIXA','Codigo','Paroquia',DM1.mParoquia));
  CarregaEdits;
  Label101.Caption :=' F7 - CADASTRO / CONSULTA';
 
end;

procedure TfLancCaixa.btNovoMouseEnter(Sender: TObject);
begin
  HintBalloon1.Text:='Incluir Lan�amento de Caixa';
  HintBalloon1.AddToolInfo(Handle,btNovo.Handle);
end;

procedure TfLancCaixa.btSalvarMouseEnter(Sender: TObject);
begin
  HintBalloon1.Text:='Salvar Lan�amento de Caixa';
  HintBalloon1.AddToolInfo(Handle,btSalvar.Handle);
end;

procedure TfLancCaixa.btAlterarMouseEnter(Sender: TObject);
begin
  HintBalloon1.Text:='Alterar Lan�amento de Caixa';
  HintBalloon1.AddToolInfo(Handle,btAlterar.Handle);
end;

procedure TfLancCaixa.btCancelarMouseEnter(Sender: TObject);
begin
  HintBalloon1.Text:='Cancelar Lan�amento de Caixa';
  HintBalloon1.AddToolInfo(Handle,btCancelar.Handle);
end;

procedure TfLancCaixa.btExcluirMouseEnter(Sender: TObject);
begin
  HintBalloon1.Text:='Excluir Lan�amento de Caixa';
  HintBalloon1.AddToolInfo(Handle,btExcluir.Handle);
end;

procedure TfLancCaixa.btSairMouseEnter(Sender: TObject);
begin
  HintBalloon1.Text:='Sair do Cadastro de  Lan�amento de Caixa';
  HintBalloon1.AddToolInfo(Handle,btSair.Handle);
end;





procedure TfLancCaixa.DBECONTAEnter(Sender: TObject);
begin
  label101.Caption   := 'F10 - CADASTRO/CONSULTA';
end;

procedure TfLancCaixa.DBECONTAExit(Sender: TObject);
begin
   Edit1.Text := RetornaTabela(DM1.TContaBanco ,'I','pParoquia',IntToStr(DM1.mParoquia),'I','pCodigo',DBECONTA.Text ,'','','','','','','NOME' );
   Label101.Caption := '';
end;

procedure TfLancCaixa.DBECONTAKeyDown(Sender: TObject;  var Key: Word; Shift: TShiftState);
begin
   if (Shift = []) and (key = VK_F10) then
     begin
       key := 0;
       xNumDevolucao := 1;
       fPrincipal.ValorRetornoInteger := 0;
       xBuscar := True;
       fConsultaContas.fRetorno := fLancCaixa ;
       fLancCaixa.Enabled := False;
       fConsultaContas.Show;

     end;
end;

procedure TfLancCaixa.CarregaEdits;
begin
  Edit1.Text := RetornaTabela(DM1.TContaBanco ,'I','pParoquia',IntToStr(DM1.mParoquia),'I','pCodigo',DM1.tCaixaCONTA.AsString ,'','','','','','','NOME' );
  Edit3.Text := RetornaTabela(DM1.TTipoPgto ,'I','pParoquia',IntToStr(DM1.mParoquia),'I','pCodigo',DM1.tCaixaTIPOMOV.AsString ,'','','','','','','NOME' );
  Edit2.Text := RetornaTabela(DM1.TTipoPgto ,'I','pParoquia',IntToStr(DM1.mParoquia),'I','pCodigo',DM1.tCaixaTIPOMOV.AsString ,'','','','','','','TIPOOPERACAO' );
end;

procedure TfLancCaixa.DBETIPOMOVEnter(Sender: TObject);
begin
  label101.Caption   := 'F10 - CADASTRO/CONSULTA';
end;

procedure TfLancCaixa.DBETIPOMOVExit(Sender: TObject);
begin
  Edit3.Text := RetornaTabela(DM1.TTipoPgto ,'I','pParoquia',IntToStr(DM1.mParoquia),'I','pCodigo',DBETIPOMOV.Text ,'','','','','','','NOME' );
  Edit2.Text := RetornaTabela(DM1.TTipoPgto ,'I','pParoquia',IntToStr(DM1.mParoquia),'I','pCodigo',DBETIPOMOV.Text ,'','','','','','','TIPOOPERACAO' );
  Label101.Caption := '';
end;

procedure TfLancCaixa.DBETIPOMOVKeyDown(Sender: TObject; var Key: Word;  Shift: TShiftState);
begin
  if (Shift = []) and (key = VK_F10) then
     begin
       key := 0;
       xNumDevolucao := 2;
       fPrincipal.ValorRetornoInteger := 0;
       xBuscar := True;
       fConsultaTipoPgto.fRetorno := fLancCaixa ;
       fLancCaixa.Enabled := False;
       fConsultaTipoPgto.Show;

     end;
end;

procedure TfLancCaixa.LimparEdits;
begin
  Edit1.Clear;
  edit2.Clear;
  edit3.Clear;
end;

procedure TfLancCaixa.FormKeyPress(Sender: TObject; var Key: Char);
begin
  Key := UpCase(Key);
end;

end.
