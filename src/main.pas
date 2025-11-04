uses Utils;
uses Controller;
uses Controls, Graph3D;

begin 
  try
    clearLogFile();

    Window.Title := APP_TITLE;
    Window.SetSize(Window.Width * 1.6, Window.Height * 1.3);
    Window.CenterOnScreen;

    var vec := Camera.LookDirection;
    vec.Normalize();
    Camera.MoveOn( vec * -17 );

    // LeftPanel(150,Colors.Orange);
    // var b := new ButtonWPF('Создать шар');

    var gameInstance := new ControllerT(() -> Window.Close());
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