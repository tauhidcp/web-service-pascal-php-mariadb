unit UWebService;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Grids, Menus, ExtCtrls, fphttpclient, fpjson, jsonparser;

type

  { TFWebService }

  TFWebService = class(TForm)
    BBrowse: TButton;
    BGetData: TButton;
    BSimpan: TButton;
    BUpdate: TButton;
    BDelete: TButton;
    BUpload: TButton;
    BDownload: TButton;
    EFile: TEdit;
    GroupUploadDownload: TGroupBox;
    GroupInsertUpdateDelete: TGroupBox;
    EID: TLabeledEdit;
    ENoHP: TLabeledEdit;
    ENama: TLabeledEdit;
    OpenFile: TOpenDialog;
    GridContact: TStringGrid;
    procedure BBrowseClick(Sender: TObject);
    procedure BGetDataClick(Sender: TObject);
    procedure BSimpanClick(Sender: TObject);
    procedure BUpdateClick(Sender: TObject);
    procedure BDeleteClick(Sender: TObject);
    procedure BUploadClick(Sender: TObject);
    procedure BDownloadClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure GridContactSelectCell(Sender: TObject; aCol, aRow: Integer;
      var CanSelect: Boolean);
  private
    { private declarations }

  public
    { public declarations }
    function UploadFile(aFilename:String):String;
    procedure DownloadFile(URLFile:String;NamaHasil:String);
  end;

var
  FWebService: TFWebService;
  Upload : Boolean;


implementation

{$R *.lfm}

{ TFWebService }

procedure TFWebService.BGetDataClick(Sender: TObject);
  var
    Contact : AnsiString;
    j : integer;
    ParsedArray: TJSONArray;
    Item: TJSONObject;
  begin

    try
        Contact := TFPHTTPClient.SimpleGet('http://localhost/fpcphp/datacontact.php');
        ParsedArray := TJSONArray(GetJSON(Contact));
        GridContact.ColWidths[0]:=10;
        GridContact.RowCount := ParsedArray.Count+1;

        for j := 0 to ParsedArray.Count - 1 do
        begin
          Item := ParsedArray.Objects[j];
          GridContact.Cells[1,j+1] := Item.Get('id','');
          GridContact.Cells[2,j+1] := Item.Get('nama','');
          GridContact.Cells[3,j+1] := Item.Get('nohp','');
        end;

    finally
      ParsedArray.Free;
    end;
  end;

procedure TFWebService.BBrowseClick(Sender: TObject);
begin
   if (OpenFile.Execute) then
      begin
       if not (OpenFile.FileName='') then
           EFile.Text:=OpenFile.FileName;
      end;
end;

procedure TFWebService.BSimpanClick(Sender: TObject);
  var
    Data: TJSONData;
    http : TFPHTTPClient;
    Response : TStringStream;
    JParser  : TJSONParser;
    JDoc     : TJSONObject;
  begin
  if not (ENama.Text='') and not (ENoHP.Text='') then
    begin

    try
      http := TFPHTTPClient.Create(nil);
      Response := TStringStream.Create('');
      Data := GetJSON('{"nama" : "'+ENama.Text+'", "nohp" : "'+ENoHP.Text+'"}');
      http.FormPost('http://localhost/fpcphp/inputcontact.php', Data.AsJSON, Response);
      JParser := TJSONParser.Create(Response.DataString);
      JDoc := TJSONObject(JParser.Parse);
      if (JDoc.FindPath('Status').AsString='DONE') then
        begin
          MessageDlg(JDoc.FindPath('Respon').AsString, mtInformation, [mbOK],0);
          BGetData.Click;
        end else
          MessageDlg(JDoc.FindPath('Respon').AsString, mtWarning, [mbOK],0);
    finally
      Response.Free;
      http.Free;
      JParser.Free;
      JDoc.Free;
    end;
    end;
end;

procedure TFWebService.BUpdateClick(Sender: TObject);
  var
    Data: TJSONData;
    http : TFPHTTPClient;
    Response : TStringStream;
    JParser  : TJSONParser;
    JDoc     : TJSONObject;
  begin
  if not (ENama.Text='') and not (ENoHP.Text='') and not (EID.Text='')  then
    begin

    try
      http := TFPHTTPClient.Create(nil);
      Response := TStringStream.Create('');
      Data := GetJSON('{"nama" : "'+ENama.Text+'", "nohp" : "'+ENoHP.Text+'", "id" : "'+EID.Text+'"}');
      http.FormPost('http://localhost/fpcphp/updatecontact.php', Data.AsJSON, Response);
      JParser := TJSONParser.Create(Response.DataString);
      JDoc := TJSONObject(JParser.Parse);
      if (JDoc.FindPath('Status').AsString='DONE') then
        begin
          MessageDlg(JDoc.FindPath('Respon').AsString, mtInformation, [mbOK],0);
          BGetData.Click;
        end else
          MessageDlg(JDoc.FindPath('Respon').AsString, mtWarning, [mbOK],0);
    finally
      Response.Free;
      http.Free;
      JParser.Free;
      JDoc.Free;
    end;
    end;
