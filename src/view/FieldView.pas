unit FieldView;

uses Index;
uses GameSettings;
uses Ball;

uses Graph3D;

type
	FieldViewT = class
	private
    field: array[0..FWid, 0..FWid, 0..FHei] of BallType;
    fieldCoords: array[0..FWid, 0..FWid, 0..FHei] of Point3D;

	public
		constructor Create();

    function GetCoord(ind: IndexT) := fieldCoords[ind[0], ind[1], ind[2]];
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
          for var k := 0 to FHei do
            field[i, j, k] := nil;
    end;

	end;


constructor FieldViewT.Create();
begin
  var radius := BASE_RADIUS;
  
  var halfDeltaX := 0.15 + 1;
  var halfDeltaY := 0.17 + 1;
  var deltaZ := sqrt(sqr(2 * radius) - (sqr(2 * halfDeltaX) + sqr(2 * halfDeltaY)) / 4.0);
  var x0 := -3.4;
  var y0 := -3.5;
  var z0 := 0.94 + radius;
  for var k:= 0 to FHei do begin
    for var i := k to FWid - k step 2 do begin
      for var j := k to FWid - k step 2 do begin
        fieldCoords[i, j, k] := P3D(x0 + j * halfDeltaX, y0 + i * halfDeltaY, z0 + k * deltaZ);
      end;
    end;
  end;

end;

end.