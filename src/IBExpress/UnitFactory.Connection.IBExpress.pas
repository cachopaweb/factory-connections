unit UnitFactory.Connection.IBExpress;

interface

uses UnitConnection.Model.Interfaces,
     UnitConnection.Model.IBExpress,
     UnitConnection.Model.Query.IBExpress;

type
  TFactoryConnectionIBExpress = class(TInterfacedObject, iFactoryConnection)
    private
      FConexao: iConnection;
    public
      constructor Create(CaminhoBD: string; Usuario: string = 'SYSDBA'; Senha: string = 'masterkey'; Singleton: Boolean = true);
      destructor Destroy; override;
      class function New(CaminhoBD: string; Usuario: string = 'SYSDBA'; Senha: string = 'masterkey'; Singleton: Boolean = true) : iFactoryConnection;
      function Query: iQuery;
  end;

implementation

{ TFactoryConexaoInterbase }

constructor TFactoryConnectionIBExpress.Create(CaminhoBD, Usuario, Senha: string;
  Singleton: Boolean);
begin
  FConexao := TConnectionIBExpress.New(CaminhoBD, Usuario, Senha, Singleton);
end;

destructor TFactoryConnectionIBExpress.Destroy;
begin

  inherited;
end;

class function TFactoryConnectionIBExpress.New(CaminhoBD, Usuario, Senha: string;
  Singleton: Boolean): iFactoryConnection;
begin
  Result := Self.Create(CaminhoBD, Usuario, Senha, Singleton);
end;

function TFactoryConnectionIBExpress.Query: iQuery;
begin
  Result := TQueryIBExpress.New(FConexao);
end;

end.
