unit UnitConexao.Model.Interbase;

interface

uses UnitConexao.Model.Interfaces, IBX.IBDatabase;

type
  TConexaoInterbase = class(TInterfacedObject, iConexao)
    private
      FConexao: TIBDatabase;
      FTransacao: TIBTransaction;
    public
      constructor Create(CaminhoBD: string);
      destructor Destroy; override;
      class function New(CaminhoBD: string) : iConexao;
      function Conexao: TObject;
  end;

implementation

uses
  System.SysUtils;



{ TConexaoInterbase }

function TConexaoInterbase.Conexao: TObject;
begin
   Result := FConexao;
end;

constructor TConexaoInterbase.Create(CaminhoBD: string);
begin
  try
    FConexao := TIBDatabase.Create(nil);
    FConexao.DatabaseName := CaminhoBD; //'D:\PROJETOS\COMETA\Dados\COMETA.FDB';
    FConexao.Params.AddPair('user_name', 'SYSDBA');
    FConexao.Params.AddPair('password', 'masterkey');
    FConexao.LoginPrompt := False;
    FTransacao := TIBTransaction.Create(nil);
    FTransacao.DefaultDatabase := TIBDataBase(Self.Conexao);
    FConexao.Connected := True;
  except on E : exception do
    begin
      raise Exception.Create('Erro ao conectar!'+sLineBreak+E.Message);
    end;
  end;
end;

destructor TConexaoInterbase.Destroy;
begin
  FreeAndNil(FConexao);
  inherited;
end;

class function TConexaoInterbase.New(CaminhoBD: string) : iConexao;
begin
  result := Self.Create(CaminhoBD);
end;

end.
