(exports ? this)["Animation"] = (animationNumber, tileset, controls, animationEditor, sequences) ->
  frames = []
  currentFrameIndex = 0
  stateId = Math.uuid(32, 16)

  name = "State #{animationNumber}"

  findUUID = (tileSrc) ->
    for uuid, src of tileset
      return uuid if src == tileSrc

  self =
    addFrame: (imgSrc, index) ->
      index ||= frames.length

      uuid = findUUID(imgSrc)

      frames.splice(index, 0, uuid)
      animationEditor.trigger 'updateFrameSprite', [uuid, index]

      controls.scrubberMax(frames.length - 1)

    addSequenceToFrames: (index) ->
      sequence = $('<div class="sequence" />')

      (sequences[index].frameArray.length - 1).times ->
        $("<div class='placeholder' />").appendTo(sequence)

      for spriteIndex in sequences[index].frameArray
        spriteSrc = tileset[spriteIndex]

        frames.push(findUUID(spriteSrc))
        controls.scrubberMax(frames.length - 1)

      spriteSrc = tileset[sequences[index].frameArray.last()]

      animationEditor.trigger 'addSpriteToSequence', [spriteSrc, sequence]
      animationEditor.trigger 'updateLastFrameSequence', [sequence]

    clearFrames: ->
      frames.clear()
      animationEditor.trigger(event) for event in ['checkExportStatus', 'clearFrames', 'disableSave']

    currentFrameIndex: (val) ->
      if val?
        currentFrameIndex = val
        animationEditor.trigger 'updateSelected', [currentFrameIndex, tileset[frames[currentFrameIndex]]]

        return self
      else
        return currentFrameIndex

    frames: frames

    stateId: stateId

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

  return self
