unit FieldView;

uses Players;
uses Index;
uses GameSettings;
uses Ball;
uses Utils;

uses Graph3D;

type
	FieldViewT = class
	private
    fieldCoords: array[0..FWid, 0..FWid, 0..FHei] of Point3D;
    field: array[0..FWid, 0..FWid, 0..FHei] of BallType;

    m_brightBalls: array[0..PLAYER_BALL_COUNT-1] of BallType;
    m_darkBalls: array[0..PLAYER_BALL_COUNT-1] of BallType;

	public
		constructor Create(centerPos: Point3D);

    property BrightBalls: read m_brightBalls;
    property DarkBalls: read m_darkBalls;

    function GetCoord(ind: IndexT) := IsValid(ind) 
      ? fieldCoords[ind[0], ind[1], ind[2]] : P3D(0, 0, 0);
    function Get(ind: IndexT) := IsValid(ind) ? field[ind[0], ind[1], ind[2]] : nil;
    procedure SetBall(ind: IndexT; ball: BallType);
    begin
    	if ball <> nil then begin
	    	ball.Position := GetCoord(ind);
	    	ball.Visible := true;
    	end;
    	field[ind[0], ind[1], ind[2]] := ball;
    end;

		procedure Clear();
    begin
      for var i := 0 to FWid do
        for var j := 0 to FWid do
          for var k := 0 to FHei do begin
            field[i, j, k] := nil;
          end;
    end;

	end;

  // _________________ Реализация методов ________________ //

  constructor FieldViewT.Create(centerPos: Point3D);
  begin
    var radius := BASE_RADIUS;
    
    // Здесь хранятся значения высоты доски для шаров, а также координаты лунок

    var halfDeltaX := 0.15 + 1;
    var halfDeltaY := 0.17 + 1;
    var deltaZ := sqrt(sqr(2 * radius) - (sqr(2 * halfDeltaX) + sqr(2 * halfDeltaY)) / 4.0);
    var x0 := -3.4 + centerPos.X;
    var y0 := -3.5 + centerPos.Y;
    var z0 := 0.94 + radius + centerPos.Z;
    for var k:= 0 to FHei do begin
      for var i := k to FWid - k step 2 do begin
        for var j := k to FWid - k step 2 do begin
          fieldCoords[i, j, k] := P3D(x0 + j * halfDeltaX, y0 + i * halfDeltaY, z0 + k * deltaZ);
        end;
      end;
    end;

    // ---- Создаём шары ---- //

    // координаты кормашка для шаров

    var negXYBall := GetCoord((0, 0, 0));
    var pocketNegXY := P3D(negXYBall.x - (halfDeltaX * 4 - 0.07 * radius), 
                           negXYBall.y - (halfDeltaX * 4 + 0.1 * radius), 
                           z0 + 0.1 * radius);

    for var i := 0 to 7 do begin
      var ball := new BallType(
        pocketNegXY + V3D(0, (i + 1) * (2.03 * radius), 0), 
        PlayerEnumT.BrightPlayer, 
        true);
      m_brightBalls[i] := ball;
    end;

    var negXposYBall := GetCoord((FWid, 0, 0));
    var pocketNegXposY := P3D(negXposYBall.x - (halfDeltaX * 4 - 0.07 * radius), 
                              negXposYBall.y + (halfDeltaX * 4 - 0.1 * radius), 
                              z0 + 0.1 * radius);
    // new BallType(pocketNegXposY, PlayerEnumT.BrightPlayer, true);
    for var i := 8 to PLAYER_BALL_COUNT - 1 do begin
      var ball := new BallType(
        (pocketNegXposY + V3D((i - 7) * (2.05 * radius), 0.0, 0.0)), 
        PlayerEnumT.BrightPlayer, 
        true);
      m_brightBalls[i] := ball;
    end;

    // Черные шары

    var posXYBall := GetCoord((FWid, FWid, 0));
    var pocketPosXY := P3D(posXYBall.x + (halfDeltaX * 4 + 0.03 * radius), 
                           posXYBall.y + (halfDeltaX * 4 + 0.2 * radius), 
                           z0 + 0.1 * radius);

    for var i := 0 to 7 do begin
      var ball := new BallType(
        pocketPosXY - V3D(0, (i + 1) * (2.03 * radius), 0), 
        PlayerEnumT.DarkPlayer, 
        true);
      m_darkBalls[i] := ball;
    end;

    var posXnegYBall := GetCoord((0, FWid, 0));
    var pocketPosXnegY := P3D(posXnegYBall.x + (halfDeltaX * 4 + 0.05 * radius), 
                              posXnegYBall.y - (halfDeltaX * 4 - 0.1 * radius), 
                              z0 + 0.1 * radius);
    // new BallType(pocketNegXposY, PlayerEnumT.BrightPlayer, true);
    for var i := 8 to PLAYER_BALL_COUNT - 1 do begin
      var ball := new BallType(
        (pocketPosXnegY - V3D((i - 7) * (2.05 * radius), 0.0, 0.0)), 
        PlayerEnumT.DarkPlayer, 
        true);
      m_darkBalls[i] := ball;
    end;

  end;

end.