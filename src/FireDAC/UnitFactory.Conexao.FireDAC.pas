unit UnitFactory.Conexao.FireDAC;

interface

uses UnitConexao.Model.Interfaces,
     UnitConexao.FireDAC.Model,
     UnitQuery.FireDAC.Model;

type
  TFactoryConexaoFireDAC = class(TInterfacedObject, iFactoryConexao)
    private
      FConexao: iConexao;
    public
      constructor Create(CaminhoBD: string; Usuario: string = 'SYSDBA'; Senha: string = 'masterkey'; Singleton: Boolean = true);
      destructor Destroy; override;
      class function New(CaminhoBD: string; Usuario: string = 'SYSDBA'; Senha: string = 'masterkey'; Singleton: Boolean = true) : iFactoryConexao;
      function Query: iQuery;
  end;

implementation



{ TFactoryConexaoFireDAC }

constructor TFactoryConexaoFireDAC.Create(CaminhoBD: string; Usuario: string = 'SYSDBA'; Senha: string = 'masterkey'; Singleton: Boolean = true);
begin
  FConexao := TConexaoFireDAC.New(CaminhoBD, Usuario, Senha, Singleton);
end;

destructor TFactoryConexaoFireDAC.Destroy;
begin

  inherited;
end;

class function TFactoryConexaoFireDAC.New(CaminhoBD: string; Usuario: string = 'SYSDBA'; Senha: string = 'masterkey'; Singleton: Boolean = true) : iFactoryConexao;
begin
  result := Self.Create(CaminhoBD, Usuario, Senha, Singleton);
end;

function TFactoryConexaoFireDAC.Query: iQuery;
begin
  Result := TQueryFireDAC.New(FConexao);
end;

end.
