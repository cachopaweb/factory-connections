unit UnitFactory.Conexao.Interbase;

interface

uses UnitConexao.Model.Interfaces,
     UnitConexao.Model.Interbase,
     UnitConexao.Model.Query.Interbase;

type
  TFactoryConexaoInterbase = class(TInterfacedObject, iFactoryConexao)
    private
      FCaminhoBD: string;
    public
      constructor Create;
      destructor Destroy; override;
      class function New : iFactoryConexao;
      function Conexao(CaminhoBD: string): iConexao;
      function Query(Conexao: iConexao): iQuery;
  end;

implementation



{ TFactoryConexaoInterbase }

function TFactoryConexaoInterbase.Conexao(CaminhoBD: string): iConexao;
begin
  FCaminhoBD := CaminhoBD;
  Result := TConexaoInterbase.New(CaminhoBD);
end;

constructor TFactoryConexaoInterbase.Create;
begin

end;

destructor TFactoryConexaoInterbase.Destroy;
begin

  inherited;
end;

class function TFactoryConexaoInterbase.New: iFactoryConexao;
begin
  result := Self.Create;
end;

function TFactoryConexaoInterbase.Query(Conexao: iConexao): iQuery;
begin
  Result := TQueryInterbase.New(Conexao);
end;

end.
