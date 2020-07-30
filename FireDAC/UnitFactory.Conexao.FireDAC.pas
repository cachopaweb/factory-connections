unit UnitFactory.Conexao.FireDAC;

interface

uses UnitConexao.Model.Interfaces,
     UnitConexao.FireDAC.Model,
     UnitQuery.FireDAC.Model;

type
  TFactoryConexaoFireDAC = class(TInterfacedObject, iFactoryConexao)
    private
      FCaminhoBD: string;
    public
      constructor Create;
      destructor Destroy; override;
      class function New : iFactoryConexao;
      function Conexao(CaminhoBD: string; Usuario: string = 'SYSDBA'; Senha: string = 'masterkey'): iConexao;
      function Query(Conexao: iConexao): iQuery;
  end;

implementation



{ TFactoryConexaoFireDAC }

function TFactoryConexaoFireDAC.Conexao(CaminhoBD: string; Usuario: string = 'SYSDBA'; Senha: string = 'masterkey'): iConexao;
begin
  FCaminhoBD := CaminhoBD;
  Result := TConexaoFireDAC.New(CaminhoBD, Usuario, Senha);
end;

constructor TFactoryConexaoFireDAC.Create;
begin

end;

destructor TFactoryConexaoFireDAC.Destroy;
begin

  inherited;
end;

class function TFactoryConexaoFireDAC.New: iFactoryConexao;
begin
  result := Self.Create;
end;

function TFactoryConexaoFireDAC.Query(Conexao: iConexao): iQuery;
begin
  Result := TQueryFireDAC.New(Conexao);
end;

end.
