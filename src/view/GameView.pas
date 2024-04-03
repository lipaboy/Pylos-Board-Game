unit GameView;

uses Index;
uses Cell;
uses GameEventResult;
uses ISubscriber;
uses Players;
uses PlayerEnum;
uses GameLogic;
uses GameSettings;

uses FieldView;
uses SwitchingBall;

uses AddBallAction;
uses MoveBallAction;
uses TakeBallAction;

uses Utils;
uses Mouse;
uses Graph3D;
uses Ball;
uses Timers;

uses SoundPlayer;

type
  GameViewT = class(ISubscriberT)
  private
    m_gameLogic: GameLogicT := nil;

    m_field : FieldViewT;
    m_addBallAction: AddBallActionT;
    m_moveBallAction: MoveBallActionT;
    m_takeBallAction: TakeBallActionT;

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
    if eventResult.IsGameOver then begin
      textStep.Text := m_gameLogic.Player.Who = PlayerEnumT.BrightPlayer ? 
        'Забрал инициативу Светлый игрок'
        : 'Преимущество защитил Тёмный игрок';
      m_stepIndicator.Hide();
    end
    else begin
      textStep.Text := 'Ходит ' + m_gameLogic.Player.Name + ' игрок';
      if m_stepIndicator.Current <> m_gameLogic.Player.Who then
        m_stepIndicator.SetBall(m_gameLogic.Player.Who);
    end;
    textBallCount.Text := 'Счёт: ' + m_gameLogic.PlayersDict.Item[BrightPlayer].BallsRemain
      + ' : ' + m_gameLogic.PlayersDict.Item[DarkPlayer].BallsRemain;

    if eventResult.IsInitializing then begin
      Init();
      m_stepIndicator.SetBall(m_gameLogic.Player.Who);
    end
    else if eventResult.IsAdd then begin
      var ball := new BallType(P3D(0, 0, 0), eventResult.Who, false);
      m_field.SetBall(eventResult.AddToPlaceInd, ball);
      
      logln('GameView: Add ball');

      SoundHandlerT.GetSoundPlayer().PlayKnock();
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
    
    logln('GameView: method Notify');
    
    if eventResult.IsNeedToTake then begin
      m_takeBallAction.IsActionOn := true;
    end;

    logln('INFO: GameView: Processed the GameLogic notification');
  end;

  procedure GameViewT.AddMouseEvent();
  begin
    // -------- Наведение (hover) -------- //

    OnMouseMove += procedure (x, y: real; mb) -> begin
      if m_takeBallAction.IsActionOn then begin
        m_takeBallAction.TryHover(x, y);
      end
      else if m_moveBallAction.IsMoving then begin
        m_moveBallAction.TryHover(x, y);
      end
      else if m_addBallAction.IsMoving then begin
        m_addBallAction.TryHover(x, y);
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

    // -------- Выбор цели (select) -------- //

    OnMouseDown += procedure(x, y, mb) -> begin
      if mb = Mouse.LEFT_BUTTON then begin
        if m_takeBallAction.IsActionOn then begin
          m_takeBallAction.TrySelect();
        end
        else if not m_moveBallAction.IsMoving then
        begin
          if not m_addBallAction.TryPlaceBall(x, y) then
            m_moveBallAction.TrySelect(x, y);
        end
        else
          m_moveBallAction.TrySelect(x, y);
      end
      else if mb = Mouse.RIGHT_BUTTON then begin
        if m_takeBallAction.IsActionOn then begin
          m_takeBallAction.ResetStep();
        end
        else
          m_moveBallAction.ResetStep();
      end;
    end;
  end;

  // _________________ Реализация методов ________________ //

  constructor GameViewT.Create(gameLogic: GameLogicT);
  begin
    m_gameLogic := gameLogic;

    // ---- Создаём сцену ---- //

    View3D.ShowGridLines := False;
    View3D.BackgroundColor := Colors.Black;

    var roomMaterial := 
      Materials.Diffuse(RGB(110,  51,  26)) 
        + Materials.Specular(100, 100) + Materials.Emissive(GrayColor(0));

    // Комната
    roomModel := FileModel3D(0, 0, 0, 'res/Scene/Low_poly_bedroom.obj', roomMaterial);
    roomModel.Rotate(V3D(1, 0, 0), 90);
    roomModel.MoveOn(V3D(-38, -42, -5));
    roomModel.Scale(20);

    // Поле с шарами
    m_field := new FieldViewT(P3D(0, 0, 0));
    
    // Обработка событий
    m_addBallAction := new AddBallActionT(m_gameLogic, m_field);
    m_moveBallAction := new MoveBallActionT(m_gameLogic, m_field);
    m_takeBallAction := new TakeBallActionT(m_gameLogic, m_field);
    
    var baseY := -12.5;
    var textColor := Colors.Brown;
    textDebug := Text3D(0, baseY - 4, 0, '', 2, textColor);
    textDebug.Rotate(V3D(1, 0, 0), 90);
    textStep := Text3D(0, baseY - 2, 0, '', 2, textColor);
    textStep.Rotate(V3D(1, 0, 0), 90);
    textBallCount := Text3D(0, baseY, 0, '', 2, textColor);
    textBallCount.Rotate(V3D(1, 0, 0), 90);

    var pIndicator := P3D(11, baseY, BallType.BASE_RADIUS);
    m_stepIndicator := new SwitchingBallT(pIndicator, pIndicator);
    // m_stepIndicator.Dark.Figure.Scale(1.1);
    // m_stepIndicator.Bright.Figure.Scale(1.1);

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

  end;

end. // module end