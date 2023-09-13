uses Graph3D;
uses global;
uses utils;

type
  GameHolder = class
  private
    brightBallMaterial := ImageMaterial('res/tree_texture.jpg');
    darkBallMaterial := ImageMaterial('res/tree_texture_dark.jpg');
    boardMaterial := Materials.Diffuse(RGB(110,  51,  26)) 
      + Materials.Specular(150,100) + Materials.Emissive(GrayColor(0));

    field: array[0..6, 0..6, 0..3] of BallType;
    ballSelected: BallType := nil;
    modelBoard: FileModelT := nil;
    ballList := new List<BallType>;
    textDebug: TextT := nil;
    ballCaught: BallType := nil;
    xx, yy: real;

  public
    constructor Create();
    begin
      var textDebug := Text3D(-5,-11,5,'text ',2);

      modelBoard := FileModel3D(0, 0, 0, 'pylos_board.obj', boardMaterial);
      modelBoard.Scale(0.2);
      
      for var i := 0 to 6 do
        for var j := 0 to 6 do
          for var k := 0 to 3 do
            field[i,j,k] := nil;
      
      var radius := 1.1;
      var deltaX := 0.15 + 1;
      var deltaY := 0.17 + 1;
      var x0 := -3.4;
      var y0 := -3.5;
      var z0 := 0.94 + radius;
      // var m := Arr((1,2,3),(4,5,6),(7,8,9));
      var basis := Arr(V3D(1, 0, 0), V3D(0, 1, 0), V3D(0, 0, 1));
      for var i := 0 to 6 step 2 do begin
        for var j := 0 to 6 step 2 do begin
          var ball := 
            new BallType(
              Sphere(x0 + j * deltaX, y0 + i * deltaY, z0, radius, 
                random(2) = 0 ? brightBallMaterial : darkBallMaterial), True);
          var (ex, ey) := (random(2), random(2));
          ball.Figure.Rotate(V3D(ex, ey, random(2) + (ex + ey = 0 ? 1  : 0)), random(360));
          // ball.Figure.Rotate(basis[1], random(2 * pi));
          // ball.Figure.Rotate(basis[2], random(2 * pi));
          // ball.Rotate(basis[random(3)], random(2 * pi));
          field[i, j, 0] := ball;
          ballList.Add(ball);
        end;
      end;

      // OnMouseDown += procedure (x,y,mb) -> begin
      //   // if mb = 1 then begin
      //   //   var p := FindNearestObjectPoint(x, y);
      //   //   textDebug.Text := '(' + Round(p.X, 2) + ', ' 
      //   //     + Round(p.Y, 2) + ', ' + Round(p.Z, 2) + ')';
      //   // end;
      //   Self.ballCaught := FindNearestBall(x, y);
      //   Self.xx := x;
      //   Self.yy := y;
      //   textDebug.Text := 'ups';
      //   if Self.ballCaught <> nil then
      //   textDebug.Text := '' + Round(Self.ballCaught.Figure.Position.X, 2);
      // end;
      // OnMouseUp += procedure (x,y,mb) -> begin
      //   Self.ballCaught := nil;
      // end;
      
      OnMouseMove += procedure (x,y,mb) -> begin
        // if Self.ballCaught <> nil then
        // begin
        //   Self.ballCaught.Figure.Rotate(V3D(1, 0, 0), xx - x);
        //   textDebug.Text := '' + Round(xx - x, 2);
        //   Self.xx := x;
        // end;


        var select := FindNearestBall(x, y);
        
        if select <> ballSelected then begin
          if ballSelected <> nil then
            ballSelected.Visible := false;
          if select <> nil then
            select.Visible := true;
          ballSelected := select;
        end;
      end;
    end;

    function FindNearestBall(x, y: real) : BallType;
    begin
      var select: BallType;
      select := nil;

      var nearest := real.MaxValue;
      foreach var ball: BallType in ballList do begin
        if (ball <> nil) and (GetRay(x, y).DistanceToPoint(ball.Position) <= ball.Radius) then
        begin
          var dstToCamera := Camera.Position.Distance(ball.Position);
          if dstToCamera < nearest then begin
            select := ball;
            nearest := dstToCamera;
          end;
        end;
      end;

      Result := select;
    end;
end;

begin 
  var gameInstance := new GameHolder();
end.