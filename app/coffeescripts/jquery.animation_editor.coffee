$.fn.animationEditor = (options) ->
  options = $.extend(
    speed: 110
  , options)

  window.animationCount = 0

  animationEditor = $(this.get(0)).addClass("animation_editor")

  templates = $("#animation_editor_templates")

  templates.find(".editor.template").tmpl().appendTo(animationEditor)

  animationEditor.find('input.speed').val(options.speed)

  animationEditor.mousedown ->
    window.currentComponent = animationEditor

  animation_id = null
  preview_dirty = false
  clear_frame_sprites = -> frame_sprites().remove()

  frame_sprites = -> frame_sprites_container().children()

  frame_sprites_container = -> animationEditor.find('.frame_sprites')

  frame_selected_sprite = -> animationEditor.find('.frame_sprites .sprite_container.selected')

  active_animation = -> animationEditor.find('.animations .animation .active')

  active_animation_sprites = -> active_animation().parent().find('.sprites')

  clear_preview = -> animationEditor.find('.preview_box img').remove()

  if $.fn.hitcircleEditor
    createHitcircleEditor = (options) ->
      animationEditor = options.animationEditor

      hitcircleEditor = $('<div />').hitcircleEditor
        width: 640
        height: 480
        animationEditor: options.animationEditor
        sprite: options.sprite
        hitcircles: options.hitcircles

      animationEditor.hide().after(hitcircleEditor)

      window.currentComponent = hitcircleEditor

      return hitcircleEditor

  if $.fn.pixie
    createPixelEditor = (options) ->
      url = options.url
      animationEditor = options.animationEditor

      pixelEditor = $('<div />').pixie
        width: options.width
        height: options.height
        initializer: (canvas) ->
          if url
            canvas.fromDataURL(url)

          canvas.addAction
            name: "Save Frame"
            icon: "/images/icons/database_save.png"
            perform: (canvas) ->
              pixelEditor.trigger 'save',
                'sprite[width]': canvas.width
                'sprite[height]': canvas.height
                'sprite[file_base64_encoded]': canvas.toBase64()
              pixelEditor.remove()
              animationEditor.show()
            undoable: false

          canvas.addAction
            name: "Back to Animation"
            icon: "/images/icons/arrow_left.png"
            perform: (canvas) ->
              pixelEditor.remove()
              animationEditor.show()
            undoable: false

      animationEditor.hide().after(pixelEditor)

      window.currentComponent = pixelEditor

      return pixelEditor

  pixelEditFrame = (selectedFrame) ->
    $(selectedFrame).parent().addClass('pixel_editor')

    if createPixelEditor
      imgSource = selectedFrame.attr('src')

      pixelEditor = createPixelEditor
        width: selectedFrame.get(0).width
        height: selectedFrame.get(0).height
        animationEditor: animationEditor
        url: imgSource.replace('http://images.pixie.strd6.com', '/s3')

      pixelEditor.bind 'save', save

  editFrameCircles = (sprite, hitcircles) ->
    if createHitcircleEditor
      imgSource = sprite.find('img').attr('src')

      hitcircleEditor = createHitcircleEditor
        width: 640
        height: 480
        animationEditor: animationEditor
        sprite: imgSource
        hitcircles: hitcircles

  save = (event, data) ->
    notify "Saving..."

    successCallback = (data) ->
      notify "Saved!"

      new_sprite = templates.find('.load_sprite').tmpl
        alt: data.sprite.title || "Sprite #{data.sprite.id}"
        id: data.sprite.id
        title: data.sprite.title || "Sprite #{data.sprite.id}"
        url: data.sprite.src

      new_sprite.clone().appendTo(animationEditor.find('.user_sprites'))
      animationEditor.find(".frame_sprites .sprite_container.pixel_editor").before(new_sprite.clone()).remove()
      animationEditor.find('.animations .animation .cover.active img').before(new_sprite.find('img')).remove()

    if data
      postData = $.extend({format: 'json'}, data)

      $.post '/sprites', postData, successCallback

    $('.pixie').remove()
    animationEditor.show()

  update_active_animation = ->
    active_animation_sprites().parent().find('.sprites').children().remove()
    frame_sprites().clone().appendTo(active_animation_sprites())

    active_animation().parent().find('.complete').text(animationEditor.find('.goto option:selected').val())
    active_animation().parent().find('.speed').text(animationEditor.find('input.speed').val())

  animationEditor.find(".frame_sprites").dropImageReader (file, event) ->
    if event.target.readyState == FileReader.DONE
      sprite_container = $("<div class='sprite_container'></div>")

      img = $ "<img/>",
        alt: file.name
        src: event.target.result
        title: file.name

      img.attr('data-hit_circles', JSON.stringify({ circles: [] }))

      sprite_container.append(img)

      animationEditor.find('.frame_sprites .demo, .frame_sprites p').remove()
      $(this).append sprite_container

  animationEditor.find('.animations .name').liveEdit()

  animationEditor.find('.animation').live
    mousedown: ->
      update_active_animation()

      animationEditor.find('.speed').val($(this).find('.speed').text())
      animationEditor.find('.goto select').val($(this).find('.complete').text())

      stop_animation()
      clear_frame_sprites()

      $(this).find('.sprite_container').each (i, sprite_container) ->
        $(sprite_container).find('.tags').removeClass('tag_container').children().remove()
        $(sprite_container).clone().appendTo(frame_sprites_container())

      active_animation().removeClass('active')
      $(this).find('.cover').addClass('active')

      if $(this).find('.cover').hasClass('locked')
        animationEditor.find('.lock').css('opacity', 1)
      else
        animationEditor.find('.lock').css('opacity', 0.5)

      animationEditor.find()
    mouseenter: ->
      if animationEditor.find('.animations .animation').length > 1
        $(this).find('.cover').append('<div class="x" title="close" alt="close" />')
    mouseleave: ->
      $(this).find('.x').remove()

  animationEditor.find('.animation .x').live
    mousedown: ->
      animation = $(this).parent().parent()
      animationEditor.find(".goto option[value='#{animation.prev().text()}']").remove()

      animation.prev().fadeOut 150, ->
        animation.prev().remove()

      animation.fadeOut 150, ->
        animation.remove()

  animationEditor.find('.lock').tipsy(
    delayIn: 500
    delayOut: 500
    fade: 50
    gravity: 'sw'
  ).live
    mousedown: ->
      $this = $(this)
      animation = active_animation()

      animation.toggleClass('locked')

      if animation.hasClass('locked')
        $this.css('opacity', 1)
      else
        $this.css('opacity', 0.5)

  animationEditor.find('.new_animation').mousedown ->
    update_active_animation()
    stop_animation()

    active_animation().removeClass('active')

    clear_frame_sprites()

    templates.find('.placeholder').tmpl().appendTo('.frame_sprites')

    animation_name = ("Animation " + ++animationCount)

    animation = templates.find('.create_animation').tmpl
      name: animation_name
      complete: animation_name

    animation.insertBefore(animationEditor.find('.new_animation'))
    animationEditor.find('.goto select').append("<option value='#{animation_name}'>#{animation_name}</option>")
    animationEditor.find('.goto select').val(animation_name)

    animation.mousedown()

  animationEditor.find('.frame_sprites').sortable
    axis: "x"
    out: ->
      $(this).removeClass('highlight')
    over: ->
      $(this).addClass('highlight')
      animationEditor.find('.frame_sprites .demo, .frame_sprites p').remove()
    receive: (event, ui) ->
      $(this).removeClass('highlight')
      active_animation().children().remove()
      active_animation().append(ui.item.find('img').clone())

  $(window).resize ->
    if window.currentComponent == animationEditor
      animationEditor.find('.frame_sprites').sortable('refresh')
      frame_selected_sprite().removeClass('selected')

  animationEditor.find('.user_sprites .sprite_container').draggable
    addClasses: false
    connectToSortable: '.frame_sprites'
    containment: 'window'
    helper: 'clone'
    opacity: 0.7
    refreshPositions: true
    zIndex: 200

  animationEditor.find('.animation_editor img, .user_sprites .sprite_container').live 'click mousedown mousemove', (event) ->
    event.preventDefault()

  play_next = ->
    preview_sprites = animationEditor.find('.preview_box img')
    active = animationEditor.find('.preview_box img.active').removeClass('active')

    active_index = active.index()
    length = preview_sprites.length

    preview_sprites.eq((active_index + 1) % length).addClass('active')

  play_animation = ->
    clearInterval(animation_id)

    if (animationEditor.find('.preview_box img').length != animationEditor.find('.frame_sprites img').length) || preview_dirty
      preview_dirty = false
      clear_preview()
      preview_sprites = animationEditor.find('.frame_sprites img').attr('style', '').clone()
      animationEditor.find('.preview_box .sprites').append(preview_sprites)

      preview_sprites.first().addClass('active')

    animation_id = setInterval(play_next, animationEditor.find('input.speed').val())

  pause_animation = ->
    clearInterval(animation_id)

  stop_animation = ->
    clearInterval(animation_id)

    clear_preview()

    animationEditor.find('.play').removeClass("pause")

  animationEditor.find('.play').mousedown ->
    if $(this).hasClass("pause") then pause_animation() else play_animation()

    $(this).toggleClass("pause") unless frame_sprites_container().find('.demo').length

  animationEditor.find('.stop').mousedown ->
    stop_animation()

  animationEditor.find('.frame_sprites .sprite_container').live
    click: ->
      $this = $(this)

      $this.addClass('selected')
      unless $this.find('.tags').hasClass('tag_container')
        $this.find('.tags').tagbox
          placeholder: "New event trigger"
          presets: $this.find('.tags')?.attr('data-tags')?.split(',') || []

      if $this.find('.tags').hasClass('tag_container')
        animationEditor.find('.frame_sprites .tags').hide()
        $this.find('.tags').show()
        $this.find('.tag_container input').focus()

    dblclick: (event) ->
      pixelEditFrame($(this).find('img'))
    mouseenter: ->
      x = $('<div class="x" title="close" alt="close" />')
      duplicate = $('<div class="duplicate" title="copy this frame" alt="copy this frame" />')
      hflip = $('<div class="hflip" title="flip horizontally" alt="flip horizontally" />')
      vflip = $('<div class="vflip" title="flip vertically" alt="flip vertically" />')

      $(this).append(x, duplicate, vflip, hflip)
    mouseleave: ->
      $(this).find('.x, .duplicate, .hflip, .vflip').remove()

  animationEditor.find('.frame_sprites .sprite_container .tags').live
    blur: ->
      $(this).hide()

  animationEditor.find('.animations input').live
    change: ->
      animationEditor.find('.goto select option').remove()

      animationEditor.find('.animations .animation').each (i, animation) ->
        animation_name = if $(animation).prev().val() == "" then $(animation).prev().text() else $(animation).prev().val()

        animationEditor.find('.goto select').append("<option value='#{animation_name}'>#{animation_name}</option>")

  animationEditor.find('.goto select').change ->
    selected_value = animationEditor.find('.goto options:selected').val()

    active_animation().parent().find('.complete').text(selected_value)

  animationEditor.mousedown ->
    frame_selected_sprite().removeClass('selected')
    frame_selected_sprite().find('.tags').hide()

  $(document).bind "keydown", 'h', (event) ->
    if window.currentComponent == animationEditor
      window.editorActive = true
      event.preventDefault()

    find_hit_circles = (sprite_el) ->
      if $(sprite_el).length && $(sprite_el).find('img[data-hit_circles]').length && (sprite_el).find('img').attr('data-hit_circles').length
        return JSON.parse($(sprite_el).find('img').attr('data-hit_circles')).circles

      return null

    selected_sprite = frame_selected_sprite()

    if $(selected_sprite).length
      image_src = $(selected_sprite).find('img').attr('src').replace('http://images.pixie.strd6.com', '/s3')

      image_circles = find_hit_circles(selected_sprite)

      editFrameCircles(selected_sprite, image_circles)

  animationEditor.find('.frame_sprites .x').live 'mousedown', ->
    parent = $(this).parent()

    if parent.next().length && !parent.next().find('.x').length && !parent.next().find('.duplicate').length
      parent.next().append('<div class= "x" />')
      parent.next().append('<div class= "duplicate" />')

    parent.fadeOut 150, ->
      parent.remove()

      templates.find('.placeholder').tmpl().appendTo('.frame_sprites') unless frame_sprites().length

  animationEditor.find('.duplicate').live 'mousedown', ->
    parent = $(this).parent()
    newEl = parent.clone()

    newEl.find('.x, .duplicate, .hflip, .vflip').remove()
    newEl.insertAfter(parent)

    newEl.find('.tags').remove()
    newEl.find('img').before('<div class="tags" />')

  animationEditor.find('.hflip').live 'mousedown', ->
    $(this).parent().find('img').toggleClass('flipped_horizontal')

  animationEditor.find('.vflip').live 'mousedown', ->
    $(this).parent().find('img').toggleClass('flipped_vertical')

  animationEditor.find("button.save").click ->
    options.save?(saveData())

  loadData = (data) ->
    debugger

    if data?.animations.length
      animationEditor.find('.goto select').children().remove()

      $(data.animations).each (i, animation) ->
        if animation.complete
          animationEditor.find('.goto select').append("<option value='#{animation.complete}'>#{animation.complete}</option>")
        else
          animationEditor.find('.goto').remove()

        animation_el = templates.find('.create_animation').tmpl(
          name: animation.name
          speed: animation.speed
          complete: animation.complete
        ).insertBefore('nav.right .new_animation')

        if animation.hasOwnProperty('interruptible') && animation.interruptible == false
          animation_el.find('.cover').addClass('locked')

        active_animation().removeClass('active')

        $.each animation.frames, (i, frame) ->
          sprite_container = templates.find('.load_sprite').tmpl(
            url: data.tileset[frame].src
            alt: data.tileset[frame].title
            title: data.tileset[frame].title
            id: data.tileset[frame].id
            circles: JSON.stringify({ circles: data.tileset[frame].circles })
          ).appendTo(animationEditor.find('.animations .name').filter( ->
            $(this).text() == animation.name
          ).next().find('.sprites'))

          sprite_container.find('.tags').tagbox
            placeholder: "New event trigger"
            presets: animation.triggers?[i] || []

          sprite_container.find('.tags').hide()

        matching_animation = animationEditor.find('.animations .name').filter( ->
          $(this).text() == animation.name
        ).next()

        last_sprite_img = matching_animation.find('.sprites .sprite_container:last img')

        matching_animation.find('.cover').append(last_sprite_img.clone())

      animationEditor.find('.speed').val(active_animation().find('.speed').text())
      stop_animation()
      clear_frame_sprites()

      active_animation().find('.sprites').children().clone().appendTo(frame_sprites_container())

      window.animationCount = animationEditor.find('.animations .animation').length

      animationEditor.find('.animations .animation').first().mousedown()
    else
      templates.find('.create_animation').tmpl(
        name: "Animation 1"
        speed: animationEditor.find('.speed').val()
        complete: "Animation 1"
      ).insertBefore(animationEditor.find('.new_animation'))

      window.animationCount = animationEditor.find('.animations .animation').length

      templates.find('.placeholder').tmpl().appendTo(animationEditor.find('.frame_sprites'))

  saveData = ->
    update_active_animation()

    frames = []
    ids = []
    tiles = []

    animationEditor.find('.animations .animation').find('.sprites img').each (i, img) ->
      circles = if $(img).data('hit_circles') then $(img).data('hit_circles').circles else []

      tile =
        id: $(img).data('id')
        src: $(img).attr('src')
        title: $(img).attr('title') || $(img).attr('alt')
        circles: circles

      if $.inArray(tile.id, ids) == -1
        ids.push tile.id
        tiles.push(tile)

    animation_data = animationEditor.find('.animations .animation').map(->
      triggers = {}

      frame_data = $(this).find('.sprites img').each (i, img) ->
        tile_id = $(this).data('id')

        if $(img).parent().find('.tags').attr('data-tags') && $(img).parent().find('.tags').attr('data-tags').length
          triggers[i] = $(img).parent().find('.tags').attr('data-tags').split(',')

        frames.push(ids.indexOf(tile_id))

      if frames.length
        animation = {
          complete: $(this).find('.complete').text()
          name: $(this).prev().text()
          interruptible: !$(this).find('.cover').hasClass('locked')
          speed: $(this).find('.speed').text()
          triggers: triggers
          frames: frames
        }

      frames = []

      return animation

    ).get()

    return {
      version: "1.4"
      name: "Animation"
      tileset: tiles
      animations: animation_data
    }

  loadData(options.data)

  $.extend animationEditor,
    animationData: saveData
