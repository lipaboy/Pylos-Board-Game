unit Controller;

uses GameLogic;
uses GameView;
uses Graph3D;

type
  ControllerT = class
  private
    gameLogicInstance: GameLogicT;
    gameViewInstance: GameViewT;
  public
    constructor Create();
    begin
      gameLogicInstance := new GameLogicT();
      gameViewInstance := new GameViewT(gameLogicInstance);

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
          Key.E : Camera.AddForwardForce();
          Key.Q : Camera.AddBackwardForce();
          Key.Escape: OnClose();
        end;
      end;
    end;

    procedure StartGame();
    begin
      gameLogicInstance.Start();
    end;
  end;

end.