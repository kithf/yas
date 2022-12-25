# YAS
Yet Another Screen manager

This is a scene manager for LÖVE. It allows you to easily switch between scenes and manage them. It is simplier than [Scenery](https://github.com/paltze/scenery). 
Just drop-in and write your scene.

## Installation
Copy `yas.lua` into your directory with game and require it in `love.load`.

## Example
You can see some other examples in `examples/` folder.

```lua
-- main.lua
function love.load()
  yas = require "yas" "folder_with_scenes"
end
```

```lua
-- main_scene.lua
default = true

some_var = 42

enter = function()
  print "Just loaded main scene!"
end

update = function()
  print "Updated main scene!"
  print("some_var become", some_var)
  some_var = some_var + 1
end

draw = function()
  print "Drawing main scene!"
end
```

## Documentation
### Initialization
#### Auto-init
YAS can automatically load all scenes from folder. Just pass folder name to `require` function.
```lua
yas = require "yas" "folder_with_scenes"
```

#### Manual-init
You can also load scenes manually.
```lua
yas = require "yas" {
  { "scene1", path = "path/to/scene1.lua", default = true},
  { key = "scene2", path = "path/to/scene2.lua"},
  { key = "scene3", path = "path/to/scene3.lua"},
}
```

### Scene
All scenes are Lua files. They can contain any Lua code. 
You can define callbacks from LÖVE in scene file, that defined in [LÖVE documentation](https://love2d.org/wiki/Category:Callbacks), but there are some special functions that will be called by YAS.

#### **pause**
This function will be called when scene is paused and drawing. It can be called by `yas.toggle` or `toggle_scene` function or when you switch to another scene.

#### **enter**
This function will be called when scene is loaded. It can be called by `yas.set` or `set_scene` function or when you switch to another scene.

#### **exit**
This function will be called when scene is unloaded. It can be called by `yas.set` or `set_scene` function or when you switch to another scene.

#### Default scene
You can set default scene by setting `default` variable to `true` in scene file.
```lua
default = true
```

#### Paused scene
You can set paused scene by setting `paused` variable to `true` in scene file.
```lua
paused = true
```

### API
#### yas.set(key: `string`, args: `table`)
This function will set scene by key.
Global alias: `set_scene`.
```lua
yas.set "scene1"

-- or

yas.set("scene1", {some_var = 42})
```

#### yas.toggle(value: `boolean`)
This function will toggle current scene.
Global alias: `toggle_scene`.
```lua
yas.toggle()

-- or

yas.toggle(true)
```

#### yas.current()
This function will return current scene key.
```lua
print(yas.current())
```

#### yas.scenes()
This function will return table with all scenes.
```lua
print(yas.scenes())
```

#### yas.get(key: `string`)
This function will return scene by key.
```lua
print(yas.get "scene1")
```

#### yas.previous()
This function will return previous scene key.
```lua
print(yas.previous())
```

#### yas.add(key: `string`, scene: `table`)
This function will add scene to scenes table.
```lua
yas.add("scene1", {load = function() print "Loaded scene1!" end})
```

#### yas.remove(key: `string`)
This function will remove scene from scenes table.
```lua
yas.remove "scene1"
```
