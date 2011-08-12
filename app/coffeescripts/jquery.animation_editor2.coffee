$.fn.animationEditor = (options) ->
  animationNumber = 1
  tileIndex = 0
  lastClickedSprite = null

  tileset = {}
  tilemap = {}
  sequences = []

  animationEditor = $(this.get(0)).addClass("editor animation_editor")

  templates = $("#animation_editor_templates")
  editorTemplate = templates.find('.editor.template')
  animationTemplate = templates.find('.animation')
  spriteTemplate = templates.find('.sprite')
  frameSpriteTemplate = templates.find('.frame_sprite')

  exportAnimation = ->
    animationData = ({ frames: (tilemap[frame] for frame in animation.frames), name: animation.name() } for animation in animations)

    console.log sequences
    sequenceData = ((tileset[frame] for frame in array) for array in sequences)

    return {
      sequences: sequenceData
      tileset: (tilemap[tileId] for tileSrc, tileId in tileset)
      animations: animationData
    }

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

  addTile = (src) ->
    id = Math.uuid(32, 16)

    tileset[id] = src
    tilemap[id] = tileIndex
    tileIndex += 1
    spritesEl = animationEditor.find('.sprites')
    spriteTemplate.tmpl(src: src).appendTo(spritesEl)

  #UI updating events
  animationEditor.bind
    clearFrames: ->
      $(this).find('.frame_sprites').children().remove()
    currentAnimationTitle: (e, title) ->
      $(this).find('.player .animation_name').text(title)
    disableSave: ->
      $(this).find('.bottom .module_header > button').attr
        disabled: true
        title: 'Add frames to save'
    enableSave: ->
      $(this).find('.bottom .module_header > button').removeAttr('disabled').attr('title', 'Save frames')
    init: ->
      animationsEl = animationEditor.find('.animations')
      animationsEl.children().remove()

      spritesEl = animationEditor.find('.sprites')

      for animation in animations
        animationTemplate.tmpl({stateId: animation.stateId, name: animation.name()}).appendTo(animationsEl)

      if spritesEl.find('img').length == 0
        for index, src of tileset
          spriteTemplate.tmpl(src: src).appendTo(spritesEl)

        animationEditor.trigger 'disableSave'
    removeFrame: (e, frameIndex) ->
      $(this).find('.frame_sprites img').eq(frameIndex).remove()
    loadCurrentAnimation: ->
      $this = $(this)

      $this.trigger 'clearFrames'
      $this.trigger 'currentAnimationTitle', [currentAnimation.name()]
      $this.find('.player img').removeAttr('src')

      currentAnimation.load()
    updateFrame: (e, index) ->
      frameSprites = $(this).find('.frame_sprites')
      spriteSrc = tileset[index]

      frameSpriteTemplate.tmpl(src: spriteSrc).appendTo(frameSprites)
    updateLastFrame: ->
      frameSprites = $(this).find('.frame_sprites')
      spriteSrc = tileset[currentAnimation.frames.last()]

      frameSpriteTemplate.tmpl(src: spriteSrc).appendTo(frameSprites)
    updateLastFrameSequence: (e, sequence) ->
      frameSprites = $(this).find('.frame_sprites')
      sequence.appendTo(frameSprites)
    updateLastSequence: ->
      sequencesEl = $(this).find('.sequences')

      sequenceFrameArray = sequences.last()
      sequence = $('<div class="sequence" />').appendTo(sequencesEl)

      for spriteIndex in sequenceFrameArray
        spriteSrc = tileset[spriteIndex]
        spriteTemplate.tmpl(src: spriteSrc).appendTo(sequence)

      sequence.appendTo(sequencesEl)

  pushSequence = (frameArray) ->
    sequences.push(frameArray)
    animationEditor.trigger 'updateLastSequence'

  createSequence = ->
    if currentAnimation.frames.length
      pushSequence(currentAnimation.frames.copy())
      currentAnimation.clearFrames()

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

        return self

      play: ->
        if currentAnimation.frames.length > 0
          intervalId = setInterval(nextFrame, 1000 / self.fps()) unless intervalId
          changePlayIcon('pause')

        return self

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
    frames = []
    currentFrameIndex = 0
    stateId = Math.uuid(32, 16)

    name = "State #{animationNumber}"
    animationNumber += 1

    findTileIndex = (tileSrc) ->
      for uuid, src of tileset
        return uuid if src == tileSrc

    self =
      addFrame: (imgSrc) ->
        frames.push(findTileIndex(imgSrc))
        controls.scrubberMax(frames.length - 1)
        animationEditor.trigger(event) for event in ['enableSave', 'updateLastFrame']

      addSequenceToFrames: (index) ->
        sequence = $('<div class="sequence" />')

        for spriteIndex in sequences[index]
          spriteSrc = tileset[spriteIndex]

          spriteTemplate.tmpl(src: spriteSrc).appendTo(sequence)
          frames.push(findTileIndex(spriteSrc))
          controls.scrubberMax(frames.length - 1)

        animationEditor.trigger 'updateLastFrameSequence', [sequence]
        animationEditor.trigger 'enableSave'

      clearFrames: ->
        frames.clear()
        animationEditor.trigger(event) for event in ['clearFrames', 'disableSave']

      currentFrameIndex: (val) ->
        if val?
          currentFrameIndex = val
          self.updateSelected(val)
          return self
        else
          return currentFrameIndex

      frames: frames

      stateId: stateId

      load: ->
        for frameIndex in frames
          animationEditor.trigger 'updateFrame', [frameIndex]

        controls.scrubberMax(frames.length - 1)

      name: (val) ->
        if val?
          name = val
          return self
        else
          return name

      removeFrame: (frameIndex) ->
        tilesetIndex = frames[frameIndex]
        frames.splice(frameIndex, 1)
        controls.scrubberMax(controls.scrubberMax() - 1)

        animationEditor.trigger 'removeFrame', [frameIndex]
        animationEditor.trigger 'disableSave' if frames.length == 0

      updateSelected: (frameIndex) ->
        tilesetIndex = frames[frameIndex]

        animationEditor.find('.frame_sprites img').removeClass('selected')

        player = $('.player img')

        if frameIndex == -1
          player.removeAttr('src')
        else
          player.attr('src', tileset[tilesetIndex])
          animationEditor.find('.frame_sprites img').eq(frameIndex).addClass('selected')

    return self

  editorTemplate.tmpl().appendTo(animationEditor)

  controls = Controls()
  currentAnimation = Animation()
  animations = [currentAnimation]

  animationEditor.trigger 'init'
  animationEditor.find('.state_name').addClass('selected')

  animationEditor.find('.play').mousedown ->
    if $(this).hasClass('pause')
      controls.pause()
    else
      controls.play()

  animationEditor.find('.scrubber').change ->
    newValue = $(this).val()

    controls.scrubber(newValue)
    currentAnimation.currentFrameIndex(newValue)

  animationEditor.find('.stop').mousedown ->
    controls.stop()

  animationEditor.find('.new_animation').mousedown ->
    animations.push(Animation())

    currentAnimation = animations.last()

    animationEditor.trigger(event) for event in ['init', 'loadCurrentAnimation']
    animationEditor.find('.animations .state_name:last').takeClass('selected')

  animationEditor.find('.export').mousedown ->
    console.log exportAnimation()

  $(document).bind 'keydown', (e) ->
    return unless e.which == 37 || e.which == 39

    index = currentAnimation.currentFrameIndex()
    framesLength = currentAnimation.frames.length

    keyMapping =
      "37": -1
      "39": 1

    controls.scrubber((index + keyMapping[e.which]).mod(framesLength))

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

        lastClickedSprite = null
      else
        sprites.push $this

        lastClickedSprite = $this

      currentAnimation.addFrame($(sprite).attr('src')) for sprite in sprites

  animationEditor.find('.left .sequence').live
    mousedown: ->
      index = $(this).index()
      currentAnimation.addSequenceToFrames(index)

  animationEditor.find('.frame_sprites img').live
    mousedown: ->
      index = animationEditor.find('.frame_sprites img').index($(this))

      controls.scrubber(index)

  animationEditor.find('.animations .state_name').live
    mousedown: ->
      index = $(this).takeClass('selected').index()

      currentAnimation = animations[index]

      animationEditor.trigger 'loadCurrentAnimation'

  animationEditor.find('.save_sequence').click ->
    createSequence()

  animationEditor.find('.fps input').change ->
    newValue = $(this).val()

    controls.pause().fps(newValue).play()

  animationEditor.find('.player .animation_name').liveEdit().live
    change: ->
      $this = $(this)

      prevValue = $this.get(0).defaultValue
      updatedStateName = $this.val()

      currentAnimation.name(updatedStateName)

      animationEditor.find('.animations .state_name').filter(->
        return $(this).attr('data-state_id') == currentAnimation.stateId
      ).text(updatedStateName)

  animationEditor.dropImageReader (file, event) ->
    if event.target.readyState == FileReader.DONE
      src = event.target.result
      name = file.fileName

      [dimensions, tileWidth, tileHeight] = name.match(/x(\d*)y(\d*)/) || []

      if tileWidth && tileHeight
        loadSpriteSheet src, parseInt(tileWidth), parseInt(tileHeight), (sprite) ->
          addTile(sprite)
      else
        addTile(src)

  $(document).bind 'keydown', 'del backspace', (e) ->
    e.preventDefault()
    currentAnimation.removeFrame(currentAnimation.currentFrameIndex())
