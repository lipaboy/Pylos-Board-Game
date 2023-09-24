unit GameLogic;

uses Players;
uses GameSettings;

// ---------------- GameLogic ----------------- //

type
  PlayersDictT = Dictionary<PlayerEnumT, PlayerT>;

type
  GameLogicT = class
  private
    m_players : PlayersDictT;
    m_currPlayer: PlayerEnumT;
    m_isGameInitializing := false;

    field: array[0..FWid, 0..FWid, 0..FHei] of CellT;
    m_availablePos := new List<IndexT>;
    selectableBalls := new List<IndexT>;

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
      m_isGameInitializing := true;

      calcAvailablePos();
      notifyAll();

      m_isGameInitializing := false;
    end;

    procedure MakeStep(stepInd : IndexT);
    begin
      if not IsEmptyIndex(stepInd) then begin
        SetCell(stepInd, GetCellByPlayer(m_currPlayer));
        m_players.Item[m_currPlayer].BallsRemain -= 1;

        m_currPlayer := NextPlayer(m_currPlayer);

        calcAvailablePos();
        notifyAll();
      end
    end;

    property Player: PlayerT read m_players.Item[m_currPlayer];
    property PlayersDict: PlayersDictT read m_players;
    property IsGameInitializing: boolean read m_isGameInitializing;
    property AvailablePos: List<IndexT> read m_availablePos;
    function Get(ind : IndexT) : CellT;
    begin
      Result := field[ind[0], ind[1], ind[2]];
    end;

    procedure Subscribe(subscriber: ISubscriberT);
    procedure notifyAll();

  private
    procedure calcAvailablePos();

    procedure SetCell(ind : IndexT; val1 : CellT);
    begin
      field[ind[0], ind[1], ind[2]] := val1;
    end;


  end;

  // ----------- Реализация методов -------------- //

  procedure GameLogicT.calcAvailablePos();
  begin
    m_availablePos.Clear();

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
            and (Get(UpLeft(ind)) <> Empty)
            and (Get(UpRight(ind)) <> Empty)
            and (Get(BottomRight(ind)) <> Empty)
            and (Get(BottomLeft(ind)) <> Empty) then
          begin
            hasSquare := true;
            m_availablePos.Add(ind);
          end;
        end;
      end;
      if not hasSquare then
      begin
        break;
      end;
    end;
  end;

  procedure GameLogicT.Subscribe(subscriber: ISubscriberT);
  begin
    subscriberList.Add(subscriber);
  end;

  procedure GameLogicT.notifyAll();
  begin
    foreach var s : ISubscriberT in subscriberList do begin
      s.notify();
    end;
  end;

end.