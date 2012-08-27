Jax.getGlobal().StatusHelper = Jax.Helper.create
  show_loading_spinner: (target, big) ->
    opts =
      lines: 13
      length: 8
      width: 4
      radius: 11
      corners: 1
      rotate: 0
      color: '#000'
      speed: 1
      trail: 70
      shadow: false
      hwaccel: true
      className: 'spinner'
      zIndex: 2e9
      top: 'auto'
      left: 'auto'
    if big
      $.extend opts,
        opts.length = 27
        opts.width = 8
        opts.radius = 33
        opts.className = 'big_spinner'
    @spinner = target.spin(opts)
    

  hide_loading_spinner: () -> @spinner.spin(false)