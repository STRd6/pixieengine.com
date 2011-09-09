(exports ? this)["AnimationFrame"] = (animationEditor, tileset, controls) ->
  currentIndex = 0
  frames = []

  findUUID = (tileSrc) ->
    for uuid, src of tileset
      return uuid if src == tileSrc

  self =
    addImage: (imgSrc, index) ->
      index ||= self.flatten().length

      uuid = findUUID(imgSrc)

      frames.splice(index + 1, 0, uuid)

      console.log frames

      if index == 0
        animationEditor.trigger 'appendFrameSprite', [tileset[uuid]]
      else
        animationEditor.trigger 'insertFrameSpriteAfter', [tileset[uuid], index - 1]

      controls.scrubberMax(self.flatten().length - 1)

    addSequence: (sequence) ->
      {id, name, frameArray} = sequence

      sequenceEl = $("<div class='sequence' data-id='#{id}' />").append($("<span class='name'>#{name}</span>"))

      (frameArray.length - 1).times ->
        $("<div class='placeholder' />").appendTo(sequenceEl)

      frames.push(sequence)

      controls.scrubberMax(self.flatten().length - 1)

      spriteSrc = tileset[frameArray.last()]

      $("#animation_editor_templates").find('.sprite').tmpl(src: spriteSrc).appendTo(sequenceEl)
      animationEditor.trigger 'appendSequenceToFrames', [sequenceEl]

    clear: ->
      frames.clear()
      animationEditor.trigger(event) for event in ['clearFrames', 'disableSave']

    currentIndex: (val) ->
      if val?
        currentIndex = val
        flattenedFrames = self.flatten()
        tileSrc = tileset[flattenedFrames[currentIndex]]

        animationEditor.trigger 'currentFrame', [currentIndex, tileSrc]

        return self
      else
        return currentIndex

    isEmpty: ->
      frames.length == 0

    flatten: ->
      (frame.frameArray || frame for frame in frames).flatten()

    remove: (frameIndex) ->
      frames.splice(frameIndex, 1)
      controls.scrubberMax(controls.scrubberMax() - 1)

      animationEditor.trigger 'removeFrame', [frameIndex]
  return self
