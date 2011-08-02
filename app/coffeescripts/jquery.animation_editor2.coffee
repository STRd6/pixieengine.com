$.fn.animationEditor = (options) ->
  animationNumber = 1

  animationEditor = $(this.get(0)).addClass("editor animation_editor")

  templates = $("#animation_editor_templates")
  editorTemplate = templates.find('.editor.template')
  animationTemplate = templates.find('.animation')
  spriteTemplate = templates.find('.sprite')
  frameTemplate = templates.find('.frame')

  Controls = ->
    intervalId = null

    fpsEl = animationEditor.find('.fps input')
    scrubberEl = animationEditor.find('.scrubber')

    scrubber =
      min: (newMin) ->
        if newMin?
          scrubberEl.get(0).min = newMin
          return scrubber
        else
          return scrubberEl.get(0).min
      max: (newMax) ->
        if newMax?
          scrubberEl.get(0).max = newMax
          return scrubber
        else
          return scrubberEl.get(0).max
      val: (newValue) ->
        if newValue?
          scrubberEl.val(newValue)
          return scrubber
        else
          scrubberEl.val()

    fps =
      min: fpsEl.get(0).min
      max: fpsEl.get(0).max
      val: (newValue) ->
        if newValue?
          fpsEl.val(newValue)
          return fps
        else
          fpsEl.val()

    updateFrame = ->
      animationEditor.trigger 'updateFrames'

      scrubber.val((parseInt(scrubber.val()) + 1) % (parseInt(scrubber.max()) + 1))
      currentAnimation.currentFrameIndex(scrubber.val())

    changePlayIcon = (icon) ->
      el = $('.play')

      el.css "background-image", "url(/images/#{icon}.png)"

      if icon == 'pause'
        el.addClass('pause')
      else
        el.removeClass('pause')

    self =
      fps: (val) ->
        fps.val(val)

      pause: ->
        changePlayIcon('play')
        clearInterval(intervalId)
        intervalId = null

      play: ->
        if currentAnimation.frames.length > 0
          intervalId = setInterval(updateFrame, 1000 / fps.val()) unless intervalId
          changePlayIcon('pause')

      scrubber: (val) ->
        scrubber.val(val)

      scrubberMax: (val) ->
        scrubber.max(val)

      scrubberPosition: ->
        "#{scrubber.val()} / #{scrubber.max}"

      stop: ->
        scrubber.val(0)
        clearInterval(intervalId)
        intervalId = null
        changePlayIcon('play')
        currentAnimation.currentFrameIndex(-1)

    return self

  Animation = ->
    tileset = {}

    [323..338].each (n) ->
      tileset[Math.uuid(32, 16)] = "http://dev.pixie.strd6.com/sprites/#{n}/original.png"

    sequences = []
    frames = []
    currentFrameIndex = 0

    name = "State #{animationNumber}"
    animationNumber += 1

    findTileIndex = (tileSrc) ->
      for uuid, src of tileset
        return uuid if src == tileSrc

    animationEditor.bind 'updateSequence', ->
      sequencesEl = animationEditor.find('.sequences')
      sequencesEl.children().remove()

      for array in sequences
        sequence = $('<div class="sequence"></div>').appendTo(sequencesEl)

        for spriteIndex in array
          spriteSrc = tileset[spriteIndex]
          spriteTemplate.tmpl(src: spriteSrc).appendTo(sequence)

    animationEditor.bind 'updateFrames', ->
      animationEditor.find('.frame_sprites').children().remove()
      for frame_index in frames
        spriteSrc = tileset[frame_index]
        frameTemplate.tmpl(src: spriteSrc).appendTo(animationEditor.find('.frame_sprites'))

    self =
      addFrame: (imgSrc) ->
        frames.push(findTileIndex(imgSrc))
        controls.scrubberMax(frames.length - 1)
        animationEditor.trigger 'updateFrames'

      addSequenceToFrames: (index) ->
        for imageIndex in sequences[index]
          self.addFrame(tileset[imageIndex])

      addTile: (src) ->
        tileset[Math.uuid(32, 16)] = src
        spritesEl = animationEditor.find('.sprites')
        spriteTemplate.tmpl(src: src).appendTo(spritesEl)

      createSequence: ->
        sequences.push(frames.copy())
        animationEditor.trigger 'updateSequence'
        frames.clear()
        animationEditor.trigger 'updateFrames'

      currentFrameIndex: (val) ->
        if val?
          currentFrameIndex = val
          self.updateSelected(val)
          return self
        else
          return currentFrameIndex

      frames: frames

      name: (val) ->
        if val?
          name = val
          return self
        else
          return name

      tileset: tileset

      removeFrame: (frameIndex) ->
        tilesetIndex = frames[frameIndex]
        frames.splice(frameIndex, 1)

        if $.inArray(tilesetIndex, frames) == -1
          delete tileset[tilesetIndex]

        animationEditor.trigger 'updateFrames'

      updateSelected: (frameIndex) ->
        tilesetIndex = frames[frameIndex]

        animationEditor.find('.frame_sprites img').removeClass('current')

        player = $('.player img')

        if frameIndex == -1
          player.attr('src', tileset[0])
        else
          player.attr('src', tileset[tilesetIndex])
          animationEditor.find('.frame_sprites img').eq(frameIndex).addClass('current')

    return self

  editorTemplate.tmpl().appendTo(animationEditor)

  controls = Controls()
  currentAnimation = Animation()
  animations = [currentAnimation]

  updateUI = ->
    animationsEl = animationEditor.find('.animations')
    animationsEl.children().remove()

    spritesEl = animationEditor.find('.sprites')

    for animation in animations
      animationTemplate.tmpl(name: animation.name()).appendTo(animationsEl)

    if spritesEl.find('.sprite_container').length == 0
      for index, src of currentAnimation.tileset
        spriteTemplate.tmpl(src: src).appendTo(spritesEl)

  updateUI()

  animationEditor.find('.play').mousedown ->
    if $(this).hasClass('pause')
      controls.pause()
    else
      controls.play()

  animationEditor.find('.scrubber').change ->
    newValue = $(this).val()

    controls.scrubber(newValue)
    currentAnimation.currentFrameIndex(newValue)

  animationEditor.find('.stop').mousedown -> controls.stop()

  animationEditor.find('.new_animation').mousedown ->
    animations.push(Animation())
    currentAnimation = animations.last()

    animationEditor.find('.sequences').children().remove()
    animationEditor.find('.frame_sprites').children().remove()
    animationEditor.find('.player img').removeAttr('src')

    updateUI()

  animationEditor.find('.sprites .sprite_container').live
    mousedown: ->
      imgSrc = $(this).find('img').attr('src')

      currentAnimation.addFrame(imgSrc)

  animationEditor.find('.sequence').live
    mousedown: ->
      index = $(this).index()
      currentAnimation.addSequenceToFrames(index)
    mouseenter: ->
      $(this).find('.sprite_container:first-child').addClass('rotate_left')
      $(this).find('.sprite_container:last-child').addClass('rotate_right')
    mouseleave: ->
      $(this).find('.sprite_container').removeClass('rotate_left').removeClass('rotate_right')

  animationEditor.find('.frame_sprites img').live
    mousedown: ->
      index = $(this).index()
      currentAnimation.currentFrameIndex(index)

  animationEditor.find('.save_sequence').click ->
    currentAnimation.createSequence()

  animationEditor.find('.fps input').change ->
    newValue = $(this).val()

    controls.stop()
    controls.fps(newValue)

  animationEditor.find('input.state_name').live
    change: ->
      updatedStateName = $(this).val()
      currentAnimation.name(updatedStateName)

  animationEditor.find('.state_name').liveEdit()

  animationEditor.dropImageReader (file, event) ->
    if event.target.readyState == FileReader.DONE
      src = event.target.result

      currentAnimation.addTile(src)

  $(document).bind 'keydown', 'del backspace', (e) ->
    e.preventDefault()
    currentAnimation.removeFrame(currentAnimation.currentFrameIndex())
