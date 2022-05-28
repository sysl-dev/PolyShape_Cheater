--[[Copyright 2022 / SysL - C.Hall

For all non SUIT parts of this software
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Suit:
Copyright (c) 2016 Matthias Richter

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

Except as contained in this notice, the name(s) of the above copyright holders
shall not be used in advertising or otherwise to promote the sale, use or
other dealings in this Software without prior written authorization.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]--

local function simpleunpack(table)
  local a = ""
  for i = 1, #table do 
    a = a .. tostring(table[i]) .. ", "
  end
  return a
end

local function check(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

local triangles = {}

local mode = 0
local count = {}
local printqueue = ""
local numbershow = false
local print2 = print 

function print(...)
  print2(...)
  printqueue = tostring(unpack({...}))
  
end

love.graphics.setDefaultFilter( "nearest", "nearest")

local lockmouse = false
local mirrormodex = false
local mirrormodey = false

-- Load UI Because I'm LAZY
local suit = require 'suit'

local font, font3
function love.load()
     font = love.graphics.newFont(10)
     font3 = love.graphics.newFont(30)
    love.graphics.setFont(font)
end

local function delete_later()
  
end
-- all the UI is defined in love.update or functions that are called from here
function love.update(dt)


	suit.layout:reset(700,10)
  suit.layout:padding(2,2)

  if mode == 0 then 
    if suit.Button("New Triangle", {id=10001}, suit.layout:row(100,10)).hit then
      mode = 1
      count = {}
    end
  end

  if mode == 1 then 
    if suit.Button("New Triangle", {id=10001, color = {normal = {bg = {1,1,0,1}, fg = {0,0,0,1}}}}, suit.layout:row(100,10)).hit then
      mode = 1
      count = {}
    end
  end

	if suit.Button("Mirror Mode X", {id=133111}, suit.layout:row()).hit then
  mirrormodex = not mirrormodex
	end
	if suit.Button("Mirror Mode Y", {id=132111}, suit.layout:row()).hit then
  mirrormodey = not mirrormodey
	end
	if suit.Button("Toggle Numbers", {id=1003111}, suit.layout:row()).hit then
 numbershow = not numbershow
	end

	if suit.Button("Export to clipboard", {id="farts"}, suit.layout:row()).hit then
    local str = ""
    local MAXSIZE = 0
    for i=1, #triangles do 
      for t=1, #triangles[i] do 
        if math.abs(triangles[i][t]) > MAXSIZE then 
          MAXSIZE = math.abs(triangles[i][t])
        end
      end
    end
    for i=1, #triangles do 
      local bit = [[love.physics.newPolygonShape(
        (%d/MAXSIZE) * settings.w/2,   (%d/MAXSIZE) * settings.h/2,
        (%d/MAXSIZE) * settings.w/2,  (%d/MAXSIZE) * settings.h/2,
        (%d/MAXSIZE) * settings.w/2,  (%d/MAXSIZE) * settings.h/2
      ),
      ]]
      bit = string.format(bit, unpack(triangles[i]))
      bit = string.gsub(bit, "MAXSIZE", MAXSIZE)
      str = str .. bit .. " "
      love.system.setClipboardText(str)
      print2(str)
    end
     end
  
	if suit.Button("Wipe", {id=10031}, suit.layout:row()).hit then
    count = {}
    triangles = {}
	end
	if suit.Button("Cancel", {id=100333}, suit.layout:row()).hit then
    mode = 0
    count = {}
	end

  for i=1, #triangles do 
    if suit.Button("Triangle " .. tostring(i), {id=999999 + i}, suit.layout:row()).hit then
      function delete_later()
        table.remove(triangles, i)
        function delete_later()
          
        end
      end
    end
  end

  for y = 0, 20 do 
    for x = 0, 20 do 
      if check(x * 30 - 2, y * 30 - 2, 5, 5, love.mouse.getX(), love.mouse.getY(), 3, 3) then 
        if love.mouse.isDown(1) and not lockmouse then
          print2(x-10, y-10)
          if mode ~= 0 then 
            if #count >= 0 or ((count[#count][1] ~= x-10) and (count[#count][2] ~= y-10)) then
              count[#count+1] = {x-10, y-10}
            else
              print("Points can't be the same - Ignored.")
            end
          end
        end
      end
    end
  end

  if love.mouse.isDown(1) then lockmouse = true else lockmouse = false end
  if love.mouse.isDown(2) then mode = 1 end

  if mode == 1 and #count >= 3 then 
    triangles[#triangles+1] = {}
    triangles[#triangles] = {
      count[1][1], 
      count[1][2], 
      count[2][1], 
      count[2][2], 
      count[3][1], 
      count[3][2], 
    }
    print2(unpack(triangles[#triangles]))

    local remove = false
      if triangles[#triangles][1] == triangles[#triangles][5] and triangles[#triangles][2] == triangles[#triangles][6] then 
        remove = true
      end
      if triangles[#triangles][1] == triangles[#triangles][3] and triangles[#triangles][2] == triangles[#triangles][4] then 
        remove = true
      end
      if triangles[#triangles][3] == triangles[#triangles][5] and triangles[#triangles][4] == triangles[#triangles][6] then 
        remove = true
      end
      if triangles[#triangles][1] == triangles[#triangles][3] and triangles[#triangles][3] == triangles[#triangles][5]  then 
        remove = true
      end
      if triangles[#triangles][2] == triangles[#triangles][4] and triangles[#triangles][4] == triangles[#triangles][6]  then 
        remove = true
      end

      if remove then 
        table.remove(triangles, #triangles)
        print("Impossible Triangle for Box2D - Removing")
      end
    count = {} 
    mode = 0

    if not remove and mirrormodex and not mirrormodey then 
      local derp = {unpack(triangles[#triangles])}
      for dd = 1, #derp, 2 do 
        derp[dd] = derp[dd] * -1
      end
      triangles[#triangles + 1] = {unpack(derp)}
    end

    if not remove and mirrormodey and not mirrormodex then 
      local derp = {unpack(triangles[#triangles])}
      for dd = 2, #derp, 2 do 
        derp[dd] = derp[dd] * -1
      end
      triangles[#triangles + 1] = {unpack(derp)}
    end

    if not remove and mirrormodey and mirrormodex then 
      local derp = {unpack(triangles[#triangles])}
      for dd = 1, #derp, 2 do 
        derp[dd] = derp[dd] * -1
      end
      triangles[#triangles + 1] = {unpack(derp)}
      local derp = {unpack(triangles[#triangles])}
      for dd = 2, #derp, 2 do 
        derp[dd] = derp[dd] * -1
      end
      triangles[#triangles + 1] = {unpack(derp)}
      local derp = {unpack(triangles[#triangles])}
      for dd = 1, #derp, 2 do 
        derp[dd] = derp[dd] * -1
      end
      triangles[#triangles + 1] = {unpack(derp)}
    end


    remove = false
  end 

  delete_later()
  
end


function love.draw()
  for x = 0, 20 do 
    love.graphics.setColor(1,1,1,1)
    love.graphics.rectangle("fill", 0 , 0 + x * 30, 600, 1)
    love.graphics.rectangle("fill", 0+ x * 30 , 0 , 1, 600)

  end
  love.graphics.setColor(1,0,0,1)
  love.graphics.rectangle("fill", 0 , 0 + 5 * 30, 600, 1)
  love.graphics.rectangle("fill", 0 , 0 + 10 * 30, 600, 1)
  love.graphics.rectangle("fill", 0 , 0 + 15 * 30, 600, 1)
  love.graphics.rectangle("fill", 0+ 5 * 30 , 0 , 1, 600)
  love.graphics.rectangle("fill", 0+ 10 * 30 , 0 , 1, 600)
  love.graphics.rectangle("fill", 0+ 15 * 30 , 0 , 1, 600)
  love.graphics.setColor(0,1,0,1)



  
  for i=1, #triangles do 
    local draw1 = {unpack(triangles[i])}
    for fx=1, #draw1 do
      draw1[fx] = (draw1[fx]+10) * 30
    end
    love.graphics.setColor(1,1,0,1)
    love.graphics.polygon("fill", unpack(draw1))
    love.graphics.setColor(1,1,1,1)

    
  end

  if numbershow then
    for i=1, #triangles do 
      local draw1 = {unpack(triangles[i])}
      for fx=1, #draw1 do
        draw1[fx] = (draw1[fx]+10) * 30
      end

      love.graphics.setColor(1,0,1,1)
      love.graphics.setFont(font3)
      love.graphics.print(i, draw1[1], draw1[2])
      love.graphics.setFont(font)
    end
  end
  love.graphics.setColor(1,1,1,1)

  love.graphics.setColor(1,1,1,1)
  for y = 0, 20 do 
    for x = 0, 20 do 
      love.graphics.setColor(0,1,0,1)
      if check(x * 30 - 2, y * 30 - 2, 5, 5, love.mouse.getX(), love.mouse.getY(), 3, 3) then 
        love.graphics.setColor(1,0,0,1)
      end
      love.graphics.rectangle("fill", x * 30 - 2, y * 30 - 2, 5, 5)
    end
  end
  love.graphics.setColor(1,1,1,1)

--	
  suit.draw()
  love.graphics.print("X: " .. love.mouse.getX() .. " Y: " .. love.mouse.getY() .. " Mode: " .. mode .. " Count: " .. #count .. " Mirror Mode X: " .. tostring(mirrormodex) .. " Mirror Mode Y: " .. tostring(mirrormodey), 10, 750)
  love.graphics.print("Last Message: " .. tostring(printqueue), 10, 780)
  for i=1, #count do
    love.graphics.print("Count " .. i .. count[i][1] .. ", " .. count[i][2], 810, 10 + 10 * (i-1))
  end
end

function love.textedited(text, start, length)
    suit.textedited(text, start, length)
end

function love.textinput(t)
	suit.textinput(t)
end

function love.keypressed(key)
	suit.keypressed(key)
end