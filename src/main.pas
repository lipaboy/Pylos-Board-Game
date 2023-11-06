uses Controller;
uses Utils;

begin 
  try
    clearLogFile();
    var gameInstance := new ControllerT();
    gameInstance.StartGame();
  except
    on e: System.IndexOutOfRangeException do
      Utils.logln(e.Message);
    on e: System.NullReferenceException do
      Utils.logln(e.Message);
    on e: System.IO.IOException do
      Utils.logln(e.Message);
    on e:System.SystemException do
      Utils.logln(e.Message);
    else
      Utils.logln('else exception');
  end;
end.