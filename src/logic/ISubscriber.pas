unit ISubscriber;

uses GameEventResult;

// TODO: rename to IGameLogicSubscriber

type
  ISubscriberT = interface
    procedure Notify(eventResult: GameEventResultT);
  end;

end.