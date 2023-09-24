unit Ball;

uses Players;
uses GameSettings;
uses GameLogic;
uses Graph3D;

///////////   Ball (View)   //////////////

const
	BASE_RADIUS = 1.1;

type
  BallType = class
  private
    m_figure: SphereT;

    m_player: PlayerEnumT;

    m_skeleton: Group3D;
    m_whole: Group3D;

  public
    constructor Create(pos: Point3D; player: PlayerEnumT; visible: boolean);
    begin
      m_player := player;
      m_figure := Sphere(pos.x, pos.y, pos.z, BASE_RADIUS);
      m_figure.Visible := visible;

	    var brightBallMaterial := ImageMaterial('res/tree_texture.jpg')
	      + Materials.Specular(150,100) + Materials.Emissive(GrayColor(0));
	    var darkBallMaterial := ImageMaterial('res/tree_texture_dark.jpg')
	      + Materials.Specular(150,100) + Materials.Emissive(GrayColor(0));

	    if m_player = PlayerEnumT.BrightPlayer then begin
	    	m_figure.Material := brightBallMaterial;
    	end
	    else
	    	m_figure.Material := darkBallMaterial;
    end;
    
    property Visible: boolean read m_figure.Visible write m_figure.Visible := value;
    property Position: Point3D read m_figure.Position write m_figure.Position := value;
    property Radius: real read m_figure.Radius;
    // property Figure: SphereT read m_figure;
    
    procedure Rotate(asix: Vector3D; angle: real);
    begin
    	m_figure.Rotate(asix, angle);
    end;
    
  end;
    
////////////////////////////////

end.