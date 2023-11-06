unit ISubscriber;

uses Index;
uses Players;

type
  GameEventResultT = record
    IsInitializing: boolean := false;

    Who: PlayerEnumT;

    IsAdd: boolean := false;
    AddToPlaceInd: IndexT;

    IsMove: boolean := false;
    MoveBallInd: IndexT;
    MovePlaceInd: IndexT;

    IsTake: boolean := false;
    TookBalls: List<IndexT>;
  end;

type
  ISubscriberT = interface
    procedure Notify(eventResult: GameEventResultT);
  end;

end.