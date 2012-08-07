Jax.getGlobal().CanvasEventRoutingHelper = Jax.Helper.create
  mouse_entered: (event) ->
    
  
  mouse_exited: (event) ->
    if @labeler
      @labeler.mouse_exited event    
  
  mouse_clicked: (event) ->
    
  
  mouse_moved: (event) ->
    picked = @world.pick(event.x, event.y)
    picked = null unless @scene.highlight(picked and picked.id) 
    if @tooltip
      @tooltip.mouse_moved event.pageX, event.pageY, picked
  
  mouse_dragged: (event) ->
    this.camera_drag(event) # camera control
    if @tooltip
      @tooltip.mouse_dragged event.pageX, event.pageY, @picked
  
  mouse_pressed: (event) ->
    this.camera_press(event)
    if @labeler
      @labeler.mouse_pressed event

  mouse_released: (event) ->
    this.camera_release(event)
    if @tooltip
      @tooltip.mouse_released event.pageX, event.pageY, @world.pick(event.x, event.y)
    if @labeler
      @labeler.mouse_released event

  key_pressed: (event) ->
    this.depth_key(event) # camera control
  
  key_typed: (event) ->
    
  
  key_released: (event) ->
  
