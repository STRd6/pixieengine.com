  (($) ->
  DIV = "<div />"
  TRANSPARENT = "transparent"
  IMAGE_DIR = "/images/pixie/"
  RGB_PARSER = /^rgba?\((\d{1,3}),\s*(\d{1,3}),\s*(\d{1,3}),?\s*(\d\.?\d*)?\)$/
  scale = 1

  falseFn = -> return false

  ColorPicker = ->
    $('<input />',
      class: 'color'
    ).colorPicker()

  UndoStack = ->
    undos = []
    redos = []
    empty = true

    last: -> undos[undos.length - 1]

    popUndo: ->
      undo = undos.pop()

      redos.push(undo) if undo

      return undo

    popRedo: ->
      undo = redos.pop()

      undos.push(undo) if undo

      return undo

    next: ->
      last = this.last()
      if (!last || !empty)
        undos.push({})
        empty = true

        redos = []

    add: (object, data) ->
      last = this.last()

      if !last[object]
        last[object] = data
        empty = false

      return this

    replayData: ->
      replayData = []

      $.each undos, (i, items) ->
        replayData[i] = []
        $.each items, (key, data) ->
          pixel = data.pixel
          replayData[i].push
            x: pixel.x
            y: pixel.y
            color: data.newColor

      return replayData

  ###
  infer action name and icon from key in json data.
  assume menu == false when there is no icon key in the data
  if no hotkey try to bind to the name of the json object key
  ###

  #TODO: clean up direction code
  ###
  shiftImage = (canvas, x, y) ->
    width = canvas.width
    height = canvas.height

    deferredColors = []

    if x?.abs() > 0
      height.times (y) ->
        # some mod stuff here to get the first column with x = 1 and the last with x = -1
        deferredColors[y] = canvas.getPixel(0, width), y).color()
    if y?.abs() > 0
      width.times (x) ->
        deferredColors[x] = canvas.getPixel(x, 0).color()

    canvas.eachPixel (pixel, x, y) ->
      adjacentPixel = canvas.getPixel(x + 1, y)

      pixel.color(adjacentPixel?.color())

    $.each deferredColors, (y, color) ->
      canvas.getPixel(width - 1, y).color(color)
  ###

  actions =
    undo:
      hotkeys: ["ctrl+z", "meta+z"]
      perform: (canvas) ->
        canvas.undo()
    redo:
      hotkeys: ["ctrl+y", "meta+z"]
      perform: (canvas) ->
        canvas.redo()
    clear:
      perform: (canvas) ->
        canvas.eachPixel (pixel) ->
          pixel.color(TRANSPARENT)
    preview:
      menu: false
      perform: (canvas) ->
        canvas.preview()

  ###
    left:
      perform: (canvas) ->
        #shiftImage(canvas, -1, 0)
    right:
      perform: (canvas) ->
        #shiftImage(canvas, 1, 0)
    up:
      perform: (canvas) ->
        #shiftImage(canvas, 0, -1)
    down:
      perform: (canvas) ->
        #shiftImage(canavs, 0, 1)
    download:
      hotkeys: ["ctrl+s"]
      perform: (canvas) ->
        #w = window.open()
        #w.document.location = canvas.toDataURL()
    options:
      hotkeys: ["o"]
      perform: ->
        # $('#optionsModal').removeAttr('style').modal(
        #   persist: true
        # ,
        # onClose: ->
        #   $.modal.close()
        #   $('#optionsModal').attr('style', 'display: none')
        # )
  ###

  colorNeighbors = (color) ->
    this.color(color)
    $.each this.canvas.getNeighbors(this.x, this.y), (i, neighbor) ->
      neighbor?.color(color)

  colorTransparent = ->
    this.color(TRANSPARENT)

  tools =
    pencil:
      hotkeys: ['p']
      mousedown: (e, color) ->
        this.color(color)
      mouseenter: (e, color) ->
        this.color(color)
    brush:
      hotkeys: ['b']
      mousedown: (e, color) ->
        colorNeighbors.call(this, color)
      mouseenter: (e, color) ->
        colorNeighbors.call(this, color)
    dropper:
      hotkeys: ['i']
      mousedown: ->
        this.canvas.color(this.color())
        this.canvas.setTool(tools.pencil)
    eraser:
      hotkeys: ['e']
      mousedown: ->
        colorTransparent.call(this)
      mouseenter: ->
        colorTransparent.call(this)
    fill:
      hotkeys: ['f']
      mousedown: (e, newColor, pixel) ->
        originalColor = this.color()
        return if newColor == originalColor

        q = []
        pixel.color(newColor)
        q.push(pixel)

        canvas = pixel.canvas

        while(q.length)
          pixel = q.pop()

          neighbors = canvas.getNeighbors(pixel.x, pixel.y)

          $.each neighbors, (index, neighbor) ->
            if neighbor?.color() == originalColor
              neighbor.color(newColor)
              q.push(neighbor)
  ###
    zoomIn:
      mousedown: ->
        scale = (scale * 2).clamp(0.25, 4)
        scaleCanvas(scale)
    zoomOut:
      mousedown: ->
        scale = (scale / 2).clamp(0.25, 4)
        scaleCanvas(scale)
  ###

  $.fn.pixie = (options) ->
    Pixel = (x, y, layerCanvas, canvas, undoStack) ->
      color = TRANSPARENT

      self =
        x: x
        y: y
        canvas: canvas

        color: (newColor, skipUndo) ->
          if arguments.length >= 1
            if !skipUndo
              undoStack.add(self, {pixel: self, oldColor: color, newColor: newColor})

            color = newColor || TRANSPARENT

            layerCanvas.clearRect(x * PIXEL_WIDTH, y * PIXEL_HEIGHT, PIXEL_WIDTH, PIXEL_HEIGHT)
            layerCanvas.fillStyle = color
            layerCanvas.fillRect(x * PIXEL_WIDTH, y * PIXEL_HEIGHT, PIXEL_WIDTH, PIXEL_HEIGHT)

            return this
          else
            color

        toString: -> "[Pixel: " + [this.x, this.y].join(",") + "]"

      return self

    Layer = ->
      layer = $ "<canvas />",
        class: "layer"

      gridColor = "#000"
      layerWidth = width * PIXEL_WIDTH
      layerHeight = height * PIXEL_HEIGHT
      layerElement = layer.get(0)
      layerElement.width = layerWidth
      layerElement.height = layerHeight

      context = layerElement.getContext("2d")

      return $.extend layer,
        clear: ->
          context.clearRect(0, 0, width * PIXEL_WIDTH, height * PIXEL_HEIGHT)
        drawGuide: ->
          context.fillStyle = gridColor
          height.times (row) ->
            context.fillRect(0, row * PIXEL_HEIGHT, layerWidth, 1)

          width.times (col) ->
            context.fillRect(col * PIXEL_WIDTH, 0, 1, layerHeight)

    PIXEL_WIDTH = 16
    PIXEL_HEIGHT = 16

    options ||= {}

    width = options.width || 8
    height = options.height || 8
    initializer = options.initializer

    return this.each ->
      pixie = $ DIV,
        class: 'pixie'

      viewport = $ DIV,
        class: 'viewport'

      canvas = $ DIV,
        class: 'canvas'

      toolbar = $ DIV,
        class: 'toolbar'

      actionbar = $ DIV,
        class: 'actions'

      preview = $ DIV,
        class: 'preview'
        style:
          width: width
          height: height

      currentTool = undefined
      active = false
      editingLayers = []
      mode = undefined
      undoStack = UndoStack()
      primaryColorPicker = ColorPicker().addClass('primary')
      secondaryColorPicker = ColorPicker().addClass('secondary')

      tilePreview = true

      pixie
        .bind('contextmenu', falseFn)
        .bind('mousedown', (e) ->
          target = $(e.target)

          if(target.is('.swatch'))
            canvas.color(target.css('backgroundColor'), e.button)

        ).bind('mouseup keyup', (e) ->
          active = false
          mode = undefined

          #canvas.preview()
        )

      pixels = []

      frameDiv = $ DIV,
        class: "frame current"

      layerDiv = Layer()

      editingLayers = layerDiv

      height.times (row) ->
        pixels[row] = []

        width.times (col) ->
          pixel = Pixel(col, row, layerDiv.get(0).getContext('2d'), canvas, undoStack)
          pixels[row][col] = pixel

      frameDiv.append(layerDiv)
      canvas.append(frameDiv)

      $.extend canvas,
        addAction: (name, action) ->
          titleText = name
          undoable = action.undoable

          doIt = ->
            undoStack.next() if undoable != false
            action.perform(canvas)

          if action.hotkeys
            titleText += " (#{action.hotkeys})"

            $.each action.hotkeys, (i, hotkey) ->
              $(document).bind 'keydown', hotkey, (e) ->
                doIt()
                e.preventDefault()

                false

          if action.menu != false
            iconImg = $("<img />",
              src: IMAGE_DIR + name + '.png'
            )

            actionButton = $("<a />",
              class: 'tool button'
              id: 'action_button_' + name.replace(" ", "-").toLowerCase()
              href: '#'
              title: titleText
              text: name
            )
            .prepend(iconImg)
            .mousedown (e) ->
              if !$(this).attr('disabled')
                doIt()

              _gaq.push(['_trackEvent', 'action_button', action.name])

              return false

            actionButton.appendTo(actionbar)

        addTool: (name, tool) ->
          alt = name

          tools[name].name = name
          tools[name].icon = IMAGE_DIR + name + '.png'
          tools[name].cursor = 'url(' + IMAGE_DIR + name + '.png) 4 14, default'

          setMe = ->
            canvas.setTool(tool)
            toolbar.children().removeClass("active")
            toolDiv.addClass("active")

          if tool.hotkeys
            alt += " (" + tool.hotkeys + ")"

            $.each tool.hotkeys, (i, hotkey) ->
              $(document).bind 'keydown', hotkey, (e) ->
                setMe()
                e.preventDefault()

          toolDiv = $("<div><img src='" + tool.icon + "' alt='" + alt + "' title='" + alt + "'></img></div>")
            .addClass('tool')
            .attr('data-icon_name', name)
            .click (e) ->
              setMe()
              return false

          toolbar.append(toolDiv)

        color: (color, alternate) ->
          if (arguments.length == 0 || color == false)
            return if mode == "S" then secondaryColorPicker.css('backgroundColor') else primaryColorPicker.css('backgroundColor')
          else if color
            return if mode == "S" then primaryColorPicker.css('backgroundColor') else secondaryColorPicker.css('backgroundColor')

          parsedColor = null
          if color[0] != "#"
            parsedColor = "#" + (this.parseColor(color) || "FFFFFF")
          else
            parsedColor = color

          if (mode == "S") ^ alternate
            secondaryColorPicker.val(parsedColor)
            secondaryColorPicker[0].onblur()
          else
            primaryColorPicker.val(parsedColor)
            primaryColorPicker[0].onblur()

          return this

        clear: -> editingLayer.clear()

        eachPixel: (fn) ->
          height.times (row) ->
            width.times (col) ->
              pixel = pixels[col][row]
              fn.call(pixel, pixel, col, row)

          canvas

        getPixel: (x, y) ->
          if y >= 0 && y < height
            if x >= 0 && x < width
              return pixels[y][x]

          return undefined

        getNeighbors: (x, y) ->
          return [
            this.getPixel(x+1, y)
            this.getPixel(x, y+1)
            this.getPixel(x-1, y)
            this.getPixel(x, y-1)
          ]

        toHex: (bits) ->
          s = parseInt(bits).toString(16)
          if s.length == 1
            s = '0' + s

          return s

        parseColor: (colorString) ->
          return false if !colorString || colorString == transparent

          bits = rgbParser.exec(colorString)
          return [
            this.toHex(bits[1])
            this.toHex(bits[2])
            this.toHex(bits[3])
          ].join('').toUpperCase()

        preview: ->
          tileCount = if tilePreview then 4 else 1
          preview.css
            backgroundImage: this.toCSSImageURL(),
            width: tileCount * width,
            height: tileCount * height

        redo: ->
          data = undoStack.popRedo()

          if data
            $.each data, ->
              this.pixel.color(this.oldColor, true)

        setTool: (tool) ->
          currentTool = tool
          canvas.css('cursor', tool.cursor || "pointer")

        toCSSImageURL: -> "url(#{this.toDataURL()})"

        toDataURL: ->
          canvas = $('<canvas width="' + width + '" height="' + height+ '"></canvas>').get(0)
          context = canvas.getContext('2d')

          this.eachPixel (pixel, x, y) ->
            color = pixel.color()
            context.fillStyle = color
            context.fillRect(x, y, 1, 1)

          return canvas.toDataURL("image/png")

        undo: ->
          data = undoStack.popUndo()

          if data
            $.each data, ->
              this.pixel.color(this.oldColor, true)

      $.each tools, (key, tool) ->
        canvas.addTool(key, tool)

      $.each actions, (key, action) ->
        canvas.addAction(key, action)

      guideLayer = Layer()
        .bind("mousedown", (e) ->
          undoStack.next()
          active = true
          if e.button == 0
            mode = "P"
          else
            mode = "S"

          e.preventDefault()
        )
        .bind("mousedown mousemove", (event) ->
          offset = $(this).offset()

          localY = event.pageY - offset.top
          localX = event.pageX - offset.left

          row = Math.floor(localY / PIXEL_HEIGHT)
          col = Math.floor(localX / PIXEL_WIDTH)

          pixel = canvas.getPixel(col, row)
          eventType = undefined

          if event.type == "mousedown"
            eventType = event.type
          else if pixel && event.type == "mousemove"
            eventType = "mouseenter"

          if pixel && active
            currentTool[eventType].call(pixel, event, canvas.color(), pixel)
        )

      canvas.setTool(tools.pencil)

      canvas.append(guideLayer)
      viewport.append(canvas)
      $('nav.left').append(toolbar)
      $('nav.top').append(actionbar)
      $('nav.bottom').append(preview)
      pixie.append(viewport)
      $(this).append(pixie)
)(jQuery)