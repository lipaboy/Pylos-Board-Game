﻿uses Graph3D;
uses utils;

type
  GameHolder = class
  private
    brightBallMaterial := ImageMaterial('res/tree_texture.jpg')
      + Materials.Specular(150,100) + Materials.Emissive(GrayColor(0));
    darkBallMaterial := ImageMaterial('res/tree_texture_dark.jpg')
      + Materials.Specular(150,100) + Materials.Emissive(GrayColor(0));
    boardMaterial := Materials.Diffuse(RGB(110,  51,  26)) 
      + Materials.Specular(150,100) + Materials.Emissive(GrayColor(0));

    field: array[0..6, 0..6, 0..3] of BallType;
    ballSelected: BallType := nil;
    boardModel: FileModelT := nil;
    roomModel: FileModelT := nil;
    ballList := new List<BallType>;
    textDebug: TextT := nil;
    ballCaught: BallType := nil;
    xx, yy: real;

  public
    constructor Create();
    begin
      View3D.ShowGridLines := False;
      View3D.BackgroundColor := Colors.Black;

      var textDebug := Text3D(-5,-11,5,'text ',2, Colors.Wheat);

      roomModel := FileModel3D(0, 0, 0, 'res/Scene/Low_poly_bedroom.obj', boardMaterial);
      roomModel.Rotate(V3D(1, 0, 0), 90);
      roomModel.MoveOn(V3D(-38, -42, -5));
      roomModel.Scale(20);

      boardModel := FileModel3D(0, 0, 0, 'pylos_board.obj', boardMaterial);
      boardModel.Scale(0.2);

      // Lights.AddDirectionalLight(RGB(255, 120, 50),V3D(-1,-1,-4));
      Lights.AddSpotLight(RGB(155, 155, 0),P3D(5, 5, 5),V3D(-1, -1, -1),120,45);
      
      for var i := 0 to 6 do
        for var j := 0 to 6 do
          for var k := 0 to 3 do
            field[i,j,k] := nil;

      
      var radius := 1.1;
      var halfDeltaX := 0.15 + 1;
      var halfDeltaY := 0.17 + 1;
      var deltaZ := sqrt(sqr(2 * radius) - (sqr(2 * halfDeltaX) + sqr(2 * halfDeltaY)) / 4.0);
      var x0 := -3.4;
      var y0 := -3.5;
      var z0 := 0.94 + radius;
      for var k:= 0 to 3 do begin
        for var i := k to 6 - k step 2 do begin
          for var j := k to 6 - k step 2 do begin
            var ball := 
              new BallType(
                Sphere(x0 + j * halfDeltaX, y0 + i * halfDeltaY, z0 + k * deltaZ, radius, 
                  random(2) = 0 ? brightBallMaterial : darkBallMaterial), True);
            var (ex, ey) := (random(2), random(2));
            ball.Figure.Rotate(V3D(ex, ey, random(2) + (ex + ey = 0 ? 1  : 0)), random(360));
            field[i, j, 0] := ball;
            ballList.Add(ball);
          end;
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