$.fn.animationEditor = (options) ->
  animationNumber = 1

  animationEditor = $(this.get(0)).addClass("editor animation_editor")

  templates = $("#animation_editor_templates")
  editorTemplate = templates.find('.editor.template')
  animationTemplate = templates.find('.animation')
  spriteTemplate = templates.find('.sprite')

  Controls = ->
    intervalId = null

    scrubberEl = $('.scrubber')

    scrubber =
      min: scrubberEl.get(0).min
      max: scrubberEl.get(0).max
      val: scrubberEl.val()

    fpsEl = $('.fps input')

    fps =
      min: fpsEl.get(0).min
      max: fpsEl.get(0).max
      val: fpsEl.val()

    updateFrame = ->
      self.update()
      scrubber.val = (scrubber.val + 1) % (scrubber.max)
      animation.currentFrameIndex(scrubber.val)

    changePlayIcon = (icon) ->
      el = $('.play')

      el.css "background-image", "url(/images/#{icon}.png)"

      if icon == 'pause'
        el.addClass('pause')
      else
        el.removeClass('pause')

    self =
      fps: (val) ->
        if val?
          fps.val = val
          return self
        else
          return fps.val

      pause: ->
        changePlayIcon('play')
        clearInterval(intervalId)
        intervalId = null

      play: ->
        intervalId = setInterval(updateFrame, 1000 / fps.val) unless intervalId
        changePlayIcon('pause')

      scrubber: (val) ->
        if val?
          scrubber.val = val
          return self
        else
          return scrubber.val

      scrubberMax: (val) ->
        if val?
          scrubber.max = val
          return self
        else
          return scrubber.max

      scrubberPosition: ->
        "#{scrubber.val} / #{scrubber.max}"

      stop: ->
        scrubber.val = 0
        self.update()
        clearInterval(intervalId)
        intervalId = null
        changePlayIcon('play')
        animation.currentFrameIndex(-1)

      update: ->
        scrubberEl.val(scrubber.val)
        scrubberEl.get(0).max = scrubber.max

    return self

  Animation = (name) ->
    tileset = []
    sequences = []
    frames = []
    currentFrameIndex = 0

    name ||= "Animation #{animationNumber}"
    animationNumber += 1

    updateSelected = (val) ->
      $('.frame_sprites .sprite_container').removeClass('current')
      $('.frame_sprites .sprite_container').eq(val).addClass('current') unless val == -1
      $('.player img').attr('src', tileset[currentFrameIndex])

    self =
      addFrame: (imgSrc) ->
        tileset.push(imgSrc) if $.inArray(imgSrc, tileset) == -1
        frames.push(tileset.indexOf(imgSrc))
        controls.scrubberMax(frames.length)
        self.update()

      currentFrameIndex: (val) ->
        if val?
          currentFrameIndex = val
          updateSelected(val)
          return self
        else
          return currentFrameIndex

      name: name

      update: ->
        $('.frame_sprites').children().remove()
        for frame_index in frames
          spriteSrc = tileset[frame_index]
          spriteTemplate.tmpl(src: spriteSrc).appendTo($('.frame_sprites'))

    return self

  editorTemplate.tmpl().appendTo(animationEditor)

  controls = Controls()
  animation = Animation()

  animations = [animation]

  updateUI = ->
    sprites = $('.sprites')

    for animation in animations
      animations = $('.animations')

      animations.children().remove()
      animationTemplate.tmpl(animation.name).appendTo(animations)

    spritesSrc = [
      "http://dev.pixie.strd6.com/sprites/323/original.png"
      "http://dev.pixie.strd6.com/sprites/324/original.png"
      "http://dev.pixie.strd6.com/sprites/325/original.png"
      "http://dev.pixie.strd6.com/sprites/326/original.png"
      "http://dev.pixie.strd6.com/sprites/327/original.png"
      "http://dev.pixie.strd6.com/sprites/328/original.png"
      "http://dev.pixie.strd6.com/sprites/329/original.png"
      "http://dev.pixie.strd6.com/sprites/330/original.png"
      "http://dev.pixie.strd6.com/sprites/331/original.png"
      "http://dev.pixie.strd6.com/sprites/332/original.png"
      "http://dev.pixie.strd6.com/sprites/333/original.png"
      "http://dev.pixie.strd6.com/sprites/334/original.png"
      "http://dev.pixie.strd6.com/sprites/335/original.png"
      "http://dev.pixie.strd6.com/sprites/336/original.png"
      "http://dev.pixie.strd6.com/sprites/337/original.png"
      "http://dev.pixie.strd6.com/sprites/338/original.png"
    ]

    for src in spritesSrc
      spriteTemplate.tmpl(src: src).appendTo(sprites)

  updateUI()

  $('.play').mousedown ->
    if $(this).hasClass('pause')
      controls.pause()
    else
      controls.play()

  $('.scrubber').change ->
    newValue = $(this).val()

    controls.scrubber(newValue)
    animation.currentFrameIndex(newValue)

  $('.stop').mousedown -> controls.stop()

  $('.sprites .sprite_container').mousedown ->
    imgSrc = $(this).find('img').attr('src')

    animation.addFrame(imgSrc)

  $('.fps input').change ->
    newValue = $(this).val()

    controls.stop()
    controls.fps(newValue)
