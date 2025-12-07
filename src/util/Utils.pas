unit Utils;

uses Graph3D;

/////////////   Debug Mode   //////////////

// {$undef DEBUG}
const
{$ifdef DEBUG}
  APP_TITLE = 'Pylos Game (Debug)';
{$else}
  APP_TITLE = 'Pylos Game';
{$endif}

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
      var f := OpenAppend('log.txt', Encoding.UTF8);
      Println(f, message);
      f.Close();
    {$endif}
  end;

  procedure log(message: string);
  begin
    {$ifdef DEBUG}
      var f := OpenAppend('log.txt', Encoding.UTF8);
      Print(f, message);
      f.Close();
    {$endif}
  end;

  procedure clearLogFile();
  begin
    {$ifdef DEBUG}
      // TODO: вывести дату начала ведения лога
      var f := OpenWrite('log.txt', Encoding.UTF8);
      Print(f, '');
      f.Close();
    {$endif}
  end;
  
end.