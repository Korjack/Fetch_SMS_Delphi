unit Unit1;

interface

uses
  {$IFDEF ANDROID}
  Androidapi.Helpers,
  Androidapi.Jni,
  Androidapi.Jni.Os,
  Androidapi.JNI.App,
  AndroidApi.Jni.JavaTypes,
  AndroidApi.Jni.GraphicsContentViewText,
  FMX.Helpers.Android,
  {$ENDIF}
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, System.Diagnostics,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls,
  FetchSMS, FMX.ListView.Types, FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base, FMX.ListView, FMX.Layouts, FMX.ListBox, FMX.Edit,
  FMX.SearchBox, FMX.Effects, FMX.Objects, FMX.Ani, System.Permissions,
  System.Actions, FMX.ActnList;

type
  TForm1 = class(TForm)
    ListBox1: TListBox;
    SearchBox1: TSearchBox;
    ToolBar1: TToolBar;
    addPhone: TSpeedButton;
    reloadSMS: TSpeedButton;
    Popup1: TPopup;
    whiteBG: TRectangle;
    adding: TButton;
    cancel: TButton;
    PhoneNumber: TEdit;
    blackBG: TRectangle;
    Label1: TLabel;
    PhoneBG: TRectangle;
    procedure FormCreate(Sender: TObject);
    procedure ListBox1ItemClick(const Sender: TCustomListBox;
      const Item: TListBoxItem);
    procedure changePhoneClick(Sender: TObject);
    procedure msgLoadClick(Sender: TObject);
    procedure cancelClick(Sender: TObject);
    procedure addingClick(Sender: TObject);
  private
    { Private declarations }
    FPermissionReadSMS :string;
    FPermissionReadSMSGranted :boolean;
    procedure ReadSMSPermissionRequestResult(Sender: TObject; const APermissions: TArray<String>; const AGrantResult: TArray<TPermissionStatus>);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    procedure Delay(ms:Integer);
  end;

var
  Form1: TForm1;
  showMsgList:TStringArray;
  filterPhone:string;

procedure loadSMS;
procedure savePreference;
procedure getPreference;

implementation

{$R *.fmx}
{$R *.LgXhdpiPh.fmx ANDROID}
{$R *.NmXhdpiPh.fmx ANDROID}
{$R *.SmXhdpiPh.fmx ANDROID}

procedure loadSMS;
var
  msg:string;
begin
  showMsgList := FetchSMS.getSMS(filterPhone);
  Form1.ListBox1.Clear;
  for msg in showMsgList do
    begin
      Form1.ListBox1.Items.Add(msg)
    end;
end;

procedure TForm1.addingClick(Sender: TObject);
var
  Tphone:string;
begin
  if (PhoneNumber.Text = '') then ShowMessage('빈칸으로 입력하셨습니다.')
  else begin
    filterPhone := PhoneNumber.Text;
    savePreference;
    ShowMessage('전화번호 ' + PhoneNumber.Text + ' 의 SMS를 가져옵니다.');
    loadSMS;
  end;
end;

procedure savePreference;
var
  Prefs: JSharedPreferences;
begin
  Prefs := SharedActivity.getPreferences(TJActivity.JavaClass.MODE_PRIVATE);
  Prefs.edit.putString(StringToJString('Phone'), StringToJString(filterPhone));
  Prefs.edit.commit;
end;

procedure getPreference;
var
  Prefs: JSharedPreferences;
begin
  Prefs := SharedActivity.getPreferences(TJActivity.JavaClass.MODE_PRIVATE);
  filterPhone := JStringToString(Prefs.getString(StringToJString('Phone'), StringToJString('')));
end;

procedure TForm1.cancelClick(Sender: TObject);
begin
  Popup1.Visible := False;
  blackBG.Visible := False;
end;

procedure TForm1.changePhoneClick(Sender: TObject);
var
  Tphone:string;
begin
  blackBG.Visible := True;
  Popup1.Visible := True;
  PhoneNumber.Text := filterPhone;
end;

constructor TForm1.Create(AOwner: TComponent);
begin
  inherited;
  FPermissionReadSMSGranted := False;
  FPermissionReadSMS := JStringToString(TJManifest_permission.JavaClass.READ_SMS);
  PermissionsService.RequestPermissions([FPermissionReadSMS], ReadSMSPermissionRequestResult);
  //getPreference;
end;

procedure TForm1.Delay(ms: Integer);
var
  StopWatch: TStopwatch;
begin
  StopWatch := TStopwatch.Create;
  StopWatch.Start;
  repeat
    Application.ProcessMessages;
    Sleep(1);
  until StopWatch.ElapsedMilliseconds >= ms;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  if FPermissionReadSMSGranted then loadSMS
  else ShowMessage('SMS 읽기 미허용으로 SMS를 불러오지 못했습니다.');
end;

procedure TForm1.ListBox1ItemClick(const Sender: TCustomListBox; const Item: TListBoxItem);
begin
  ShowMessage(Item.Text);
end;

procedure TForm1.msgLoadClick(Sender: TObject);
begin
  if FPermissionReadSMSGranted then begin
    loadSMS;
    ShowMessage('SMS 메시지 정상 로딩 되었습니다.');
  end
  else ShowMessage('SMS 읽기 미허용으로 SMS를 불러오지 못했습니다.');
end;

procedure TForm1.ReadSMSPermissionRequestResult(Sender: TObject;
  const APermissions: TArray<String>;
  const AGrantResult: TArray<TPermissionStatus>);
begin
  if (Length(AGrantResult) = 1) and (AGrantResult[0] = TPermissionStatus.Granted) then
    FPermissionReadSMSGranted := True
  else
    SharedActivity.finish
end;

end.
