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
      update()

      scrubber.val = (scrubber.val + 1) % (scrubber.max + 1)
      currentAnimation.currentFrameIndex(scrubber.val)

    changePlayIcon = (icon) ->
      el = $('.play')

      el.css "background-image", "url(/images/#{icon}.png)"

      if icon == 'pause'
        el.addClass('pause')
      else
        el.removeClass('pause')

    update = ->
      scrubberEl.val(scrubber.val)
      scrubberEl.get(0).max = scrubber.max

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
        if currentAnimation.frames.length > 0
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
        update()
        clearInterval(intervalId)
        intervalId = null
        changePlayIcon('play')
        currentAnimation.currentFrameIndex(-1)

    return self

  Animation = ->
    tileset = {}

    tileset[Math.uuid(32, 16)] = "http://dev.pixie.strd6.com/sprites/323/original.png"
    tileset[Math.uuid(32, 16)] = "http://dev.pixie.strd6.com/sprites/324/original.png"
    tileset[Math.uuid(32, 16)] = "http://dev.pixie.strd6.com/sprites/325/original.png"
    tileset[Math.uuid(32, 16)] = "http://dev.pixie.strd6.com/sprites/326/original.png"
    tileset[Math.uuid(32, 16)] = "http://dev.pixie.strd6.com/sprites/327/original.png"
    tileset[Math.uuid(32, 16)] = "http://dev.pixie.strd6.com/sprites/328/original.png"
    tileset[Math.uuid(32, 16)] = "http://dev.pixie.strd6.com/sprites/329/original.png"
    tileset[Math.uuid(32, 16)] = "http://dev.pixie.strd6.com/sprites/330/original.png"
    tileset[Math.uuid(32, 16)] = "http://dev.pixie.strd6.com/sprites/331/original.png"
    tileset[Math.uuid(32, 16)] = "http://dev.pixie.strd6.com/sprites/332/original.png"
    tileset[Math.uuid(32, 16)] = "http://dev.pixie.strd6.com/sprites/333/original.png"
    tileset[Math.uuid(32, 16)] = "http://dev.pixie.strd6.com/sprites/334/original.png"
    tileset[Math.uuid(32, 16)] = "http://dev.pixie.strd6.com/sprites/335/original.png"
    tileset[Math.uuid(32, 16)] = "http://dev.pixie.strd6.com/sprites/336/original.png"
    tileset[Math.uuid(32, 16)] = "http://dev.pixie.strd6.com/sprites/337/original.png"
    tileset[Math.uuid(32, 16)] = "http://dev.pixie.strd6.com/sprites/338/original.png"

    sequences = []
    frames = []
    currentFrameIndex = 0

    name = "Animation #{animationNumber}"
    animationNumber += 1

    findTileIndex = (tileSrc) ->
      for uuid, src of tileset
        return uuid if src == tileSrc

    updateSelected = (frameIndex) ->
      tilesetIndex = frames[frameIndex]

      $('.frame_sprites .sprite_container').removeClass('current')

      player = $('.player img')

      if frameIndex == -1
        player.attr('src', tileset[0])
      else
        player.attr('src', tileset[tilesetIndex])
        $('.frame_sprites .sprite_container').eq(frameIndex).addClass('current')

    updateSequence = ->
      sequencesEl = $('.sequences')
      sequencesEl.children().remove()

      for array in sequences
        sequence = $('<div class="sequence"></div>').appendTo(sequencesEl)

        for spriteIndex in array
          spriteSrc = tileset[spriteIndex]
          spriteTemplate.tmpl(src: spriteSrc).appendTo(sequence)

    update = ->
      $('.frame_sprites').children().remove()
      for frame_index in frames
        spriteSrc = tileset[frame_index]
        spriteTemplate.tmpl(src: spriteSrc).appendTo($('.frame_sprites'))

    self =
      addFrame: (imgSrc) ->
        frames.push(findTileIndex(imgSrc))
        controls.scrubberMax(frames.length - 1)
        update()

      addSequenceToFrames: (index) ->
        for imageIndex in sequences[index]
          self.addFrame(tileset[imageIndex])

      createSequence: ->
        sequences.push(frames.copy())
        updateSequence()
        frames.clear()
        update()

      currentFrameIndex: (val) ->
        if val?
          currentFrameIndex = val
          updateSelected(val)
          return self
        else
          return currentFrameIndex

      frames: frames

      name: name

      tileset: tileset

      removeFrame: (frameIndex) ->
        tilesetIndex = frames[frameIndex]
        frames.splice(frameIndex, 1)

        if $.inArray(tilesetIndex, frames) == -1
          delete tileset[tilesetIndex]

        update()

    return self

  editorTemplate.tmpl().appendTo(animationEditor)

  controls = Controls()
  currentAnimation = Animation()
  animations = [currentAnimation]

  updateUI = ->
    animationsEl = $('.animations')
    animationsEl.children().remove()

    spritesEl = $('.sprites')
    spritesEl.children().remove()

    for animation in animations
      animationTemplate.tmpl(name: animation.name).appendTo(animationsEl)

    for index, src of currentAnimation.tileset
      spriteTemplate.tmpl(src: src).appendTo(spritesEl)

  updateUI()

  $('.play').mousedown ->
    if $(this).hasClass('pause')
      controls.pause()
    else
      controls.play()

  $('.scrubber').change ->
    newValue = $(this).val()

    controls.scrubber(newValue)
    currentAnimation.currentFrameIndex(newValue)

  $('.stop').mousedown -> controls.stop()

  $('.new_animation').mousedown ->
    animations.push(Animation())
    currentAnimation = animations.last()
    updateUI()

  $('.sprites .sprite_container').mousedown ->
    imgSrc = $(this).find('img').attr('src')

    currentAnimation.addFrame(imgSrc)

  $('.sequence').live
    mousedown: ->
      index = $(this).index()
      currentAnimation.addSequenceToFrames(index)

  $('.frame_sprites .sprite_container').live
    mousedown: ->
      index = $(this).index()
      currentAnimation.removeFrame(index)

  $('.save_sequence').click ->
    currentAnimation.createSequence()

  $('.fps input').change ->
    newValue = $(this).val()

    controls.stop()
    controls.fps(newValue)
