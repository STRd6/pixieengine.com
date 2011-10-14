#= require tmpls/lebenmeister/frame_sprite
#= require tmpls/lebenmeister/sprite

(exports ? this)["AnimationUI"] = (animationEditor) ->
  constructSequenceEl = (id, name) ->
    $ "<div class='sequence' data-id='#{id}'><span class='name'>#{name}</span></div>"

  constructSequenceStack = (sequence, lastSpriteSrc) ->
    {id, name, frameArray} = sequence

    sequenceEl = constructSequenceEl(id, name)

    (frameArray.length - 1).times ->
      $("<div class='placeholder' />").appendTo(sequenceEl)

    $.tmpl("lebenmeister/sprite", {src: lastSpriteSrc}).appendTo(sequenceEl)

    return sequenceEl

  animationEditor.bind
    addTile: (e, src) ->
      spritesEl = $(this).find('.sprites')
      sprite = $.tmpl("lebenmeister/sprite", {src: src})
      sprite.appendTo(spritesEl)
    appendFrameSprite: (e, spriteSrc) ->
      frameSprites = $(this).find('.frame_sprites')

      frameSprites.append($.tmpl("lebenmeister/frame_sprite", {src: spriteSrc}))

      animationEditor.trigger 'enableSave'
    appendSequenceToFrames: (e, sequence) ->
      frameSprites = $(this).find('.frame_sprites')
      sequence.appendTo(frameSprites)

      animationEditor.trigger 'enableSave'
    clearFrames: ->
      $(this).find('.frame_sprites').children().remove()
    createSequence: (e, sequence, lastSpriteSrc) ->
      sequencesEl = $(this).find('.sequences')
      sequenceEl = constructSequenceStack(sequence, lastSpriteSrc)

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
    disableSequenceEdit: ->
      $(this).find('.edit_sequences').attr({ disabled: "true", title: "Create a sequence before editing" }).removeClass('active')
    enableExport: ->
      exportButtons = $(this).find('.player button:not(.help)')
      exportButtons.removeAttr('disabled').attr('title', 'Export animation')
    enableSave: ->
      $this = $(this)

      $this.find('.create_sequence').removeAttr('disabled').attr('title', 'Create a sequence')
      $this.find('.clear_frames').removeAttr('disabled').attr('title', 'Clear frames')
    enableSequenceEdit: ->
      $(this).find('.edit_sequences').removeAttr('disabled').attr('title', 'Edit sequences')
    insertFrameSpriteAfter: (e, spriteSrc, index) ->
      frameSprites = $(this).find('.frame_sprites')

      elementAtIndex = frameSprites.find('.placeholder, img').eq(index)

      frameSprite = $.tmpl("lebenmeister/frame_sprite, {src: spriteSrc}")
      frameSprites.find('img').removeClass('selected')
      frameSprite.find('img').addClass('selected')
      frameSprite.insertAfter(elementAtIndex.parent())

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
    updateSequence: (e, sequence, lastSpriteSrc) ->
      sequenceEl = constructSequenceStack(sequence, lastSpriteSrc)

      matches = animationEditor.find('.sequence').filter ->
        return $(this).attr('data-id') == sequence.id

      for match in matches
        $(match).replaceWith(sequenceEl.clone())
    scrubberMax: (e, newMax) ->
      scrubberEl = animationEditor.find('.scrubber')
      scrubberEl.get(0).max = newMax
    scrubberValue: (e, newValue) ->
      scrubberEl = animationEditor.find('.scrubber')
      scrubberEl.val(newValue)

