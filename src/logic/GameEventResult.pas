unit GameEventResult;

uses Index;
uses Players;
uses PlayerEnum;

type
  GameEventResultT = record
    IsInitializing: boolean := false;

    // в чей ход произошло событие
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

    IsGameOver: boolean := false;
  end;

end.