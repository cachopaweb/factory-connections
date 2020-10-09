unit UnitConexao.FireDAC.Model;

interface

uses UnitConexao.Model.Interfaces,
     FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
     FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
     FireDAC.Phys, Data.DB, FireDAC.Comp.Client, FireDAC.Phys.FB,
     FireDAC.Phys.FBDef, FireDAC.Phys.IBBase,
     FireDAC.Comp.UI,
     FireDAC.VCLUI.Wait;

type
  TConexaoFireDAC = class(TInterfacedObject, iConexao)
    private
      FConexao: TFDConnection;
      FTransacao: TFDTransaction;
      FBLink: TFDPhysFBDriverLink;
      FDGui: TFDGUIxWaitCursor;
      FCaminhoBD: string;
    public
      constructor Create(CaminhoBD: string; Usuario: string = 'SYSDBA'; Senha: string = 'masterkey');
      destructor Destroy; override;
      class var Instancia: iConexao;
      class function New(CaminhoBD: string; Usuario: string = 'SYSDBA'; Senha: string = 'masterkey'; Singleton: Boolean = true) : iConexao;
      function Conexao: TObject;
      function Transacao: TObject;
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
  FDGui := TFDGUIxWaitCursor.Create(nil);
  FBLink := TFDPhysFBDriverLink.Create(nil);
  //FBLink.VendorLib := '/home/bin/fbclient.dll';
  FConexao := TFDConnection.Create(nil);
  FConexao.DriverName := 'FB';
  FConexao.Params.Database := FCaminhoBD;
  FConexao.Params.UserName := Usuario;
  FConexao.Params.Password := Senha;
  FConexao.LoginPrompt     := False;
  FTransacao := TFDTransaction.Create(nil);
  FTransacao.Options.AutoCommit := False;
  FTransacao.Options.Isolation := xiReadCommitted;
  FConexao.Transaction := FTransacao;
  FConexao.Connected := True;
end;

destructor TConexaoFireDAC.Destroy;
begin
  inherited;
end;

class function TConexaoFireDAC.New(CaminhoBD: string; Usuario: string = 'SYSDBA'; Senha: string = 'masterkey'; Singleton: Boolean = true) : iConexao;
begin
  if Singleton then
  begin
    if not Assigned(Instancia) then
    begin
      Instancia := Self.Create(CaminhoBD, Usuario, Senha);
    end;
    result := Instancia;
  end else
    Result := Self.Create(CaminhoBD, Usuario, Senha);
end;

function TConexaoFireDAC.Transacao: TObject;
begin
  Result := FTransacao;
end;

end.
