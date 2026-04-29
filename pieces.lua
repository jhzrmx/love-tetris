local pieces = {}

pieces.shapes = {
  I = {{{1, 1, 1, 1}}},
  O = {{{1, 1}, {1, 1}}},
  T = {{{0, 1, 0}, {1, 1, 1}}},
  S = {{{0, 1, 1}, {1, 1, 0}}},
  Z = {{{1, 1, 0}, {0, 1, 1}}},
  J = {{{1, 0, 0}, {1, 1, 1}}},
  L = {{{0, 0, 1}, {1, 1, 1}}}
}

local kinds = {"I", "O", "T", "S", "Z", "J", "L"}

function pieces.rotate(shape)
  local height = #shape
  local width = #shape[1]
  local rotated = {}

  for x = 1, width do
    rotated[x] = {}

    for y = height, 1, -1 do
      table.insert(rotated[x], shape[y][x])
    end
  end

  return rotated
end

function pieces.newBag()
  local bag = {}

  for i, kind in ipairs(kinds) do
    bag[i] = kind
  end

  for i = #bag, 2, -1 do
    local j = love.math.random(i)
    bag[i], bag[j] = bag[j], bag[i]
  end

  return bag
end

function pieces.newPiece(kind)
  return {
    kind = kind,
    shape = pieces.shapes[kind][1],
    x = 4,
    y = 1
  }
end

return pieces
