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
    MoveFromInd: IndexT;
    MoveToInd: IndexT;

    IsTake: boolean := false;
    TookBalls: List<IndexT>;
  end;

type
  ISubscriberT = interface
    procedure notify(eventResult: GameEventResultT);
  end;

end.