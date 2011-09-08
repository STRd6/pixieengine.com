(exports ? this)["Animation"] = (tileset, controls, animationEditor, sequences) ->
  frames = []
  currentFrameIndex = 0

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

    addSequenceToFrames: (sequenceIndex) ->
      sequence = sequences[sequenceIndex]
      {id, name, frameArray} = sequence

      sequenceEl = $("<div class='sequence' data-id='#{id}' />").append($("<span class='name'>#{name}</span>"))

      (frameArray.length - 1).times ->
        $("<div class='placeholder' />").appendTo(sequenceEl)

      frames.push(sequence)

      #controls.scrubberMax(frames.length - 1)

      spriteSrc = tileset[frameArray.last()]

      # gross, this first ui call has side effects that modify sequenceEl
      animationEditor.trigger 'addSpriteToSequence', [spriteSrc, sequenceEl]
      animationEditor.trigger 'updateLastFrameSequence', [sequenceEl]

    clearFrames: ->
      frames.clear()
      animationEditor.trigger(event) for event in ['clearFrames', 'disableSave']

    currentFrameIndex: (val) ->
      if val?
        currentFrameIndex = val
        animationEditor.trigger 'updateSelected', [currentFrameIndex, tileset[frames[currentFrameIndex]]]

        return self
      else
        return currentFrameIndex

    frames: frames

    removeFrame: (frameIndex) ->
      frames.splice(frameIndex, 1)
      controls.scrubberMax(controls.scrubberMax() - 1)

      animationEditor.trigger 'removeFrame', [frameIndex]
  return self
