unit ISubscriber;

uses GameEventResult in '../logic/GameEventResult';

// TODO: rename to IGameLogicSubscriber

type
  ISubscriberT = interface
    procedure Notify(eventResult: GameEventResultT);
  end;

end.