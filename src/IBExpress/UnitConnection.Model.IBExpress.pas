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
    public
      class var Instancia: iConnection;
      constructor Create(CaminhoBD: string; Usuario: string = 'SYSDBA'; Senha: string = 'masterkey');
      destructor Destroy; override;
      class function New(CaminhoBD: string; Usuario: string = 'SYSDBA'; Senha: string = 'masterkey'; Singleton: Boolean = true): iConnection;
      function Connected : Integer;
      procedure Disconnected(Index : Integer);
      function GetListaConexoes: TObjectList<TObject>;
	end;

var
	FConnList : TObjectList<TIBDatabase>;

implementation

uses
  System.SysUtils;



{ TConnectionIBExpress }

function TConnectionIBExpress.Connected: Integer;
begin
 if not Assigned(FConnList) then
		FConnList := TObjectList<TIBDatabase>.Create;

  FConnList.Add(TIBDatabase.Create(nil));
	Result := Pred(FConnList.Count);
	FConnList.Items[Result].DatabaseName := FCaminhoBD;
	FConnList.Items[Result].Params.AddPair('user_name', FUsuario);
	FConnList.Items[Result].Params.AddPair('password', FSenha);
	FConnList.Items[Result].LoginPrompt := False;
	FConnList.Items[Result].Connected := True;
  FTransaction := TIBTransaction.Create(nil);
  FTransaction.DefaultDatabase := FConnList.Items[Result];
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
	FConnList.Items[Index].Connected := False;
	FConnList.Items[Index].Free;
end;

function TConnectionIBExpress.GetListaConexoes: TObjectList<TObject>;
begin
  Result := TObjectList<TObject>(FConnList);
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
