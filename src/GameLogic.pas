unit GameLogic;

uses Utils;

uses Cell;
uses Index;
uses ISubscriber;
uses Players;
uses GameSettings;

// Понятия:
//
// 1) Квадрат (square) - квадрат шаров, на котором может поместится ещё один шар так, что
// все 4 шара снизу будут его держать с каждой из сторон.

// ---------------- GameLogic ----------------- //

type
  PlayersDictT = Dictionary<PlayerEnumT, PlayerT>;

type
  AvailableMovesT = System.Tuple< IndexT, List<IndexT> >;

type
  GameLogicT = class
  private
    m_players : PlayersDictT;
    m_currPlayer: PlayerEnumT;

    m_field: array[0..FWid, 0..FWid, 0..FHei] of CellT;

    // Свободные места для добавления новых шаров
    m_availablePos := new List<IndexT>;

    // Списки свободных квадратов и шаров на поле, которые можно переместить
    m_squareList := new List<IndexT>;
    m_ballsToMove := new List<AvailableMovesT>;

    m_ballsForTake := new List<IndexT>;

    m_subscriberList := new List<ISubscriberT>;

  public
    constructor Create(); begin end;
    procedure Start();

    // Изменение состояние игры (совершение хода)
    procedure AddBallStep(placeInd : IndexT);
    procedure MoveBallStep(ballInd, placeInd : IndexT);
    procedure TakeBallsStep(balls : List<IndexT>);

    // Селекторы
    function Get(ind : IndexT) := m_field[ind[0], ind[1], ind[2]];
    property Player: PlayerT read m_players.Item[m_currPlayer];
    property PlayersDict: PlayersDictT read m_players;
    property AvailablePos: List<IndexT> read m_availablePos;
    property BallsToMove: List<AvailableMovesT> read m_ballsToMove;
    property BallsForTake: List<IndexT> read m_ballsForTake;

    // Подписка на события модели
    procedure Subscribe(subscriber: ISubscriberT);

  private
    procedure NotifyAll(eventResult: GameEventResultT);

    procedure CalcAvailablePos();
    procedure UpdateBallsToTake();
    function FindSolidColorSquare(): boolean;

    procedure SetCell(ind : IndexT; val1 : CellT);
    begin
      m_field[ind[0], ind[1], ind[2]] := val1;
    end;

    function IsLockedByTopBall(index : IndexT) : boolean;
    function CanMoveBall(ballInd, placeInd : IndexT) : boolean;

  end;

  // ----------- Реализация методов -------------- //

  procedure GameLogicT.AddBallStep(placeInd : IndexT);
  begin
    if not IsEmptyIndex(placeInd) then begin
      SetCell(placeInd, GetCellByPlayer(m_currPlayer));
      m_players.Item[m_currPlayer].BallsRemain -= 1;

      if m_players[NextPlayer(m_currPlayer)].BallsRemain > 0 then
        UpdateBallsToTake();

      var eventResult: GameEventResultT;
      if Self.BallsForTake.Any() then begin
        eventResult.IsNeedToTake := true;
        eventResult.Who := m_currPlayer;
      end;

      eventResult.IsAdd := true;
      eventResult.AddToPlaceInd := placeInd;
      eventResult.Who := m_currPlayer;

      if (not eventResult.IsNeedToTake) and 
        (m_players[NextPlayer(m_currPlayer)].BallsRemain > 0) then
      begin
        m_currPlayer := NextPlayer(m_currPlayer);
      end;

      CalcAvailablePos();
      NotifyAll(eventResult);
    end;
  end;

  procedure GameLogicT.MoveBallStep(ballInd, placeInd : IndexT);
  begin
    if IsValid(ballInd) and (Get(ballInd) = GetCellByPlayer(Self.Player.Who))
      and IsValid(placeInd) and (Get(placeInd) = CellT.Empty) then
    begin
      SetCell(placeInd, Get(ballInd));
      SetCell(ballInd, CellT.Empty);

      if m_players[NextPlayer(m_currPlayer)].BallsRemain > 0 then
        UpdateBallsToTake();

      var eventResult: GameEventResultT;
      if Self.BallsForTake.Any() then begin
        eventResult.IsNeedToTake := true;
        eventResult.Who := m_currPlayer;
      end;

      eventResult.IsMove := true;
      eventResult.MoveBallInd := ballInd;
      eventResult.MovePlaceInd := placeInd;
      eventResult.Who := m_currPlayer;

      if (not eventResult.IsNeedToTake) and 
        (m_players[NextPlayer(m_currPlayer)].BallsRemain > 0) then
      begin
        m_currPlayer := NextPlayer(m_currPlayer);
      end;

      CalcAvailablePos();
      NotifyAll(eventResult);
    end;
  end;

  procedure GameLogicT.TakeBallsStep(balls : List<IndexT>);
  begin
    foreach var ballInd: IndexT in balls do
      SetCell(ballInd, CellT.Empty);
    m_players.Item[m_currPlayer].BallsRemain += balls.Count();

    m_ballsForTake.Clear();

    var eventResult: GameEventResultT;
    eventResult.IsTaken := true;
    eventResult.BallsTaken := balls;
    eventResult.Who := m_currPlayer;

    m_currPlayer := NextPlayer(m_currPlayer);
    CalcAvailablePos();
    NotifyAll(eventResult);
  end;

  procedure GameLogicT.UpdateBallsToTake();
  begin
    if not FindSolidColorSquare() then begin
      m_ballsForTake.Clear();
    end
    else begin
      for var k := 0 to FHei - 1 do
        for var i := k to FWid step 2 do
          for var j := k to FWid step 2 do begin
            var ind := (i, j, k);
            if (Get(ind) = GetCellByPlayer(Self.Player.Who)) 
              and (not IsLockedByTopBall(ind)) then
            begin
              m_ballsForTake.Add(ind);
            end;
          end;
    end;
  end;

  function GameLogicT.FindSolidColorSquare(): boolean;
  begin
    for var k := FHei downto 1 do begin
      for var i := k to FWid - k step 2 do begin
        for var j := k to FWid - k step 2 do begin
          // вершина квадрата (позиция, которая находится над квадратом из шаров)
          var ind := (i, j, k);
          if (Get(ind) = Empty) then begin
            var uniqueCells :=
              | Get(UpLeft(Bottom(ind))),
                Get(UpRight(Bottom(ind))),
                Get(DownRight(Bottom(ind))),
                Get(DownLeft(Bottom(ind))) |.Distinct;

            if (uniqueCells.Count = 1) 
              and (GetCellByPlayer(Self.Player.Who) in uniqueCells) then
            begin
              Result := true;
              exit;
            end;
          end;
        end;
      end;
    end;
    logln('solid');
    Result := false;
  end;

  function GameLogicT.IsLockedByTopBall(index : IndexT) : boolean;
  begin
    var indices := | UpLeft(index), UpRight(index), DownLeft(index), DownRight(index) |;
    foreach ind : IndexT in indices do begin
      var topInd := Top(ind);
      if (IsValid(topInd)) and (Get(topInd) <> Empty) then begin
        Result := true;
        exit;
      end;
    end;
    Result := false;
  end;

  function GameLogicT.CanMoveBall(ballInd, placeInd : IndexT) : boolean;
  begin
    var indices := | UpLeft(placeInd), UpRight(placeInd), 
                     DownLeft(placeInd), DownRight(placeInd) |;
    foreach ind : IndexT in indices do begin
      var bottomInd := Bottom(ind);
      if bottomInd = ballInd then begin
        Result := false;
        exit;
      end;
    end;
    Result := true;
  end;

  procedure GameLogicT.CalcAvailablePos();
  begin
    m_availablePos.Clear();
    m_squareList.Clear();
    m_ballsToMove.Clear();

    for var i := 0 to FWid step 2 do begin
      for var j := 0 to FWid step 2 do begin
        var ind := (i, j, 0);
        if Get(ind) = Empty then
        begin
          m_availablePos.Add(ind);
        end;
      end;
    end;

    for var k := 1 to FHei do begin
      var hasSquare := false;
      for var i := k to FWid - k step 2 do begin
        for var j := k to FWid - k step 2 do begin
          var ind := (i, j, k);
          if (Get(ind) = Empty)
            and (Get(UpLeft(Bottom(ind))) <> Empty)
            and (Get(UpRight(Bottom(ind))) <> Empty)
            and (Get(DownRight(Bottom(ind))) <> Empty)
            and (Get(DownLeft(Bottom(ind))) <> Empty) then
          begin
            hasSquare := true;
            m_availablePos.Add(ind);
            m_squareList.Add(ind);
          end;
        end;
      end;
    end;

    for var k := 0 to FHei - 1 do begin
      for var i := k to FWid step 2 do begin
        for var j := k to FWid step 2 do begin
          var ind := (i, j, k);
          if (Get(ind) <> Empty) and (not IsLockedByTopBall(ind)) then
          begin
            var ballInd := ind;
            var places := new List<IndexT>();

            foreach square: IndexT in m_squareList do
              if (square[2] > ballInd[2]) and CanMoveBall(ballInd, square) then
                places.Add(square);

            if places.Count() > 0 then
              m_ballsToMove.Add((ballInd, places));
          end;
        end;
      end;
    end;
  end;

  procedure GameLogicT.Start();
  begin
    m_players := 
      Arr((BrightPlayer, PlayerT.Create(BrightPlayer)),
        (DarkPlayer, PlayerT.Create(DarkPlayer)))
          .ToDictionary(x->x[0], x->x[1]);

    for var i := 0 to FWid do 
      for var j := 0 to FWid do 
        for var k := 0 to FHei do 
          m_field[i, j, k] := Empty;

    m_currPlayer := BrightPlayer;

    CalcAvailablePos();

    var eventResult: GameEventResultT;
    eventResult.IsInitializing := true;
    NotifyAll(eventResult);
  end;

  procedure GameLogicT.Subscribe(subscriber: ISubscriberT);
  begin
    m_subscriberList.Add(subscriber);
  end;

  procedure GameLogicT.NotifyAll(eventResult: GameEventResultT);
  begin
    foreach var s : ISubscriberT in m_subscriberList do begin
      s.Notify(eventResult);
    end;
  end;

end.