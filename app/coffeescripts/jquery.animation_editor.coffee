$.fn.animationEditor = (options) ->
  options = $.extend(
    speed: 110
  , options)

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
              pixelEditor.trigger 'save', canvas.toDataURL()
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

    $('.pixie').remove()
    animationEditor.show()

    successCallback = (data) ->
      notify "Saved!"

      new_sprite = templates.find('.load_sprite').tmpl
        alt: data.sprite.title
        id: data.sprite.id
        title: data.sprite.title
        url: data.sprite.src

      sprite_copy = new_sprite.clone()

      sprite_copy.appendTo(animationEditor.find('.user_sprites'))

      animationEditor.find(".frame_sprites .sprite_container.pixel_editor").before(sprite_copy).remove()
      animationEditor.find('.animations .animation .cover.active img').before(new_sprite.find('img')).remove()

    if data
      postData = $.extend({format: 'json'}, data)

      $.post '/sprites', postData, successCallback

  update_active_animation = ->
    active_animation_sprites().parent().find('.sprites').children().remove()
    frame_sprites().clone().appendTo(active_animation_sprites())

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

  animationEditor.find('.animation').live
    mousedown: ->
      update_active_animation()

      animationEditor.find('.speed').val($(this).find('.speed').text())
      stop_animation()
      clear_frame_sprites()

      $(this).find('.sprites').children().clone().appendTo(frame_sprites_container())

      active_animation().removeClass('active')
      $(this).find('.cover').addClass('active')

      if $(this).find('.cover').hasClass('locked')
        animationEditor.find('.lock').css('opacity', 1)
      else
        animationEditor.find('.lock').css('opacity', 0.5)
    mouseenter: ->
      if animationEditor.find('.animations .animation').length > 1
        $(this).find('.cover').append('<div class="x" />')
    mouseleave: ->
      $(this).find('.x').remove()

  animationEditor.find('.animation .x').live
    mousedown: ->
      animation = $(this).parent().parent()

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

    animation = templates.find('.create_animation').tmpl
      name: "Animation " + (animationEditor.find('.animations .animation').length + 1)

    animation.insertBefore(animationEditor.find('.new_animation'))

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
    click: -> $(this).addClass('selected')
    dblclick: (event) ->
      pixelEditFrame($(this).find('img'))
    mouseenter: ->
      $('<div class="x" />').appendTo $(this)
      $('<div class="duplicate" />').appendTo $(this)
    mouseleave: ->
      $(this).find('.x, .duplicate').remove()

  animationEditor.mousedown ->
    frame_selected_sprite().removeClass('selected')

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

  $(document).bind "keydown", 'left', (event) ->
    if window.currentComponent == animationEditor
      preview_dirty = true
      event.preventDefault()

      selected_sprite = frame_selected_sprite()
      selected_sprite.find('.x, .duplicate').remove()

      if selected_sprite.prev().length
        selected_sprite.prev().before(selected_sprite)

  $(document).bind "keydown", 'right', (event) ->
    if window.currentComponent == animationEditor
      preview_dirty = true
      event.preventDefault()

      selected_sprite = frame_selected_sprite()
      selected_sprite.find('.x, .duplicate').remove()

      if selected_sprite.next().length
        selected_sprite.next().after(selected_sprite)

  animationEditor.find('.animations .name, .filename').liveEdit()

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

    newEl.find('.x, .duplicate').remove()

    newEl.insertAfter(parent)

  animationEditor.find("button.save").click ->
    options.save?(saveData())

  loadData = (data) ->
    if data && data.animations.length
      $(data.animations).each (i, animation) ->

        animation_el = templates.find('.create_animation').tmpl(
          name: animation.name
          speed: animation.speed
        ).insertBefore('nav.right .new_animation')

        $.each animation.frames, (i, frame) ->
          active_animation().removeClass('active')

          templates.find('.load_sprite').tmpl(
            url: data.tileset[frame].src
            alt: data.tileset[frame].title
            title: data.tileset[frame].title
            id: data.tileset[frame].id
            circles: JSON.stringify({ circles: data.tileset[frame].circles })
          ).appendTo(animationEditor.find('.animations .name:contains("' + animation.name + '")').next().find('.sprites'))

        last_sprite_img = animationEditor.find('.animations .name:contains("' + animation.name + '")').next().find('.sprites').children().last().find('img')

        animationEditor.find('.animations .name:contains("' + animation.name + '")').next().find('.cover').append(last_sprite_img.clone())

      animationEditor.find('.speed').val(active_animation().find('.speed').text())
      stop_animation()
      clear_frame_sprites()

      active_animation().find('.sprites').children().clone().appendTo(frame_sprites_container())

      animationEditor.find('.animations .animation').first().mousedown()
    else
      templates.find('.create_animation').tmpl(
        name: "Animation 1"
        speed: animationEditor.find('.speed').val()
      ).insertBefore(animationEditor.find('.new_animation'))

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

      frame_data = $(this).find('.sprites img').each (i, img) ->
        tile_id = $(this).data('id')

        frames.push(ids.indexOf(tile_id))

      if frames.length

        animation = {
          name: $(this).prev().text()
          speed: $(this).find('.speed').text()
          frames: frames
        }

      frames = []

      return animation

    ).get()

    return {
      version: "1.3"
      name: animationEditor.find('nav.right .filename').text()
      tileset: tiles
      animations: animation_data
    }

  loadData(options.data)

  $.extend animationEditor,
    animationData: saveData