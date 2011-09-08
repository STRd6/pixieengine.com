(exports ? this)["AnimationUI"] = (animationEditor, animation, tileset, sequences) ->
  templates = $("#animation_editor_templates")
  editorTemplate = templates.find('.editor.template')
  spriteTemplate = templates.find('.sprite')
  frameSpriteTemplate = templates.find('.frame_sprite')
  editSequenceModal = templates.find('.edit_sequence_modal')

  animationEditor.bind
    addFrameToSequenceEditModal: (e, spriteSrc) ->
      spriteTemplate.tmpl(src: spriteSrc).appendTo('.edit_sequence_modal')
    appendFrameSprite: (e, uuid) ->
      frameSprites = $(this).find('.frame_sprites')
      spriteSrc = tileset[uuid]

      frameSprites.append(frameSpriteTemplate.tmpl(src: spriteSrc))

      animationEditor.trigger 'enableSave'
    addTile: (e, src) ->
      spritesEl = $(this).find('.sprites')
      spriteTemplate.tmpl(src: src).appendTo(spritesEl)
    clearFrames: ->
      $(this).find('.frame_sprites').children().remove()
    createSequence: ->
      sequence = sequences.last()
      {frameArray, id, name} = sequence

      sequencesEl = $(this).find('.sequences')
      sequenceEl = $("<div class='sequence' data-id='#{id}' />").append($("<span class='name'>#{name}</span>"))

      (frameArray.length - 1).times ->
        $("<div class='placeholder' />").appendTo(sequenceEl)

      spriteIndex = frameArray.last()
      spriteSrc = tileset[spriteIndex]

      spriteTemplate.tmpl(src: spriteSrc).appendTo(sequenceEl)
      sequenceEl.appendTo(sequencesEl)
    currentFrame: (e, frameIndex, tileSrc) ->
      animationEditor.find('.frame_sprites .placeholder, .frame_sprites img').removeClass('selected')

      player = $('.player img')

      if frameIndex == -1
        player.removeAttr('src')
      else
        player.attr('src', tileSrc)
        animationEditor.find('.frame_sprites .placeholder, .frame_sprites img').eq(frameIndex).addClass('selected')
    disableExport: ->
      exportButtons = $(this).find('.player button:not(.help)')
      exportButtons.attr({ disabled: true, title: 'Create a sequence to export' })
    disableSave: ->
      $this = $(this)

      $this.find('.create_sequence').attr({ disabled: true, title: "Add frames to create a sequence" })
      $this.find('.clear_frames').attr({ disabled: true, title: "There are no frames to clear" })
    enableExport: ->
      exportButtons = $(this).find('.player button:not(.help)')
      exportButtons.removeAttr('disabled').attr('title', 'Export animation')
    enableSave: ->
      $this = $(this)

      $this.find('.create_sequence').removeAttr('disabled').attr('title', 'Create a sequence')
      $this.find('.clear_frames').removeAttr('disabled').attr('title', 'Clear frames')
    insertFrameSpriteAfter: (e, uuid, index) ->
      frameSprites = $(this).find('.frame_sprites')
      spriteSrc = tileset[uuid]

      placeholderOrImage = frameSprites.find('.placeholder, img').eq(index)

      frameSpriteTemplate.tmpl(src: spriteSrc).insertAfter(placeholderOrImage.parent())

      animationEditor.trigger 'enableSave'
    removeFrame: (e, frameIndex) ->
      if (frame = $(this).find('.frame_sprites img, .frame_sprites .placeholder').eq(frameIndex).parent()).hasClass('frame_sprite')
        frame.remove()
    removeSequence: (e, sequence) ->
      $(this).find('.sequence').filter(->
        return $(this).attr('data-id') == sequence.id
      ).remove()
    fps: (e, newValue) ->
      animationEditor.find('.fps input').val(newValue)
    updateFrame: (e, index) ->
      frameSprites = $(this).find('.frame_sprites')
      spriteSrc = tileset[index]

      frameSpriteTemplate.tmpl(src: spriteSrc).appendTo(frameSprites)
    updateLastFrameSequence: (e, sequence) ->
      frameSprites = $(this).find('.frame_sprites')
      sequence.appendTo(frameSprites)

      animationEditor.trigger(event) for event in ['enableSave', 'checkExportStatus']
    updateSequence: (e, sequence) ->
      {frameArray, id, name} = sequence

      sequencesEl = $(this).find('.sequences')
      sequenceEl = $("<div class='sequence' data-id='#{id}' />").append($("<span class='name'>#{name}</span>"))

      (frameArray.length - 1).times ->
        $("<div class='placeholder' />").appendTo(sequenceEl)

      spriteIndex = frameArray.last()
      spriteSrc = tileset[spriteIndex]

      spriteTemplate.tmpl(src: spriteSrc).appendTo(sequenceEl)

      matches = animationEditor.find('.sequence').filter ->
        return $(this).attr('data-id') == id

      for match in matches
        $(match).replaceWith(sequenceEl.clone())
    scrubberMax: (e, newMax) ->
      scrubberEl = animationEditor.find('.scrubber')
      scrubberEl.get(0).max = newMax
    scrubberValue: (e, newValue) ->
      scrubberEl = animationEditor.find('.scrubber')
      scrubberEl.val(newValue)

  editorTemplate.tmpl().appendTo(animationEditor)
