#= require animation/animation
#= require animation/animation_ui

$.fn.animationEditor = ->
  sequenceNumber = 1
  tileIndex = 0
  lastClickedSprite = null
  lastSelectedFrame = null

  tileset = {}
  tilemap = {}
  sequences = []
  clipboard = []

  animationEditor = $(this.get(0)).addClass("editor animation_editor")

  window.exportAnimationCSV = ->
    (for sequenceObject in sequences
      sequenceObject.name + ": " + (tilemap[frame] for frame in sequenceObject.frameArray).join(",")
    ).join("\n")

  window.exportAnimationJSON = ->
    JSON.stringify(
      for sequenceObject in sequences
        {name: sequenceObject.name, frames: (tilemap[frame] for frame in sequenceObject.frameArray)}
    )

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

  Controls = (animationEditor) ->
    intervalId = null

    scrubberMax = 0
    scrubberValue = 0
    fps = 30

    scrubber =
      max: (newMax) ->
        if newMax?
          scrubberMax = newMax
          animationEditor.trigger 'updateScrubberMax', [newMax]
          return scrubber
        else
          return scrubberMax
      val: (newValue) ->
        if newValue?
          scrubberValue = newValue
          animationEditor.trigger 'updateScrubberValue', [newValue]
          animation.currentFrameIndex(newValue)
          return scrubber
        else
          scrubberValue

    nextFrame = ->
      scrubber.val((scrubber.val() + 1) % (scrubber.max() + 1))

    changePlayIcon = (icon) ->
      el = $(".#{icon}")

      el.attr("class", "#{icon} static-#{icon}")

    self =
      fps: (newValue) ->
        if newValue?
          fps = newValue
          animationEditor.trigger 'updateFPS', [newValue]
          return self
        else
          fps

      pause: ->
        changePlayIcon('play')
        clearInterval(intervalId)
        intervalId = null

        return self

      play: ->
        if animation.frames.length > 0
          changePlayIcon('pause')
          intervalId = setInterval(nextFrame, 1000 / self.fps()) unless intervalId

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
        animation.currentFrameIndex(-1)

    return self

  addTile = (src) ->
    id = Math.uuid(32, 16)

    tileset[id] = src
    tilemap[id] = tileIndex
    tileIndex += 1
    animationEditor.trigger 'addTile', [src]

  window.findSequence = (uuid) ->
    for sequence in sequences
      return sequence if sequence.id == uuid

  removeSequence = (sequenceIndex) ->
    sequences.splice(sequenceIndex, 1)
    animationEditor.trigger 'removeSequence', [sequenceIndex]
    animationEditor.trigger "disableExport" if sequences.length == 0

  pushSequence = (frameArray) ->
    sequenceId = Math.uuid(32, 16)

    sequences.push({id: sequenceId, name: "sequence#{sequenceNumber++}", frameArray: frameArray})
    animationEditor.trigger 'updateSequence'
    animationEditor.trigger 'enableExport'

  shiftSequenceFrame = (sequenceId, frameIndex, shiftAmount) ->
    elementToShift = removeSequenceFrame(sequenceId, frameIndex)
    sequence = findSequence(sequenceId)

    sequence.frameArray.splice((frameIndex + shiftAmount).mod(sequences.length), 0, elementToShift)

  removeSequenceFrame = (sequenceId, frameIndex) ->
    sequence = findSequence(sequenceId)
    sequence.frameArray.splice(frameIndex, 1).first()

  createSequence = ->
    if animation.frames.length
      pushSequence(animation.frames.copy())
      animation.clearFrames()

  controls = Controls(animationEditor)
  animation = Animation(tileset, controls, animationEditor, sequences)
  ui = AnimationUI(animationEditor, animation, tileset, sequences)

  $(document).bind 'keydown', (e) ->
    return unless e.which == 37 || e.which == 39

    index = animation.currentFrameIndex()
    framesLength = animation.frames.length

    keyMapping =
      "37": -1
      "39": 1

    controls.scrubber((index + keyMapping[e.which]).mod(framesLength))

  changeEvents =
    '.fps input': (e) ->
      newValue = $(this).val()

      controls.pause().fps(newValue).play()
    '.scrubber': (e) ->
      newValue = $(this).val()

      controls.scrubber(newValue)
      animation.currentFrameIndex(newValue)

  for key, value of changeEvents
    animationEditor.find(key).change(value)

  mousedownEvents =
    '.play': (e) ->
      if $(this).hasClass('pause')
        controls.pause()
      else
        controls.play()
    '.stop': (e) ->
      controls.stop()

  for key, value of mousedownEvents
    animationEditor.find(key).mousedown(value)

  liveMousedownEvents =
    '.edit_sequences': (e) ->
      $this = $(this)
      text = $this.text()

      $this.text(if text == "Edit" then "Done" else "Edit")

      if text == "Edit"
        img = $ '<div />'
          class: 'x static-x'


        $('.right .sequence').append(img).addClass('edit')
      else
        $('.right .sequence').removeClass('edit')
        $('.right .x').remove()
    '.frame_sprites img, .frame_sprites .placeholder': (e) ->
      if e.shiftKey && lastSelectedFrame
        lastIndex = animationEditor.find('.frame_sprites img, .frame_sprites .placeholder').index(lastSelectedFrame)
        currentIndex = animationEditor.find('.frame_sprites img, .frame_sprites .placeholder').index($(this))

        if currentIndex > lastIndex
          sprites = animationEditor.find('.frame_sprites img, .frame_sprites .placeholder').filter ->
            imgIndex = animationEditor.find('.frame_sprites img, .frame_sprites .placeholder').index($(this))
            return lastIndex < imgIndex <= currentIndex
        else if currentIndex <= lastIndex
          sprites = animationEditor.find('.frame_sprites img, .frame_sprites .placeholder').filter ->
            imgIndex = animationEditor.find('.frame_sprites img, .frame_sprites .placeholder').index($(this))
            return currentIndex <= imgIndex < lastIndex

        sprites.addClass('selected')
        lastSelectedFrame = $(this)
      else
        index = animationEditor.find('.frame_sprites .placeholder, .frame_sprites img').index($(this))

        controls.scrubber(index)

        lastSelectedFrame = $(this)
    '.right .sequence.edit': (e) ->
      index = $(this).index()
      sequenceId = $(this).attr('data-id')
      sequence = sequences[index]

      $('.edit_sequence_modal img').remove()

      for uuid in sequence.frameArray
        animationEditor.trigger "addFrameToSequenceEditModal", [tileset[uuid]]

      $('.edit_sequence_modal').attr('data-id', sequenceId)
      $('.edit_sequence_modal').modal()
    '.right .sequence': (e) ->
      return if $(e.target).is('.name')
      return if $(e.target).hasClass('edit') || $(e.target).parent().hasClass('edit')

      index = $(this).index()

      animation.addSequenceToFrames(index)
    '.right .x': (e) ->
      e.stopPropagation()
      removeSequence $(this).parent().index()
    '.sprites img': (e) ->
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

      index =
        if (lastSelected = animationEditor.find('.frame_sprites .selected:last')).length
          animationEditor.find('.frame_sprites img').index(lastSelected)
        else
          null

      animation.addFrame($(sprite).attr('src'), index) for sprite in sprites

  for key, value of liveMousedownEvents
    animationEditor.find(key).live
      mousedown: value

  clickEvents =
    '.save_sequence': (e) ->
      createSequence()
    '.clear_frames': (e) ->
      animation.clearFrames()
      controls.stop()

  for key, value of clickEvents
    animationEditor.find(key).click(value)

  animationEditor.find('.sequences .name').liveEdit().live
    change: ->
      $this = $(this)

      updatedName = $this.val()
      sequenceId = $this.parent().attr('data-id')

      findSequence(sequenceId).name = updatedName

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

  keybindings =
    "del backspace": (e) ->
      e.preventDefault()

      selectedFrames = animationEditor.find('.frame_sprites .selected')
      selectedSequenceFrames = $('.edit_sequence_modal img.selected')

      if selectedFrames.length
        for frame in selectedFrames
          index = animationEditor.find('.frame_sprites img, .frame_sprites .placeholder').index(frame)
          animation.removeFrame(index)
      else if selectedSequenceFrames.length
        for frame in selectedSequenceFrames
          index = $('.edit_sequence_modal img').index(frame)
          sequenceId = $('.edit_sequence_modal').attr('data-id')
          removeSequenceFrame(sequenceId, index)
          animationEditor.trigger "updateSequence", [sequenceId]
          $(frame).remove()
    "1 2 3 4 5 6 7 8 9": (e) ->
      return unless lastClickedSprite

      keyOffset = 48

      index = if (lastSelected = animationEditor.find('.frame_sprites .selected:last')).length then animationEditor.find('.frame_sprites img').index(lastSelected) else null

      (e.which - keyOffset).times ->
        animation.addFrame(lastClickedSprite.get(0).src, index)
    "ctrl+c, meta+c": (e) ->
      e.preventDefault()

      if (selectedSprites = animationEditor.find('.frame_sprites .selected')).length
        clipboard = selectedSprites
    "ctrl+x, meta+x": (e) ->
      e.preventDefault()

      if (selectedSprites = animationEditor.find('.frame_sprites .selected')).length
        clipboard = selectedSprites

      for frame in selectedSprites
        index = animationEditor.find('.frame_sprites img, .frame_sprites .placeholder').index(frame)
        animation.removeFrame(index)
    "ctrl+v, meta+v": (e) ->
      e.preventDefault()

      index = if (lastSelected = animationEditor.find('.frame_sprites .selected:last')).length then animationEditor.find('.frame_sprites img').index(lastSelected) else null

      if clipboard.length
        for frame in clipboard
          animation.addFrame($(frame).attr('src'), index + 1)

  for keybinding, handler of keybindings
    $(document).bind 'keydown', keybinding, handler

  animationEditor.trigger 'init'
