unit GameLogic;

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

    field: array[0..FWid, 0..FWid, 0..FHei] of CellT;
    m_availablePos := new List<IndexT>;
    m_ballsToMove := new List<AvailableMovesT>;
    squareList := new List<IndexT>;

    subscriberList := new List<ISubscriberT>;
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
            field[i, j, k] := Empty;

      m_currPlayer := BrightPlayer;

      calcAvailablePos();

      var eventResult: GameEventResultT;
      eventResult.IsInitializing := true;
      notifyAll(eventResult);
    end;

    procedure MakeStep(stepInd : IndexT);
    begin
      if not IsEmptyIndex(stepInd) then begin
        SetCell(stepInd, GetCellByPlayer(m_currPlayer));
        m_players.Item[m_currPlayer].BallsRemain -= 1;

        var eventResult: GameEventResultT;
        eventResult.IsAdd := true;
        eventResult.AddToPlaceInd := stepInd;
        eventResult.Who := m_currPlayer;

        m_currPlayer := NextPlayer(m_currPlayer);

        calcAvailablePos();
        notifyAll(eventResult);
      end
    end;

    property Player: PlayerT read m_players.Item[m_currPlayer];
    property PlayersDict: PlayersDictT read m_players;
    property AvailablePos: List<IndexT> read m_availablePos;
    property BallsToMove: List<AvailableMovesT> read m_ballsToMove;

    function Get(ind : IndexT) : CellT;
    begin
      Result := field[ind[0], ind[1], ind[2]];
    end;

    procedure Subscribe(subscriber: ISubscriberT);
    procedure notifyAll(eventResult: GameEventResultT);

  private
    procedure calcAvailablePos();

    procedure SetCell(ind : IndexT; val1 : CellT);
    begin
      field[ind[0], ind[1], ind[2]] := val1;
    end;

    function isLocked(index : IndexT) : boolean;
    begin
      var indices := Arr(UpLeft(index), UpRight(index), DownLeft(index), DownRight(index));
      foreach ind : IndexT in indices do begin
        var tInd := Top(ind);
        if (IsValid(tInd)) and (Get(tInd) <> Empty) then begin
          Result := true;
        end;
      end;
      Result := false;
    end;

  end;

  // ----------- Реализация методов -------------- //

  procedure GameLogicT.calcAvailablePos();
  begin
    m_availablePos.Clear();
    squareList.Clear();
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
            squareList.Add(ind);
          end;
        end;
      end;
    end;

    for var k := 0 to FHei - 1 do begin
      for var i := 0 to FWid step 2 do begin
        for var j := 0 to FWid step 2 do begin
          var ind := (i, j, k);
          if (Get(ind) <> Empty) and (not isLocked(ind)) then
          begin
            var lst := new List<IndexT>();
            foreach square: IndexT in squareList do begin
              if square[2] > ind[2] then begin
                lst.Add(square);
              end;
            end;
            if lst.Count() > 0 then
              m_ballsToMove.Add((ind, lst));
          end;
        end;
      end;
    end;

  end;

  procedure GameLogicT.Subscribe(subscriber: ISubscriberT);
  begin
    subscriberList.Add(subscriber);
  end;

  procedure GameLogicT.notifyAll(eventResult: GameEventResultT);
  begin
    foreach var s : ISubscriberT in subscriberList do begin
      s.notify(eventResult);
    end;
  end;

end.