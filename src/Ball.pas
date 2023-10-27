unit Ball;

uses Players;
uses GameSettings;
uses GameLogic;
uses Graph3D;

///////////   Ball (View)   //////////////

// TODO: move into BallType class
const
	BASE_RADIUS = 1.1;

type
  BallType = class
  private
    m_figure: SphereT;
    m_material: GMaterial;

    m_player: PlayerEnumT;
    m_isSelected: boolean;

    m_skeleton: Group3D;
    m_whole: Group3D;

  public
    constructor Create(pos: Point3D; player: PlayerEnumT; visible: boolean);
    
    property Visible: boolean read m_figure.Visible write m_figure.Visible := value;
    property Position: Point3D read m_figure.Position write m_figure.Position := value;
    property Radius: real read m_figure.Radius;
    // property Selected: boolean read m_isSelected write SetSelected;

    procedure SetSelected(isSelected: boolean);
    begin
      if (isSelected <> m_isSelected) then begin
        m_isSelected := isSelected;
        if isSelected then begin
          m_figure.Material := m_material + Materials.Specular(150,100) 
            + Materials.Emissive(GrayColor(50));
        end
        else begin
          m_figure.Material := m_material + Materials.Specular(150,100) 
            + Materials.Emissive(GrayColor(0));
        end;
      end;
    end;
    
    procedure Rotate(asix: Vector3D; angle: real);
    begin
    	m_figure.Rotate(asix, angle);
    end;
    
  end;


  constructor BallType.Create(pos: Point3D; player: PlayerEnumT; visible: boolean);
  begin
    m_player := player;
    m_figure := Sphere(pos.x, pos.y, pos.z, BASE_RADIUS);
    m_figure.Visible := visible;

    if m_player = PlayerEnumT.BrightPlayer then begin
      m_material := 
        // DiffuseMaterial(Colors.Yellow);
        ImageMaterial('res/tree_texture.jpg');
      m_figure.Material := m_material + Materials.Specular(150,100) 
        + Materials.Emissive(GrayColor(0));
    end
    else begin
      m_material := 
        // DiffuseMaterial(Colors.Green);
        ImageMaterial('res/tree_texture_dark.jpg');
      m_figure.Material := m_material + Materials.Specular(150,100) 
        + Materials.Emissive(GrayColor(0));
    end;
  end;
  
////////////////////////////////

end.