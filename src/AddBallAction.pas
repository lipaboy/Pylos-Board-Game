unit AddBallAction;

uses Graph3D;

uses Index;
uses utils;
uses GameLogic;
uses GameSettings;
uses FieldView;
uses Ball;
uses Players;

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
      m_fantomDarkBall := new BallType(P3D(0, 0, 0), PlayerEnumT.DarkPlayer, false);
      m_currentBall := m_fantomDarkBall;
    end;

    procedure Init();
    begin
      m_currentBall := m_fantomDarkBall;
      m_hoverPlace := EmptyIndex();
      UpdateCurrentBall();
    end;

    function GetHoveredPlace(): IndexT;
    begin
      Result := m_hoverPlace;
    end;

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

    procedure PlaceBall(x, y: real);
    begin
      if GetHoveredPlace() <> EmptyIndex() then
      begin
        m_gameLogic.MakeStep(GetHoveredPlace());
      end;
    end;

    function TryHover(x, y: real): boolean;
    begin
      var ind := FindNearestAvailableIndex(x, y);
      Hover(ind);
      if ind <> EmptyIndex() then
      begin
        Result := true;
      end
      else
        Result := false;
    end;

  private
    function FindNearestAvailableIndex(x, y: real) : IndexT;
    begin
      var indFound := EmptyIndex();

      var hoverInd := GetHoveredPlace();
      if (hoverInd <> EmptyIndex()) 
        and (GetRay(x, y).DistanceToPoint(m_field.GetCoord(hoverInd)) <= BASE_RADIUS) then
      begin
        Result := hoverInd;
        exit;
      end;

      var nearest := real.MaxValue;
      foreach var ind: IndexT in m_gameLogic.AvailablePos do begin
        var p := m_field.GetCoord(ind);
        // коэффициент 1.1 выбран, чтобы область выделения шара была чуть больше чем размер
        // самого шара
        if GetRay(x, y).DistanceToPoint(p) <= BASE_RADIUS * 1.1 then
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

    procedure UpdateCurrentBall();
    begin
      var ball := m_gameLogic.Player.Who = PlayerEnumT.BrightPlayer
        ? m_fantomBrightBall : m_fantomDarkBall;
      if m_currentBall <> ball then
        m_currentBall.Visible := False;
      m_currentBall := ball;
    end;

  end;

end.