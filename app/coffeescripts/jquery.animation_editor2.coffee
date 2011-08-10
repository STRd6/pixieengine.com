$.fn.animationEditor = (options) ->
  animationNumber = 1
  lastClickedSprite = null

  animationEditor = $(this.get(0)).addClass("editor animation_editor")

  templates = $("#animation_editor_templates")
  editorTemplate = templates.find('.editor.template')
  animationTemplate = templates.find('.animation')
  spriteTemplate = templates.find('.sprite')

  loadSpriteSheet = (src, rows, columns, loadedCallback) ->
    canvas = $('<canvas>').get(0)
    context = canvas.getContext('2d')

    image = new Image()

    image.onload = ->
      tileWidth = image.width / rows
      tileHeight = image.height / columns

      canvas.width = tileWidth
      canvas.height = tileHeight

      columns.times (col) ->
        rows.times (row) ->
          sourceX = row * tileWidth
          sourceY = col * tileHeight
          sourceWidth = tileWidth
          sourceHeight = tileHeight
          destWidth = tileWidth
          destHeight = tileHeight
          destX = 0
          destY = 0

          context.clearRect(0, 0, tileWidth, tileHeight)
          context.drawImage(image, sourceX, sourceY, sourceWidth, sourceHeight, destX, destY, destWidth, destHeight)

          loadedCallback?(canvas.toDataURL())

    image.src = src

  Controls = ->
    intervalId = null

    fpsEl = animationEditor.find('.fps input')
    scrubberEl = animationEditor.find('.scrubber')

    scrubber =
      max: (newMax) ->
        if newMax?
          scrubberEl.get(0).max = newMax
          return scrubber
        else
          return parseInt(scrubberEl.get(0).max)
      val: (newValue) ->
        if newValue?
          scrubberEl.val(newValue)
          currentAnimation.currentFrameIndex(newValue)
          return scrubber
        else
          parseInt(scrubberEl.val())

    nextFrame = ->
      scrubber.val((scrubber.val() + 1) % (scrubber.max() + 1))

    changePlayIcon = (icon) ->
      el = $('.play')

      el.css "background-image", "url(/images/#{icon}.png)"

      if icon == 'pause'
        el.addClass('pause')
      else
        el.removeClass('pause')

    self =
      fps: (newValue) ->
        if newValue?
          fpsEl.val(newValue)
          return self
        else
          parseInt(fpsEl.val())

      pause: ->
        changePlayIcon('play')
        clearInterval(intervalId)
        intervalId = null

      play: ->
        if currentAnimation.frames.length > 0
          intervalId = setInterval(nextFrame, 1000 / self.fps()) unless intervalId
          changePlayIcon('pause')

      scrubber: (val) ->
        scrubber.val(val)

      scrubberMax: (val) ->
        scrubber.max(val)

      stop: ->
        scrubber.val(0)
        clearInterval(intervalId)
        intervalId = null
        changePlayIcon('play')
        currentAnimation.currentFrameIndex(-1)

    return self

  Animation = ->
    tileset = {}

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

    animationEditor.bind 'clearFrames', ->
      animationEditor.find('.frame_sprites').children().remove()

    animationEditor.bind 'loadAnimation', (e, animationIndex) ->
      #load the images for this particular animation

    animationEditor.bind 'removeFrame', (e, frameIndex) ->
      animationEditor.find('.frame_sprites img').eq(frameIndex).remove()

    animationEditor.bind 'updateLastFrame', ->
      spriteSrc = tileset[frames.last()]
      spriteTemplate.tmpl(src: spriteSrc).appendTo(animationEditor.find('.frame_sprites'))

    animationEditor.bind 'updateLastFrameSequence', (e, sequence) ->
      sequence.appendTo(animationEditor.find('.frame_sprites'))

    animationEditor.bind 'updateCurrentAnimationTitle', ->
      animationEditor.find('.player .animation_name').text(currentAnimation.name())

    animationEditor.bind 'updateAnimations', ->
      animationEditor.trigger 'updateCurrentAnimationTitle'
      animationEditor.find('.sequences').children().remove()
      animationEditor.find('.frame_sprites').children().remove()

      animationEditor.find('.player img').remove()
      animationEditor.find('.player').append('<img />')

    animationEditor.bind 'disableSave', ->
      animationEditor.find('.save_sequence, .save_reverse_sequence, .save_animation').attr
        disabled: true
        title: 'Add frames to save'

    animationEditor.bind 'enableSave', ->
      animationEditor.find('.save_sequence, .save_reverse_sequence, .save_animation').removeAttr('disabled').attr('title', 'Save frames')

    clearFrames = ->
      frames.clear()
      animationEditor.trigger 'clearFrames'
      animationEditor.trigger 'disableSave'

    pushSequence = (frameArray) ->
      sequences.push(frameArray)
      animationEditor.trigger 'updateSequence'

    self =
      addFrame: (imgSrc) ->
        frames.push(findTileIndex(imgSrc))
        controls.scrubberMax(frames.length - 1)
        animationEditor.trigger 'updateLastFrame'
        animationEditor.trigger 'enableSave'

      addSequenceToFrames: (index) ->
        sequence = $('<div class="sequence"></div>')

        for spriteIndex in sequences[index]
          spriteSrc = tileset[spriteIndex]

          spriteTemplate.tmpl(src: spriteSrc).appendTo(sequence)
          frames.push(findTileIndex(spriteSrc))
          controls.scrubberMax(frames.length - 1)
          animationEditor.trigger 'updateLastFrameSequence', [sequence]
          animationEditor.trigger 'enableSave'

      addTile: (src) ->
        tileset[Math.uuid(32, 16)] = src
        spritesEl = animationEditor.find('.sprites')
        spriteTemplate.tmpl(src: src).appendTo(spritesEl)

      createSequence: ->
        if frames.length
          pushSequence(frames.copy())
          clearFrames()

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
        controls.scrubberMax(controls.scrubberMax() - 1)

        animationEditor.trigger 'removeFrame', [frameIndex]
        animationEditor.trigger 'disableSave' if frames.length == 0

      updateSelected: (frameIndex) ->
        tilesetIndex = frames[frameIndex]

        animationEditor.find('.frame_sprites img').removeClass('current')

        player = $('.player img')

        if frameIndex == -1
          player.removeAttr('src')
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

    if spritesEl.find('img').length == 0
      for index, src of currentAnimation.tileset
        spriteTemplate.tmpl(src: src).appendTo(spritesEl)

      animationEditor.trigger 'disableSave'

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
    animationEditor.trigger 'updateAnimations'

    updateUI()

  $(document).bind 'keydown', (e) ->
    return unless e.which == 37 || e.which == 39

    index = currentAnimation.currentFrameIndex()
    framesLength = currentAnimation.frames.length

    if e.which == 37
      controls.scrubber((index - 1).mod(framesLength))

    if e.which == 39
      controls.scrubber((index + 1).mod(framesLength))

  animationEditor.find('.sprites img').live
    dblclick: (e) ->
      $this = $(this)

      4.times ->
        currentAnimation.addFrame($this.attr('src'))

      lastClickedSprite = $this

    mousedown: (e) ->
      $this = $(this)
      sprites = []

      if e.shiftKey && lastClickedSprite
        lastIndex = lastClickedSprite.index()
        currentIndex = $this.index()

        if currentIndex > lastIndex
          sprites = animationEditor.find('.sprites img').filter(->
            imgIndex = $(this).index()
            return lastIndex < imgIndex <= currentIndex
          ).get()
        else if currentIndex <= lastIndex
          sprites = animationEditor.find('.sprites img').filter(->
            imgIndex = $(this).index()
            return currentIndex <= imgIndex < lastIndex
          ).get().reverse()
      else
        sprites.push $this

      lastClickedSprite = $this

      for sprite in sprites
        currentAnimation.addFrame($(sprite).attr('src'))

  animationEditor.find('.left .sequence').live
    mousedown: ->
      index = $(this).index()
      currentAnimation.addSequenceToFrames(index)

  animationEditor.find('.frame_sprites img').live
    mousedown: ->
      index = animationEditor.find('.frame_sprites img').index($(this))

      controls.scrubber(index)

  animationEditor.find('.animations h4').live
    mousedown: ->
      $this = $(this)

      index = $this.index()

      currentAnimation = animations[index]

      $this.parent().children().removeClass('selected')
      $this.addClass('selected')

      animationEditor.trigger 'loadAnimation', [index]
      animationEditor.trigger 'updateCurrentAnimationTitle'

  animationEditor.find('.save_sequence').click(currentAnimation.createSequence)

  animationEditor.find('.fps input').change ->
    newValue = $(this).val()

    controls.pause()
    controls.fps(newValue)
    controls.play()

  animationEditor.find('.player .animation_name').liveEdit().live
    change: ->
      $this = $(this)

      prevValue = $this.get(0).defaultValue
      updatedStateName = $this.val()

      currentAnimation.name(updatedStateName)

      animationEditor.find('.animations h4').filter(->
        return $(this).text() == prevValue
      ).text(updatedStateName)

  animationEditor.dropImageReader (file, event) ->
    if event.target.readyState == FileReader.DONE
      src = event.target.result
      name = file.fileName

      [dimensions, tileWidth, tileHeight] = name.match(/x(\d*)y(\d*)/) || []

      if tileWidth && tileHeight
        loadSpriteSheet src, parseInt(tileWidth), parseInt(tileHeight), (sprite) ->
          currentAnimation.addTile(sprite)
      else
        currentAnimation.addTile(src)

  $(document).bind 'keydown', 'del backspace', (e) ->
    e.preventDefault()
    currentAnimation.removeFrame(currentAnimation.currentFrameIndex())
