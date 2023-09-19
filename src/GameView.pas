unit GameView;

uses Graph3D;
uses Ball;
uses utils;
uses GameLogic;

type
  GameViewT = class(ISubscriberT)
  private
    m_gameLogic: GameLogicT := nil;

    field: array[0..FWid, 0..FWid, 0..FHei] of BallType;
    fieldCoords: array[0..FWid, 0..FWid, 0..FHei] of Point3D;
    brightBalls := new BallType[PLAYER_BALL_COUNT];
    darkBalls := new BallType[PLAYER_BALL_COUNT];

    ballSelected: BallType := nil;
    m_availablePos := new List<IndexT>;

    boardModel: FileModelT := nil;
    roomModel: FileModelT := nil;

    textDebug: TextT := nil;

  public
    constructor Create(gameLogic: GameLogicT);

    procedure notify();
    begin
      textDebug.Text := 'Ходит ' + (m_gameLogic.Player = BrightPlayer ? 'Светлый' : 'Тёмный') 
        + ' игрок';

      if m_gameLogic.IsGameInitializing then
      begin
        Init();
      end;

      if m_gameLogic.Player = BrightPlayer then
      begin
        ballSelected := BallType.Create(P3D(0, 0, 0), BrightPlayer, false);
        m_availablePos := m_gameLogic.AvailablePos;
      end;
    end;

  private
    procedure Init();
    begin
      for var i := 0 to FWid do
        for var j := 0 to FWid do
          for var k := 0 to FHei do
            field[i, j, k] := nil;
    end;

    function FindNearestAvailableCoord(x, y: real) : (Point3D, boolean);
    begin
      var select: Point3D;
      var isFound := false;

      var nearest := real.MaxValue;
      for var k := 0 to FHei do
        for var i := k to FWid - k step 2 do
          for var j := k to FWid - k step 2 do begin
            var p := fieldCoords[i, j, k];
            if m_availablePos.Contains((i, j, k)) 
              and (GetRay(x, y).DistanceToPoint(p) <= BASE_RADIUS) then
            begin
              var dstToCamera := Camera.Position.Distance(p);
              if dstToCamera < nearest then begin
                isFound := true;
                select := p;
                nearest := dstToCamera;
              end;
            end;
          end;

      Result := (select, isFound);
    end;

    procedure AddMouseEvent();
    begin
      OnMouseMove += procedure (x,y,mb) -> begin
        var selectPos := FindNearestAvailableCoord(x, y);

        if ballSelected <> nil then begin
          if not selectPos[1] then begin
            ballSelected.Visible := false;
          end
          else begin
            ballSelected.Visible := true;
            if selectPos[0] <> ballSelected.Position then
              ballSelected.Position := selectPos[0];
          end;
        end;

      end;
    end;

  end;    // end of class

  constructor GameViewT.Create(gameLogic: GameLogicT);
  begin
    m_gameLogic := gameLogic;

    // ---- Создаём сцену ---- //

    View3D.ShowGridLines := False;
    View3D.BackgroundColor := Colors.Black;

    var boardMaterial := 
      Materials.Diffuse(RGB(110,  51,  26)) 
        + Materials.Specular(150,100) + Materials.Emissive(GrayColor(0));

    roomModel := FileModel3D(0, 0, 0, 'res/Scene/Low_poly_bedroom.obj', boardMaterial);
    roomModel.Rotate(V3D(1, 0, 0), 90);
    roomModel.MoveOn(V3D(-38, -42, -5));
    roomModel.Scale(20);

    boardModel := FileModel3D(0, 0, 0, 'res/pylos_board.obj', boardMaterial);
    boardModel.Scale(0.2);
    textDebug := Text3D(-5,-9,2.5,'text ',2, Colors.Wheat);

    // Lights.AddDirectionalLight(RGB(255, 120, 50),V3D(-1,-1,-4));
    Lights.AddSpotLight(RGB(155, 155, 0),P3D(5, 5, 5),V3D(-1, -1, -1),120,45);


    // ---- Создаём шары ---- //

    for var i := 0 to brightBalls.Length - 1 do begin
      var ball := new BallType(P3D(0, 0, 0), BrightPlayer, false);
      brightBalls[i] := ball;
    end;

    for var i := 0 to darkBalls.Length - 1 do begin
      var ball := new BallType(P3D(0, 0, 0), DarkPlayer, false);
      darkBalls[i] := ball;
    end;

    var radius := brightBalls[0].Radius;
    
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
          // var ball := 
          //   new BallType(
          //     Sphere(x0 + j * halfDeltaX, y0 + i * halfDeltaY, z0 + k * deltaZ, radius, 
          //       random(2) = 0 ? brightBallMaterial : darkBallMaterial), True);
          // var (ex, ey) := (random(2), random(2));
          // ball.Figure.Rotate(V3D(ex, ey, random(2) + (ex + ey = 0 ? 1  : 0)), random(360));
          // field[i, j, 0] := ball;
          // ballList.Add(ball);
        end;
      end;
    end;
    
    AddMouseEvent();
  end;




end. // module end