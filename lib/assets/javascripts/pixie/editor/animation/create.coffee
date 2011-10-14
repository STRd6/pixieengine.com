#= require undo_stack
#= require_tree .

#= require tmpls/editors/animation
#= require tmpls/lebenmeister/help_tips

(($) ->
  Pixie.Editor.Animation.create = ->
    sequenceNumber = 1
    tileIndex = 0
    lastClickedSprite = null
    lastSelectedFrame = null
    editedSequence = null

    tileset = {}
    tilemap = {}
    sequences = []
    clipboard = []

    lebenmeister = $.tmpl("editors/animation")
    lebenmeisterEditor = $(lebenmeister[0])

    window.exportAnimationCSV = ->
      (for sequenceObject in sequences
        sequenceObject.name + ": " + (tilemap[frame] for frame in sequenceObject.frameArray).join(",")
      ).join("\n")

    window.exportAnimationJSON = ->
      JSON.stringify(
        for sequenceObject in sequences
          {name: sequenceObject.name, frames: (tilemap[frame] for frame in sequenceObject.frameArray)}
      )

    window.lastSelectedIndex = ->
      if (lastSelected = lebenmeisterEditor.find('.frame_sprite .selected:last')).length
        return lebenmeisterEditor.find('.frame_sprites img').index(lastSelected)
      else
        null

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

    Controls = (lebenmeisterEditor) ->
      intervalId = null

      scrubberMax = 0
      scrubberValue = 0
      fps = 30

      advanceFrame = ->
        self.scrubberVal((self.scrubberVal() + 1) % (self.scrubberMax() + 1))

      self =
        fps: (newValue) ->
          if newValue?
            fps = newValue
            lebenmeisterEditor.trigger 'fps', [newValue]
            return self
          else
            fps

        pause: ->
          lebenmeisterEditor.find('.controls').children().first().attr("class", "play static-play")

          clearInterval(intervalId)
          intervalId = null

          return self

        play: ->
          unless animationFrame.isEmpty()
            lebenmeisterEditor.find('.controls').children().first().attr("class", "pause static-pause")
            intervalId = setInterval(advanceFrame, 1000 / self.fps()) unless intervalId

          return self

        scrubberVal: (newValue) ->
          if newValue?
            scrubberValue = newValue
            lebenmeisterEditor.trigger 'scrubberValue', [newValue]
            animationFrame.currentIndex(newValue)
            return self
          else
            scrubberValue

        scrubberMax: (newMax) ->
          if newMax?
            scrubberMax = newMax
            lebenmeisterEditor.trigger 'scrubberMax', [newMax]
            return self
          else
            return scrubberMax

        stop: ->
          self.scrubberVal(0)
          clearInterval(intervalId)
          intervalId = null
          lebenmeisterEditor.find('.controls').children().first().attr("class", "play static-play")
          animationFrame.currentIndex(-1)

          return self

      return self

    addTile = (src) ->
      id = Math.uuid(32, 16)

      tileset[id] = src
      tilemap[id] = tileIndex
      tileIndex += 1
      lebenmeisterEditor.trigger 'addTile', [src]

    findSequence = (id) ->
      for sequence in sequences
        return sequence if sequence.id == id

    removeSequence = (sequenceIndex) ->
      sequence = sequences.splice(sequenceIndex, 1).first()
      lebenmeisterEditor.trigger 'removeSequence', [sequence]

      if sequences.length == 0
        lebenmeisterEditor.trigger "disableExport"
        lebenmeisterEditor.trigger "disableSequenceEdit"
        lebenmeisterEditor.find('.edit_sequences').mousedown()

    pushSequence = (frameArray) ->
      id = Math.uuid(32, 16)

      sequences.push({id: editedSequence?.id || id, name: editedSequence?.name || "sequence#{sequenceNumber++}", frameArray: frameArray})

      editedSequence = null if editedSequence
      lastSequence = sequences.last()
      lastFrameId = lastSequence.frameArray.last()

      lebenmeisterEditor.trigger event for event in ['enableExport', 'enableSequenceEdit']
      lebenmeisterEditor.trigger 'createSequence', [lastSequence, tileset[lastFrameId]]

    createSequence = (frames) ->
      unless animationFrame.isEmpty()
        pushSequence(frames)
        animationFrame.clear()

    controls = Controls(lebenmeisterEditor)
    animationFrame = AnimationFrame(lebenmeisterEditor, tileset, controls)
    AnimationUI(lebenmeisterEditor)

    $(document).bind 'keydown', (e) ->
      return unless e.which == 37 || e.which == 39
      return if $(e.target).is('input')

      index = animationFrame.currentIndex()
      framesLength = animationFrame.flatten().length

      keyMapping =
        "37": -1
        "39": 1

      controls.scrubberVal((index + keyMapping[e.which]).mod(framesLength))

    changeEvents =
      '.fps input': (e) ->
        newValue = $(this).val()

        controls.pause().fps(newValue).play()
      '.scrubber': (e) ->
        newValue = $(this).val()

        controls.scrubberVal(newValue)
        animationFrame.currentIndex(newValue)

    for key, value of changeEvents
      lebenmeisterEditor.find(key).change(value)

    mousedownEvents =
      '.play': (e) ->
        if $(this).hasClass('pause')
          controls.pause()
        else
          controls.play()
      '.stop': (e) ->
        controls.stop()

    for key, value of mousedownEvents
      lebenmeisterEditor.find(key).mousedown(value)

    liveMousedownEvents =
      '.edit_sequences': (e) ->
        $this = $(this)
        text = $this.text()

        $this.toggleClass('active')

        if $this.hasClass('active')
          img = $ '<div />'
            class: 'x static-x'

          $('.right .sequence').append(img).addClass('edit')
        else
          $('.right .sequence').removeClass('edit')
          $('.right .x').remove()
      '.frame_sprites img, .frame_sprites .placeholder': (e) ->
        if e.shiftKey && lastSelectedFrame
          lastIndex = lebenmeisterEditor.find('.frame_sprites img, .frame_sprites .placeholder').index(lastSelectedFrame)
          currentIndex = lebenmeisterEditor.find('.frame_sprites img, .frame_sprites .placeholder').index($(this))

          if currentIndex > lastIndex
            sprites = lebenmeisterEditor.find('.frame_sprites img, .frame_sprites .placeholder').filter ->
              imgIndex = lebenmeisterEditor.find('.frame_sprites img, .frame_sprites .placeholder').index($(this))
              return lastIndex < imgIndex <= currentIndex
          else if currentIndex <= lastIndex
            sprites = lebenmeisterEditor.find('.frame_sprites img, .frame_sprites .placeholder').filter ->
              imgIndex = lebenmeisterEditor.find('.frame_sprites img, .frame_sprites .placeholder').index($(this))
              return currentIndex <= imgIndex < lastIndex

          sprites.addClass('selected')
          lastSelectedFrame = $(this)
        else
          frameElement = lebenmeisterEditor.find('.frame_sprites .placeholder, .frame_sprites img')

          if (parent = frameElement.parent()).hasClass('sequence')
            parent.addClass('selected')

          index = frameElement.index($(this))

          controls.scrubberVal(index)

          lastSelectedFrame = $(this)
      '.help': (e) ->
        $(this).addClass('active')
        $.tmpl('lebenmeister/help_tips').modal
          onClose: ->
            lebenmeisterEditor.find('.help').removeClass('active')
            $.modal.close()
      '.right .sequence.edit': (e) ->
        index = $(this).index()
        sequence = sequences[index]
        editedSequence = {id: sequence.id, name: sequence.name}

        # crush the frames for now. In the
        # future keep track of their frames
        animationFrame.clear()

        for uuid in sequence.frameArray
          if index = lastSelectedIndex()
            animationFrame.addImageAfter(tileset[uuid], index)
            lastSelectedFrame = tileset[uuid]
          else
            animationFrame.appendImage(tileset[uuid])

        removeSequence(index)

      '.right .sequence': (e) ->
        return if $(e.target).is('.name')
        return if $(e.target).hasClass('edit') || $(e.target).parent().hasClass('edit')

        index = $(this).index()

        animationFrame.addSequence(sequences[index])
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
            # lastIndex + 1 because you've already added it
            sprites = lebenmeisterEditor.find('.sprites img').slice(lastIndex + 1, currentIndex + 1).get()
          else if currentIndex < lastIndex
            # you've already added the last index
            sprites = lebenmeisterEditor.find('.sprites img').slice(currentIndex, lastIndex).get().reverse()

          lastClickedSprite = null
        else
          sprites.push $this

          lastClickedSprite = $this

        for sprite in sprites
          if index = lastSelectedIndex()
            animationFrame.addImageAfter($(sprite).attr('src'), index)
            lastSelectedFrame = $(sprite)
          else
            animationFrame.appendImage($(sprite).attr('src'))

    for key, value of liveMousedownEvents
      lebenmeisterEditor.find(key).live
        mousedown: value

    clickEvents =
      '.create_sequence': (e) ->
        createSequence(animationFrame.flatten())
      '.clear_frames': (e) ->
        animationFrame.clear()
        controls.stop()

    for key, value of clickEvents
      lebenmeisterEditor.find(key).click(value)

    lebenmeisterEditor.find('.sequences .name').liveEdit().live
      change: ->
        $this = $(this)

        updatedName = $this.val()
        sequenceId = $this.parent().attr('data-id')

        sequence = findSequence(sequenceId)
        sequence.name = updatedName

        lastFrameId = sequence.frameArray.last()

        lebenmeisterEditor.trigger 'updateSequence', [sequence, tileset[lastFrameId]]

    lebenmeisterEditor.dropImageReader (file, event) ->
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
        return if $(e.target).is('input')
        e.preventDefault()

        selectedFrames = lebenmeisterEditor.find('.frame_sprite .selected')

        if selectedFrames.length
          for frame in selectedFrames
            index = lebenmeisterEditor.find('.frame_sprites img, .frame_sprites .placeholder').index(frame)
            animationFrame.remove(index)
      "1 2 3 4 5 6 7 8 9": (e) ->
        return unless lastClickedSprite
        return if $(e.target).is('input')

        keyOffset = 48

        index = lastSelectedIndex()

        (e.which - keyOffset).times ->
          if index = lastSelectedIndex()
            animationFrame.addImageAfter(lastClickedSprite.get(0).src, index)
            lastSelectedFrame = lastClickedSprite.get(0).src
          else
            animationFrame.appendImage(lastClickedSprite.get(0).src)

      "ctrl+s, meta+s": (e) ->
        e.preventDefault()

        lebenmeisterEditor.find('.create_sequence').click()
      "ctrl+c, meta+c": (e) ->
        e.preventDefault()

        if (selectedSprites = lebenmeisterEditor.find('.frame_sprite .selected')).length
          if selectedSprites.index(lastSelectedFrame) == 0
            clipboard = selectedSprites.get().reverse()
          else
            clipboard = selectedSprites.get()
      "ctrl+x, meta+x": (e) ->
        e.preventDefault()

        if (selectedSprites = lebenmeisterEditor.find('.frame_sprite .selected')).length
          if selectedSprites.index(lastSelectedFrame) == 0
            clipboard = selectedSprites.get().reverse()
          else
            clipboard = selectedSprites.get()

        for frame in selectedSprites
          index = lebenmeisterEditor.find('.frame_sprites img, .frame_sprites .placeholder').index(frame)
          animationFrame.remove(index)
      "ctrl+v, meta+v": (e) ->
        e.preventDefault()

        if clipboard.length
          for frame in clipboard
            if index = lastSelectedIndex()
              animationFrame.addImageAfter($(frame).attr('src'), index)
              lastSelectedFrame = $(frame)
            else
              animationFrame.appendImage($(frame).attr('src'))

    for keybinding, handler of keybindings
      $(document).bind 'keydown', keybinding, handler

    return lebenmeisterEditor
)(jQuery)
