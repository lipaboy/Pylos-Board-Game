unit Ball;

uses Players;
uses GameSettings;
uses GameLogic;
uses Graph3D;

uses Timers;

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
    m_isHovered: boolean;
    m_isSelected: boolean;
    m_isRed: boolean;

    m_skeleton: Group3D;
    m_whole: Group3D;

    rotTimer : Timer;
    m_baseVecRotation: Vector3D;

  public
    constructor Create(pos: Point3D; player: PlayerEnumT; visible: boolean);
    
    property Visible: boolean read m_figure.Visible write m_figure.Visible := value;
    property Position: Point3D read m_figure.Position write m_figure.Position := value;
    property Radius: real read m_figure.Radius;
    // property Selected: boolean read m_isHovered write SetSelected;

    procedure SetRed(isRed: boolean);
    begin
      if (isRed <> m_isRed) then begin
        m_isRed := isRed;
        if isRed then begin
          m_figure.Material := m_material + Materials.Specular(150,100) 
            + Materials.Emissive(ARGB(100, 255, 0, 0));
        end
        else begin
          m_figure.Material := m_material + Materials.Specular(150,100);
        end;
      end;
    end;

    procedure SetHovered(isHovered: boolean);
    begin
      if (isHovered <> m_isHovered) then begin
        m_isHovered := isHovered;
        if isHovered then begin
          m_figure.Material := m_material + Materials.Specular(150,100) 
            + Materials.Emissive(GrayColor(30));
        end
        else begin
          m_figure.Material := m_material + Materials.Specular(150,100) 
            + Materials.Emissive(GrayColor(0));
        end;
      end;
    end;

    procedure SetSelected(isSelected: boolean);
    begin
      SetHovered(false);
      if (isSelected <> m_isSelected) then begin
        m_isSelected := isSelected;
        // todo: можно добавить кручение вокруг оси
        // или кручение при hovered а при выделение подсветку светлую
        if isSelected then begin
          m_figure.Material := m_material + Materials.Specular(150,100) 
            + Materials.Emissive(GrayColor(0));
          rotTimer.Start();
        end
        else begin
          m_figure.Material := m_material + Materials.Specular(150,100) 
            + Materials.Emissive(GrayColor(0));
          rotTimer.Stop();
        end;
      end;
    end;
    
    procedure Rotate(asix: Vector3D; angle: real);
    begin
    	m_figure.Rotate(asix, angle);
    end;
    
  end;

  // _________________ Реализация методов ________________ //

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

    m_baseVecRotation := V3D(1, 0, 0);
    rotTimer := new Timer(30, procedure() -> begin
      Rotate(m_baseVecRotation, 1);
      var f1 : function (): real := () -> power(random(-1.0, 1.0), 2.0);
      m_baseVecRotation := Vector3D.Add( m_baseVecRotation, Vector3D.Create(f1(), f1(), f1()) );
    end);
  end;
  
////////////////////////////////

end.