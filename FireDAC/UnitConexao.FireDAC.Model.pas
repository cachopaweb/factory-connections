unit UnitConexao.FireDAC.Model;

interface

uses UnitConexao.Model.Interfaces,
     FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
     FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
     FireDAC.Phys, Data.DB, FireDAC.Comp.Client, FireDAC.Phys.FB,
     FireDAC.Phys.FBDef, FireDAC.Phys.IBBase,
     FireDAC.Comp.UI;

type
  TConexaoFireDAC = class(TInterfacedObject, iConexao)
    private
      FConexao: TFDConnection;
      FBLink: TFDPhysFBDriverLink;
      FDGui: TFDGUIxWaitCursor;
      FCaminhoBD: string;
    public
      constructor Create(CaminhoBD: string; Usuario: string = 'SYSDBA'; Senha: string = 'masterkey');
      destructor Destroy; override;
      class function New(CaminhoBD: string; Usuario: string = 'SYSDBA'; Senha: string = 'masterkey') : iConexao;
      function Conexao: TObject;
  end;

implementation
uses System.SysUtils;



{ TConexaoFireDAC }

function TConexaoFireDAC.Conexao: TObject;
begin
  Result := FConexao;
end;

constructor TConexaoFireDAC.Create(CaminhoBD: string; Usuario: string = 'SYSDBA'; Senha: string = 'masterkey');
begin
  FCaminhoBD := CaminhoBD;
  FBLink := TFDPhysFBDriverLink.Create(nil);
  //FBLink.VendorLib := '/home/bin/fbclient.dll';
  FConexao := TFDConnection.Create(nil);
  FConexao.DriverName := 'FB';
  FConexao.Params.Database := FCaminhoBD;
  FConexao.Params.UserName := Usuario;
  FConexao.Params.Password := Senha;
  FConexao.LoginPrompt     := False;
  FConexao.Connected := True;
  FDGui := TFDGUIxWaitCursor.Create(nil);
end;

destructor TConexaoFireDAC.Destroy;
begin
  inherited;
end;

class function TConexaoFireDAC.New(CaminhoBD: string; Usuario: string = 'SYSDBA'; Senha: string = 'masterkey') : iConexao;
begin
  result := Self.Create(CaminhoBD, Usuario, Senha);
end;

end.
