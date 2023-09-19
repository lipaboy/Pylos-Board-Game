unit Controller;

uses GameLogic;
uses GameView;

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
    end;

    procedure StartGame();
    begin
      gameLogicInstance.Start();
    end;
  end;

end.