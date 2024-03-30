unit AutoPlayGame;

uses Index;
uses GameEventResult;
uses ISubscriber;
uses GameLogic;
uses PlayerEnum;
uses Players;

type
  AutoPlayGameT = class(ISubscriberT)
  private
    m_gameLogic : GameLogicT;

  public
    constructor Create(gameLogic : GameLogicT);
    begin
      m_gameLogic := gameLogic;
    end;

    procedure Play();
    begin
      m_gameLogic.Subscribe(Self);
      if m_gameLogic.IsStarted then
        m_gameLogic.AddBallStep((2, 2, 0));
      m_gameLogic.UnSubscribe(Self);
    end;

    procedure Notify(eventResult: GameEventResultT);
    begin
      if m_gameLogic.PlayersDict.Sum(p -> p.Value.BallsRemain) < 5 then
        exit;

      if eventResult.IsAdd or eventResult.IsTaken then begin
        if m_gameLogic.AvailablePos.Any() then
          m_gameLogic.AddBallStep(m_gameLogic.AvailablePos.First());
      end
      else if eventResult.IsMove then begin
        if m_gameLogic.BallsToMove.Any() then begin
          var ballMove := m_gameLogic.BallsToMove.First();
          m_gameLogic.MoveBallStep(ballMove[0], ballMove[1].First());
        end;
      end
      else if eventResult.IsNeedToTake then begin
        m_gameLogic.TakeBallsStep(m_gameLogic.BallsForTake.Take(2).ToList());
      end;
    end;

  end;

end.