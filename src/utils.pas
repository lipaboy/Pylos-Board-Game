unit utils;

uses Graph3D;

///////////   Ball   //////////////

type
  BallType = class
  private
    m_figure: SphereT;
    m_skeleton: Group3D;
    m_whole: Group3D;

  public
    constructor Create(figure: SphereT; visible: boolean);
    begin
      m_figure := figure;
      m_figure.Visible := visible;
    end;
    
    property Visible: boolean read m_figure.Visible write m_figure.Visible := value;
    property Position: Point3D read m_figure.Position;
    property Radius: real read m_figure.Radius;
    property Figure: SphereT read m_figure;
    
  end;
    
////////////////////////////////

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
  
end.