unit GameView;

uses GameSettings;
uses Players;
uses GameLogic;

uses utils;
uses Graph3D;
uses Ball;
uses Timers;

type
  GameViewT = class(ISubscriberT)
  private
    m_gameLogic: GameLogicT := nil;

    field: array[0..FWid, 0..FWid, 0..FHei] of BallType;
    fieldCoords: array[0..FWid, 0..FWid, 0..FHei] of Point3D;
    brightBalls := new BallType[PLAYER_BALL_COUNT];
    darkBalls := new BallType[PLAYER_BALL_COUNT];

    ballSelected: BallType := nil;
    indexSelected: IndexT;
    m_availablePos := new List<IndexT>;
    rotTimer : Timer;
    baseVecRotation := V3D(1, 0, 0);

    boardModel: FileModelT := nil;
    roomModel: FileModelT := nil;

    textDebug : TextT;
    textBallCount : TextT;
    textStep : TextT;

  public
    constructor Create(gameLogic: GameLogicT);

    procedure notify();
    begin
      textStep.Text := 'Ходит ' + m_gameLogic.Player.Name + ' игрок';
      textBallCount.Text := 'Счёт: ' + m_gameLogic.PlayersDict.Item[BrightPlayer].BallsRemain
        + ' : ' + m_gameLogic.PlayersDict.Item[DarkPlayer].BallsRemain;

      for var i := 0 to FWid do
        for var j := 0 to FWid do
          for var k := 0 to FHei do begin
            var elem := m_gameLogic.Get((i, j, k));
            if elem <> CellT.Empty then
            begin
              var ball := new BallType(fieldCoords[i, j, k], GetPlayerByCell(elem), true);
              // ball.Rotate(ballSelected.)
              // var (ex, ey) := (random(2), random(2));
              // ball.Rotate(V3D(ex, ey, random(2) + (ex + ey = 0 ? 1  : 0)), random(360));

              field[i, j, k] := ball;
            end;
          end;

      if m_gameLogic.IsGameInitializing then
      begin
        Init();
      end;

      ballSelected := BallType.Create(P3D(0, 0, 0), m_gameLogic.Player.Who, false);
      m_availablePos := m_gameLogic.AvailablePos;
      rotTimer := new Timer(30, procedure()->begin
        ballSelected.Rotate(baseVecRotation, 1);
        var f1 : function (): real := () -> power(random(-9.0, 9.0), 1.0);
        Vector3D.Add( baseVecRotation, Vector3D.Create(f1(), f1(), f1()) );
      end);
      // rotTimer.Start();
    end;

  private

    procedure Init();
    begin
      for var i := 0 to FWid do
        for var j := 0 to FWid do
          for var k := 0 to FHei do
            field[i, j, k] := nil;
    end;

    function FindNearestAvailableCoord(x, y: real) : (boolean, Point3D, IndexT);

    procedure AddMouseEvent();

  end;

  // ---------------- Реализация методов ---------------- //

  procedure GameViewT.AddMouseEvent();
  begin
    OnMouseMove += procedure (x,y,mb) -> begin
      var selectPos := FindNearestAvailableCoord(x, y);

      if ballSelected <> nil then begin
        if not selectPos[0] then begin
          ballSelected.Visible := false;
          indexSelected := EmptyIndex();
        end
        else begin
          ballSelected.Visible := true;
          if selectPos[1] <> ballSelected.Position then
            ballSelected.Position := selectPos[1];
            indexSelected := selectPos[2];
        end;
      end;
    end;

    OnMouseDown += procedure(x, y, mb) -> begin
      if mb = 1 then begin
        rotTimer.Stop();
        m_gameLogic.MakeStep(indexSelected);
      end;
    end;
  end;

  function GameViewT.FindNearestAvailableCoord(x, y: real) : (boolean, Point3D, IndexT);
  begin
    var select: Point3D;
    var indFound := (-1, -1, -1);
    var isFound := false;

    var nearest := real.MaxValue;
    for var k := 0 to FHei do
      for var i := k to FWid - k step 2 do
        for var j := k to FWid - k step 2 do begin
          var p := fieldCoords[i, j, k];
          var ind := (i, j, k);
          if m_availablePos.Contains(ind) 
            and (GetRay(x, y).DistanceToPoint(p) <= BASE_RADIUS * 1.2) then
          begin
            var dstToCamera := Camera.Position.Distance(p);
            if dstToCamera < nearest then begin
              isFound := true;
              select := p;
              indFound := ind;
              nearest := dstToCamera;
            end;
          end;
        end;

    Result := (isFound, select, indFound);
  end;

  constructor GameViewT.Create(gameLogic: GameLogicT);
  begin
    m_gameLogic := gameLogic;

    // ---- Создаём сцену ---- //

    View3D.ShowGridLines := False;
    View3D.BackgroundColor := Colors.Black;

    var boardMaterial := 
      Materials.Diffuse(RGB(110,  51,  26)) 
        + Materials.Specular(150, 100) + Materials.Emissive(GrayColor(0));

    roomModel := FileModel3D(0, 0, 0, 'res/Scene/Low_poly_bedroom.obj', boardMaterial);
    roomModel.Rotate(V3D(1, 0, 0), 90);
    roomModel.MoveOn(V3D(-38, -42, -5));
    roomModel.Scale(20);

    boardModel := FileModel3D(0, 0, 0, 'res/pylos_board.obj', boardMaterial);
    boardModel.Scale(0.2);
    
    var baseY := -12.5;
    var textColor := Colors.Brown;
    textDebug := Text3D(0, baseY - 4, 0, 'debug',2, textColor);
    textDebug.Rotate(V3D(1, 0, 0), 90);
    textBallCount := Text3D(0, baseY, 0, '', 2, textColor);
    textBallCount.Rotate(V3D(1, 0, 0), 90);
    textStep := Text3D(0, baseY - 2, 0, '', 2, textColor);
    textStep.Rotate(V3D(1, 0, 0), 90);

    Invoke(()->hvp.Children.RemoveAt(1));
    Lights.AddDirectionalLight(RGB(255, 255, 255),V3D(-1,-1,-4));
    Lights.AddSpotLight(RGB(155, 155, 0), P3D(5, 5, 5), V3D(-1, -1, -1), 120, 45);


    // ---- Создаём шары ---- //

    // for var i := 0 to brightBalls.Length - 1 do begin
    //   var ball := new BallType(P3D(0, 0, 0), BrightPlayer, false);
    //   // var (ex, ey) := (random(2), random(2));
    //   // ball.Rotate(V3D(ex, ey, random(2) + (ex + ey = 0 ? 1  : 0)), random(360));
    //   brightBalls[i] := ball;
    // end;

    // for var i := 0 to darkBalls.Length - 1 do begin
    //   var ball := new BallType(P3D(0, 0, 0), DarkPlayer, false);
    //   darkBalls[i] := ball;
    // end;

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
    
    AddMouseEvent();
  end;




end. // module end