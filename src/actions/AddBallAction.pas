unit AddBallAction;

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
  AddBallActionT = class
  private
    m_field: FieldViewT;
    m_hoverPlace: IndexT := EmptyIndex();
    m_fantomBrightBall: BallType;
    m_fantomDarkBall: BallType;
    m_currentBall: BallType;
    m_gameLogic: GameLogicT;

  public
    constructor Create(gameLogic: GameLogicT; field: FieldViewT);
    begin 
      m_field := field;
      m_gameLogic := gameLogic;
      m_fantomBrightBall := new BallType(P3D(0, 0, 0), PlayerEnumT.BrightPlayer, false);
      m_fantomBrightBall.SetBlue(true);
      m_fantomDarkBall := new BallType(P3D(0, 0, 0), PlayerEnumT.DarkPlayer, false);
      m_fantomDarkBall.SetBlue(true);
      m_currentBall := m_fantomDarkBall;
    end;

    procedure Init();
    begin
      m_currentBall := m_fantomDarkBall;
      m_hoverPlace := EmptyIndex();
      UpdateCurrentBall();
    end;

    property HoveredPlace: IndexT read m_hoverPlace;

    procedure Hover(placeInd: IndexT);
    begin
      UpdateCurrentBall();
      if placeInd = m_hoverPlace then
        exit;

      m_hoverPlace := placeInd;

      if placeInd = EmptyIndex() then
      begin
        m_currentBall.Visible := false;
      end
      else begin
        m_currentBall.Visible := true;
        m_currentBall.Position := m_field.GetCoord(placeInd);
      end;
    end;

    procedure UnHover() := Hover(EmptyIndex());

    function TryPlaceBall(x, y: real): boolean;
    begin
      if Self.HoveredPlace <> EmptyIndex() then
      begin
        m_gameLogic.AddBallStep(Self.HoveredPlace);
        UnHover();
        Result := true;
      end
      else
        Result := false;
    end;

    function TryHover(x, y: real): boolean;
    begin
      var ind := FindNearestAvailablePlaceToAdd(x, y);
      Hover(ind);
      Result := ind <> EmptyIndex();
    end;

  private
    function FindNearestAvailableBallToMove(x, y: real) : Integer;
    function FindNearestAvailablePlaceToAdd(x, y: real) : IndexT;

    procedure UpdateCurrentBall();
    begin
      var ball := m_gameLogic.Player.Who = PlayerEnumT.BrightPlayer
        ? m_fantomBrightBall : m_fantomDarkBall;
      if m_currentBall <> ball then
        m_currentBall.Visible := False;
      m_currentBall := ball;
    end;

  end;

  function AddBallActionT.FindNearestAvailableBallToMove(x, y: real) : Integer;
  begin
    var ballsInRail := m_gameLogic.Player.Who = PlayerEnumT.BrightPlayer
      ? m_field.BrightBalls : m_field.DarkBalls;

    var nearest := real.MaxValue;
    var railIndex := -1;
    for var i := 0 to PLAYER_BALL_COUNT - 1 do begin
      var p := ballsInRail[i].Position;
      // коэффициент 1.1 выбран, чтобы область выделения шара была чуть больше чем размер
      // самого шара
      if GetRay(x, y).DistanceToPoint(p) <= BallType.BASE_RADIUS * 1.05 then
      begin
        var dstToCamera := Camera.Position.Distance(p);
        if dstToCamera < nearest then begin
          nearest := dstToCamera;
          railIndex := i;
        end;
      end;
    end;

    Result := railIndex;
  end;

  function AddBallActionT.FindNearestAvailablePlaceToAdd(x, y: real) : IndexT;
  begin
    var indFound := EmptyIndex();

    // Q: разумна ли эта оптимизация в этом месте? может стоит её вынести отсюда,
    //    сделав функцию более универсальной?
    var hoverInd := Self.HoveredPlace;
    if (hoverInd <> EmptyIndex()) 
      and (GetRay(x, y).DistanceToPoint(m_field.GetCoord(hoverInd)) <= BallType.BASE_RADIUS) then
    begin
      Result := hoverInd;
      exit;
    end;

    var nearest := real.MaxValue;
    foreach var ind: IndexT in m_gameLogic.AvailablePos do begin
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

end.