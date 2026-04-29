local config = require("config")
local pieces = require("pieces")

local ui = {}

local function setColor(color)
  love.graphics.setColor(color)
end

function ui.drawCell(x, y, color, size)
  size = size or config.cell

  setColor(color)
  love.graphics.rectangle("fill", x, y, size - 2, size - 2, 6, 6)
  setColor(config.colors.cellBorder)
  love.graphics.rectangle("line", x, y, size - 2, size - 2, 6, 6)
end

function ui.drawBoard(grid)
  setColor(config.colors.boardFrame)
  love.graphics.rectangle(
    "fill",
    config.board.frameX,
    config.board.frameY,
    config.cols * config.cell + config.board.padding,
    config.rows * config.cell + config.board.padding,
    18,
    18
  )

  for y = 1, config.rows do
    for x = 1, config.cols do
      local px = config.board.x + (x - 1) * config.cell
      local py = config.board.y + (y - 1) * config.cell
      local kind = grid[y][x]

      if kind then
        ui.drawCell(px, py, config.colors.pieces[kind])
      else
        setColor(config.colors.gridLine)
        love.graphics.rectangle("line", px, py, config.cell - 2, config.cell - 2, 4, 4)
      end
    end
  end
end

function ui.drawPiece(piece)
  for y = 1, #piece.shape do
    for x = 1, #piece.shape[y] do
      if piece.shape[y][x] == 1 then
        ui.drawCell(
          config.board.x + (piece.x + x - 2) * config.cell,
          config.board.y + (piece.y + y - 2) * config.cell,
          config.colors.pieces[piece.kind]
        )
      end
    end
  end
end

function ui.drawSidebar(score, lines, level, nextKind)
  setColor(config.colors.text)
  love.graphics.print("Score: " .. score, 360, 60)
  love.graphics.print("Lines: " .. lines, 360, 90)
  love.graphics.print("Level: " .. level, 360, 120)
  love.graphics.print("< > Move", 360, 200)
  love.graphics.print("^ Rotate", 360, 230)
  love.graphics.print("v Soft Drop", 360, 260)
  love.graphics.print("Space Hard Drop", 360, 290)
  love.graphics.print("Next:", 360, 360)

  if nextKind then
    local preview = pieces.shapes[nextKind][1]

    for y = 1, #preview do
      for x = 1, #preview[y] do
        if preview[y][x] == 1 then
          ui.drawCell(360 + (x - 1) * 24, 390 + (y - 1) * 24, config.colors.pieces[nextKind], 24)
        end
      end
    end
  end
end

function ui.drawGameOver()
  setColor(config.colors.overlay)
  love.graphics.rectangle("fill", 40, 260, 280, 120, 16, 16)
  setColor(config.colors.text)
  love.graphics.printf("GAME OVER\nPress R to Restart", 40, 300, 280, "center")
end

return ui
