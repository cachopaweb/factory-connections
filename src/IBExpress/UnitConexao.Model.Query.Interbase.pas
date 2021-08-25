unit UnitConexao.Model.Query.Interbase;

interface

uses UnitConexao.Model.Interfaces, IBX.IBQuery, IBX.IBDatabase, Data.DB,
  System.Classes, System.Generics.Collections;

type
  TQueryInterbase = class(TInterfacedObject, iQuery)
  private
    FQuery: TIBQuery;
    FConexao: iConexao;
    FDataSet: TDataSet;
    FSQL: TStringList;
    FParams: TDictionary<string, variant>;
    FCampoBlob: TDictionary<string, boolean>;
    FIndiceConexao: Integer;
  public
    constructor Create(Value: iConexao);
    destructor Destroy; override;
    class function New(Value: iConexao): iQuery;
    function Open(Value: string): iQuery; overload;
    function Open: iQuery; overload;
    function Query: TObject;
    function Clear: iQuery;
    function Add(Value: string): iQuery;
    function AddParam(Param: string; Value: variant; Blob: boolean = false): iQuery;
    function ExecSQL: iQuery;
    function DataSet: TDataSet;
  end;

implementation

uses
  System.SysUtils;

{ TQueryInterbase }

function TQueryInterbase.AddParam(Param: string; Value: variant; Blob: boolean): iQuery;
begin
  Result := Self;
  FParams.AddOrSetValue(Param, Value);
  FCampoBlob.AddOrSetValue(Param, Blob);
end;

function TQueryInterbase.Clear: iQuery;
begin
  Result := Self;
  FSQL.Clear;
  FParams.Clear;
  FCampoBlob.Clear;
end;

constructor TQueryInterbase.Create(Value: iConexao);
begin
  FDataSet             := TDataSet.Create(nil);
  FQuery               := TIBQuery.Create(nil);
  FConexao             := Value;
  FIndiceConexao       := FConexao.Connected;
  FQuery.Database      := TIBDatabase(FConexao.GetListaConexoes[FIndiceConexao]);
  FQuery.CachedUpdates := True;
  FSQL                 := TStringList.Create;
  FParams              := TDictionary<string, variant>.Create;
  FCampoBlob           := TDictionary<String, boolean>.Create;
end;

function TQueryInterbase.DataSet: TDataSet;
begin
  Result := FDataSet;
end;

destructor TQueryInterbase.Destroy;
begin
  FreeAndNil(FParams);
  FreeAndNil(FSQL);
  FreeAndNil(FCampoBlob);
  FConexao.Disconnected(FIndiceConexao);
  inherited;
end;

function TQueryInterbase.ExecSQL: iQuery;
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
    FDataSet := FQuery;
  except on E: exception do
    begin
      raise Exception.Create(E.Message);
    end;
  end;
end;

class function TQueryInterbase.New(Value: iConexao): iQuery;
begin
  Result := Self.Create(Value);
end;

function TQueryInterbase.Open: iQuery;
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
    FDataSet := FQuery;
  except on E: exception do
    begin
      raise Exception.Create(E.Message);
    end;
  end;
end;

function TQueryInterbase.Open(Value: string): iQuery;
begin
  Result := Self;
  FQuery.Close;
  FQuery.SQL.Clear;
  FQuery.SQL.Add(Value);
  FQuery.Open;
  FDataSet := FQuery;
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
