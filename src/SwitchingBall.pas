unit SwitchingBall;

uses Ball;
uses Graph3D;
uses Players;

type
  SwitchingBallT = class

  private
    m_darkBall : BallType;
    m_brightBall : BallType;
    m_currBall : BallType;

  public
    constructor Create(darkPos, brightPos : Point3D);
    begin
      m_darkBall := new BallType(darkPos, PlayerEnumT.DarkPlayer, false);
      m_brightBall := new BallType(brightPos, PlayerEnumT.BrightPlayer, false);
      m_currBall := m_darkBall;
    end;

    property Dark: BallType read m_darkBall;
    property Bright: BallType read m_brightBall;
    property Current: PlayerEnumT read m_currBall.Player;

    procedure SetBall(player: PlayerEnumT);
    begin
      m_currBall.Visible := false;
      m_currBall := player = PlayerEnumT.BrightPlayer ? m_brightBall : m_darkBall;
      m_currBall.Visible := true;
    end;

    procedure Switch();
    begin
      m_currBall.Visible := false;
      m_currBall := m_currBall.Player = PlayerEnumT.DarkPlayer ? m_brightBall : m_darkBall;
      m_currBall.Visible := true;
    end;

    procedure AddSwitchBallMouseEvent();
    begin
      AddMouseEvent(procedure () -> begin Self.Switch(); end);
    end;

    procedure AddMouseEvent(lambda: () -> ());
    begin
      OnMouseDown += procedure (x,y,mb) -> begin
        if mb<>1 then 
          exit;
        var v := FindNearestObject(x,y);
        if (v = m_brightBall.Figure) or (v = m_darkBall.Figure) then
        begin
          lambda();
        end;
      end;
    end;

  end;

end.