unit UnitConnection.Model.Query.IBExpress;

interface

uses UnitConnection.Model.Interfaces,
     IBX.IBQuery,
     IBX.IBDatabase,
     Data.DB,
     System.Classes,
     System.Generics.Collections;

type
  TQueryIBExpress = class(TInterfacedObject, iQuery)
  private
    FQuery: TIBQuery;
    FConnection: iConnection;
    FDataSet: TDataSet;
    FSQL: TStringList;
    FParams: TDictionary<string, variant>;
    FCampoBlob: TDictionary<string, boolean>;
    FIndiceConexao: Integer;
  public
    constructor Create(Value: iConnection);
    destructor Destroy; override;
    class function New(Value: iConnection): iQuery;
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

{ TQueryIBExpress }

function TQueryIBExpress.AddParam(Param: string; Value: variant; Blob: boolean): iQuery;
begin
  Result := Self;
  FParams.AddOrSetValue(Param, Value);
  FCampoBlob.AddOrSetValue(Param, Blob);
end;

function TQueryIBExpress.Clear: iQuery;
begin
  Result := Self;
  FSQL.Clear;
  FParams.Clear;
  FCampoBlob.Clear;
end;

constructor TQueryIBExpress.Create(Value: iConnection);
begin
  FDataSet             := TDataSet.Create(nil);
  FQuery               := TIBQuery.Create(nil);
  FConnection             := Value;
  FIndiceConexao       := FConnection.Connected;
  FQuery.Database      := TIBDatabase(FConnection.GetListaConexoes[FIndiceConexao]);
  FQuery.CachedUpdates := True;
  FSQL                 := TStringList.Create;
  FParams              := TDictionary<string, variant>.Create;
  FCampoBlob           := TDictionary<String, boolean>.Create;
end;

function TQueryIBExpress.DataSet: TDataSet;
begin
  Result := FDataSet;
end;

destructor TQueryIBExpress.Destroy;
begin
  FreeAndNil(FParams);
  FreeAndNil(FSQL);
  FreeAndNil(FCampoBlob);
  FConnection.Disconnected(FIndiceConexao);
  inherited;
end;

function TQueryIBExpress.ExecSQL: iQuery;
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

class function TQueryIBExpress.New(Value: iConnection): iQuery;
begin
  Result := Self.Create(Value);
end;

function TQueryIBExpress.Open: iQuery;
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

function TQueryIBExpress.Open(Value: string): iQuery;
begin
  Result := Self;
  FQuery.Close;
  FQuery.SQL.Clear;
  FQuery.SQL.Add(Value);
  FQuery.Open;
  FDataSet := FQuery;
end;

function TQueryIBExpress.Query: TObject;
begin
  Result := FQuery;
end;

function TQueryIBExpress.Add(Value: string): iQuery;
begin
  Result := Self;
  FSQL.Add(Value);
end;

end.
