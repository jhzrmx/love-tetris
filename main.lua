-- Modern Tetris for LÖVE (Love2D)
-- Save as main.lua and run with Love2D

local cell = 30
local cols, rows = 10, 20
local board = {}
local score, lines, level = 0, 0, 1
local dropTimer, dropDelay = 0, 0.8
local gameOver = false

local colors = {
  I={0,1,1}, O={1,1,0}, T={0.7,0,1}, S={0,1,0}, Z={1,0,0}, J={0,0.4,1}, L={1,0.5,0}
}

local shapes = {
 I={{{1,1,1,1}}},
 O={{{1,1},{1,1}}},
 T={{{0,1,0},{1,1,1}}},
 S={{{0,1,1},{1,1,0}}},
 Z={{{1,1,0},{0,1,1}}},
 J={{{1,0,0},{1,1,1}}},
 L={{{0,0,1},{1,1,1}}}
}

local bag = {}
local current
local nextKind

local function rotate(m)
  local h,w=#m,#m[1]
  local r={}
  for x=1,w do r[x]={} for y=h,1,-1 do table.insert(r[x],m[y][x]) end end
  return r
end

local function initBoard()
  for y=1,rows do board[y]={} for x=1,cols do board[y][x]=nil end end
end

local function refillBag()
  bag={"I","O","T","S","Z","J","L"}
  for i=#bag,2,-1 do local j=love.math.random(i) bag[i],bag[j]=bag[j],bag[i] end
end

local function spawn()
  if #bag==0 then refillBag() end
  if not nextKind then nextKind = table.remove(bag) end
  local kind = nextKind
  if #bag==0 then refillBag() end
  nextKind = table.remove(bag)
  current={kind=kind,shape=shapes[kind][1],x=4,y=1}
  if collide(current.x,current.y,current.shape) then gameOver=true end
end

function collide(px,py,shape)
  for y=1,#shape do for x=1,#shape[y] do
    if shape[y][x]==1 then
      local bx,by=px+x-1,py+y-1
      if bx<1 or bx>cols or by>rows then return true end
      if by>=1 and board[by][bx] then return true end
    end
  end end
  return false
end

local function lockPiece()
  for y=1,#current.shape do for x=1,#current.shape[y] do
    if current.shape[y][x]==1 then
      local bx,by=current.x+x-1,current.y+y-1
      if by>=1 then board[by][bx]=current.kind end
    end
  end end
end

local function clearLines()
  local cleared=0
  for y=rows,1,-1 do
    local full=true
    for x=1,cols do if not board[y][x] then full=false break end end
    if full then
      table.remove(board,y)
      local newRow={} for x=1,cols do newRow[x]=nil end
      table.insert(board,1,newRow)
      cleared=cleared+1
      y=y+1
    end
  end
  if cleared>0 then
    lines=lines+cleared
    score=score + ({100,300,500,800})[cleared]*level
    level=1+math.floor(lines/10)
    dropDelay=math.max(0.08,0.8-(level-1)*0.06)
  end
end

local function hardDrop()
  while not collide(current.x,current.y+1,current.shape) do current.y=current.y+1 score=score+2 end
  lockPiece(); clearLines(); spawn()
end

function love.load()
  love.window.setTitle('Tetris')
  love.window.setMode(520,680,{resizable=false})
  love.graphics.setBackgroundColor(0.08,0.09,0.12)
  initBoard(); refillBag(); spawn()
end

function love.update(dt)
  if gameOver then return end
  dropTimer=dropTimer+dt
  if dropTimer>=dropDelay then
    dropTimer=0
    if not collide(current.x,current.y+1,current.shape) then current.y=current.y+1 else lockPiece(); clearLines(); spawn() end
  end
end

function love.keypressed(key)
  if gameOver and key=='r' then score,lines,level=0,0,1;dropDelay=0.8;gameOver=false;nextKind=nil;initBoard();refillBag();spawn();return end
  if gameOver then return end
  if key=='left' and not collide(current.x-1,current.y,current.shape) then current.x=current.x-1 end
  if key=='right' and not collide(current.x+1,current.y,current.shape) then current.x=current.x+1 end
  if key=='down' and not collide(current.x,current.y+1,current.shape) then current.y=current.y+1;score=score+1 end
  if key=='up' then local r=rotate(current.shape) if not collide(current.x,current.y,r) then current.shape=r end end
  if key=='space' then hardDrop() end
end

local function drawCell(x,y,c)
  love.graphics.setColor(c)
  love.graphics.rectangle('fill',x,y,cell-2,cell-2,6,6)
  love.graphics.setColor(1,1,1,0.08)
  love.graphics.rectangle('line',x,y,cell-2,cell-2,6,6)
end

function love.draw()
  love.graphics.setColor(0.12,0.13,0.17)
  love.graphics.rectangle('fill',20,20,cols*cell+8,rows*cell+8,18,18)
  for y=1,rows do for x=1,cols do
    local px,py=24+(x-1)*cell,24+(y-1)*cell
    if board[y][x] then drawCell(px,py,colors[board[y][x]]) else love.graphics.setColor(1,1,1,0.03); love.graphics.rectangle('line',px,py,cell-2,cell-2,4,4) end
  end end

  for y=1,#current.shape do for x=1,#current.shape[y] do
    if current.shape[y][x]==1 then
      drawCell(24+(current.x+x-2)*cell,24+(current.y+y-2)*cell,colors[current.kind])
    end
  end end

  love.graphics.setColor(1,1,1)
  love.graphics.print('Score: '..score,360,60)
  love.graphics.print('Lines: '..lines,360,90)
  love.graphics.print('Level: '..level,360,120)
  love.graphics.print('← → Move',360,200)
  love.graphics.print('↑ Rotate',360,230)
  love.graphics.print('↓ Soft Drop',360,260)
  love.graphics.print('Space Hard Drop',360,290)
  love.graphics.print('Next:',360,360)

  if nextKind then
    local preview = shapes[nextKind][1]
    for py=1,#preview do for px=1,#preview[py] do
      if preview[py][px]==1 then
        drawCell(360 + (px-1)*24,390 + (py-1)*24,colors[nextKind])
      end
    end end
  end

  if gameOver then
    love.graphics.setColor(0,0,0,0.6)
    love.graphics.rectangle('fill',40,260,280,120,16,16)
    love.graphics.setColor(1,1,1)
    love.graphics.printf('GAME OVER\nPress R to Restart',40,300,280,'center')
  end
end
