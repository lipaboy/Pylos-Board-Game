unit Index;

uses GameSettings;

uses Utils;

// Note: Чем выше уровень k, тем меньше слой, т.е. k=0 - основание пирамиды, k=FHei - её верхушка.

type
  IndexT = System.Tuple<Integer, Integer, Integer>;
  
function EmptyIndex() := (-1, -1, -1);

// Проверка на пустой индекс
function IsEmpty(Self: IndexT) : boolean; extensionmethod;
begin
  Result := (Self[0] = -1) and (Self[1] = -1) and (Self[2] = -1) ? true : false;
end;

function Top(ind : IndexT) : IndexT := (ind[0], ind[1], ind[2] + 1);
function Bottom(ind : IndexT) : IndexT := (ind[0], ind[1], ind[2] - 1);
// Note:  Сами по себе функции UpLeft(ind) - бесполезны, так как относительно корректного
//        индекса ind они вернут некорретный результирующий индекс. Эти функции имеет смысле использовать
//        в связке с функциями Top(ind) и Bottom(ind).
function UpLeft(ind : IndexT) : IndexT := (ind[0] - 1, ind[1] - 1, ind[2]);
function UpRight(ind : IndexT) : IndexT := (ind[0] - 1, ind[1] + 1, ind[2]);
function DownLeft(ind : IndexT) : IndexT := (ind[0] + 1, ind[1] - 1, ind[2]);
function DownRight(ind : IndexT) : IndexT := (ind[0] + 1, ind[1] + 1, ind[2]);

// Проверка, что индекс валидный: находится в пределах игрового поля
// Note: хотелось бы чтобы случаев с невалидным индексом вообще не встречалось.
function IsValid(ind : IndexT) : boolean;
begin
  var k := ind[2];
  if (k in 0..FHei) and (ind[0] in k..FWid-k) and (ind[1] in k..FWid-k)
    and (ind[0] mod 2 = k mod 2) and (ind[1] mod 2 = k mod 2) then
  begin
    Result := true;
  end
  else begin
    logln('WARNING: IndexT: Not valid index');
    Result := false;
  end;
end;

function ToStr(ind: IndexT) := '(' + ind[0] + ', ' + ind[1] + ', ' + ind[2] + ')';
function ToStr(Self: IndexT) : String; extensionmethod;
begin
  Result := '(' + Self[0] + ', ' + Self[1] + ', ' + Self[2] + ')';
end;

end.