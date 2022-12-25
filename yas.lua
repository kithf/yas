--[[
  Yet Another Screenmanager for LÖVE
  Version 1.0.0
  Author: kithf (code-kithf@proton.me)

  This is a scene manager for LÖVE. It allows you to easily switch between scenes
  and manage them. It is very simple to use and is very lightweight.

  Inspiried by scenery(https://github.com/paltze/scenery) by paltze

  LICENSE
  MIT License
  Copyright (c) 2022 kithf
  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:
  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.
  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.
--]]

--[[
Usage:
love.load = function()
  yas = require "yas" "scenes"
end

-- main_scene.lua
default = true

load = function()
  print("Loaded main scene")
end

update = function(dt)
  print("Updating main scene")
end

draw = function()
  print("Drawing main scene")
end
--]]

local file_ext = function(str)
  return str:match "%.([^%.]+)$" or ""
end

local file_name = function(str)
  return str:match "([^/\\]+)$" or ""
end

local file_path = function(str)
  return str:match "^(.*[/\\])[^/\\]-$" or ""
end

local strip_ext = function(str)
  local i = str:match ".+()%.%w+$"
  return i and str:sub(1, i - 1) or str
end

local export = {}
local scenes = {}
local current_scene = nil
local previous_scene = nil

local load_with_end = function(path, env)
  local t = {}

  local f = assert(love.filesystem.load(path), "Error occured during loading scene!")

  setfenv(f, setmetatable(t, {
    __index = function(t, k)
      return rawget(t, k) or env[k] or _G[k]
    end,
    __newindex = function(t, k, v)
      rawset(t, k, v)
    end
  }))

  pcall(f)

  return t
end

local load_scenes
load_scenes = function(base_path, env)
  env = env or {}

  local files = love.filesystem.getDirectoryItems(base_path)

  for _, v in ipairs(files) do
    local v_file_name = file_name(v)

    if love.filesystem.getInfo(base_path .. "/" .. v, "directory") then
      load_scenes(base_path .. "/" .. v, env)
    elseif file_ext(v) == "lua" then
      local scene = load_with_end(base_path .. "/" .. v, env)

      if scene.default then
        current_scene = strip_ext(v_file_name)
      end

      scenes[strip_ext(v_file_name)] = scene
    end
  end

  if not current_scene then
    print "No default scene specified, using first scene"
    current_scene = strip_ext(file_name(files[1]))
  end

  if scenes[current_scene].load then
    scenes[current_scene]:load()
  end
end

local load_manual = function(conf, env)
  env = env or {}

  for _, v in ipairs(conf) do
    if type(v.path) ~= "string" then error("Path must be a string!") end
    if scenes[v[1]] or scenes[v.key] then error("Scene with key " .. v.key .. " already exists!") end

    v.key = v.key or v[1] 

    local scene = load_with_end(v.path, env)

    if scene.default then
      current_scene = v.key
    end

    scenes[v.key] = scene
  end

  if not current_scene then
    print "No default scene specified, using first scene"
    current_scene = conf[1].key
  end

  if scenes[current_scene].load then
    scenes[current_scene]:load()
  end
end

-- All callbacks from https://love2d.org/wiki/Category:Callbacks
local callbacks = {
  "audiodisconnected",
  "sensorupdated",
  "displayrotated",
  "update",
  "joystickreleased",
  "mousemoved",
  "textedited",
  "threaderror",
  "keypressed",
  "keyreleased",
  "touchpressed",
  "gamepadaxis",
  "joystickaxis",
  "load",
  "visible",
  "mousepressed",
  "quit",
  "joystickpressed",
  "focus",
  "directorydropped",
  "mousefocus",
  "resize",
  -- "errorhandler", -- special case
  "joystickremoved",
  "joystickhat",
  "wheelmoved",
  --"draw", -- special case
  "mousereleased",
  "run",
  "textinput",
  "touchreleased",
  "gamepadreleased",
  "touchmoved",
  "lowmemory",
  -- "errhand",
  "filedropped",
  "joystickadded",
  "gamepadpressed",
}

for _, v in ipairs(callbacks) do
  export[v] = function(...)
    if scenes[current_scene] and scenes[current_scene][v] then
      scenes[current_scene][v](scenes[current_scene][v], ...)
    end
  end
end

export.draw = function(...)
  if scenes[current_scene] then
    if scenes[current_scene].paused and scenes[current_scene].pause then
      scenes[current_scene]:pause(...)
    elseif scenes[current_scene].draw then
      scenes[current_scene]:draw(...)
    end
  end
end

export.set = function(key, params)
  params = params or {}

  if scenes[current_scene].unload then
    scenes[current_scene]:unload(params)
  end

  if scenes[key] then
    previous_scene = current_scene
    current_scene = key
  else
    print("Scene " .. key .. " does not exist")
  end

  if scenes[current_scene].load then
    scenes[current_scene]:load(params)
  end
end

export.current = function()
  return current_scene
end

export.scenes = function()
  return scenes
end

export.get = function(key)
  return scenes[key]
end

export.previous = function()
  return previous_scene
end

export.add = function(key, scene)
  if scenes[key] then
    print("Scene " .. key .. " already exists")
  end

  if scene.default then current_scene = key end
  scenes[key] = scene
end

export.remove = function(key)
  if scenes[key] then
    scenes[key] = nil
  else
    print("Scene " .. key .. " does not exist")
  end
end

export.toggle = function(value)
  if scenes[current_scene] then
    if value ~= nil then
      scenes[current_scene].paused = value
    else
      scenes[current_scene].paused = not scenes[current_scene].paused
    end
  end
end

_G.toggle_scene = export.toggle
_G.set_scene = export.set

return function(conf, env)
  env = env or {}

  if type(conf) == "string" then
    load_scenes(conf, env)
  elseif type(conf) == "table" then
    load_manual(conf, env)
  else
    error("Invalid argument #1, expected string or table, got " .. type(conf))
  end

  if env.dont_override then
    return export
  end

  for _, v in ipairs(callbacks) do
    local prev_func = love[v]
    love[v] = function(...)
      if prev_func then
        prev_func(...)
      end

      if scenes[current_scene] and scenes[current_scene][v] then
        scenes[current_scene][v](scenes[current_scene][v], ...)
      end
    end
  end

  local prev_draw = love.draw
  love.draw = function(...)
    if prev_draw then
      prev_draw(...)
    end
    
    if scenes[current_scene] then
      if scenes[current_scene].paused and scenes[current_scene].pause then
        scenes[current_scene]:pause(...)
      elseif scenes[current_scene].draw then
        scenes[current_scene]:draw(...)
      end
    end
  end

  return export
end
