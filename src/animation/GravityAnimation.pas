unit GravityAnimation;

uses Graph3D;
uses Timers;
uses Utils in '../util/Utils';

const 
  GRAVITY = 9.8;

type
  GravityAnimationT = class
  private
    m_timer : Timer;
    m_object : Object3D := nil;
    m_inTheEnd : Action0 := nil;

    dt := 0.005; // 5 ms
    t := 0.0;
    diff := 0.0;

    m_speedCoef := 2.0;
    m_zLevel := 0.0;
    m_dir := 1.0;

  public
    constructor Create();
    procedure StartFall(objectToFall: Object3D; zDest, dir: real; inTheEnd: Action0 := nil);
    function IsPlaying(): boolean := m_timer.Enabled;
    
  private
    function IsLevelReached(): boolean;
  end;

constructor GravityAnimationT.Create();
begin
  var timerRef : Timer;
  m_timer := new Timer(Integer(dt * 1000),
    procedure () ->
    begin
      if not IsLevelReached() then
      begin
        t += dt;
        m_object.Z += m_dir * (GRAVITY * t * t / 2.0 + t * m_speedCoef - diff);
        diff := GRAVITY * t * t / 2.0 + t * m_speedCoef - diff;
      end
      else begin
        timerRef.Stop();
        m_object.Z := m_zLevel;
        m_inTheEnd();
      end;
    end);
  timerRef := m_timer;
end;

procedure GravityAnimationT.StartFall(objectToFall : Object3D; zDest, dir: real; inTheEnd: Action0);
begin
  t := 0;
  diff := 0;
  m_zLevel := zDest;
  m_dir := dir;
  m_object := objectToFall;
  m_inTheEnd := inTheEnd;
  // m_timer.Stop();
  m_timer.Start();
end;

function GravityAnimationT.IsLevelReached(): boolean;
begin
  Result := m_dir > 0.0 ? m_object.Z >= m_zLevel : m_object.Z <= m_zLevel;
end;

end.
