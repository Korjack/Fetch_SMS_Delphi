unit FetchSMS;

interface
uses
  System.SysUtils,
  FMX.Helpers.Android,
  Androidapi.JNI.GraphicsContentViewText,
  Androidapi.JNI.Net,
  Androidapi.JNI.JavaTypes,
  Androidapi.JNI.Telephony,
  Androidapi.Helpers;

type
  TStringArray = array of string;

function getSMS(const filtered:string):TStringArray;
function StrInArray(const Value:string; const ArrayOfString:array of string):Boolean;

implementation
function StrInArray(const Value:string; const ArrayOfString:array of string):Boolean;
var
  Loop:string;
begin
  for Loop in ArrayOfString do
  begin
    if Value = Loop then Exit(True)
  end;
  result := False;
end;

function getSMS(const filtered:string):TStringArray;
var
  cursor: JCursor;
  uri: Jnet_Uri;
  address, body:string;
  addressidx, bodyidx:integer;

  msglist:TStringArray;
begin
  uri:=StrToJURI('content://sms/inbox');
  cursor := SharedActivity.getContentResolver.query(uri, nil, nil,nil,nil);
  addressidx:=cursor.getColumnIndex(StringToJstring('address'));
  bodyidx:=cursor.getColumnIndex(StringToJstring('body'));

  while (cursor.moveToNext) do begin
    address:=JStringToString(cursor.getString(addressidx));
    body:=JStringToString(cursor.getString(bodyidx));
    if address = filtered then
      begin
        SetLength(msglist, Length(msglist) + 1);
        msglist[High(msglist)] := {address + '|' + }body;
      end;
  end;
  Result := msglist;
end;

end.
