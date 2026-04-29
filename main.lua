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
local paused = false
local clearingLines = {}
local clearTimer = 0
local repeatState = {
  left = {timer = 0, repeating = false},
  right = {timer = 0, repeating = false},
  down = {timer = 0, repeating = false},
  rotate = {timer = 0, repeating = false}
}

local inputKeys = {
  left = {"left", "a"},
  right = {"right", "d"},
  down = {"down", "s"},
  rotate = {"up", "w"}
}

local function isActionDown(action)
  for _, key in ipairs(inputKeys[action]) do
    if love.keyboard.isDown(key) then
      return true
    end
  end

  return false
end

local function resetRepeat(action)
  repeatState[action].timer = 0
  repeatState[action].repeating = false
end

local function resetRepeats()
  for action in pairs(repeatState) do
    resetRepeat(action)
  end
end

local function moveLeft()
  if not board.collides(grid, current.x - 1, current.y, current.shape) then
    current.x = current.x - 1
  end
end

local function moveRight()
  if not board.collides(grid, current.x + 1, current.y, current.shape) then
    current.x = current.x + 1
  end
end

local function softDrop()
  if not board.collides(grid, current.x, current.y + 1, current.shape) then
    current.y = current.y + 1
    score = score + config.scoring.softDrop
  end
end

local function rotatePiece()
  local rotated = pieces.rotate(current.shape)

  if not board.collides(grid, current.x, current.y, rotated) then
    current.shape = rotated
  end
end

local function updateRepeat(action, dt, callback, interval)
  local state = repeatState[action]

  if not isActionDown(action) then
    resetRepeat(action)
    return
  end

  state.timer = state.timer + dt

  local delay = state.repeating and interval or config.input.repeatDelay

  if state.timer >= delay then
    callback()
    state.timer = 0
    state.repeating = true
  end
end

local function isClearingLines()
  return #clearingLines > 0
end

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

local function applyClearedLines()
  local cleared = #clearingLines

  board.removeLines(grid, clearingLines)
  clearingLines = {}
  clearTimer = 0

  if cleared > 0 then
    lines = lines + cleared
    score = score + config.scoring.lineClears[cleared] * level
    level = 1 + math.floor(lines / 10)
    dropDelay = math.max(config.drop.minDelay, config.drop.initialDelay - (level - 1) * config.drop.levelStep)
  end

  spawn()
end

local function startLineClear()
  clearingLines = board.findFullLines(grid)
  clearTimer = 0

  if isClearingLines() then
    current = nil
    resetRepeats()
  else
    spawn()
  end
end

local function lockAndSpawn()
  board.lockPiece(grid, current)
  startLineClear()
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
  paused = false
  clearingLines = {}
  clearTimer = 0
  resetRepeats()
  spawn()
end

function love.load()
  love.window.setTitle(config.window.title)
  love.window.setMode(config.window.width, config.window.height, {resizable = false})
  love.graphics.setBackgroundColor(config.colors.background)
  resetGame()
end

function love.update(dt)
  if gameOver or paused then
    resetRepeats()
    return
  end

  if isClearingLines() then
    clearTimer = clearTimer + dt

    if clearTimer >= config.animation.lineClearDuration then
      applyClearedLines()
    end

    return
  end

  updateRepeat("left", dt, moveLeft, config.input.moveRepeatInterval)
  updateRepeat("right", dt, moveRight, config.input.moveRepeatInterval)
  updateRepeat("down", dt, softDrop, config.input.softDropRepeatInterval)
  updateRepeat("rotate", dt, rotatePiece, config.input.rotateRepeatInterval)

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
  if key == "r" then
    resetGame()
    return
  end

  if key == "p" and not gameOver then
    paused = not paused
    resetRepeats()
    return
  end

  if paused then
    return
  end

  if isClearingLines() then
    return
  end

  if gameOver then
    return
  end

  if key == "left" or key == "a" then
    moveLeft()
    resetRepeat("left")
  elseif key == "right" or key == "d" then
    moveRight()
    resetRepeat("right")
  elseif key == "down" or key == "s" then
    softDrop()
    resetRepeat("down")
  elseif key == "up" or key == "w" then
    rotatePiece()
    resetRepeat("rotate")
  elseif key == "space" then
    hardDrop()
  end
end

function love.draw()
  ui.drawBoard(grid)

  if current then
    ui.drawPiece(current)
  end

  if isClearingLines() then
    ui.drawLineClearAnimation(clearingLines, clearTimer, config.animation.lineClearDuration)
  end

  ui.drawSidebar(score, lines, level, nextKind)

  if gameOver then
    ui.drawGameOver()
  elseif paused then
    ui.drawPaused()
  end
end