end;

procedure TFWebService.BDeleteClick(Sender: TObject);
  var
    Data: TJSONData;
    http : TFPHTTPClient;
    Response : TStringStream;
    JParser  : TJSONParser;
    JDoc     : TJSONObject;
  begin
     if not (EID.Text='') then
      begin
        if MessageDlg('Hapus Data', 'Hapus data "'+ENama.Text+'" ini?', mtConfirmation, [mbYes, mbNo],0) = mrYes then
           begin
            try
              http := TFPHTTPClient.Create(nil);
              Response := TStringStream.Create('');
              Data := GetJSON('{"id" : "'+EID.Text+'"}');
              http.FormPost('http://localhost/fpcphp/deletecontact.php', Data.AsJSON, Response);
              JParser := TJSONParser.Create(Response.DataString);
              JDoc := TJSONObject(JParser.Parse);
              if (JDoc.FindPath('Status').AsString='DONE') then
                begin
                  MessageDlg(JDoc.FindPath('Respon').AsString, mtInformation, [mbOK],0);
                  BGetData.Click;
                end else
                  MessageDlg(JDoc.FindPath('Respon').AsString, mtWarning, [mbOK],0);
            finally
             Response.Free;
             http.Free;
             JParser.Free;
             JDoc.Free;
            end;
           end;
      end else
      MessageDlg('Pilih Data Sebelum Hapus!', mtWarning, [mbOK],0);
  end;

procedure TFWebService.BUploadClick(Sender: TObject);
  begin
    if not (EFile.Text='') then
        begin
             if FileExists(EFile.Text) then
                 if (UploadFile(EFile.Text)='OK') then
                     begin
                     MessageDlg('Upload File Berhasil!', mtInformation, [mbOK],0);
                     Upload:=True;
                     end;
        end else
        MessageDlg('Pilih File Sebelum Upload!', mtWarning, [mbOK],0);
  end;


procedure TFWebService.BDownloadClick(Sender: TObject);
  var
    namahasil,urlfile:String;
  begin
    if (Upload=True) then
        begin
         namahasil   := ExtractFilePath(Application.ExeName)+'/'+ExtractFileName(OpenFile.FileName);
         urlfile     := 'http://localhost/fpcphp/upload/'+StringReplace(ExtractFileName(OpenFile.FileName),' ','%20',[rfReplaceAll, rfIgnoreCase]);
         DownloadFile(urlfile,namahasil);
         MessageDlg('Download File Berhasil!', mtInformation, [mbOK],0);
        end else
        MessageDlg('Upload File Sebelum Download!', mtWarning, [mbOK],0);
  end;

procedure TFWebService.FormCreate(Sender: TObject);
begin
  Upload:=False;
end;

procedure TFWebService.GridContactSelectCell(Sender: TObject; aCol, aRow: Integer;
  var CanSelect: Boolean);
begin
   EID.Text:=GridContact.Cells[1,aRow];
   ENoHP.Text:=GridContact.Cells[3,aRow];
   ENama.Text:=GridContact.Cells[2,aRow];
end;

function TFWebService.UploadFile(aFilename: String):String;
  var
    Respo: TStringStream;
    upload : TFPHttpClient;
    JParser  : TJSONParser;
    JDoc     : TJSONObject;
    hasil : String;
  begin
    hasil := '';
      try
        upload := TFPHTTPClient.Create(nil);
        Respo := TStringStream.Create('');
        upload.FileFormPost('http://localhost/fpcphp/uploadfile.php','fileupload',aFilename,Respo);
        JParser := TJSONParser.Create(Respo.DataString);
        JDoc := TJSONObject(JParser.Parse);
        if (JDoc.FindPath('Status').AsString='DONE') then
           hasil := 'OK' else
             hasil :='FAIL';
      finally
         JDoc.Free;
         JParser.Free;
         Respo.Free;
         upload.Free;
      end;
   Result:=hasil;
  end;

procedure TFWebService.DownloadFile(URLFile:String;NamaHasil:String);
var
  HttpClient: TFPHttpClient;
  Stream: TFileStream;
  URL, OutputFile: string;
begin
  URL := URLFile;
  OutputFile := NamaHasil;
  try
    HttpClient := TFPHttpClient.Create(nil);
    Stream := TFileStream.Create(OutputFile, fmCreate);
    try
      HttpClient.Get(URL, Stream);
    finally
      Stream.Free;
    end;
  except
  end;
  HttpClient.Free;
end;

end.

