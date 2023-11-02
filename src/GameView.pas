unit GameView;

uses Index;
uses Cell;
uses ISubscriber;
uses Players;
uses GameLogic;
uses GameSettings;

uses FieldView;
uses AddBallAction;
uses MoveBallAction;

uses utils;
uses Graph3D;
uses Ball;
uses Timers;

type
  GameViewT = class(ISubscriberT)
  private
    m_gameLogic: GameLogicT := nil;

    m_field := new FieldViewT();
    m_addBallAction: AddBallActionT;
    m_moveBallAction: MoveBallActionT;

    boardModel: FileModelT := nil;
    roomModel: FileModelT := nil;
    carpetObj: FileModelT := nil;

    textDebug : TextT;
    textBallCount : TextT;
    textStep : TextT;

  public
    constructor Create(gameLogic: GameLogicT);

    procedure Notify(eventResult: GameEventResultT);

  private
    procedure Init();
    begin
      m_field.Clear();
      m_addBallAction.Init();
      m_moveBallAction.Init();
      AddMouseEvent();
    end;

    procedure AddMouseEvent();

  end;

  // ---------------- Реализация методов ---------------- //

  procedure GameViewT.Notify(eventResult: GameEventResultT);
  begin
    textStep.Text := 'Ходит ' + m_gameLogic.Player.Name + ' игрок';
    textBallCount.Text := 'Счёт: ' + m_gameLogic.PlayersDict.Item[BrightPlayer].BallsRemain
      + ' : ' + m_gameLogic.PlayersDict.Item[DarkPlayer].BallsRemain;

    if eventResult.IsInitializing then
    begin
      Init();
    end
    else if eventResult.IsAdd then
    begin
      var ball := new BallType(P3D(0, 0, 0), eventResult.Who, false);
      m_field.SetBall(eventResult.AddToPlaceInd, ball);
    end;

    textDebug.Text := '' + m_gameLogic.SquareList.Select(v -> ToStr(v)).JoinIntoString(' ');
  end;

  procedure GameViewT.AddMouseEvent();
  begin
    // _________________ Наведение (hover) ________________ //

    OnMouseMove += procedure (x, y: real; mb) -> begin
      // if not m_moveBallAction.IsStepLocked then
      // begin
      //   var addHoverSuccess := m_addBallAction.TryHover(x, y);
      //   if addHoverSuccess then begin
      //     m_moveBallAction.UnHover();
      //     exit;
      //   end;
      // end;
      // m_moveBallAction.TryHover(x, y);

      if not m_moveBallAction.IsStepLocked then
      begin
        var moveHoverSuccess := m_moveBallAction.TryHover(x, y);
        if not moveHoverSuccess then begin
          m_addBallAction.TryHover(x, y);
        end
        else
          m_addBallAction.UnHover();
      end
      else
        m_moveBallAction.TryHover(x, y);
    end;

    // _________________ Выбор цели (select) ________________ //

    OnMouseDown += procedure(x, y, mb) -> begin
      if mb = 1 then begin
        if not m_addBallAction.TryPlaceBall(x, y) then
          m_moveBallAction.SelectBall(x, y, true);
      end
      else if mb = 2 then begin
        m_moveBallAction.ResetStep();
      end;
    end;
  end;

  constructor GameViewT.Create(gameLogic: GameLogicT);
  begin
    m_gameLogic := gameLogic;
    m_addBallAction := new AddBallActionT(m_gameLogic, m_field);
    m_moveBallAction := new MoveBallActionT(m_gameLogic, m_field);

    // ---- Создаём сцену ---- //

    View3D.ShowGridLines := False;
    View3D.BackgroundColor := Colors.Black;

    var boardMaterial := 
      Materials.Diffuse(RGB(110,  51,  26)) 
        + Materials.Specular(150, 100) + Materials.Emissive(GrayColor(0));

    roomModel := FileModel3D(0, 0, 0, 'res/Scene/Low_poly_bedroom.obj', boardMaterial);
    roomModel.Rotate(V3D(1, 0, 0), 90);
    roomModel.MoveOn(V3D(-38, -42, -5));
    roomModel.Scale(20);

    // ImageMaterial('res/carpet.jpg')
    // var mat := ImageMaterial('res/tree_texture.jpg', 10, 10);
    // carpetObj := FileModel3D(0, 0, 0, 'res/Carpet.obj', mat);
    // carpetObj.Rotate(V3D(1, 0, 0), 90);
    // carpetObj.MoveOn(V3D(0, 0, 6));
    // carpetObj.Scale(10);
    // carpetObj.Material := mat;


    boardModel := FileModel3D(0, 0, 0, 'res/pylos_board.obj', boardMaterial);
    boardModel.Scale(0.2);
    
    var baseY := -12.5;
    var textColor := Colors.Brown;
    textDebug := Text3D(0, baseY - 4, 0, 'debug',2, textColor);
    textDebug.Rotate(V3D(1, 0, 0), 90);
    textBallCount := Text3D(0, baseY, 0, '', 2, textColor);
    textBallCount.Rotate(V3D(1, 0, 0), 90);
    textStep := Text3D(0, baseY - 2, 0, '', 2, textColor);
    textStep.Rotate(V3D(1, 0, 0), 90);

    // textDebug.Text := '' + carpetObj.Items[0].X;

    Invoke(()->hvp.Children.RemoveAt(1));
    Lights.AddDirectionalLight(RGB(255, 255, 255),V3D(-1,-1,-4));
    Lights.AddSpotLight(RGB(155, 155, 0), P3D(5, 5, 5), V3D(-1, -1, -1), 120, 45);


    // ---- Создаём шары ---- //

    // for var i := 0 to brightBalls.Length - 1 do begin
    //   var ball := new BallType(P3D(0, 0, 0), BrightPlayer, false);
    //   // var (ex, ey) := (random(2), random(2));
    //   // ball.Rotate(V3D(ex, ey, random(2) + (ex + ey = 0 ? 1  : 0)), random(360));
    //   brightBalls[i] := ball;
    // end;

    // for var i := 0 to darkBalls.Length - 1 do begin
    //   var ball := new BallType(P3D(0, 0, 0), DarkPlayer, false);
    //   darkBalls[i] := ball;
    // end;
  end;

end. // module end