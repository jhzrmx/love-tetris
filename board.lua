local config = require("config")

local board = {}

local function newRow()
  local row = {}

  for x = 1, config.cols do
    row[x] = nil
  end

  return row
end

function board.new()
  local grid = {}

  for y = 1, config.rows do
    grid[y] = newRow()
  end

  return grid
end

function board.collides(grid, px, py, shape)
  for y = 1, #shape do
    for x = 1, #shape[y] do
      if shape[y][x] == 1 then
        local bx = px + x - 1
        local by = py + y - 1

        if bx < 1 or bx > config.cols or by > config.rows then
          return true
        end

        if by >= 1 and grid[by][bx] then
          return true
        end
      end
    end
  end

  return false
end

function board.lockPiece(grid, piece)
  for y = 1, #piece.shape do
    for x = 1, #piece.shape[y] do
      if piece.shape[y][x] == 1 then
        local bx = piece.x + x - 1
        local by = piece.y + y - 1

        if by >= 1 then
          grid[by][bx] = piece.kind
        end
      end
    end
  end
end

function board.clearLines(grid)
  local cleared = 0
  local y = config.rows

  while y >= 1 do
    local full = true

    for x = 1, config.cols do
      if not grid[y][x] then
        full = false
        break
      end
    end

    if full then
      table.remove(grid, y)
      table.insert(grid, 1, newRow())
      cleared = cleared + 1
    else
      y = y - 1
    end
  end

  return cleared
end

return board
