unit UnitConexao.Model.Interfaces;

interface

uses
  Data.DB;
  type
    iConexao = interface
      ['{FA5FBBEB-2FDF-4395-8994-61D1DD98D8FD}']
      function Conexao: TObject;
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
      function DataSource(Value: TDataSource): iQuery;
    end;

    iProdutos = interface
      ['{CA36B1F7-F79A-45A1-A2B8-D3DDA0610ADB}']
      function SetCodigo(Value: integer): iProdutos;
    end;

    iEntidades = interface
      ['{D752FE22-A63C-4F3A-908E-A7442613AEA5}']
      function Produtos: iProdutos;
    end;

    iFactoryConexao = interface
      ['{4830BCA5-B7F0-4592-B6EE-D85F9A126867}']
      function Conexao(CaminhoBD: string; Usuario: string = 'SYSDBA'; Senha: string = 'masterkey'): iConexao;
      function Query(Conexao: iConexao): iQuery;
    end;

implementation

end.
