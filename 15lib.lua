local random = math.random

local
function move_left(board)
  local empty = board.empty
  for x = board.cols , board.cols*board.rows , board.cols do
    if empty == x then return false end
  end
  board[empty + 1], board[empty] = board[empty], board[empty + 1]
  board.empty = empty + 1
  return true
end

local
function move_right(board)
  local empty = board.empty
  for x = 1 , board.cols*board.rows , board.cols do
    if empty == x then return false end
  end
  board[empty - 1], board[empty] = board[empty], board[empty - 1]
  board.empty = empty - 1
  return true
end

local
function move_up(board)
  local empty = board.empty
  for x = board.cols*board.rows , board.cols*board.rows - board.cols + 1 , -1 do
    if empty == x then return false end
  end
  board[empty + board.cols], board[empty] = board[empty], board[empty + board.cols]
  board.empty = empty + board.cols
  return true
end

local
function move_down(board)
  local empty = board.empty
  for x = 1 , board.cols do
    if empty == x then return false end
  end
  board[empty - board.cols], board[empty] = board[empty], board[empty - board.cols]
  board.empty = empty - board.cols
  return true
end

local
function init_board(board)
  for a=1,board.cols*board.rows do
    board[a] = a
  end
  board.empty = board.cols*board.rows
  return board
end

-- The invariant is the parity of the permutation of all 16 squares
-- plus the parity of the taxicab distance (number of rows plus number
-- of columns) of the empty square from the lower right corner

-- check if board has even or odd parity
local isEven
function isEven(board)
  -- make local copy of board
  local tmp = {}
  for a=1,board.cols*board.rows do
    tmp[a] = board[a]
  end
  tmp.empty = board.empty

  -- calculate the parity of this permutation
  local sum = 0
  for a = 1, board.cols*board.rows-1 do
    for b = a + 1, board.cols*board.rows do
      if tmp[a] > tmp[b] then
        tmp[a], tmp[b] = tmp[b], tmp[a]
        sum = sum + 1
      end
    end
  end
  -- x, y coordinates of empty space
  -- coordinates are in range [0..3]
  local x = math.fmod((board.cols*board.rows - board.empty), board.cols)
  local y = math.floor((board.cols*board.rows - board.empty) / board.cols)
  sum = sum + x + y
  return (math.fmod(sum, 2)==0) and true or false
end

local initialized = false
local shuffle
function shuffle(board)
  if not initialized then
    math.randomseed(os.time())
    initialized = true
  end

  init_board(board)

  -- make the random shuffle
  repeat
    for a = #board, 2, -1 do
      local idx = random(a)
      board[a], board[idx] = board[idx], board[a]
    end
    -- find where empty space is (number board.cols*board.rows)
    for a = 1, board.cols*board.rows do
      if board[a] == board.cols*board.rows then
        board.empty = a
        break
      end
    end
  until isEven(board)
end

return {
  left = move_left,
  down = move_down,
  right = move_right,
  up = move_up,
  init = init_board,
  shuffle = shuffle,
}
