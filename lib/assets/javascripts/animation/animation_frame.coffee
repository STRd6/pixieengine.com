(exports ? this)["AnimationFrame"] = (tileset, controls, animationEditor, sequences) ->
  currentFrameIndex = 0
  frames = []

  findUUID = (tileSrc) ->
    for uuid, src of tileset
      return uuid if src == tileSrc

  self =
    addImage: (imgSrc, index) ->
      index ||= self.flatten().length

      uuid = findUUID(imgSrc)

      frames.splice(index, 0, uuid)

      if index == 0
        animationEditor.trigger 'appendFrameSprite', [uuid]
      else
        animationEditor.trigger 'insertFrameSpriteAfter', [uuid, index - 1]

      controls.scrubberMax(self.flatten().length - 1)

    addSequence: (sequenceIndex) ->
      sequence = sequences[sequenceIndex]
      {id, name, frameArray} = sequence

      sequenceEl = $("<div class='sequence' data-id='#{id}' />").append($("<span class='name'>#{name}</span>"))

      (frameArray.length - 1).times ->
        $("<div class='placeholder' />").appendTo(sequenceEl)

      frames.push(sequence)

      controls.scrubberMax(self.flatten().length - 1)

      spriteSrc = tileset[frameArray.last()]

      $("#animation_editor_templates").find('.sprite').tmpl(src: spriteSrc).appendTo(sequenceEl)
      animationEditor.trigger 'updateLastFrameSequence', [sequenceEl]

    clear: ->
      frames.clear()
      animationEditor.trigger(event) for event in ['clearFrames', 'disableSave']

    currentIndex: (val) ->
      if val?
        currentFrameIndex = val
        animationEditor.trigger 'currentFrame', [currentFrameIndex, tileset[frames[currentFrameIndex]]]

        return self
      else
        return currentFrameIndex

    empty: ->
      frames.length == 0

    flatten: ->
      (frame.frameArray || frame for frame in frames).flatten()

    frames: frames

    length: ->
      frames.length

    remove: (frameIndex) ->
      frames.splice(frameIndex, 1)
      controls.scrubberMax(controls.scrubberMax() - 1)

      animationEditor.trigger 'removeFrame', [frameIndex]
  return self
