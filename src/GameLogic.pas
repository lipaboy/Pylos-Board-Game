unit GameLogic;

uses Utils;

uses Cell;
uses Index;
uses ISubscriber;
uses Players;
uses GameSettings;

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
    m_availablePos := new List<IndexT>;
    m_ballsToMove := new List<AvailableMovesT>;
    m_squareList := new List<IndexT>;

    m_subscriberList := new List<ISubscriberT>;

  public
    constructor Create();
    begin
    end;

    procedure Start();
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

    procedure AddBallStep(stepInd : IndexT);
    begin
      if not IsEmptyIndex(stepInd) then begin
        SetCell(stepInd, GetCellByPlayer(m_currPlayer));
        m_players.Item[m_currPlayer].BallsRemain -= 1;

        var eventResult: GameEventResultT;
        eventResult.IsAdd := true;
        eventResult.AddToPlaceInd := stepInd;
        eventResult.Who := m_currPlayer;

        m_currPlayer := NextPlayer(m_currPlayer);

        CalcAvailablePos();
        NotifyAll(eventResult);
      end;
    end;

    property Player: PlayerT read m_players.Item[m_currPlayer];
    property PlayersDict: PlayersDictT read m_players;
    property AvailablePos: List<IndexT> read m_availablePos;
    property BallsToMove: List<AvailableMovesT> read m_ballsToMove;
    // debug
    property SquareList: List<IndexT> read m_squareList;

    function Get(ind : IndexT) : CellT;
    begin
      Result := m_field[ind[0], ind[1], ind[2]];
    end;

    procedure Subscribe(subscriber: ISubscriberT);
    procedure NotifyAll(eventResult: GameEventResultT);

  private
    procedure CalcAvailablePos();

    procedure SetCell(ind : IndexT; val1 : CellT);
    begin
      m_field[ind[0], ind[1], ind[2]] := val1;
    end;

    function IsLockedByTopBall(index : IndexT) : boolean;
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

    function CanMoveBall(ballInd, placeInd : IndexT) : boolean;
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

  end;

  // ----------- Реализация методов -------------- //

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

            // Utils.log(ToStr(ballInd) + ' ');
            foreach square: IndexT in m_squareList do
              if (square[2] > ballInd[2]) and CanMoveBall(ballInd, square) then
                places.Add(square);

            if places.Count() > 0 then
              m_ballsToMove.Add((ballInd, places));
          end;
        end;
      end;
    end;
    // Utils.logln();

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