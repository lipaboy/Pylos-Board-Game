unit MoveBallAction;

uses Graph3D;

uses Index;
uses Utils;
uses GameLogic;
uses GameSettings;
uses FieldView;
uses Ball;
uses Players;
uses PlayerEnum;

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

    m_hoverPlace: IndexT := EmptyIndex();

  public
    constructor Create(gameLogic: GameLogicT; field: FieldViewT);
    begin 
      m_field := field;
      m_gameLogic := gameLogic;
      m_fantomBrightBall := new BallType(P3D(0, 0, 0), PlayerEnumT.BrightPlayer, false);
      m_fantomDarkBall := new BallType(P3D(0, 0, 0), PlayerEnumT.DarkPlayer, false);
      m_fantomBrightBall.SetRed(true);
      m_fantomDarkBall.SetRed(true);
      m_currentPlayerBall := m_fantomDarkBall;
    end;

    procedure Init();
    begin
      m_hoverBall := EmptyIndex();
      m_selectedBall := EmptyIndex();
      m_hoverPlace := EmptyIndex();
      m_state := MoveBallStateEnumT.BALL;
      UpdateCurrentPlayerBall();
    end;

    property IsMoving: boolean read (m_state = MoveBallStateEnumT.PLACE);
    property HoveredBall: IndexT read m_hoverBall;
    property SelectedBall: IndexT read m_selectedBall;
    property HoveredPlace: IndexT read m_hoverPlace;

    procedure Hover(ind: IndexT);
    procedure UnHover() := Hover(EmptyIndex());
    // проверяем, попадают ли координаты курсора на цель 
    // (шар, либо место для переноса). В случае успеха, выделяем цель
    function TryHover(x, y: real): boolean;

    procedure ResetStep();
    // пытаемся выбрать цель (шар, либо место для переноса)
    function TrySelect(x, y: real): boolean;

  private
    function FindNearestAvailableBallToMove(x, y: real) : IndexT;
    function FindNearestAvailablePlaceToMove(x, y: real; movesList: List<IndexT>) : IndexT;
    procedure UpdateCurrentPlayerBall();
  end;

  // _________________ Реализация методов ________________ //

  procedure MoveBallActionT.Hover(ind: IndexT);
  begin
    UpdateCurrentPlayerBall();
    if m_state = MoveBallStateEnumT.BALL then begin
      var ballInd := ind;
      if ballInd = m_hoverBall then
        exit;

      if m_hoverBall <> EmptyIndex() then
        m_field.Get(m_hoverBall).SetHovered(false);

      m_hoverBall := ballInd;

      if ballInd <> EmptyIndex() then begin
        m_field.Get(ballInd).SetHovered(true);
      end;
    end
    else begin
      var placeInd := ind;
      if placeInd = m_hoverPlace then
        exit;

      m_hoverPlace := placeInd;

      if placeInd = EmptyIndex() then
      begin
        m_currentPlayerBall.Visible := false;
      end
      else begin
        m_currentPlayerBall.Visible := true;
        m_currentPlayerBall.Position := m_field.GetCoord(placeInd);
      end;
    end;
  end;

  procedure MoveBallActionT.ResetStep();
  begin
    m_state := MoveBallStateEnumT.BALL;
    if Self.HoveredBall <> EmptyIndex() then
      m_field.Get(Self.HoveredBall).SetSelected(false);
    m_hoverBall := EmptyIndex();
    if Self.SelectedBall <> EmptyIndex() then
      m_field.Get(Self.SelectedBall).SetSelected(false);
    m_selectedBall := EmptyIndex();
    m_currentPlayerBall.Visible := false;
    m_hoverPlace := EmptyIndex();
  end;

  function MoveBallActionT.TrySelect(x, y: real): boolean;
  begin
    if m_state = MoveBallStateEnumT.BALL then begin
      if Self.HoveredBall <> EmptyIndex() then begin
        m_state := MoveBallStateEnumT.PLACE;
        m_field.Get(Self.HoveredBall).SetSelected(true);
        m_selectedBall := Self.HoveredBall;
        Result := true;
      end
      else
        Result := false;
    end
    else begin  // MoveBallStateEnumT.Place
      if Self.HoveredPlace <> EmptyIndex() then begin
        var (s, h) := (Self.SelectedBall, Self.HoveredPlace);
        ResetStep();
        m_gameLogic.MoveBallStep(s, h);
        Result := true;
      end
      else
        Result := false;
    end;
  end;

  function MoveBallActionT.TryHover(x, y: real): boolean;
  begin
    if m_state = MoveBallStateEnumT.BALL then begin
      var ind := FindNearestAvailableBallToMove(x, y);
      Hover(ind);
      if ind <> EmptyIndex() then begin
        Result := true;
      end
      else
        Result := false;
    end
    else begin  // MoveBallStateEnumT.Place
      var ind := FindNearestAvailablePlaceToMove(x, y, 
        m_gameLogic.BallsToMove.Where(v -> (v[0] = m_selectedBall)).First()[1]);
      Hover(ind);
      if ind <> EmptyIndex() then begin
        Result := true;
      end
      else
        Result := false;
    end;
  end;

  function MoveBallActionT.FindNearestAvailablePlaceToMove(x, y: real; movesList: List<IndexT>) : IndexT;
  begin
    var indFound := EmptyIndex();

    var nearest := real.MaxValue;
    foreach var ind: IndexT in movesList do begin
      var p := m_field.GetCoord(ind);
      // коэффициент 1.1 выбран, чтобы область выделения шара была чуть больше чем размер
      // самого шара
      if GetRay(x, y).DistanceToPoint(p) <= BallType.BASE_RADIUS * 1.1 then
      begin
        var dstToCamera := Camera.Position.Distance(p);
        if dstToCamera < nearest then begin
          indFound := ind;
          nearest := dstToCamera;
        end;
      end;
    end;

    Result := indFound;
  end;

  function MoveBallActionT.FindNearestAvailableBallToMove(x, y: real) : IndexT;
  begin
    var indFound := EmptyIndex();

    var nearest := real.MaxValue;
    foreach var pair: AvailableMovesT in m_gameLogic.BallsToMove do begin
      if (pair[1].Count() > 0)
        and (GetPlayerByCell(m_gameLogic.Get(pair[0])) = m_gameLogic.Player.Who) then
      begin
        var p := m_field.GetCoord(pair[0]);
        // коэффициент 1.1 выбран, чтобы область выделения шара была чуть больше чем размер
        // самого шара
        if GetRay(x, y).DistanceToPoint(p) <= BallType.BASE_RADIUS * 1.1 then
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