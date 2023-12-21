unit Controller;

uses Graph3D;

uses Utils;
uses GameLogic;
uses GameView;
uses AutoPlayGame;

type
  ControllerT = class
  private
    gameLogicInstance: GameLogicT;
    gameViewInstance: GameViewT;
    autoPlayGameInstance: AutoPlayGameT;
  public
    constructor Create();
    begin
      gameLogicInstance := new GameLogicT();
      gameViewInstance := new GameViewT(gameLogicInstance);
      autoPlayGameInstance := new AutoPlayGameT(gameLogicInstance);

      gameLogicInstance.Subscribe(gameViewInstance);

      OnKeyDown += procedure(k: Key) -> begin
        var forwardVec := Camera.LookDirection;
        forwardVec.Normalize();
        // var leftVec := -Vector3D.CrossProduct(forwardVec, Camera.UpDirection);
        case k of
          Key.W : Camera.AddUpForce();
          // нужно запоминать какую клавишу мы нажали и забывать клавиши которые мы отпустили
          // Key.S, Key.A : Camera.Position += - forwardVec + leftVec;
          Key.S : Camera.AddDownForce();
          Key.A : Camera.AddLeftForce();
          Key.D : Camera.AddRightForce();
          // Key.Q : Camera.Rotate(V3D(0, 0, 1), 10);
        end;
      end;
    end;

    procedure StartGame();
    begin
      gameLogicInstance.Start();
      if IS_AUTO_PLAY_MODE_ON then
        autoPlayGameInstance.Play();
    end;
  end;

end.