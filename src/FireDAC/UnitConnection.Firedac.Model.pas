unit UnitConnection.Firedac.Model;

interface

uses UnitConnection.Model.Interfaces,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, Data.DB, FireDAC.Comp.Client, FireDAC.Phys.FB,
  FireDAC.Phys.FBDef, FireDAC.Phys.IBBase,
  FireDAC.VCLUI.Wait,
  FireDAC.Comp.UI, System.Generics.Collections;

type
  TConnectionFiredac = class(TInterfacedObject, iConnection)
  private
    FConexao  : TFDConnection;
    FCaminhoBD: string;
    FUsuario  : string;
    FSenha    : string;
    FConnList: TObjectList<TObject>;
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
  FConnList.Free;
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
begin
  if not Assigned(FConnList) then
    FConnList := TObjectList<TObject>.Create;

  FConnList.Add(TFDConnection.Create(nil));
  Result := Pred(FConnList.Count);
  TFDConnection(FConnList.Items[Result]).Params.DriverID := 'FB';
  TFDConnection(FConnList.Items[Result]).Params.Database := FCaminhoBD;
  TFDConnection(FConnList.Items[Result]).Params.UserName := FUsuario;
  TFDConnection(FConnList.Items[Result]).Params.Password := FSenha;
  TFDConnection(FConnList.Items[Result]).Connected;
end;

procedure TConnectionFiredac.Disconnected(Index: Integer);
begin
  TFDConnection(FConnList.Items[Index]).Connected := False;
  FConnList.Items[Index].Free;
  FConnList.TrimExcess;
end;

function TConnectionFiredac.GetListaConexoes: TObjectList<TObject>;
begin
  Result := FConnList;
end;

end.
