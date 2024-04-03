unit Utils;

uses Graph3D;

/////////////   Debug Mode   //////////////

// {$undef DEBUG}
const
{$ifdef DEBUG}
  APP_TITLE = 'Pylos Game (Debug)';
{$else}
  APP_TITLE = 'Pylos Game';
{$endif}

/////////////   Auto-play Mode   //////////////

// {$define AUTO_PLAY}
const
{$ifdef AUTO_PLAY}
  IS_AUTO_PLAY_MODE_ON = true;
{$else}
  IS_AUTO_PLAY_MODE_ON = false;
{$endif}

/////////////   Loging (only in debug mode)   //////////////

  procedure logln(message: string := '');
  begin
    {$ifdef DEBUG}
      var f := OpenAppend('log.txt', Encoding.UTF8);
      Println(f, message);
      f.Close();
    {$endif}
  end;

  procedure log(message: string);
  begin
    {$ifdef DEBUG}
      var f := OpenAppend('log.txt', Encoding.UTF8);
      Print(f, message);
      f.Close();
    {$endif}
  end;

  procedure clearLogFile();
  begin
    {$ifdef DEBUG}
      // TODO: вывести дату начала ведения лога
      var f := OpenWrite('log.txt', Encoding.UTF8);
      Print(f, '');
      f.Close();
    {$endif}
  end;

///////////   Geometry Extension   //////////////

  function LineIntersection(Self: Ray3D; other: Ray3D): Point3D; extensionmethod;
  begin 
    var normalVec := Vector3D.CrossProduct(Self.Direction, other.Direction);
    var planeNormal := Vector3D.CrossProduct(Self.Direction, normalVec);
    var p := other.PlaneIntersection(Self.Origin, planeNormal);
    if p.HasValue then
      Result := p.Value
    else 
      Result := BadPoint;
  end;

  function Distance(Self: Point3D; other: Point3D): real; extensionmethod;
  begin
    Result := sqrt(sqr(Self.X - other.X) + sqr(Self.Y - other.Y) + sqr(Self.Z - other.Z));
  end;

  function DistanceToPoint(Self: Ray3D; point: Point3D): real; extensionmethod;
  begin
    var origin := Self.Origin;
    var pVec := Vector3D.Create(Round(point.X - origin.X), Round(point.Y - origin.Y), Round(point.Z - origin.Z));
    var normal := Vector3D.CrossProduct(pVec, Self.Direction);
    var lineNormal := Vector3D.CrossProduct(normal, Self.Direction);
    Result := point.Distance(Self.LineIntersection(Ray(point, lineNormal)));
  end;

  function ToPoint(Self: Vector3D) : Point3D; extensionmethod;
  begin
    Result := P3D(Self.X, Self.Y, Self.Z);
  end;

  function op_Addition(Self: Point3D; other: Point3D): Point3D; extensionmethod;
  begin
    Result := P3D(Self.X + other.X, Self.Y + other.Y, Self.Z + other.Z);
  end;
  
end.