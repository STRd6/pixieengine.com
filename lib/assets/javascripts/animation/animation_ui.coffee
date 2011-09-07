(exports ? this)["AnimationUI"] = (animationEditor, animation, tileset, sequences) ->
  templates = $("#animation_editor_templates")
  editorTemplate = templates.find('.editor.template')
  spriteTemplate = templates.find('.sprite')
  frameSpriteTemplate = templates.find('.frame_sprite')
  editSequenceModal = templates.find('.edit_sequence_modal')

  $('.edit_sequence_modal img').live
    mousedown: (e) ->
      $(this).toggleClass('selected')

  animationEditor.bind
    addFrameToSequenceEditModal: (e, spriteSrc) ->
      spriteTemplate.tmpl(src: spriteSrc).appendTo('.edit_sequence_modal')
    addSpriteToSequence: (e, spriteSrc, sequence) ->
      spriteTemplate.tmpl(src: spriteSrc).appendTo(sequence)
    addTile: (e, src) ->
      spritesEl = $(this).find('.sprites')
      spriteTemplate.tmpl(src: src).appendTo(spritesEl)
    checkExportStatus: ->
      framesEmpty = true

      if animation.frames.length > 0 || sequences.length > 0
        framesEmpty = false

      exportButtons = $(this).find('.player button')

      exportButtons.removeAttr('disabled').attr('title', 'Export animation')
      exportButtons.attr({ disabled: true, title: 'Add frames to export'}) if framesEmpty
    clearFrames: ->
      $(this).find('.frame_sprites').children().remove()
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

      if spritesEl.find('img').length == 0
        for index, src of tileset
          spriteTemplate.tmpl(src: src).appendTo(spritesEl)

        animationEditor.trigger 'disableSave'
        animationEditor.trigger 'checkExportStatus'
    removeFrame: (e, frameIndex) ->
      if (frame = $(this).find('.frame_sprites img, .frame_sprites .placeholder').eq(frameIndex).parent()).hasClass('frame_sprite')
        frame.remove()

      if (parent = $(this).find('.frame_sprites img, .frame_sprites .placeholder').eq(frameIndex).parent()).hasClass('sequence')
        $(this).find('.frame_sprites img, .frame_sprites .placeholder').eq(frameIndex).remove()

        if parent.children().not('.x').length == 0
          parent.remove()

    removeSequence: (e, sequenceIndex) ->
      $(this).find('.sequences .sequence').eq(sequenceIndex).remove()
    updateFPS: (e, newValue) ->
      animationEditor.find('.fps input').val(newValue)
    updateFrame: (e, index) ->
      frameSprites = $(this).find('.frame_sprites')
      spriteSrc = tileset[index]

      frameSpriteTemplate.tmpl(src: spriteSrc).appendTo(frameSprites)
    updateFrameSprite: (e, uuid, index) ->
      frameSprites = $(this).find('.frame_sprites')
      spriteSrc = tileset[uuid]

      if index == 0
        frameSprites.append(frameSpriteTemplate.tmpl(src: spriteSrc))
      else
        frameSpriteTemplate.tmpl(src: spriteSrc).insertAfter(frameSprites.find('.frame_sprite').eq(index - 1))

      animationEditor.trigger(event) for event in ['checkExportStatus', 'enableSave']
    updateLastFrameSequence: (e, sequence) ->
      frameSprites = $(this).find('.frame_sprites')
      sequence.appendTo(frameSprites)

      animationEditor.trigger(event) for event in ['enableSave', 'checkExportStatus']
    updateSequence: (e, index) ->
      sequenceFrameArray = if index then sequences[index].frameArray else sequences.last().frameArray
      sequenceName = if index then sequences[index].name else sequences.last().name
      sequencesEl = $(this).find('.sequences')
      sequence = $('<div class="sequence" />').append($("<span class='name'>#{sequenceName}</span>"))

      (sequenceFrameArray.length - 1).times ->
        $("<div class='placeholder' />").appendTo(sequence)

      spriteIndex = sequenceFrameArray.last()
      spriteSrc = tileset[spriteIndex]

      spriteTemplate.tmpl(src: spriteSrc).appendTo(sequence)

      if index
        sequencesEl.find('.sequence').eq(index).replaceWith(sequence)
      else
        sequence.appendTo(sequencesEl)
    updateScrubberMax: (e, newMax) ->
      scrubberEl = animationEditor.find('.scrubber')
      scrubberEl.get(0).max = newMax
    updateScrubberValue: (e, newValue) ->
      scrubberEl = animationEditor.find('.scrubber')
      scrubberEl.val(newValue)
    updateSelected: (e, frameIndex, tileSrc) ->
      animationEditor.find('.frame_sprites .placeholder, .frame_sprites img').removeClass('selected')

      player = $('.player img')

      if frameIndex == -1
        player.removeAttr('src')
      else
        player.attr('src', tileSrc)
        animationEditor.find('.frame_sprites .placeholder, .frame_sprites img').eq(frameIndex).addClass('selected')

  editorTemplate.tmpl().appendTo(animationEditor)
