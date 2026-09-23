unit AddBallAction;

uses Graph3D;

uses Utils in '../util/Utils';
uses Logger in '../util/Logger';
uses Stereometry in '../util/Stereometry';

uses Index in '../logic/Index';
uses GameLogic in '../logic/GameLogic';
uses GameSettings in '../logic/GameSettings';
uses Players in '../logic/Players';
uses PlayerEnum in '../logic/PlayerEnum';

uses Ball in '../view/Ball';
uses FieldView in '../view/FieldView';
uses GravityAnimation in '../animation/GravityAnimation';

uses AnimSeq;

(*
          Добавление шара на поле

    В чём особенность данной реализации. Я хочу, чтобы взятие шара
    и выкладка его на место строилась из анимаций. Анимация поднятия шара,
    анимация подлёта к предположительному месту посадки, анимация посадки шара.

    В идеале хочется вообще сюда кучу разных анимаций запилить (вращение 
    двух шаров в танце вихря), возможность вернуть шарик на место,
    различные артефакты на шарах. 

    Коротко говоря, одно только усовершенствование этой механики (из телепортации шарика
    перейти к анимации) уже побуждает меня к куче возможных вариаций. Благо я могу оставить
    свои мысли здесь.
*)


(* Состояние добавления шара на поле разделяется на два этапа:
  - этап выбора шара с рейки (BALL)
  - этап выбора места, куда поставить шар (PLACE)
*)
type
  AddBallStateEnumT = (BALL, PLACE, ANIMATING);

type
  AddBallActionT = class
  private
    m_field: FieldViewT;

    m_hoveredPlace: IndexT := EmptyIndex();
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

    property HoveredPlace: IndexT read m_hoveredPlace;
    property IsBallGrabbed: Boolean read (m_state = AddBallStateEnumT.PLACE);
    property IsChoosing: Boolean read (m_state = AddBallStateEnumT.BALL);
    property IsAnimated: Boolean read (m_state = AddBallStateEnumT.ANIMATING);

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

  function AddBallActionT.TryPlaceBall(x, y: real): boolean;
  begin
    if Self.IsAnimated then begin
      LoggerT.Debug('AddBallActionT.TryPlaceBall(): IsAnimated');
      Result := False;
      exit;
    end;

    if Self.IsChoosing then begin
      if m_hoverRailInd < 0 then
      begin
        Result := False;
        exit;
      end;

      m_ballSelected := GetRailBall(m_hoverRailInd);
      m_ballSelected.SetHovered(false);
      LoggerT.Debug('' + m_ballSelected.Position.Z);
      m_state := AddBallStateEnumT.ANIMATING;
      m_gravityAnim.StartFall(m_ballSelected.Figure, 
                              m_ballSelected.Position.Z + 5.0, 1.0, 
                              () -> begin m_state := AddBallStateEnumT.PLACE; end);
      Result := True;
      exit;
    end
    else if Self.IsBallGrabbed then begin
      var ind: IndexT := Self.HoveredPlace;
      LoggerT.Debug('AddBallAction.TryPlaceBall(): ind = ' + ind.ToStr());
      var placeCoord := m_currentBall.Position;
      var hoverRailInd := m_hoverRailInd;
      var currPlayer := m_gameLogic.Player.Who;
      HideFantomBall();

      m_state := AddBallStateEnumT.ANIMATING;
      m_gravityAnim.StartFall(m_ballSelected.Figure, 
                              placeCoord.Z, -1.0, 
                              () -> begin 
                                m_state := AddBallStateEnumT.BALL; 
                                m_field.MoveToBoard(hoverRailInd, ind, currPlayer);
                                if not m_gameLogic.AddBallStep(ind) then
                                  LoggerT.Error('AddBallActionT.TryPlaceBall: Ball is not added to logic field');
                                m_hoverRailInd := -1;
                              end);
      (* Wtf: Странно, что логика работы с полем происходит здесь, а не в FieldView.
      Получается AddBallAction - что-то вроде Controller для логики и отображения.
      Вообще большая ответственность получается. Ещё и анимациями занимается.
      *)
      Result := True;
      exit;
    end;

    Result := False;
  end;

  //----------------------

  (* Вычисление по координате мышки, какой шар нужно выделить
    и соответствующее выделение. Также обрабатываем каждое
    движение курсора. *)
  function AddBallActionT.TryHover(x, y: real): Boolean;
  begin
    if Self.IsChoosing then begin
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

      LoggerT.Debug('Hover ball ' + iRail);

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
    else if Self.IsBallGrabbed then begin      
      (* Шар находится в полёте *)

      (* Ищем место, куда можно положить шар *)
      var ind : IndexT := FindNearestAvailablePlaceToAdd(x, y);

      var isHovered : Boolean := PlaceFantomBall(ind);

      if ind.IsEmpty or not isHovered then begin
        Result := false;
        exit;
      end;

      LoggerT.Debug('AddBallActionT.TryHover(): Ball starts flying to ' + ind.ToStr);
      var coord := m_field.GetCoord(ind);

      (* Собственно полёт шара *)
      FlyBall(coord.x, coord.y);
      Result := true;
      exit;
    end;

    Result := false;
  end;

  //----------------------

  (* Как будто сложная функция, упростить бы её *)
  function AddBallActionT.PlaceFantomBall(placeInd: IndexT) : Boolean;
  begin
    UpdateCurrentBall();
    if placeInd = Self.HoveredPlace then begin
      Result := false;
      exit;
    end;

    m_hoveredPlace := placeInd;

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
    m_hoveredPlace := EmptyIndex();
    LoggerT.Debug('  Hide Fantom Ball');
    m_currentBall.Visible := false;
    if m_currentBall = m_fantomBrightBall then
      LoggerT.Debug('    bright ball');
  end;

  //----------------------

  procedure AddBallActionT.FlyBall(x, y: real);
  begin
    var destPoint := P3D(x, y, m_ballSelected.Position.Z);

    var getFlyAnimToPointFunc: Point3D -> AnimationBase := destPoint -> 
      m_ballSelected.Figure.AnimMoveTo(
        destPoint, 1.0, 
        () -> begin 
          m_animSeq.Run();
        end
      ).AccelerationRatio(6.5, 6.0);

    if not Self.IsAnimated then begin
      m_animSeq.SetLast(() -> begin 
         LoggerT.Debug('AddBallActionT.FlyBall().last_anim: End flying');
        m_state := AddBallStateEnumT.PLACE;
      end);

      m_flyAnim := getFlyAnimToPointFunc(destPoint);

      m_state := AddBallStateEnumT.ANIMATING;
      m_flyAnim.Begin;
    end
    else begin
      m_animSeq.Add(() -> begin 
        m_flyAnim := getFlyAnimToPointFunc(destPoint);

        m_flyAnim.Begin;
        LoggerT.Debug('AddBallActionT.FlyBall(): Extra anim is running');
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
    m_hoveredPlace := EmptyIndex();
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