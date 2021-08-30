unit UnitConexao.FireDAC.Model;

interface

uses UnitConexao.Model.Interfaces,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, Data.DB, FireDAC.Comp.Client, FireDAC.Phys.FB,
  FireDAC.Phys.FBDef, FireDAC.Phys.IBBase,
  FireDAC.VCLUI.Wait,
  FireDAC.Comp.UI, System.Generics.Collections;

type
  TConexaoFireDAC = class(TInterfacedObject, iConexao)
  private
    FConexao  : TFDConnection;
    FCaminhoBD: string;
    FUsuario  : string;
    FSenha    : string;
    FConnList: TObjectList<TFDConnection>;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
  public
    constructor Create(CaminhoBD: string; Usuario: string = 'SYSDBA'; Senha: string = 'masterkey');
    destructor Destroy; override;
    class var Instancia: iConexao;
    class function New(CaminhoBD: string; Usuario: string = 'SYSDBA'; Senha: string = 'masterkey'; Singleton: Boolean = true): iConexao;
    function Connected: Integer;
    procedure Disconnected(Index: Integer);
    function GetListaConexoes: TObjectList<TFDConnection>;
  end;

var
  FDriver : TFDPhysFBDriverLink;

implementation

uses System.SysUtils;

{ TConexaoFireDAC }


constructor TConexaoFireDAC.Create(CaminhoBD: string; Usuario: string = 'SYSDBA'; Senha: string = 'masterkey');
begin
  FCaminhoBD := CaminhoBD;
  FUsuario   := Usuario;
  FSenha     := Senha;
  FDGUIxWaitCursor1 := TFDGUIxWaitCursor.Create(nil);
end;

destructor TConexaoFireDAC.Destroy;
begin
  FConnList.Free;
  inherited;
end;

class function TConexaoFireDAC.New(CaminhoBD: string; Usuario: string = 'SYSDBA'; Senha: string = 'masterkey'; Singleton: Boolean = true): iConexao;
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

function TConexaoFireDAC.Connected: Integer;
begin
  if not Assigned(FConnList) then
    FConnList := TObjectList<TFDConnection>.Create;

  FConnList.Add(TFDConnection.Create(nil));
  Result := Pred(FConnList.Count);
  FConnList.Items[Result].Params.DriverID := 'FB';
  FConnList.Items[Result].Params.Database := FCaminhoBD;
  FConnList.Items[Result].Params.UserName := FUsuario;
  FConnList.Items[Result].Params.Password := FSenha;
  FConnList.Items[Result].Connected;
end;

procedure TConexaoFireDAC.Disconnected(Index: Integer);
begin
  FConnList.Items[Index].Connected := False;
  FConnList.Items[Index].Free;
  FConnList.TrimExcess;
end;

function TConexaoFireDAC.GetListaConexoes: TObjectList<TFDConnection>;
begin
  Result := FConnList;
end;

end.
