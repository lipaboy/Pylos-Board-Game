unit GameView;

uses GameSettings;
uses Players;
uses GameLogic;
uses FieldView;

uses utils;
uses Graph3D;
uses Ball;
uses Timers;

type
  GameViewT = class(ISubscriberT)
  private
    m_gameLogic: GameLogicT := nil;

    m_field := new FieldViewT();
    // field: array[0..FWid, 0..FWid, 0..FHei] of BallType;
    // fieldCoords: array[0..FWid, 0..FWid, 0..FHei] of Point3D;

    m_ballsToMove := new List<AvailableMovesT>;
    indToMoveSelected := EmptyIndex();

    ballSelected: BallType := nil;
    indexSelected := EmptyIndex();
    m_availablePos := new List<IndexT>;
    rotTimer : Timer;
    baseVecRotation : Vector3D;

    boardModel: FileModelT := nil;
    roomModel: FileModelT := nil;
    carpetObj: FileModelT := nil;

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

      var updateField := procedure -> begin
        for var i := 0 to FWid do
          for var j := 0 to FWid do
            for var k := 0 to FHei do begin
              var ind := (i, j, k);
              var elem := m_gameLogic.Get(ind);
              if (elem <> CellT.Empty) and (m_field.Get(ind) = nil) then
              begin
                // var ball := new BallType(fieldCoords[i, j, k], GetPlayerByCell(elem), true);
                // ball.Rotate(ballSelected.)
                // var (ex, ey) := (random(2), random(2));
                // ball.Rotate(V3D(ex, ey, random(2) + (ex + ey = 0 ? 1  : 0)), random(360));

                var ball := ballSelected;
                ball.Visible := true;
                m_field.SetBall(ind, ball);
                exit;
              end;
            end;
        end;
      updateField();

      if m_gameLogic.IsGameInitializing then
      begin
        Init();
      end;

      ballSelected := new BallType(P3D(0, 0, 0), m_gameLogic.Player.Who, false);
      m_availablePos := m_gameLogic.AvailablePos;
      m_ballsToMove := m_gameLogic.BallsToMove;
      
      // rotTimer.Start();
    end;

  private

    procedure Init();
    begin
      m_field.Reset();
      // textDebug.Text := '' + carpetObj.Count();
    end;

    function FindNearestSelectable(x, y: real) : (boolean, boolean, IndexT);

    procedure AddMouseEvent();

  end;

  // ---------------- Реализация методов ---------------- //

  procedure GameViewT.AddMouseEvent();
  begin
    OnMouseMove += procedure (x,y,mb) -> begin
      var (isFound, isBallToMove, ind) := FindNearestSelectable(x, y);

      if (not isBallToMove) and (indToMoveSelected <> EmptyIndex()) then begin
        m_field.Get(indToMoveSelected).SetSelected(false);
        indToMoveSelected := EmptyIndex();
      end;

      if ballSelected <> nil then begin
        if not isFound then begin
          ballSelected.Visible := false;
          indexSelected := EmptyIndex();
          // textDebug.Text := '';
        end
        else if isBallToMove then begin
          indToMoveSelected := ind;
          m_field.Get(ind).SetSelected(true);
          // if m_field.Get(ind) = nil then
            // textDebug.Text := 'Ups: ' + ToStr(ind);
          ballSelected.Visible := false;
          indexSelected := EmptyIndex();
        end
        else begin
          // textDebug.Text := '';
          ballSelected.Visible := true;
          if ind <> indexSelected then begin
            ballSelected.Position := m_field.GetCoord(ind);
            indexSelected := ind;
          end;
        end;
      end;
    end;

    OnMouseDown += procedure(x, y, mb) -> begin
      if mb = 1 then begin
        rotTimer.Stop();
        ballSelected.Visible := false;
        m_gameLogic.MakeStep(indexSelected);
      end;
    end;
  end;

  function GameViewT.FindNearestSelectable(x, y: real) : (boolean, boolean, IndexT);
  begin
    var isFound := false;
    var isBallToMoveFound := false;
    var indFound := (-1, -1, -1);

    var nearest := real.MaxValue;
    for var k := 0 to FHei do
      for var i := k to FWid - k step 2 do
        for var j := k to FWid - k step 2 do begin
          var ind := (i, j, k);
          var p := m_field.GetCoord(ind);
          var isAvailable := ind in m_availablePos;
          var isBallToMove := m_ballsToMove.Any(x -> (x[0] = ind) and (x[1].Count() > 0));
          if (isAvailable or isBallToMove)
            and (GetRay(x, y).DistanceToPoint(p) <= BASE_RADIUS * 1.2) then
          begin
            var dstToCamera := Camera.Position.Distance(p);
            if dstToCamera < nearest then begin
              isFound := true;
              indFound := ind;
              nearest := dstToCamera;
              isBallToMoveFound := isBallToMove;
            end;
          end;
        end;

    Result := (isFound, isBallToMoveFound, indFound);
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

// ImageMaterial('res/carpet.jpg')
    // var mat := ImageMaterial('res/tree_texture.jpg', 10, 10);
    // carpetObj := FileModel3D(0, 0, 0, 'res/Carpet.obj', mat);
    // carpetObj.Rotate(V3D(1, 0, 0), 90);
    // carpetObj.MoveOn(V3D(0, 0, 6));
    // carpetObj.Scale(10);
    // carpetObj.Material := mat;


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

//    textDebug.Text := '' + carpetObj.Items[0].X;

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

    baseVecRotation := V3D(1, 0, 0);
    rotTimer := new Timer(30, procedure()->begin
      ballSelected.Rotate(baseVecRotation, 1);
      var f1 : function (): real := () -> power(random(-1.0, 1.0), 2.0);
      baseVecRotation := Vector3D.Add( baseVecRotation, Vector3D.Create(f1(), f1(), f1()) );
    end);
    
    AddMouseEvent();
  end;




end. // module end