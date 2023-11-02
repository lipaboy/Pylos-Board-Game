uses Controller;
uses utils;

begin 
  try
    clearLogFile();
    var gameInstance := new ControllerT();
    gameInstance.StartGame();
  except
    on e: System.IndexOutOfRangeException do
      utils.logln(e.Message);
    on e: System.NullReferenceException do
      utils.logln(e.Message);
    on e: System.IO.IOException do
      utils.logln(e.Message);
    on e:System.SystemException do
      utils.logln(e.Message);
    else
      utils.logln('else exception');
  end;
end.