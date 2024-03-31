uses Graph3D;
uses Timers;

const 
  GRAVITY = 9.8;

begin
  var sBlue := Cube(3,0,10,1.5,Colors.Blue);
  var sRed := Cube(0,0,10,1.5,Colors.Red);
  // var anim := sRed.AnimMoveByZ(-10, 0.5).AccelerationRatio(0.5, 0);
  var anim := sRed.AnimMoveByZ(0, 0);
//  anim := anim * anim;
  
  var animBlue := sBlue.AnimMoveByZ(-10).AccelerationRatio(0.5,0);
  


  var t := 0.0;
  var tStep := 0.05;
  var z0 := 10.0;
  var z := 0.0;

  while (z < z0) do
  begin
    t += tStep;
    anim := anim + sRed.AnimMoveByZ(-(GRAVITY * t * t / 2.0 - z), tStep);
    z := GRAVITY * t * t / 2.0;
  end;

  var tb := 0.0;
  var tbStep := 0.005;
  var diff := 0.0;
  var timRef : Timer := nil;
  var tim := new Timer(Integer(tbStep * 1000), 
    procedure() ->
    begin
      if sBlue.Z > 0.0 + 1.5 then
      begin
        tb += tbStep;
        sBlue.Z += - (GRAVITY * tb * tb / 2.0 + tb * 2.0 - diff);
        diff := GRAVITY * tb * tb / 2.0  + tb * 2.0 - diff;
      end
      else
        timRef.Stop;
    end);
  timRef := tim;
  
  OnMouseDown += procedure(x,y:real; mb:integer) ->
  begin
    sRed.Z := 10;

    sBlue.Z := 10;
    tb := 0.0;
    diff := 0.0;

    tim.Start();
    anim.Begin;
  end;
  
end.