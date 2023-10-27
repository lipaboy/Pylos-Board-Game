unit GameSettings;

const
  GAME_BASE_WIDTH = 4;
  GAME_BASE_HEIGHT = 4;
  PLAYER_BALL_COUNT = 30 div 2;
  FIELD_WIDTH = 2 * GAME_BASE_WIDTH - 1;
  FIELD_HEIGHT = GAME_BASE_HEIGHT;
  FWid = FIELD_WIDTH - 1;
  FHei = FIELD_HEIGHT - 1;

type
  ISubscriberT = interface
    procedure notify();
  end;

type
  CellT = (Bright, Dark, Empty);

type
  IndexT = System.Tuple<Integer, Integer, Integer>;

function EmptyIndex() := (-1, -1, -1);
function IsEmptyIndex(ind: IndexT) := (ind[0] = -1) and (ind[1] = -1) and (ind[2] = -1) ? true : false;

function Top(ind : IndexT) : IndexT := (ind[0], ind[1], ind[2] + 1);
function Bottom(ind : IndexT) : IndexT := (ind[0], ind[1], ind[2] - 1);
function UpLeft(ind : IndexT) : IndexT := (ind[0] - 1, ind[1] - 1, ind[2]);
function UpRight(ind : IndexT) : IndexT := (ind[0] - 1, ind[1] + 1, ind[2]);
function DownLeft(ind : IndexT) : IndexT := (ind[0] + 1, ind[1] - 1, ind[2]);
function DownRight(ind : IndexT) : IndexT := (ind[0] + 1, ind[1] + 1, ind[2]);
function IsValid(ind : IndexT) : boolean;
begin
  var k := ind[2];
  if (k in 0..FHei) and (ind[0] in k..FWid-k) and (ind[1] in k..FWid-k) then begin
    Result := true;
  end
  else
    Result := false;
end;
function ToStr(ind: IndexT) := '(' + ind[0] + ', ' + ind[1] + ', ' + ind[2] + ')';


end.