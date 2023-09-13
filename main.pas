uses Graph3D;
uses global;
uses utils;

type
  GameHolder = class
  private
    field: array[0..6, 0..6, 0..3] of BallType;
    ballSelected: BallType := nil;
    modelBoard: FileModelT := nil;
    ballList := new List<BallType>;
    textDebug: TextT := nil;

  public
    constructor Create();
    begin
      var textDebug := Text3D(-5,-11,5,'text',2);

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
    //  var m := (field[1, 1, 1] as Sphere).Material;
      for var i := 0 to 6 step 2 do begin
        for var j := 0 to 6 step 2 do begin
          field[i, j, 0] := new BallType(
            Sphere(x0 + j * deltaX, y0 + i * deltaY, z0, radius, 
              random(2) = 0 ? brightBallMaterial : darkBallMaterial), True);
          // ballList.Add(field[i, j, 0]);
        end;
      end;

      OnMouseDown += procedure (x,y,mb) -> begin
        if mb = 1 then begin
          var p := FindNearestObjectPoint(x, y);
          textDebug.Text := '(' + Round(p.X, 2) + ', ' + Round(p.Y, 2) + ', ' + Round(p.Z, 2) + ')';
        end;
      end;
      
      OnMouseMove += procedure (x,y,mb) -> begin
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
        
        if select <> ballSelected then begin
          if ballSelected <> nil then
            ballSelected.Visible := false;
          if select <> nil then
            select.Visible := true;
          ballSelected := select;
        end;
      end;
    end;
end;

begin 
  var gameInstance := new GameHolder();
end.