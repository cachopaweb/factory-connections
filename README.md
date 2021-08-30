# factory-conection

Create connection queries for Firedac and IBExpress

### For install in your project using [boss](https://github.com/HashLoad/boss):
``` sh
$ boss install https://github.com/CachopaWeb/factory-connections
```

## Sample Factory Connection FireDAC
## Need fbclient.dll next to executable

```delphi

uses System.SysUtils,
     System.Json,
     UnitConnection.Model.Interfaces,
     UnitFactory.Connection.Firedac;

function BuscaClientePorCodigo(Codigo: integer): TJSONArray;
var
  Query: iQuery;
  oJson: TJSONObject;
begin
  Result := TJSONArray.Create; 
  Query := TFactoryConnectionFiredac.New('caminhoBD', 'usuario', 'senha').Query;
  Query.Add('SELECT CLI_CODIGO, CLI_NOME FROM CLIENTES WHERE CLI_CODIGO = :CODIGO');
  Query.AddParm('CODIGO', Codigo);
  Query.Open;
  Query.DataSet.First;
  while not Query.DataSet.Eof do
  begin
    oJson := TJSONObject.Create;
    oJson.AddPair('codigo', TJSONNumber.Create(Query.DataSet.FieldByName('CLI_CODIGO').AsInteger));
    oJson.AddPair('nome', Query.DataSet.FieldByName('CLI_NOME').AsString);
    Result.AddElement(oJson);
    Query.DataSet.Next;
  end;
end.
```

## Sample Factory Connection Interbase/IBExpress
```delphi

uses System.SysUtils,
     System.Json,
     UnitConexao.Model.Interfaces,
     UnitFactory.Connection.IBExpress;

function BuscaClientePorCodigo(Codigo: integer): TJSONArray;
var
  Query: iQuery;
  oJson: TJSONObject;
begin
  Result := TJSONArray.Create; 
  Query := TFactoryConnectionIBExpress.New('caminhoBD', 'usuario', 'senha').Query;
  Query.Add('SELECT CLI_CODIGO, CLI_NOME FROM CLIENTES WHERE CLI_CODIGO = :CODIGO');
  Query.AddParm('CODIGO', Codigo);
  Query.Open;
  Query.DataSet.First;
  while not Query.DataSet.Eof do
  begin
    oJson := TJSONObject.Create;
    oJson.AddPair('codigo', TJSONNumber.Create(Query.DataSet.FieldByName('CLI_CODIGO').AsInteger));
    oJson.AddPair('nome', Query.DataSet.FieldByName('CLI_NOME').AsString);
    Result.AddElement(oJson);
    Query.DataSet.Next;
  end;
end.
```
