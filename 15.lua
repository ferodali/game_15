local game = require '15lib'

local read, write = io.read, io.write
local len, format, rep = string.len, string.format, string.rep
local floor = math.floor
local tostring = tostring

local rows, cols
cols = arg and tonumber(arg[1]) or 4
rows = arg and tonumber(arg[2]) or cols

-- initialize board game
local MyBoard = {
  cols = cols,
  rows = rows,
  empty = rows * cols
}
for a = 1, MyBoard.empty do
  MyBoard[a] = a
end

local
function print_board(board)
  write '\r\n'
  for i = 0, board.rows - 1 do
    write '\r\n'
    for j = 1, board.cols do
      local idx = i*board.cols+j
      local value = board[idx]
      if idx == board.empty then
        write('   .   ')
      else
        local str = tostring(value)
        local len = len (str)
        local space =  floor((7-len)/2)
        local before = rep(' ', space)
        local after = rep(' ', 7-len-space)
        write(format('%s%s%s', before, str, after))
      end
    end
    write '\r\n'
    write '\r\n'
  end
  write '\r\n'
  write('    ←,↑,→,↓ or q, r, z\r\n')
end

local
function get_arrow_key(key)
  if key == 'a'
    or key == 's'
    or key == 'd'
    or key == 'w'
    or key == 'r'
    or key == 'q'
    or key == 'z'
  then
    return key
  end
  local k = key:byte()
  if k == 27 then
    local group = read(1):byte()
    if group == 91 then
      local direction = read(1):byte()
      local UP, DOWN, RIGHT, LEFT = 65, 66, 67, 68
      if direction == UP then return 'w' end
      if direction == DOWN then return 's' end
      if direction == RIGHT then return 'd' end
      if direction == LEFT then return 'a' end
    end
  end
  return 'nothing'
end

os.execute("stty raw -echo") -- on startup
os.execute'clear'

game.init(MyBoard)
print_board(MyBoard)

local k, kk
local success
while true do
  success = false
  kk = read(1)
  k = get_arrow_key(kk)
  if k == 'a' then
    success = game.left(MyBoard)
  elseif k == 's'then
    success = game.down(MyBoard)
  elseif k == 'd'then
    success = game.right(MyBoard)
  elseif k == 'w'then
    success = game.up(MyBoard)
  elseif k == 'r'then
    game.init(MyBoard)
  elseif k == 'q'then
    break
  elseif k == 'z'then
    game.shuffle(MyBoard)
  else
  end

  os.execute'clear'
  print_board(MyBoard)
end

os.execute("stty sane") -- restore terminal befor exit
print'Good Bay'
