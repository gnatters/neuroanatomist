c = [0,0,0]
a = 0
h = 0
d = 30
min_d = 15
max_d = 40
half_pi = Math.PI/2

prev_picked = picked = null

Jax.getGlobal().ObjectMovementHelper = Jax.Helper.create
  key_pressed: (event) ->
    switch event.keyCode
      when KeyEvent.DOM_VK_W then d -= 1
      when KeyEvent.DOM_VK_S then d += 1
    d = min_d if d < min_d
    d = max_d if d > max_d
  
  mouse_moved: (event) ->
    picked = @world.pick(event.offsetX, event.offsetY)
    if picked and picked != prev_picked
      picked.mesh.material = "teapot"
      prev_picked = picked
    else if prev_picked
      prev_picked.mesh.material = "scene"
      prev_picked = null
    
  mouse_dragged: (event) ->
    a += 0.02 * -event.diffx
    h += 0.02 * -event.diffy
    h = half_pi  if h > half_pi
    h = -half_pi if h < -half_pi
    
  update: (timechange) ->
    x = c[0] + d * Math.cos(h) * Math.sin(a)
    y = c[1] + d * Math.sin(h)
    z = c[2] + d * Math.cos(h) * Math.cos(a)
    @player.camera.lookAt c, [x,y,z]
    @player.lantern.camera.lookAt c, [x,y+1,z]

      