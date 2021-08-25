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
      FDataSet: TDataSet;
      FSQL: TStringList;
      FParams: TDictionary<string, variant>;
      FCampoBlob: TDictionary<string, boolean>;
      FIndiceConexao: Integer;
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
      function DataSet: TDataSet;
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
  FParams.Clear;
  FCampoBlob.Clear;
end;

constructor TQueryFireDAC.Create(Value: iConexao);
begin
  FDataSet := TDataSet.Create(nil);
  FQuery := TFDQuery.Create(nil);
  FConexao := Value;
  FIndiceConexao := FConexao.Connected;
  FQuery.Connection  := TFDConnection(FConexao.GetListaConexoes[FIndiceConexao]);
  FQuery.CachedUpdates := True;
  FSQL := TStringList.Create;
  FParams := TDictionary<string, variant>.Create;
  FCampoBlob := TDictionary<String, Boolean>.Create;
end;

function TQueryFireDAC.DataSet: TDataSet;
begin
  Result := FDataSet;
end;

destructor TQueryFireDAC.Destroy;
begin
  FreeAndNil(FParams);
  FreeAndNil(FSQL);
  FreeAndNil(FCampoBlob);
  FConexao.Disconnected(FIndiceConexao);
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
    FDataSet := FQuery;
  except on E: exception do
    begin
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
    FDataSet := FQuery;
  except on E: exception do
    begin
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
  FDataSet := FQuery;
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
