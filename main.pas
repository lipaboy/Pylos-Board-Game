uses Graph3D;
uses utils;

begin 
  var field: array[0..6, 0..6, 0..3] of BallType;
  var ballSelected: BallType;
  var ballList := new List<BallType>;
  // var textDebug := Text3D(-5,0,1,text,2);
  
  for var i := 0 to 6 do
    for var j := 0 to 6 do
      for var k := 0 to 3 do
        field[i,j,k] := nil;
  ballSelected := nil;
  
  var x0 := -3;
  var y0 := -3;
  var z0 := 1;
  var material1 := Materials.Diffuse(RGB(255, 163, 117)) 
    + Materials.Specular(150,100) + Materials.Emissive(GrayColor(0));
  var material2 := Materials.Diffuse(RGB(110,  51,  26)) 
    + Materials.Specular(150,100) + Materials.Emissive(GrayColor(0));
//  var m := (field[1, 1, 1] as Sphere).Material;
  for var i := 0 to 6 step 2 do begin
    for var j := 0 to 6 step 2 do begin
      field[i, j, 0] := new BallType(
        Sphere(x0 + j, y0 + i, z0, 1, 
          random(2) = 0 ? material1 : material2), False);
      ballList.Add(field[i, j, 0]);
    end;
  end;

  
  OnMouseMove += procedure (x,y,mb) -> begin
    var select: BallType;
    select := nil;

    var nearest := real.MaxValue;
    foreach var ball: BallType in ballList do begin
      if (ball <> nil) and (GetRay(x, y).DistanceToPoint(ball.Position) <= ball.Radius) then
      begin
        select := ball;
      end;
    end;

    // for var i := 0 to 6 do
    //   for var j := 0 to 6 do
    //     for var k := 0 to 3 do begin
    //       var ball := field[i, j, k];
    //       if (ball <> nil) and (GetRay(x, y).DistanceToPoint(ball.Position) <= 1) then
    //       begin
    //         b := ball;
    //       end;
    //     end;
    
    if select <> ballSelected then begin
      if ballSelected <> nil then
        ballSelected.Visible := false;
      if select <> nil then
        select.Visible := true;
      ballSelected := select;
    end;
  end;
end.