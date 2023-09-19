unit GameLogic;

const
  GAME_BASE_WIDTH = 4;
  GAME_BASE_HEIGHT = 4;
  PLAYER_BALL_COUNT = 30 div 2;
  FIELD_WIDTH = 2 * GAME_BASE_WIDTH - 1;
  FIELD_HEIGHT = GAME_BASE_HEIGHT;
  FWid = FIELD_WIDTH - 1;
  FHei = FIELD_HEIGHT - 1;


type
  PlayerT = (BrightPlayer, DarkPlayer);

type
  ISubscriberT = interface
    procedure notify();
  end;

type
  CellT = (Bright, Dark, Empty);

type
  IndexT = System.Tuple<Integer, Integer, Integer>;

type
  GameLogicT = class
  private
    field: array[0..FWid, 0..FWid, 0..FHei] of CellT;
    m_availablePos := new List<IndexT>;
    selectableBalls := new List<IndexT>;
    m_player: PlayerT;
    m_isGameInitializing := false;

    subscriberList := new List<ISubscriberT>;
  public
    constructor Create();
    begin
    end;

    procedure Start();
    begin
      for var i := 0 to FWid do 
        for var j := 0 to FWid do 
          for var k := 0 to FHei do 
            field[i, j, k] := Empty;

      m_player := BrightPlayer;
      m_isGameInitializing := true;

      calcAvailablePos();
      notifyAll();
    end;

    property Player: PlayerT read m_player;
    property IsGameInitializing: boolean read m_isGameInitializing;
    property AvailablePos: List<IndexT> read m_availablePos;

    procedure Subscribe(subscriber: ISubscriberT);
    procedure notifyAll();

  private
    procedure calcAvailablePos();

    function Get(ind : IndexT) : CellT;
    begin
      Result := field[ind[0], ind[1], ind[2]];
    end;

    procedure SetCell(ind : IndexT; val1 : CellT);
    begin
      field[ind[0], ind[1], ind[2]] := val1;
    end;

    function UpLeft(ind : IndexT) : IndexT := (ind[0] - 1, ind[1] - 1, ind[2] - 1);
    function UpRight(ind : IndexT) : IndexT := (ind[0] - 1, ind[1] + 1, ind[2] - 1);
    function BottomLeft(ind : IndexT) : IndexT := (ind[0] + 1, ind[1] - 1, ind[2] - 1);
    function BottomRight(ind : IndexT) : IndexT := (ind[0] + 1, ind[1] + 1, ind[2] - 1);
    function IsValid(ind : IndexT) : boolean;
    begin
      var k := ind[2];
      if (k in 0..FHei) and (ind[0] in k..FWid-k) and (ind[1] in k..FWid-k) then begin
        Result := true;
      end
      else
        Result := false;
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