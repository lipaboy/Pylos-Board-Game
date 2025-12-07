unit Stereometry;

uses Graph3D;

///////////   Geometry Extension   //////////////

  // ИНФО
  // Делаем допущение, что Ray3D - это класс для работы не только с лучами,
  // но и с прямой. Потому что Line3D в библиотеке Graph3D определён как Ray3D,
  // т.е. является его эквивалентом.

  function LineIntersection(Self: Ray3D; other: Ray3D): Point3D; extensionmethod;
  begin 
    // Вектор нормали к прямой Self и other (т.е. это плоскость, в которой лежат
    // эти две прямые)
    var normalVec := Vector3D.CrossProduct(Self.Direction, other.Direction);
    // Вектор нормали плоскости, которая перпендикулярна предыдущей и в которой
    // лежит прямая Self
    var planeNormal := Vector3D.CrossProduct(Self.Direction, normalVec);
    // Пытаемся найти пересечение прямой other с плоскостью, 
    // заданной одной из точек прямой Self и вектором нормали planeNormal
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

  function PlaneProjection(Self: Point3D; 
                           planePoint: Point3D; 
                           planeNormal: Vector3D): Point3D; extensionmethod;
  begin
    
  end;

  function DistanceToPoint(Self: Ray3D; point: Point3D): real; extensionmethod;
  begin
    var origin := Self.Origin;
    // Question: Зачем здесь Round?
    var pVec := Vector3D.Create(Round(point.X - origin.X), 
                                Round(point.Y - origin.Y), 
                                Round(point.Z - origin.Z));
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