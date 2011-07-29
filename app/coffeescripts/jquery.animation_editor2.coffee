$.fn.animationEditor = (options) ->
  animationNumber = 1

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
      scrubber.val = (scrubber.val + 1) % scrubber.max
      self.update()

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
          scrubber.max = val
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
        stopped = false

      scrubberPosition: ->
        "#{scrubber.val} / #{scrubber.max}"

      stop: ->
        scrubber.val = 0
        self.update()
        clearInterval(intervalId)
        intervalId = null
        changePlayIcon('play')
        stopped = true

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

    self =
      addFrame: (imgSrc) ->
        tileset.push(imgSrc) if $.inArray(imgSrc, tileset) == -1
        frames.push(tileset.indexOf(imgSrc))

      name: name

    return self

  animationEditor = $(this.get(0)).addClass("editor animation_editor")

  templates = $("#animation_editor_templates")
  editorTemplate = templates.find('.editor.template')
  animationTemplate = templates.find('.animation')
  spriteTemplate = templates.find('.sprite')

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
      "http://dev.pixie.strd6.com/sprites/15408/original.png"
      "http://dev.pixie.strd6.com/sprites/15407/original.png"
      "http://dev.pixie.strd6.com/sprites/15406/original.png"
      "http://dev.pixie.strd6.com/sprites/15405/original.png"
      "http://dev.pixie.strd6.com/sprites/15404/original.png"
      "http://dev.pixie.strd6.com/sprites/15403/original.png"
      "http://dev.pixie.strd6.com/sprites/15402/original.png"
      "http://dev.pixie.strd6.com/sprites/15401/original.png"
      "http://dev.pixie.strd6.com/sprites/15400/original.png"
      "http://dev.pixie.strd6.com/sprites/15399/original.png"
      "http://dev.pixie.strd6.com/sprites/15398/original.png"
      "http://dev.pixie.strd6.com/sprites/15397/original.png"
      "http://dev.pixie.strd6.com/sprites/15396/original.png"
      "http://dev.pixie.strd6.com/sprites/15395/original.png"
      "http://dev.pixie.strd6.com/sprites/15394/original.png"
      "http://dev.pixie.strd6.com/sprites/15393/original.png"
    ]

    for src in spritesSrc
      spriteTemplate.tmpl(src: src).appendTo(sprites)

  updateUI()

  $('.play').mousedown ->
    if $(this).hasClass('pause')
      controls.pause()
    else
      controls.play()

  $('.stop').mousedown -> controls.stop()

  $('.sprites .sprite_container').mousedown ->
    imgSrc = $(this).find('img').attr('src')

    animation.addFrame(imgSrc)

  $('.fps input').change ->
    newValue = $(this).val()

    controls.stop()
    controls.fps(newValue)
