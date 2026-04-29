local config = {}

config.cell = 30
config.cols = 10
config.rows = 20

config.window = {
  width = 520,
  height = 680,
  title = "Tetris"
}

config.board = {
  x = 24,
  y = 24,
  frameX = 20,
  frameY = 20,
  padding = 8
}

config.drop = {
  initialDelay = 0.8,
  minDelay = 0.08,
  levelStep = 0.06
}

config.input = {
  repeatDelay = 0.16,
  moveRepeatInterval = 0.06,
  softDropRepeatInterval = 0.045,
  rotateRepeatInterval = 0.12
}

config.animation = {
  lineClearDuration = 0.28
}

config.scoring = {
  lineClears = {100, 300, 500, 800},
  softDrop = 1,
  hardDrop = 2
}

config.colors = {
  background = {0.08, 0.09, 0.12},
  boardFrame = {0.12, 0.13, 0.17},
  gridLine = {1, 1, 1, 0.03},
  cellBorder = {1, 1, 1, 0.08},
  text = {1, 1, 1},
  overlay = {0, 0, 0, 0.6},
  pieces = {
    I = {0, 1, 1},
    O = {1, 1, 0},
    T = {0.7, 0, 1},
    S = {0, 1, 0},
    Z = {1, 0, 0},
    J = {0, 0.4, 1},
    L = {1, 0.5, 0}
  }
}

return config
