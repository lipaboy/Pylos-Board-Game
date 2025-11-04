unit AddBallAction;

uses Graph3D;

uses Utils;
uses Stereometry;

uses Index;
uses GameLogic;
uses GameSettings;
uses Players;
uses PlayerEnum;

uses Ball;
uses FieldView;
uses GravityAnimation;

uses AnimSeq;

type
  AddBallStateEnumT = (BALL, PLACE);

type
  AddBallActionT = class
  private
    m_field: FieldViewT;

    m_hoverPlace: IndexT := EmptyIndex();
    m_hoverRailInd: Integer := -1;

    m_ballSelected: BallType := nil;
    m_gravityAnim := new GravityAnimationT();

    m_state: AddBallStateEnumT;
    m_isFly : boolean := false;
    m_flyAnim : AnimationBase := nil;
    m_animSeq := new AnimSeqT();

    // legacy
    m_currentBall: BallType;
    m_gameLogic: GameLogicT;

    m_fantomBrightBall: BallType;
    m_fantomDarkBall: BallType;

  public
    constructor Create(gameLogic: GameLogicT; field: FieldViewT);

    procedure Init();

    property HoveredPlace: IndexT read m_hoverPlace;
    property IsMoving: Boolean read (m_state = AddBallStateEnumT.PLACE);

    function Hover(placeInd: IndexT) : Boolean;
    procedure UnHover() := Hover(EmptyIndex());

    function TryPlaceBall(x, y: real): Boolean;
    function TryHover(x, y: real): Boolean;

  private
    procedure FlyBall(x, y: real);

    function GetRailBall(railIndex : Integer) 
      := m_field.GetBallsOnRailBy(m_gameLogic.Player.Who)[railIndex];

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

  // _________________ Реализация методов ________________ //

  function AddBallActionT.TryPlaceBall(x, y: real): boolean;
  begin
    if not IsMoving then begin
      if m_hoverRailInd < 0 then
      begin
        Result := False;
        exit;
      end;

      m_ballSelected := GetRailBall(m_hoverRailInd);
      m_ballSelected.SetHovered(false);
      logln('' + m_ballSelected.Position.Z);
      m_gravityAnim.StartFall(m_ballSelected.Figure, 
                              m_ballSelected.Position.Z + 5.0, 1.0);
      m_state := AddBallStateEnumT.PLACE;
    end
    else begin
      logln('' + m_ballSelected.Position.Z);
      m_gravityAnim.StartFall(m_ballSelected.Figure, 
                              m_ballSelected.Position.Z - 5.0, -1.0);
      m_state := AddBallStateEnumT.BALL;
      UnHover();
    end;
    Result := True;

    (* Previous implementation *)
    // if Self.HoveredPlace <> EmptyIndex() then
    // begin
    //   m_gameLogic.AddBallStep(Self.HoveredPlace);
    //   UnHover();
    //   Result := true;
    // end
    // else
    //   Result := false;
  end;

  (* Вычисление по координате мышки, какой шар нужно выделить
    и соответствующее выделение. Также обрабатываем каждое
    движение курсора. *)
  function AddBallActionT.TryHover(x, y: real): Boolean;
  begin
    (* Previous implementation *)
    // var ind := FindNearestAvailablePlaceToAdd(x, y);
    // Hover(ind);
    // Result := ind <> EmptyIndex();

    (* Если шар ещё не движется (т.е. не летит) *)
    if not Self.IsMoving then begin
      var iRail := FindNearestAvailableBallToMove(x, y);
      (* Нашли шар для выделения *)
      if (iRail >= 0) then begin
        (* Шар уже выделен *)
        if (iRail = m_hoverRailInd) then begin
          Result := true;
          exit;
        end;

        (* Курсор навёлся на новый шар *)

        (* Если до этого был выделен шар, развыделяем его *)
        if m_hoverRailInd >= 0 then
          GetRailBall(m_hoverRailInd).UnHover();

        (* Выделяем новый шар *)
        var ball := GetRailBall(iRail);
        ball.Hover();
        m_hoverRailInd := iRail;
        Result := true;
        exit;
      end
      else begin (* Не нашли шар для выделения *)
        (* Если до этого был выделенный шар, снимаем с него выделение *)
        if m_hoverRailInd >= 0 then
          GetRailBall(m_hoverRailInd).UnHover();
        Result := false;
        exit;
      end;
    end
    else begin      
      (* Шар находится в движении (в полёте) *)

      (* Ищем место, куда можно положить шар *)
      var ind : IndexT := FindNearestAvailablePlaceToAdd(x, y);

      var isHovered : Boolean := Hover(ind);

      if ind.IsEmpty or not isHovered then begin
        Result := false;
        exit;
      end;

      logln('Ball starts flying to ' + ind.ToStr);
      var coord := m_field.GetCoord(ind);
      FlyBall(coord.x, coord.y);
    end;

    Result := false;
  end;

  function AddBallActionT.Hover(placeInd: IndexT) : Boolean;
  begin
    UpdateCurrentBall();
    if placeInd = m_hoverPlace then begin
      Result := false;
      exit;
    end;

    m_hoverPlace := placeInd;

    if placeInd = EmptyIndex() then
    begin
      m_currentBall.Visible := false;
      Result := false;
    end
    else begin
      m_currentBall.Visible := true;
      m_currentBall.Position := m_field.GetCoord(placeInd);
      Result := true;
    end;
  end;

  procedure AddBallActionT.FlyBall(x, y: real);
  begin
      /// Расчёт полёта за курсором мышки

      // var f := m_field.Borders[0];
      // var s := m_field.Borders[1];
      // var th := m_field.Borders[2];
      // var normal := Vector3D.CrossProduct(s - f, th - f);
      // normal.Normalize();

      // var cameraRay := GetRay(x, y);
      // var proj1 := cameraRay.Origin - 
      //   normal * Vector3D.DotProduct(cameraRay.Origin - f, normal);
      // var o := cameraRay.Origin + cameraRay.Direction;
      // var proj2 := o - normal * Vector3D.DotProduct(o - f, normal);
      // var point := cameraRay.LineIntersection(Ray(proj1, proj2 - proj1));

      // var destPoint := P3D(point.x, point.y, m_ballSelected.Position.Z);

      // Полёт до места выделения на поле (когда показывается синий шар)

    var destPoint := P3D(x, y, m_ballSelected.Position.Z);

    var f: Point3D -> AnimationBase := destPoint -> 
      m_ballSelected.Figure.AnimMoveTo(
        destPoint, 1.0, 
        () -> begin 
          m_animSeq.Run();
        end
      ).AccelerationRatio(6.5, 6.0);

    if not m_isFly then begin
      logln('New Animation');

      m_animSeq.SetLast(() -> begin 
        m_isFly := false;
        logln('      Animation completed 1');
      end);

      m_flyAnim := f(destPoint);

      m_isFly := true;
      m_flyAnim.Begin;
    end
    else begin
      logln('Add animation');

      m_animSeq.Add(() -> begin 
        m_flyAnim := f(destPoint);

        m_flyAnim.Begin;
        logln('      Extra anim is running');
      end);
    end;
  end;

  constructor AddBallActionT.Create(gameLogic: GameLogicT; field: FieldViewT);
  begin 
    m_field := field;
    m_gameLogic := gameLogic;
    m_fantomBrightBall := new BallType(P3D(0, 0, 0), PlayerEnumT.BrightPlayer, false);
    m_fantomBrightBall.SetBlue(true);
    m_fantomDarkBall := new BallType(P3D(0, 0, 0), PlayerEnumT.DarkPlayer, false);
    m_fantomDarkBall.SetBlue(true);
    m_currentBall := m_fantomDarkBall;
  end;

  procedure AddBallActionT.Init();
  begin
    m_currentBall := m_fantomDarkBall;
    m_hoverPlace := EmptyIndex();
    m_state := AddBallStateEnumT.BALL;
    UpdateCurrentBall();
  end;

  (* Функция для нахождения шара на рейке, который можно выделить *)
  function AddBallActionT.FindNearestAvailableBallToMove(x, y: real) : Integer;
  begin
    var ballsInRail := m_field.GetBallsOnRailBy(m_gameLogic.Player.Who);

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

  (* Функция для поиска ближайщего места, куда можно поставить шар на поле *)
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