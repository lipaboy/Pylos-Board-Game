unit Utils;

uses Logger;
uses Graph3D;

/////////////   Auto-play Mode   //////////////

// {$define AUTO_PLAY}
const
{$ifdef AUTO_PLAY}
  IS_AUTO_PLAY_MODE_ON = true;
{$else}
  IS_AUTO_PLAY_MODE_ON = false;
{$endif}

/////////////   Loging (only in debug mode)   //////////////

  procedure logln(message: string := '');
  begin
    {$ifdef DEBUG}
      var now := DateTime.Now.ToString('dd-MM-yyyy');
      var f := OpenAppend(now + '.log', Encoding.UTF8);
      Println(f, message);
      f.Close();
    {$endif}
  end;

  procedure log(message: string);
  begin
    {$ifdef DEBUG}
      var now := DateTime.Now.ToString('dd-MM-yyyy');
      var f := OpenAppend(now + '.log', Encoding.UTF8);
      Print(f, message);
      f.Close();
    {$endif}
  end;

  procedure clearLogFile();
  begin
    {$ifdef DEBUG}
      var now := DateTime.Now.ToString('dd-MM-yyyy');
      var f := OpenWrite(now + '.log', Encoding.UTF8);
      Print(f, '');
      f.Close();
    {$endif}
  end;
  
end.