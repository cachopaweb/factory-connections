unit UnitFactory.Connection.Firedac;

interface

uses UnitConnection.Model.Interfaces,
     UnitConnection.Firedac.Model,
     UnitQuery.FireDAC.Model;

type
  TFactoryConexaoFiredac = class(TInterfacedObject, iFactoryConnection)
    private
      FConexao: iConnection;
    public
      constructor Create(CaminhoBD: string; Usuario: string = 'SYSDBA'; Senha: string = 'masterkey'; Singleton: Boolean = true);
      destructor Destroy; override;
      class function New(CaminhoBD: string; Usuario: string = 'SYSDBA'; Senha: string = 'masterkey'; Singleton: Boolean = true) : iFactoryConnection;
      function Query: iQuery;
  end;

implementation



{ TFactoryConexaoFireDAC }

constructor TFactoryConexaoFiredac.Create(CaminhoBD: string; Usuario: string = 'SYSDBA'; Senha: string = 'masterkey'; Singleton: Boolean = true);
begin
  FConexao := TConnectionFiredac.New(CaminhoBD, Usuario, Senha, Singleton);
end;

destructor TFactoryConexaoFiredac.Destroy;
begin

  inherited;
end;

class function TFactoryConexaoFiredac.New(CaminhoBD: string; Usuario: string = 'SYSDBA'; Senha: string = 'masterkey'; Singleton: Boolean = true) : iFactoryConnection;
begin
  result := Self.Create(CaminhoBD, Usuario, Senha, Singleton);
end;

function TFactoryConexaoFiredac.Query: iQuery;
begin
  Result := TQueryFirerac.New(FConexao);
end;

end.
