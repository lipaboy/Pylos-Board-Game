unit GameView;

uses Index;
uses Cell;
uses ISubscriber;
uses Players;
uses GameLogic;
uses GameSettings;

uses FieldView;
uses SwitchingBall;

uses AddBallAction;
uses MoveBallAction;
uses TakeBallAction;

uses Utils;
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
    m_takeBallAction: TakeBallActionT;

    boardModel: FileModelT := nil;
    roomModel: FileModelT := nil;

    lampObj: FileModelT := nil;
    isDark := false;

    textDebug : TextT;
    textBallCount : TextT;

    textStep : TextT;
    m_stepIndicator : SwitchingBallT;

  public
    constructor Create(gameLogic: GameLogicT);

    procedure Notify(eventResult: GameEventResultT);

  private
    procedure Init();
    begin
      m_field.Clear();
      m_addBallAction.Init();
      m_moveBallAction.Init();
      m_takeBallAction.Init();
      AddMouseEvent();
    end;

    procedure AddMouseEvent();

  end;

  // ---------------- Реализация методов ---------------- //

  procedure GameViewT.Notify(eventResult: GameEventResultT);
  begin
    textStep.Text := 'Ходит ' + m_gameLogic.Player.Name + ' игрок';
    if m_stepIndicator.Current <> m_gameLogic.Player.Who then
      m_stepIndicator.SetBall(m_gameLogic.Player.Who);

    textBallCount.Text := 'Счёт: ' + m_gameLogic.PlayersDict.Item[BrightPlayer].BallsRemain
      + ' : ' + m_gameLogic.PlayersDict.Item[DarkPlayer].BallsRemain;

    if eventResult.IsInitializing then begin
      Init();
      m_stepIndicator.SetBall(m_gameLogic.Player.Who);

      // Debug
      var kek : procedure(x, y: real; mousebutton: integer) := OnMouseMove;
      OnMouseMove := procedure (x,y,m) -> begin end;
      // m_addBallAction.Hover((0, 0, 0)); m_addBallAction.TryPlaceBall(0, 0);
      // m_addBallAction.Hover((4, 0, 0)); m_addBallAction.TryPlaceBall(0, 0);
      // m_addBallAction.Hover((2, 0, 0)); m_addBallAction.TryPlaceBall(0, 0);
      // m_addBallAction.Hover((6, 0, 0)); m_addBallAction.TryPlaceBall(0, 0);
      // m_addBallAction.Hover((0, 2, 0)); m_addBallAction.TryPlaceBall(0, 0);
      // m_addBallAction.Hover((4, 2, 0)); m_addBallAction.TryPlaceBall(0, 0);
      OnMouseMove := kek;
    end
    else if eventResult.IsAdd then begin
      var ball := new BallType(P3D(0, 0, 0), eventResult.Who, false);
      m_field.SetBall(eventResult.AddToPlaceInd, ball);
    end
    else if eventResult.IsMove then begin
      var ball := m_field.Get(eventResult.MoveBallInd);
      ball.Visible := false;
      m_field.SetBall(eventResult.MoveBallInd, nil);
      m_field.SetBall(eventResult.MovePlaceInd, ball);
      ball.Visible := true;
    end
    else if eventResult.IsTaken then begin
      foreach var ballInd: IndexT in eventResult.BallsTaken do begin
        var ball := m_field.Get(ballInd);
        ball.Visible := false;
        m_field.SetBall(ballInd, nil);
      end;
      m_takeBallAction.IsActionOn := false;
    end;
    
    logln('gameview');
    if eventResult.IsNeedToTake then begin
      m_takeBallAction.IsActionOn := true;
    end;
  end;

  procedure GameViewT.AddMouseEvent();
  begin
    // _________________ Наведение (hover) ________________ //

    OnMouseMove += procedure (x, y: real; mb) -> begin
      if m_takeBallAction.IsActionOn then begin
        m_takeBallAction.TryHover(x, y);
      end
      else if m_moveBallAction.IsStepLocked then begin
        m_moveBallAction.TryHover(x, y);
      end
      else begin
        var moveHoverSuccess := m_moveBallAction.TryHover(x, y);
        if not moveHoverSuccess then begin
          m_addBallAction.TryHover(x, y);
        end
        else
          m_addBallAction.UnHover();
      end;
    end;

    // _________________ Выбор цели (select) ________________ //

    OnMouseDown += procedure(x, y, mb) -> begin
      if mb = 1 then begin
        if m_takeBallAction.IsActionOn then begin
          m_takeBallAction.TrySelect();
        end
        else if not m_moveBallAction.IsStepLocked then
        begin
          if not m_addBallAction.TryPlaceBall(x, y) then
            m_moveBallAction.TrySelect(x, y);
        end
        else
          m_moveBallAction.TrySelect(x, y);
      end
      else if mb = 2 then begin
        if m_takeBallAction.IsActionOn then begin
          m_takeBallAction.ResetStep();
        end
        else
          m_moveBallAction.ResetStep();
      end;
    end;
  end;

  constructor GameViewT.Create(gameLogic: GameLogicT);
  begin
    m_gameLogic := gameLogic;
    m_addBallAction := new AddBallActionT(m_gameLogic, m_field);
    m_moveBallAction := new MoveBallActionT(m_gameLogic, m_field);
    m_takeBallAction := new TakeBallActionT(m_gameLogic, m_field);

    // ---- Создаём сцену ---- //

    View3D.ShowGridLines := False;
    View3D.BackgroundColor := Colors.Black;

    var boardMaterial := 
      Materials.Diffuse(RGB(110,  51,  26)) 
        + Materials.Specular(100, 100) + Materials.Emissive(GrayColor(0));

    roomModel := FileModel3D(0, 0, 0, 'res/Scene/Low_poly_bedroom.obj', boardMaterial);
    roomModel.Rotate(V3D(1, 0, 0), 90);
    roomModel.MoveOn(V3D(-38, -42, -5));
    roomModel.Scale(20);

    boardModel := FileModel3D(0, 0, 0, 'res/pylos_board.obj', boardMaterial);
    boardModel.Scale(0.2);
    
    var baseY := -12.5;
    var textColor := Colors.Brown;
    textDebug := Text3D(0, baseY - 4, 0, '', 2, textColor);
    textDebug.Rotate(V3D(1, 0, 0), 90);
    textStep := Text3D(0, baseY - 2, 0, '', 2, textColor);
    textStep.Rotate(V3D(1, 0, 0), 90);
    textBallCount := Text3D(0, baseY, 0, '', 2, textColor);
    textBallCount.Rotate(V3D(1, 0, 0), 90);

    var pIndicator := P3D(11, baseY, BASE_RADIUS);
    m_stepIndicator := new SwitchingBallT(pIndicator, pIndicator);
    m_stepIndicator.Dark.Figure.Scale(1.2);
    m_stepIndicator.Bright.Figure.Scale(1.2);

    lampObj := FileModel3D(14, -5, -1, 'res/Lamp.obj', Materials.Specular(100, 100) );
    lampObj.Rotate(V3D(1, 0, 0), 90);
    lampObj.Scale(8);
    OnMouseDown += procedure (x,y,mb) -> begin
      if mb<>1 then 
        exit;
      var v := FindNearestObject(x,y);
      if v = lampObj then
      begin
        while Lights.Count > 0 do begin
          Lights.RemoveLight(0);
        end;
        isDark := not isDark;
        if isDark then begin
          // Тёмное освещение
          var c1 := RGB(155, 155, 0);
          var c2 := RGB(0, 155, 155);
          var c3 := RGB(155, 0, 155);
          var c4 := RGB(255, 255, 255);
          Lights.AddSpotLight(c1, P3D(5, 5, 5), V3D(-1, -1, -1), 120, 45);
          Lights.AddSpotLight(c2, P3D(15, 5, 5), V3D(-1, -1, -1), 120, 45);
          Lights.AddSpotLight(c3, P3D(5, 15, 5), V3D(-1, -1, -1), 120, 45);
          Lights.AddSpotLight(c4, P3D(0, -13, 10), V3D(0, -1, -10), 100, 90);
        end
        else begin
          Lights.AddDirectionalLight(RGB(255, 255, 200),V3D(-1,-1,-4));
        end;
      end;
    end;

    Invoke(()->hvp.Children.RemoveAt(1));
    Lights.AddDirectionalLight(RGB(255, 255, 200),V3D(-1,-1,-4));
    // Lights.AddDirectionalLight(RGB(255, 0, 0),V3D(-1,-1,-4));
    // Lights.AddDirectionalLight(RGB(0, 255, 0),V3D(-1,1,-4));
    // Lights.AddDirectionalLight(RGB(0, 0, 255),V3D(1,-1,-4));

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