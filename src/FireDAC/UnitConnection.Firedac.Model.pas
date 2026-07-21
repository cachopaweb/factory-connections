unit UnitConnection.Firedac.Model;

interface

uses UnitConnection.Model.Interfaces,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, Data.DB, FireDAC.Comp.Client, FireDAC.Phys.FB,
  FireDAC.Phys.FBDef, FireDAC.Phys.IBBase, FireDAC.Comp.UI, System.Generics.Collections;

type
  TConnectionFiredac = class(TInterfacedObject, iConnection)
  private
    FConexao  : TFDConnection;
    FCaminhoBD: string;
    FUsuario  : string;
    FSenha    : string;
		FDGUIxWaitCursor1: TFDGUIxWaitCursor;
  public
    constructor Create(CaminhoBD: string; Usuario: string = 'SYSDBA'; Senha: string = 'masterkey');
    destructor Destroy; override;
		class var Instancia: iConnection;
		class function New(CaminhoBD: string; Usuario: string = 'SYSDBA'; Senha: string = 'masterkey'; Singleton: Boolean = true): iConnection;
		function Connected: Integer;
		procedure Disconnected(Index: Integer);
		function GetListaConexoes: TObjectList<TObject>;
  end;

var
	FDriver : TFDPhysFBDriverLink;
	FConnList : TObjectList<TFDConnection>;
	FConnBusy : TList<Boolean>;
	FConnLock : TObject;

implementation

uses System.SysUtils;

{ TConexaoFireDAC }


constructor TConnectionFiredac.Create(CaminhoBD: string; Usuario: string = 'SYSDBA'; Senha: string = 'masterkey');
begin
  FCaminhoBD := CaminhoBD;
  FUsuario   := Usuario;
  FSenha     := Senha;
  FDGUIxWaitCursor1 := TFDGUIxWaitCursor.Create(nil);
end;

destructor TConnectionFiredac.Destroy;
begin
  if Assigned(FConnBusy) then
    FConnBusy.DisposeOf;
  if Assigned(FConnList) then
	  FConnList.DisposeOf;
  FDGUIxWaitCursor1.DisposeOf;
  inherited;
end;

class function TConnectionFiredac.New(CaminhoBD: string; Usuario: string = 'SYSDBA'; Senha: string = 'masterkey'; Singleton: Boolean = true): iConnection;
begin
  if Singleton then
  begin
    if not Assigned(Instancia) then
    begin
      Instancia := Self.Create(CaminhoBD, Usuario, Senha);
    end;
    Result := Instancia;
  end
  else
    Result := Self.Create(CaminhoBD, Usuario, Senha);
end;

function TConnectionFiredac.Connected: Integer;
var
  I: Integer;
  Conexao: TFDConnection;
begin
  Conexao := nil;
  TMonitor.Enter(FConnLock);
  try
    if not Assigned(FConnList) then
    begin
		  FConnList := TObjectList<TFDConnection>.Create;
      FConnBusy := TList<Boolean>.Create;
    end;

    for I := 0 to Pred(FConnList.Count) do
    begin
      if not FConnBusy[I] then
      begin
        Result := I;
        FConnBusy[Result] := True;
        Conexao := FConnList.Items[Result];
        Break;
      end;
    end;

    if not Assigned(Conexao) then
    begin
      Conexao := TFDConnection.Create(nil);
      FConnList.Add(Conexao);
      FConnBusy.Add(True);
      Result := Pred(FConnList.Count);
	    Conexao.Params.DriverID := 'FB';
	    Conexao.Params.Database := FCaminhoBD;
	    Conexao.Params.UserName := FUsuario;
	    Conexao.Params.Password := FSenha;
	    Conexao.Params.Add('CharacterSet=utf8');
    end;
  finally
    TMonitor.Exit(FConnLock);
  end;

  try
    if Conexao.Connected and not Conexao.Ping then
      Conexao.Connected := False;
    if not Conexao.Connected then
      Conexao.Connected := True;
  except
    try
      Conexao.Connected := False;
    except
      // A conexao remota pode ter sido encerrada pelo servidor.
    end;
    TMonitor.Enter(FConnLock);
    try
      if Assigned(FConnBusy) and (Result >= 0) and (Result < FConnBusy.Count) then
        FConnBusy[Result] := False;
    finally
      TMonitor.Exit(FConnLock);
    end;
    raise;
  end;
end;

procedure TConnectionFiredac.Disconnected(Index: Integer);
var
  Conexao: TFDConnection;
begin
  Conexao := nil;

  // 1. Obtém a conexão com validação segura de limites
  TMonitor.Enter(FConnLock);
  try
    if Assigned(FConnList) and (Index >= 0) and (Index < FConnList.Count) then
      Conexao := FConnList[Index];
  finally
    TMonitor.Exit(FConnLock);
  end;

  // 2. Trata o encerramento da conexão isoladamente (fora do Lock)
  if Assigned(Conexao) then
  begin
    try
      // Cancela qualquer transação pendente sem travar
      if Conexao.InTransaction then
        Conexao.Rollback;
        
      // Força o desligamento direto se estiver conectado
      if Conexao.Connected then
        Conexao.Connected := False;
    except
      // Se o Rollback ou disconnect suave falhar, força o encerramento
      try
        Conexao.Close; // True ignora erros e força a desconexão do socket
      except
        // Silencia exceções para garantir que o pool recupere o controle
      end;
    end;
  end;

  // 3. Libera o slot na lista de conexões ocupadas (FConnBusy)
  TMonitor.Enter(FConnLock);
  try
    if Assigned(FConnBusy) and (Index >= 0) and (Index < FConnBusy.Count) then
      FConnBusy[Index] := False;
  finally
    TMonitor.Exit(FConnLock);
  end;
end;

function TConnectionFiredac.GetListaConexoes: TObjectList<TObject>;
begin
	Result := TObjectList<TObject>(FConnList);
end;

initialization
  FConnLock := TObject.Create;

finalization
  FConnLock.Free;

end.
