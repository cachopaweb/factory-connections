unit UnitFactory.Conexao.Interbase;

interface

uses UnitConexao.Model.Interfaces,
     UnitConexao.Model.Interbase,
     UnitConexao.Model.Query.Interbase;

type
  TFactoryConexaoInterbase = class(TInterfacedObject, iFactoryConexao)
    private
      FConexao: iConexao;
    public
      constructor Create(CaminhoBD: string; Usuario: string = 'SYSDBA'; Senha: string = 'masterkey'; Singleton: Boolean = true);
      destructor Destroy; override;
      class function New(CaminhoBD: string; Usuario: string = 'SYSDBA'; Senha: string = 'masterkey'; Singleton: Boolean = true) : iFactoryConexao;
      function Query: iQuery;
  end;

implementation

{ TFactoryConexaoInterbase }

constructor TFactoryConexaoInterbase.Create(CaminhoBD, Usuario, Senha: string;
  Singleton: Boolean);
begin
  FConexao := TConexaoInterbase.New(CaminhoBD, Usuario, Senha, Singleton);
end;

destructor TFactoryConexaoInterbase.Destroy;
begin

  inherited;
end;

class function TFactoryConexaoInterbase.New(CaminhoBD, Usuario, Senha: string;
  Singleton: Boolean): iFactoryConexao;
begin
  Result := Self.Create(CaminhoBD, Usuario, Senha, Singleton);
end;

function TFactoryConexaoInterbase.Query: iQuery;
begin
  Result := TQueryInterbase.New(FConexao);
end;

end.
