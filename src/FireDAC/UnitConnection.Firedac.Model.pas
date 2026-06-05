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
begin
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
        if not FConnList.Items[Result].Connected then
          FConnList.Items[Result].Connected := True;
        Exit;
      end;
    end;

    FConnList.Add(TFDConnection.Create(nil));
    FConnBusy.Add(True);
    Result := Pred(FConnList.Count);
	  FConnList.Items[Result].Params.DriverID := 'FB';
	  FConnList.Items[Result].Params.Database := FCaminhoBD;
	  FConnList.Items[Result].Params.UserName := FUsuario;
	  FConnList.Items[Result].Params.Password := FSenha;
	  FConnList.Items[Result].Params.Add('CharacterSet=utf8');
	  FConnList.Items[Result].Connected := True;
  finally
    TMonitor.Exit(FConnLock);
  end;
end;

procedure TConnectionFiredac.Disconnected(Index: Integer);
begin
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

