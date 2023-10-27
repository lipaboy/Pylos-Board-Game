uses Controller;

procedure log(message: string);
begin
  var f := OpenWrite('logError.txt', Encoding.UTF8);
  Println(f, message);
  f.Flush();
  Println(message);
end;

procedure clearLogFile();
begin
  var f := OpenWrite('logError.txt', Encoding.UTF8);
  Print(f, '');
  f.Flush();
end;

begin 
  try
    clearLogFile();
    var gameInstance := new ControllerT();
    gameInstance.StartGame();
  except
    on e: System.IndexOutOfRangeException do
      log(e.Message);
    on e: System.NullReferenceException do
      log(e.Message);
    on e: System.IO.IOException do
      log(e.Message);
    on e:System.SystemException do
      log(e.Message);
    else
      log('else exception');
  end;
end.