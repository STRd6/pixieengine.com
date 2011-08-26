window.Animation = (animationNumber, tileset, controls, animationEditor, sequences) ->
  frames = []
  currentFrameIndex = 0
  stateId = Math.uuid(32, 16)

  name = "State #{animationNumber}"

  findTileIndex = (tileSrc) ->
    for uuid, src of tileset
      return uuid if src == tileSrc

  self =
    addFrame: (imgSrc) ->
      frames.push(findTileIndex(imgSrc))
      controls.scrubberMax(frames.length - 1)
      animationEditor.trigger(event) for event in ['checkExportStatus', 'enableSave', 'updateLastFrame']

    addSequenceToFrames: (index) ->
      sequence = $('<div class="sequence" />')

      for spriteIndex in sequences[index]
        spriteSrc = tileset[spriteIndex]

        spriteTemplate.tmpl(src: spriteSrc).appendTo(sequence)
        frames.push(findTileIndex(spriteSrc))
        controls.scrubberMax(frames.length - 1)

      animationEditor.trigger 'updateLastFrameSequence', [sequence]
      animationEditor.trigger 'enableSave'
      animationEditor.trigger 'checkExportStatus'

    clearFrames: ->
      frames.clear()
      animationEditor.trigger(event) for event in ['checkExportStatus', 'clearFrames', 'disableSave']

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
      frames.splice(frameIndex, 1)
      controls.scrubberMax(controls.scrubberMax() - 1)

      animationEditor.trigger 'removeFrame', [frameIndex]
      animationEditor.trigger 'disableSave' if frames.length == 0
      animationEditor.trigger 'checkExportStatus'

    removeFrameSequence: (sequenceIndex) ->
      sequenceImages = animationEditor.find('.frame_sprites .sequence').eq(sequenceIndex).children().not('.x')

      for image in sequenceImages
        index = $(image).index('.frame_sprites img')
        self.removeFrame(index)

    updateSelected: (frameIndex) ->
      tilesetIndex = frames[frameIndex]

      animationEditor.find('.frame_sprites img').removeClass('selected')

      player = $('.player img')

      if frameIndex == -1
        player.removeAttr('src')
      else
        player.attr('src', tileset[tilesetIndex])
        animationEditor.find('.frame_sprites img:not(.x)').eq(frameIndex).addClass('selected')

  return self
