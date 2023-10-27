unit Players;

uses GameSettings;

type
  PlayerEnumT = (BrightPlayer, DarkPlayer);

type
	PlayerT = class
	private
		m_playerEn: PlayerEnumT;
		m_ballRemains: Integer;
	public
		constructor Create(playerEn : PlayerEnumT);
		begin
			m_playerEn := playerEn;
			m_ballRemains := PLAYER_BALL_COUNT;
		end;

		property Who: PlayerEnumT read m_playerEn;
		property Name: string read m_playerEn = BrightPlayer ? 'Светлый' : 'Тёмный';
		property BallsRemain: Integer read m_ballRemains write m_ballRemains := value;
	end;

function GetCellByPlayer(player: PlayerEnumT) := player = BrightPlayer ? CellT.Bright : CellT.Dark;
function GetPlayerByCell(cell: CellT) := cell = Bright ? BrightPlayer : DarkPlayer;
function NextPlayer(player: PlayerEnumT) := player = BrightPlayer ? DarkPlayer : BrightPlayer;

end.