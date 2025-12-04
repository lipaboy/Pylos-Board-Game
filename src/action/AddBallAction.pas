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

    function TryPlaceBall(x, y: real): Boolean;
    function TryHover(x, y: real): Boolean;

    procedure UnHover() := PlaceFantomBall(EmptyIndex());

  private
    function PlaceFantomBall(placeInd: IndexT) : Boolean;
    procedure HideFantomBall();

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

  (* Вычисление по координате мышки, какой шар нужно выделить
    и соответствующее выделение. Также обрабатываем каждое
    движение курсора. *)
  function AddBallActionT.TryHover(x, y: real): Boolean;
  begin
    (* Если шар ещё не движется (т.е. не летит) *)
    if not Self.IsMoving then begin
      var iRail := FindNearestAvailableBallToMove(x, y);

      if (iRail < 0) then begin (* Не нашли шар для выделения *)
        (* Если до этого был выделенный шар, снимаем с него выделение *)
        if m_hoverRailInd >= 0 then begin
          GetRailBall(m_hoverRailInd).UnHover();
          m_hoverRailInd := -1;
        end;
        Result := false;
        exit;
      end;

      (* Нашли шар для выделения *)

      (* Шар уже выделен *)
      if (iRail = m_hoverRailInd) then begin
        Result := true;
        exit;
      end;

      logln('Hover ball ' + iRail);

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
    else begin      
      (* Шар находится в движении (в полёте) *)

      (* Ищем место, куда можно положить шар *)
      var ind : IndexT := FindNearestAvailablePlaceToAdd(x, y);

      var isHovered : Boolean := PlaceFantomBall(ind);

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

  //----------------------

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

      var ind: IndexT := Self.HoveredPlace;
      var placeCoord := m_currentBall.Position;
      HideFantomBall();

      m_gravityAnim.StartFall(m_ballSelected.Figure, 
                              placeCoord.Z, -1.0);
      m_state := AddBallStateEnumT.BALL;
      m_field.MoveToBoard(m_hoverRailInd, ind, m_gameLogic.Player.Who);
      m_gameLogic.AddBallStep(ind);
      m_hoverRailInd := -1;
    end;
    Result := True;
  end;

  //----------------------

  (* Как будто сложная функция, упростить бы её *)
  function AddBallActionT.PlaceFantomBall(placeInd: IndexT) : Boolean;
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

  //----------------------

  procedure AddBallActionT.HideFantomBall();
  begin
    m_hoverPlace := EmptyIndex();
    logln('  Hide Fantom BAll');
    m_currentBall.Visible := false;
    if m_currentBall = m_fantomBrightBall then
      logln('    bright ball');
  end;

  //----------------------

  procedure AddBallActionT.FlyBall(x, y: real);
  begin
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

  //----------------------

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

  //----------------------

  procedure AddBallActionT.Init();
  begin
    m_currentBall := m_fantomDarkBall;
    m_hoverPlace := EmptyIndex();
    m_state := AddBallStateEnumT.BALL;
    UpdateCurrentBall();
  end;

  //----------------------

  (* Функция для нахождения шара на рейке, который можно выделить *)
  function AddBallActionT.FindNearestAvailableBallToMove(x, y: real) : Integer;
  begin
    var ballsInRail := m_field.GetBallsOnRailBy(m_gameLogic.Player.Who);

    var nearest := real.MaxValue;
    var railIndex := -1;
    for var i := 0 to PLAYER_BALL_COUNT - 1 do begin
      if ballsInRail[i] = nil then
        continue;
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

  //----------------------

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