Jax.views.push "Quiz/index", ->
  @glClear GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT
  @world.render()
