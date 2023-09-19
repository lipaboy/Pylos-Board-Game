unit Ball;

uses GameLogic;
uses Graph3D;

///////////   Ball   //////////////

const
	BASE_RADIUS = 1.1;

type
  BallType = class
  private
    m_figure: SphereT;

    m_player: PlayerT;

    m_skeleton: Group3D;
    m_whole: Group3D;

  public
    constructor Create(pos: Point3D; player: PlayerT; visible: boolean);
    begin
      m_player := player;
      m_figure := Sphere(pos.x, pos.y, pos.z, BASE_RADIUS);
      m_figure.Visible := visible;

	    var brightBallMaterial := ImageMaterial('res/tree_texture.jpg')
	      + Materials.Specular(150,100) + Materials.Emissive(GrayColor(0));
	    var darkBallMaterial := ImageMaterial('res/tree_texture_dark.jpg')
	      + Materials.Specular(150,100) + Materials.Emissive(GrayColor(0));

	    if m_player = PlayerT.BrightPlayer then begin
	    	m_figure.Material := brightBallMaterial;
    	end
	    else
	    	m_figure.Material := darkBallMaterial;
    end;
    
    property Visible: boolean read m_figure.Visible write m_figure.Visible := value;
    property Position: Point3D read m_figure.Position write m_figure.Position := value;
    property Radius: real read m_figure.Radius;
    property Figure: SphereT read m_figure;
    
  end;
    
////////////////////////////////

end.