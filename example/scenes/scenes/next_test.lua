another_scene_var = 0

load = function(scene, args)
  another_scene_var = args and args.test_param or 1
end

update = function(scene)
  another_scene_var = another_scene_var + 1
  if love.keyboard.isDown "s" then
    set_scene("main_scene", {
      test_param = another_scene_var,
    })
  end
  print("another_scene_var =", another_scene_var)
end

draw = function(scene)
  love.graphics.print("Hello World", 400, 300)
end
