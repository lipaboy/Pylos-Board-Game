unit TakeBallAction;

uses Graph3D;

uses Index;
uses Utils;
uses GameLogic;
uses GameSettings;
uses FieldView;
uses Ball;
uses Players;

type
  TakeBallActionT = class
  private
    m_field: FieldViewT;
    m_gameLogic: GameLogicT;

    m_isActionOn := false;
    m_hoverBall: IndexT := EmptyIndex();
    m_selectedBalls := new List<IndexT>;

  public
    constructor Create(gameLogic: GameLogicT; field: FieldViewT);
    begin 
      m_field := field;
      m_gameLogic := gameLogic;
    end;

    procedure Init();
    begin
      m_hoverBall := EmptyIndex();
      m_isActionOn := false;
      m_selectedBalls.Clear();
    end;

    property HoveredBall: IndexT read m_hoverBall;
    property IsActionOn: boolean read m_isActionOn write m_isActionOn := value;

    function TryHover(x, y: real): boolean;
    begin
      if not m_isActionOn then
        exit;
        
      var ind := FindNearestBallForTake(x, y);
      Hover(ind);
      if ind <> EmptyIndex() then
      begin
        Result := true;
      end
      else
        Result := false;
    end;

    function TrySelect(): boolean;
    begin
      if (Self.HoveredBall = EmptyIndex())
        or m_selectedBalls.Contains(Self.HoveredBall) then 
      begin
        Result := false;
        exit;
      end;

      var ind := Self.HoveredBall;
      m_selectedBalls.Add(ind);
      if (m_selectedBalls.Count() >= 2) or (m_gameLogic.BallsForTake.Count() <= 1) then
      begin
        var balls := m_selectedBalls.ToList();
        log('select ');
        foreach b : IndexT in balls do begin
          logln(ToStr(b));
        end;
        Deselect();
        UnHover();
        m_gameLogic.TakeBallsStep(balls);
      end;
    end;

    procedure ResetStep();
    begin
      foreach ballInd : IndexT in m_selectedBalls do begin
        m_field.Get(ballInd).SetYellow(false);
      end;
      Deselect();
      UnHover();
    end;

  private
    procedure Hover(ballInd: IndexT);
    begin
      if ballInd = m_hoverBall then
        exit;

      logln('before hover ' + ToStr(m_hoverBall));
      if m_hoverBall <> EmptyIndex() then
        if not (m_hoverBall in m_selectedBalls) then
          m_field.Get(m_hoverBall).SetYellow(false);

      m_hoverBall := ballInd;

      if (ballInd <> EmptyIndex()) and (m_field.Get(ballInd) <> nil) then
      begin
        m_field.Get(ballInd).SetYellow(true);
      end;
    end;

    procedure UnHover() := Hover(EmptyIndex());
    procedure Deselect() := m_selectedBalls.Clear();

    function FindNearestBallForTake(x, y: real) : IndexT;
    begin
      var indFound := EmptyIndex();

      var nearest := real.MaxValue;
      foreach var ind: IndexT in m_gameLogic.BallsForTake do begin
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

  end;

end.