unit UnitQuery.FireDAC.Model;

interface

uses UnitConexao.Model.Interfaces, Data.DB,
     System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
     FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
     FireDAC.Phys, FireDAC.Comp.Client, FireDAC.Phys.FB,
     FireDAC.Phys.FBDef, FireDAC.Phys.IBBase, FireDAC.Stan.Param,
     FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet,
     System.Generics.Collections;

type
  TQueryFireDAC = class(TInterfacedObject, iQuery)
    private
      FQuery: TFDQuery;
      FConexao: iConexao;
      FDatasource: TDataSource;
      FSQL: TStringList;
      FParams: TDictionary<string, variant>;
      FCampoBlob: TDictionary<string, boolean>;
    public
      constructor Create(Value: iConexao);
      destructor Destroy; override;
      class function New(Value: iConexao) : iQuery;
      function Open(Value: string): iQuery;overload;
      function Open: iQuery;overload;
      function Add(Value: string): iQuery;
      function AddParam(Param: string; Value: variant; Blob: Boolean = false): iQuery;
      function ExecSQL: iQuery;
      function Query: TObject;
      function Clear: iQuery;
      function DataSource(Value: TDataSource): iQuery;
  end;

implementation

uses
  System.SysUtils;



{ TQueryFireDAC }

function TQueryFireDAC.AddParam(Param: string; Value: variant; Blob: Boolean = false): iQuery;
begin
  Result := Self;
  FParams.AddOrSetValue(Param, Value);
  FCampoBlob.AddOrSetValue(Param, Blob);
end;

function TQueryFireDAC.Clear: iQuery;
begin
  Result := Self;
  FSQL.Clear;
end;

constructor TQueryFireDAC.Create(Value: iConexao);
begin
  FQuery := TFDQuery.Create(nil);
  FConexao := Value;
  FQuery.Connection := TFDConnection(FConexao.Conexao);
  FQuery.CachedUpdates := True;
  FSQL := TStringList.Create;
  FParams := TDictionary<string, variant>.Create;
  FCampoBlob := TDictionary<String, Boolean>.Create;
end;

function TQueryFireDAC.DataSource(Value: TDataSource): iQuery;
begin
  Result := Self;
  FDatasource := Value;
end;

destructor TQueryFireDAC.Destroy;
begin
  FreeAndNil(FParams);
  FreeAndNil(FSQL);
  FreeAndNil(FCampoBlob);
  inherited;
end;

function TQueryFireDAC.ExecSQL: iQuery;
var
  param: string;
  Valor: Variant;
  campoBlob: Boolean;
begin
  try
    FQuery.Close;
    FQuery.SQL.Clear;
    FQuery.SQL.Add(FSQL.Text);
    if FParams.Keys.Count > 0 then
    begin
      for param in FParams.Keys do
      begin
        if FParams.TryGetValue(param, Valor) then
        begin
          FCampoBlob.TryGetValue(param, campoBlob);
          if campoBlob then
          begin
            FQuery.ParamByName(param).AsString := Valor
          end else
            FQuery.ParamByName(param).Value := Valor;
        end;
      end;
    end;
    FQuery.ExecSQL;
    if Assigned(FDatasource) then
      FDatasource.DataSet := FQuery;
  except on E: exception do
    begin
      FQuery.Transaction.RollbackRetaining;
      raise Exception.Create(E.Message);
    end;
  end;
end;

class function TQueryFireDAC.New(Value: iConexao) : iQuery;
begin
  result := Self.Create(Value);
end;

function TQueryFireDAC.Open: iQuery;
var
  param: string;
  Valor: Variant;
begin
  try
    FQuery.Close;
    FQuery.SQL.Clear;
    FQuery.SQL.Add(FSQL.Text);
    if FParams.Keys.Count > 0 then
    begin
      for param in FParams.Keys do
      begin
        if FParams.TryGetValue(param, Valor) then
          FQuery.ParamByName(param).Value := Valor;
      end;
    end;
    FQuery.Open;
    if Assigned(FDatasource) then
      FDatasource.DataSet := FQuery;
  except on E: exception do
    begin
      FQuery.Transaction.RollbackRetaining;
      raise Exception.Create(E.Message);
    end;
  end;
end;

function TQueryFireDAC.Open(Value: string): iQuery;
begin
  Result := Self;
  FQuery.Close;
  FQuery.SQL.Clear;
  FQuery.SQL.Add(Value);
  FQuery.Open;
  if Assigned(FDatasource) then
    FDatasource.DataSet := FQuery;
end;

function TQueryFireDAC.Query: TObject;
begin
   Result := FQuery;
end;

function TQueryFireDAC.Add(Value: string): iQuery;
begin
  Result := Self;
  FSQL.Add(Value);
end;

end.
