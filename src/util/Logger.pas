unit Logger;

uses Graph3D;

/////////////   Debug Mode   //////////////

// {$undef DEBUG}
const
{$ifdef DEBUG}
  APP_TITLE = 'Pylos Game (Debug)';
{$else}
  APP_TITLE = 'Pylos Game';
{$endif}


///////////   Logger   //////////////

type
  LogLevel = (llDebug, llInfo, llWarning, llError);

  LoggerT = class
  private
    static instance: LoggerT;
    m_fileName: string;

    constructor Create;

    function LevelToString(level: LogLevel): string;

  public
    static function GetInstance: LoggerT;

    static procedure Log(level: LogLevel; message: string);

    static procedure Debug(message: string);
    static procedure Info(message: string);
    static procedure Warning(message: string);
    static procedure Error(message: string);
  end;

//----------------------

constructor LoggerT.Create;
begin
  var now := DateTime.Now.ToString('dd-MM-yyyy');
  m_fileName := now + '_new.log';

  // clear logs
  if FileExists(m_fileName) then
    DeleteFile(m_fileName);
  // var clearingFile := OpenWrite(m_fileName, Encoding.UTF8);
  // Print(clearingFile, '');
  // clearingFile.Close();
end;

//----------------------

class function LoggerT.GetInstance: LoggerT;
begin
  if instance = nil then
    instance := new LoggerT;

  Result := instance;
end;

//----------------------

function LoggerT.LevelToString(level: LogLevel): string;
begin
  case level of
    llDebug: Result := 'DEBUG';
    llInfo: Result := 'INFO';
    llWarning: Result := 'WARNING';
    llError: Result := 'ERROR';
  end;
end;

//----------------------

class procedure LoggerT.Log(level: LogLevel; message: string);
var
  line: string;
begin
  var logger := LoggerT.GetInstance;
  line := DateTime.Now.ToString('yyyy-MM-dd HH:mm:ss')
          + ' [' + logger.LevelToString(level) + '] '
          + message;

  System.IO.File.AppendAllText(
    logger.m_fileName,
    line + System.Environment.NewLine
  );
end;

//----------------------

class procedure LoggerT.Debug(message: string);
begin
  Log(llDebug, message);
end;

//----------------------

class procedure LoggerT.Info(message: string);
begin
  Log(llInfo, message);
end;

//----------------------

class procedure LoggerT.Warning(message: string);
begin
  Log(llWarning, message);
end;

//----------------------

class procedure LoggerT.Error(message: string);
begin
  Log(llError, message);
end;

//----------------------
  
end.