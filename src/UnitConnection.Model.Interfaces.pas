unit UnitConnection.Model.Interfaces;

interface

uses
  Data.DB, System.Generics.Collections,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Comp.Client, FireDAC.Phys.FB,
  FireDAC.Phys.FBDef, FireDAC.Phys.IBBase,
  FireDAC.Comp.UI;

  type
    iConnection = interface
      ['{FA5FBBEB-2FDF-4395-8994-61D1DD98D8FD}']
      function Connected : Integer;
      procedure Disconnected(Index : Integer);
      function GetListaConexoes: TObjectList<TObject>;
    end;

    iQuery = interface
      ['{16864F5A-8685-41B9-8201-2DE1440D931F}']
      function Open(Value: string): iQuery;overload;
      function Open: iQuery;overload;
      function Query: TObject;
      function Clear: iQuery;
      function Add(Value: string): iQuery;
      function AddParam(Param: string; Value: variant; Blob: Boolean = false): iQuery;
      function ExecSQL: iQuery;
      function DataSet: TDataSet;
    end;

    iFactoryConnection = interface
      ['{4830BCA5-B7F0-4592-B6EE-D85F9A126867}']
      function Query: iQuery;
    end;

implementation

end.
