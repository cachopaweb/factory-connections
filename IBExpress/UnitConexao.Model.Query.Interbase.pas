unit UnitConexao.Model.Query.Interbase;

interface

uses UnitConexao.Model.Interfaces, IBX.IBQuery, IBX.IBDatabase, Data.DB,
  System.Classes;

type
  TQueryInterbase = class(TInterfacedObject, iQuery)
    private
      FQuery: TIBQuery;
      FConexao: iConexao;
      FDatasource: TDataSource;
      FSQL: TStringList;
    public
      constructor Create(Value: iConexao);
      destructor Destroy; override;
      class function New(Value: iConexao) : iQuery;
      function Open(Value: string): iQuery;
      function Add(Value: string): iQuery;
      function ExecSQL: iQuery;
      function Query: TObject;
      function DataSource(Value: TDataSource): iQuery;
  end;

implementation

uses
  System.SysUtils;



{ TQueryInterbase }

constructor TQueryInterbase.Create(Value: iConexao);
begin
  FQuery := TIBQuery.Create(nil);
  FConexao := Value;
  FQuery.Database := TIBDataBase(FConexao.Conexao);
  FQuery.Transaction := TIBTransaction(FConexao.Transacao);
  FQuery.CachedUpdates := True;
  FSQL := TStringList.Create;
end;

function TQueryInterbase.DataSource(Value: TDataSource): iQuery;
begin
  Result := Self;
  FDatasource := Value;
end;

destructor TQueryInterbase.Destroy;
begin
  FreeAndNil(FSQL);
  inherited;
end;

function TQueryInterbase.ExecSQL: iQuery;
begin
  try
    FQuery.Close;
    FQuery.SQL.Clear;
    FQuery.SQL.Add(FSQL.Text);
    FQuery.Open;
    if Assigned(FDatasource) then
      FDatasource.DataSet := FQuery;
    FQuery.Transaction.CommitRetaining;
  except on E: exception do
    begin
      FQuery.Transaction.RollbackRetaining;
      raise Exception.Create(E.Message);
    end;
  end;
end;

class function TQueryInterbase.New(Value: iConexao) : iQuery;
begin
  result := Self.Create(Value);
end;

function TQueryInterbase.Open(Value: string): iQuery;
begin
  Result := Self;
  FQuery.Close;
  FQuery.SQL.Clear;
  FQuery.SQL.Add(Value);
  FQuery.Open;
  if Assigned(FDatasource) then
    FDatasource.DataSet := FQuery;
end;

function TQueryInterbase.Query: TObject;
begin
   Result := FQuery;
end;

function TQueryInterbase.Add(Value: string): iQuery;
begin
  Result := Self;
  FSQL.Add(Value);
end;

end.
