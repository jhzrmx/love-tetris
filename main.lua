local board = require("board")
local config = require("config")
local pieces = require("pieces")
local ui = require("ui")

local bag = {}
local grid = {}
local current
local nextKind
local score = 0
local lines = 0
local level = 1
local dropTimer = 0
local dropDelay = config.drop.initialDelay
local gameOver = false

local function spawn()
  if #bag == 0 then
    bag = pieces.newBag()
  end

  if not nextKind then
    nextKind = table.remove(bag)
  end

  local kind = nextKind

  if #bag == 0 then
    bag = pieces.newBag()
  end

  nextKind = table.remove(bag)
  current = pieces.newPiece(kind)

  if board.collides(grid, current.x, current.y, current.shape) then
    gameOver = true
  end
end

local function clearLines()
  local cleared = board.clearLines(grid)

  if cleared > 0 then
    lines = lines + cleared
    score = score + config.scoring.lineClears[cleared] * level
    level = 1 + math.floor(lines / 10)
    dropDelay = math.max(config.drop.minDelay, config.drop.initialDelay - (level - 1) * config.drop.levelStep)
  end
end

local function lockAndSpawn()
  board.lockPiece(grid, current)
  clearLines()
  spawn()
end

local function hardDrop()
  while not board.collides(grid, current.x, current.y + 1, current.shape) do
    current.y = current.y + 1
    score = score + config.scoring.hardDrop
  end

  lockAndSpawn()
end

local function resetGame()
  bag = pieces.newBag()
  grid = board.new()
  current = nil
  nextKind = nil
  score = 0
  lines = 0
  level = 1
  dropTimer = 0
  dropDelay = config.drop.initialDelay
  gameOver = false
  spawn()
end

function love.load()
  love.window.setTitle(config.window.title)
  love.window.setMode(config.window.width, config.window.height, {resizable = false})
  love.graphics.setBackgroundColor(config.colors.background)
  resetGame()
end

function love.update(dt)
  if gameOver then
    return
  end

  dropTimer = dropTimer + dt

  if dropTimer >= dropDelay then
    dropTimer = 0

    if not board.collides(grid, current.x, current.y + 1, current.shape) then
      current.y = current.y + 1
    else
      lockAndSpawn()
    end
  end
end

function love.keypressed(key)
  if gameOver and key == "r" then
    resetGame()
    return
  end

  if gameOver then
    return
  end

  if (key == "left" or key == "a") and not board.collides(grid, current.x - 1, current.y, current.shape) then
    current.x = current.x - 1
  elseif (key == "right" or key == "d") and not board.collides(grid, current.x + 1, current.y, current.shape) then
    current.x = current.x + 1
  elseif (key == "down" or key == "s") and not board.collides(grid, current.x, current.y + 1, current.shape) then
    current.y = current.y + 1
    score = score + config.scoring.softDrop
  elseif key == "up" or key == "w" then
    local rotated = pieces.rotate(current.shape)

    if not board.collides(grid, current.x, current.y, rotated) then
      current.shape = rotated
    end
  elseif key == "space" then
    hardDrop()
  end
end

function love.draw()
  ui.drawBoard(grid)

  if current then
    ui.drawPiece(current)
  end

  ui.drawSidebar(score, lines, level, nextKind)

  if gameOver then
    ui.drawGameOver()
  end
end
