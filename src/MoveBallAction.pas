unit MoveBallAction;

uses Graph3D;

uses Index;
uses utils;
uses GameLogic;
uses GameSettings;
uses FieldView;
uses Ball;
uses Players;

type
  MoveBallStateEnumT = (BALL, PLACE);

type
  MoveBallActionT = class
  private
    m_field: FieldViewT;
    m_gameLogic: GameLogicT;
    m_state: MoveBallStateEnumT;

    m_hoverBall: IndexT := EmptyIndex();

    m_selectedBall: IndexT := EmptyIndex();
    m_fantomBrightBall: BallType;
    m_fantomDarkBall: BallType;
    m_currentPlayerBall: BallType;

  public
    constructor Create(gameLogic: GameLogicT; field: FieldViewT);
    begin 
      m_field := field;
      m_gameLogic := gameLogic;
      m_fantomBrightBall := new BallType(P3D(0, 0, 0), PlayerEnumT.BrightPlayer, false);
      m_fantomDarkBall := new BallType(P3D(0, 0, 0), PlayerEnumT.DarkPlayer, false);
      m_currentPlayerBall := m_fantomDarkBall;
    end;

    procedure Init();
    begin
      m_hoverBall := EmptyIndex();
      m_selectedBall := EmptyIndex();
      m_state := MoveBallStateEnumT.BALL;
      UpdateCurrentPlayerBall();
    end;

    property IsStepLocked: boolean read (m_state = MoveBallStateEnumT.PLACE);
    property HoveredBall: IndexT read m_hoverBall;
    property SelectedBall: IndexT read m_selectedBall;

    procedure Hover(ballInd: IndexT);
    procedure UnHover() := Hover(EmptyIndex());
    function TryHover(x, y: real): boolean;

    procedure ResetStep();
    procedure SelectBall(x, y: real; selected: boolean);

  private
    function FindNearestAvailableIndex(x, y: real) : IndexT;
    procedure UpdateCurrentPlayerBall();
  end;

  // _________________ Реализация методов ________________ //

  procedure MoveBallActionT.Hover(ballInd: IndexT);
  begin
    UpdateCurrentPlayerBall();
    if ballInd = m_hoverBall then
      exit;

    if m_hoverBall <> EmptyIndex() then
      m_field.Get(m_hoverBall).SetHovered(false);

    m_hoverBall := ballInd;

    if ballInd <> EmptyIndex() then begin
      m_field.Get(ballInd).SetHovered(true);
    end;
  end;

  procedure MoveBallActionT.ResetStep();
  begin
    m_state := MoveBallStateEnumT.BALL;
    if Self.HoveredBall <> EmptyIndex() then
      m_field.Get(Self.HoveredBall).SetSelected(false);
    if Self.SelectedBall <> EmptyIndex() then
      m_field.Get(Self.SelectedBall).SetSelected(false);
    m_hoverBall := EmptyIndex();
    m_selectedBall := EmptyIndex();
  end;

  procedure MoveBallActionT.SelectBall(x, y: real; selected: boolean);
  begin
    if Self.HoveredBall <> EmptyIndex() then begin
      m_state := MoveBallStateEnumT.PLACE;
      m_field.Get(Self.HoveredBall).SetSelected(selected);
    end;
  end;

  function MoveBallActionT.TryHover(x, y: real): boolean;
  begin
    if m_state = MoveBallStateEnumT.BALL then begin
      var ind := FindNearestAvailableIndex(x, y);
      Hover(ind);
      if ind <> EmptyIndex() then begin
        Result := true;
      end
      else
        Result := false;
    end
    else
      Result := false;
  end;

  function MoveBallActionT.FindNearestAvailableIndex(x, y: real) : IndexT;
  begin
    var indFound := EmptyIndex();

    // var hoverInd := m_addBallAction.GetHoveredPlace();
    // if (hoverInd <> EmptyIndex()) 
    //   and (GetRay(x, y).DistanceToPoint(m_field.GetCoord(hoverInd)) <= BASE_RADIUS) then
    // begin
    //   textDebug.Text := '' + ToStr(hoverInd);
    //   Result := hoverInd;
    //   exit;
    // end;

    var nearest := real.MaxValue;

    foreach var pair: AvailableMovesT in m_gameLogic.BallsToMove do begin
      if pair[1].Count() > 0 then
      begin
        var p := m_field.GetCoord(pair[0]);
        // коэффициент 1.1 выбран, чтобы область выделения шара была чуть больше чем размер
        // самого шара
        if GetRay(x, y).DistanceToPoint(p) <= BASE_RADIUS * 1.1 then
        begin
          var dstToCamera := Camera.Position.Distance(p);
          if dstToCamera < nearest then begin
            indFound := pair[0];
            nearest := dstToCamera;
          end;
        end;
      end;
    end;

    Result := indFound;
  end;

  procedure MoveBallActionT.UpdateCurrentPlayerBall();
  begin
    var ball := m_gameLogic.Player.Who = PlayerEnumT.BrightPlayer
      ? m_fantomBrightBall : m_fantomDarkBall;
    if m_currentPlayerBall <> ball then
      m_currentPlayerBall.Visible := False;
    m_currentPlayerBall := ball;
  end;

end.