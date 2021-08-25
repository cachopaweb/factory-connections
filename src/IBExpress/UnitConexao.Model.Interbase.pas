unit UnitConexao.Model.Interbase;

interface

uses UnitConexao.Model.Interfaces, IBX.IBDatabase, System.Generics.Collections;

type
  TConexaoInterbase = class(TInterfacedObject, iConexao)
    private
      FConexao: TIBDatabase;
      FTransacao: TIBTransaction;
      FCaminhoBD: string;
      FUsuario  : string;
      FSenha    : string;
      FConnList: TObjectList<TObject>;
    public
      class var Instancia: iConexao;
      constructor Create(CaminhoBD: string; Usuario: string = 'SYSDBA'; Senha: string = 'masterkey');
      destructor Destroy; override;
      class function New(CaminhoBD: string; Usuario: string = 'SYSDBA'; Senha: string = 'masterkey'; Singleton: Boolean = true): iConexao;
      function Connected : Integer;
      procedure Disconnected(Index : Integer);
      function GetListaConexoes: TObjectList<TObject>;
  end;

implementation

uses
  System.SysUtils;



{ TConexaoInterbase }

function TConexaoInterbase.Connected: Integer;
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
  FTransacao := TIBTransaction.Create(nil);
  FTransacao.DefaultDatabase := TIBDataBase(Self);
end;

constructor TConexaoInterbase.Create(CaminhoBD: string; Usuario: string = 'SYSDBA'; Senha: string = 'masterkey');
begin
  FCaminhoBD := CaminhoBD;
  FUsuario := Usuario;
  FSenha := Senha;
end;

destructor TConexaoInterbase.Destroy;
begin
  FreeAndNil(FConexao);
  inherited;
end;

procedure TConexaoInterbase.Disconnected(Index: Integer);
begin

end;

function TConexaoInterbase.GetListaConexoes: TObjectList<TObject>;
begin

end;

class function TConexaoInterbase.New(CaminhoBD: string; Usuario: string = 'SYSDBA'; Senha: string = 'masterkey'; Singleton: Boolean = true): iConexao;
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
