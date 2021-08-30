unit UnitConnection.Model.IBExpress;

interface

uses UnitConnection.Model.Interfaces, IBX.IBDatabase, System.Generics.Collections;

type
  TConnectionIBExpress = class(TInterfacedObject, iConnection)
    private
      FConnection: TIBDatabase;
      FTransaction: TIBTransaction;
      FCaminhoBD: string;
      FUsuario  : string;
      FSenha    : string;
      FConnList: TObjectList<TObject>;
    public
      class var Instancia: iConnection;
      constructor Create(CaminhoBD: string; Usuario: string = 'SYSDBA'; Senha: string = 'masterkey');
      destructor Destroy; override;
      class function New(CaminhoBD: string; Usuario: string = 'SYSDBA'; Senha: string = 'masterkey'; Singleton: Boolean = true): iConnection;
      function Connected : Integer;
      procedure Disconnected(Index : Integer);
      function GetListaConexoes: TObjectList<TObject>;
  end;

implementation

uses
  System.SysUtils;



{ TConnectionIBExpress }

function TConnectionIBExpress.Connected: Integer;
begin
 if not Assigned(FConnList) then
    FConnList := TObjectList<TObject>.Create;

  FConnList.Add(TIBDatabase.Create(nil));
  Result := Pred(FConnList.Count);
  TIBDatabase(FConnList.Items[Result]).DatabaseName := FCaminhoBD;
  TIBDatabase(FConnList.Items[Result]).Params.AddPair('user_name', FUsuario);
  TIBDatabase(FConnList.Items[Result]).Params.AddPair('password', FSenha);
  TIBDatabase(FConnList.Items[Result]).LoginPrompt := False;
  TIBDatabase(FConnList.Items[Result]).Connected := True;
  FTransaction := TIBTransaction.Create(nil);
  FTransaction.DefaultDatabase := TIBDataBase(TIBDatabase(FConnList.Items[Result]));
end;

constructor TConnectionIBExpress.Create(CaminhoBD: string; Usuario: string = 'SYSDBA'; Senha: string = 'masterkey');
begin
  FCaminhoBD := CaminhoBD;
  FUsuario := Usuario;
  FSenha := Senha;
end;

destructor TConnectionIBExpress.Destroy;
begin
  FTransaction.DisposeOf;
  FConnList.DisposeOf;
  inherited;
end;

procedure TConnectionIBExpress.Disconnected(Index: Integer);
begin
  TIBDatabase(FConnList.Items[Index]).Connected := False;
  FConnList.TrimExcess;
end;

function TConnectionIBExpress.GetListaConexoes: TObjectList<TObject>;
begin
  Result := FConnList;
end;

class function TConnectionIBExpress.New(CaminhoBD: string; Usuario: string = 'SYSDBA'; Senha: string = 'masterkey'; Singleton: Boolean = true): iConnection;
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

end.
