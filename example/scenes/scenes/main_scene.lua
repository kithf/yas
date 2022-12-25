default = true

ball = {
  x = 0,
  y = 0,
}

some_scene_var = 1

enter = function(scene, args)
  some_scene_var = args and args.test_param or 1
end

update = function(scene)
  ball.x = ball.x + 1
  ball.y = ball.y + 1

  some_scene_var = some_scene_var - 1
  if love.keyboard.isDown "w" then
    set_scene("next_test", {
      test_param = 1,
    })
  end

  print("some_scene_var =", some_scene_var)
end

draw = function(scene)
  love.graphics.circle("fill", ball.x, ball.y, 10)
end

exit = function(scene)
  print "Exit"
end
