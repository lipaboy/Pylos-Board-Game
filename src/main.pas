uses Controller;

begin 
  try
    var gameInstance := new ControllerT();
    gameInstance.StartGame();
  except
    on e: System.IndexOutOfRangeException do
      writeln(e.Message);
    else
      writeln('else exception');
  end;
end.