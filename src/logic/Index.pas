unit Index;

uses GameSettings;

// Note: Чем выше уровень k, тем меньше слой, т.е. k=0 - основание пирамиды, k=FHei - её верхушка.

type
  IndexT = System.Tuple<Integer, Integer, Integer>;
  
function EmptyIndex() := (-1, -1, -1);

function IsEmptyIndex(ind: IndexT) := (ind[0] = -1) and (ind[1] = -1) and (ind[2] = -1) ? true : false;

function Top(ind : IndexT) : IndexT := (ind[0], ind[1], ind[2] + 1);
function Bottom(ind : IndexT) : IndexT := (ind[0], ind[1], ind[2] - 1);
// Note:  Сами по себе функции UpLeft(ind) - бесполезны, так как относительно корректного
//        индекса ind они вернут некорретный результирующий индекс. Эти функции имеет смысле использовать
//        в связке с функциями Top(ind) и Bottom(ind).
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