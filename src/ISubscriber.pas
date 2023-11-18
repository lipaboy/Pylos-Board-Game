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

    // состояние, при котором нужно взять шарики
    IsNeedToTake: boolean := false;
    // событие взятия шаров и каких конкретно
    IsTaken: boolean := false;
    BallsTaken: List<IndexT>;
  end;

type
  ISubscriberT = interface
    procedure Notify(eventResult: GameEventResultT);
  end;

end.