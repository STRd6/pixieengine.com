window.UI = (animationEditor, animations, tileset, sequences) ->
  templates = $("#animation_editor_templates")
  editorTemplate = templates.find('.editor.template')
  animationTemplate = templates.find('.animation')
  spriteTemplate = templates.find('.sprite')
  frameSpriteTemplate = templates.find('.frame_sprite')

  animationEditor.bind
    addSpriteToSequence: (e, spriteSrc, sequence) ->
      spriteTemplate.tmpl(src: spriteSrc).appendTo(sequence)
    addTile: (e, src) ->
      spritesEl = $(this).find('.sprites')
      spriteTemplate.tmpl(src: src).appendTo(spritesEl)

    checkExportStatus: ->
      framesEmpty = true

      for animation in animations
        if animation.frames.length
          framesEmpty = false

      exportButtons = $(this).find('.player button:not(.new_animation)')

      exportButtons.removeAttr('disabled').attr('title', 'Export animation')
      exportButtons.attr({ disabled: true, title: 'Add frames to export'}) if framesEmpty
    clearFrames: ->
      $(this).find('.frame_sprites').children().remove()
    currentAnimationTitle: (e, title) ->
      $(this).find('.player .animation_name').text(title)
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

      for animation in animations
        animationTemplate.tmpl({stateId: animation.stateId, name: animation.name()}).appendTo(animationsEl)

      if spritesEl.find('img').length == 0
        for index, src of tileset
          spriteTemplate.tmpl(src: src).appendTo(spritesEl)

        animationEditor.trigger 'disableSave'
        animationEditor.trigger 'checkExportStatus'
    removeFrame: (e, frameIndex) ->
      if $(this).find('.frame_sprites img').eq(frameIndex).parent().hasClass('frame_sprite')
        $(this).find('.frame_sprites img').eq(frameIndex).parent().remove()

      if $(this).find('.frame_sprites img').eq(frameIndex).parent().hasClass('sequence')
        parent = $(this).find('.frame_sprites img').eq(frameIndex).parent()
        $(this).find('.frame_sprites img').eq(frameIndex).remove()

        if parent.children().not('.x').length == 0
          parent.remove()

    removeSequence: (e, sequenceIndex) ->
      $(this).find('.sequences .sequence').eq(sequenceIndex).remove()
    loadCurrentAnimation: ->
      $this = $(this)

      $this.trigger 'clearFrames'
      $this.trigger 'currentAnimationTitle', [currentAnimation.name()]
      $this.find('.player img').removeAttr('src')

      currentAnimation.load()
    updateFPS: (e, newValue) ->
      animationEditor.find('.fps input').val(newValue)
    updateFrame: (e, index) ->
      frameSprites = $(this).find('.frame_sprites')
      spriteSrc = tileset[index]

      frameSpriteTemplate.tmpl(src: spriteSrc).appendTo(frameSprites)
    updateLastFrame: ->
      frameSprites = $(this).find('.frame_sprites')
      spriteSrc = tileset[currentAnimation.frames.last()]

      frameSpriteTemplate.tmpl(src: spriteSrc).appendTo(frameSprites)

      animationEditor.trigger(event) for event in ['checkExportStatus', 'enableSave']
    updateLastFrameSequence: (e, sequence) ->
      frameSprites = $(this).find('.frame_sprites')
      sequence.appendTo(frameSprites)

      animationEditor.trigger(event) for event in ['enableSave', 'checkExportStatus']
    updateLastSequence: ->
      sequencesEl = $(this).find('.sequences')

      sequenceFrameArray = sequences.last().frameArray
      sequence = $('<div class="sequence" />')
      name = $("<span class='name'>#{sequences.last().name}</span>").appendTo(sequence)

      sequence.appendTo(sequencesEl)

      (sequenceFrameArray.length - 1).times ->
        $("<div class='placeholder' />").appendTo(sequence)

      spriteIndex = sequenceFrameArray.last()
      spriteSrc = tileset[spriteIndex]

      spriteTemplate.tmpl(src: spriteSrc).appendTo(sequence)

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
