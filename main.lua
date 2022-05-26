local android = require 'android'
local Dialog = require 'game_15.dialog'
local game = require 'game_15.15lib'

local floor, fmod = math.floor, math.fmod
local slen = string.len
local LPK = luajava.package
local G = LPK 'android.graphics'
local V = LPK 'android.view'

local paint = G.Paint()
-- note how nested classes are accessed...
local FILL = G.Paint_Style.FILL
local CENTER = G.Paint_Align.CENTER

local BLACK = G.Color.BLACK
local WHITE = 0xffffffff - 4294967296 -- = -1
local MAGENTA = G.Color.MAGENTA
local YELLOW = G.Color.YELLOW

local rows, cols
cols = 4
rows = cols

-- initialize board game
local MyBoard, createBoard
function createBoard(cols, rows)
  local tab = {
    cols = cols,
    rows = rows,
    empty = rows * cols
  }
  for a = 1, tab.empty do
    tab[a] = a
  end
  return tab
end

MyBoard = createBoard(cols, rows)

local size
local left, right, up, down
local showGame
local MyView

local drawTable
function drawTable(c, board)
  paint:setStyle(FILL)
  paint:setColor(WHITE)
  c:drawPaint(paint)
  paint:setAntiAlias(true)
  paint:setTextAlign(CENTER)

  local cols, rows = board.cols, board.rows
  local sizeCell = size/cols
  for k, v in ipairs(board) do
    local row, col -- values start with 0
    row = floor((k-1) / cols)
    col = fmod(k - 1, rows)
    local x, y = row * sizeCell, col * sizeCell
    -- draw backgroud
    if fmod(v, 2) == 0 then
      paint:setColor(MAGENTA)
    else
      paint:setColor(YELLOW)
    end
    if k == board.empty then
      paint:setColor(WHITE)
    end
    c:drawRect(y+2, x+2, y+sizeCell-4, x+sizeCell-4, paint)

    -- draw number
    paint:setColor(BLACK)
    local txt = v == #board and ' ' or tostring(v)
    local tsize = sizeCell * 1/2
    paint:setTextSize(tsize)
    local ss = (sizeCell - tsize)
    c:drawText(txt, y + sizeCell/2, x + sizeCell - ss/2, paint)
  end
end

local MAIN = android.new()
local MainApp

function MAIN.create(me, arg)
  MainApp = me
  local width, height
  width = me.a:getResources():getDisplayMetrics().widthPixels
  height = me.a:getResources():getDisplayMetrics().heightPixels
  if width < height then size = width else size = height end

  local MeasureSpec = V.View_MeasureSpec
  local T
  T= {
    onMeasure = function(wspec,hspec)
      MyView:measuredDimension(size, size)
      return true
    end;
    onDraw = function (c)
      return drawTable(c, MyBoard)
    end;
    touch = function(kind,idx,x,y,dir,movement)
      if kind == 'SWIPE' then
        if dir == 'X' then if (movement < 0) then return right(MyBoard) else return left(MyBoard) end end
        if dir == 'Y' then if (movement < 0) then return down(MyBoard) else return up(MyBoard) end end
      end
    end;
  }
  T.onTouchEvent = require 'android.touch'(T);
  MyView = me:luaView(T)

  game.init(MyBoard)
  showGame(MyBoard)

  local emptyText = me:textView('')
  if width > height then
    emptyText:setWidth(width - size)
  end

  local status = me:vbox{
    emptyText,
    '+',
    me:hbox{
      me:button('Mix Up', function ()
                  game.shuffle(MyBoard)
                  showGame(MyBoard)
      end),
      '+',
      me:button('S', function ()
                  -- initialize a game
                  game.init(MyBoard)
                  showGame(MyBoard)
                  me:luaActivity('game_15.dialog')
      end),
    },
  }

  local allView
  if width < height then
    allView = me:vbox{MyView, '...', status}
  else
    allView = me:hbox{MyView, status}
  end
  return allView
end

function showGame(board)
  MyView:invalidate()
end

function left(board)
  game.left(board)
  showGame(board)
end

function right(board)
  game.right(board)
  showGame(board)
end

function up(board)
  game.up(board)
  showGame(board)
end

function down(board)
  game.down(board)
  showGame(board)
end

function MAIN.onResume()
  -- get saved game instance
  local preference = MainApp.a:getSharedPreferences('abc,eoikc.dldl.game_15', 0)
  local gs = preference:getString('GameState', '')
  if gs ~= '' then
    MyBoard = loadstring(gs)()
  end
  -- make new board size
  if Dialog.RESULT then
    local num = tonumber(Dialog.RESULT)
    MyBoard = createBoard(num, num)
    Dialog.RESULT = nil
  end
  showGame(MyBoard)
end

function MAIN.onPause()
  -- save game instance
  local gamestate = 'return {'
  local size = MyBoard.cols * MyBoard.rows
  for a = 1, size do
    gamestate = gamestate .. tostring(MyBoard[a]) .. ','
  end
  gamestate = gamestate .. 'cols=' .. tostring(MyBoard.cols) .. ','
  gamestate = gamestate .. 'rows=' .. tostring(MyBoard.rows) .. ','
  gamestate = gamestate .. 'empty=' .. tostring(MyBoard.empty) .. '}'
  local preference = MainApp.a:getSharedPreferences('abc,eoikc.dldl.game_15', 0)
  local ed = preference:edit()
  ed:putString('GameState', gamestate)
  ed:commit()
end

return MAIN
