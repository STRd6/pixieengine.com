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
      redo = redos.pop()

      undos.push(redo) if redo

      return redo

    next: ->
      last = this.last()
      if !last || !empty
        undos.push({})
        empty = true

        redos = []

    add: (object, data) ->
      last = this.last()

      unless last[object]
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

  shiftImageHorizontal = (canvas, byX) ->
    width = canvas.width
    height = canvas.height
    index = if byX == -1 then 0 else width - 1

    deferredColors = []

    height.times (y) ->
      deferredColors[y] = canvas.getPixel(index, y).color()

    canvas.eachPixel (pixel, x, y) ->
      adjacentPixel = canvas.getPixel(x - byX, y)

      pixel.color(adjacentPixel?.color())

    $.each deferredColors, (y, color) ->
      canvas.getPixel(index, y).color(color)

  shiftImageVertical = (canvas, byY) ->
    width = canvas.width
    height = canvas.height
    index = if byY == -1 then 0 else height - 1

    deferredColors = []

    width.times (x) ->
      deferredColors[x] = canvas.getPixel(x, index).color()

    canvas.eachPixel (pixel, x, y) ->
      adjacentPixel = canvas.getPixel(x, y - byY)

      pixel.color(adjacentPixel?.color())

    $.each deferredColors, (x, color) ->
      canvas.getPixel(x, index).color(color)

  actions =
    undo:
      hotkeys: ["ctrl+z", "meta+z"]
      perform: (canvas) ->
        canvas.undo()
      undoable: false
    redo:
      hotkeys: ["ctrl+y", "meta+z"]
      perform: (canvas) ->
        canvas.redo()
      undoable: false
    clear:
      perform: (canvas) ->
        canvas.eachPixel (pixel) ->
          pixel.color(TRANSPARENT)
    preview:
      menu: false
      perform: (canvas) ->
        canvas.preview()
      undoable: false
    left:
      hotkeys: ["left"]
      menu: false
      perform: (canvas) ->
        shiftImageHorizontal(canvas, 1)
    right:
      hotkeys: ["right"]
      menu: false
      perform: `function(canvas) {
        var width = canvas.width;
        var height = canvas.height;

        var deferredColors = [];

        height.times(function(y) {
          deferredColors[y] = canvas.getPixel(width - 1, y).color();
        });

        for(var x = width-1; x >= 0; x--) {
          for(var y = 0; y < height; y++) {
            var currentPixel = canvas.getPixel(x, y);
            var leftPixel = canvas.getPixel(x - 1, y);

            if(leftPixel) {
              currentPixel.color(leftPixel.color());
            } else {
              currentPixel.color(transparent);
            }
          }
        }

        $.each(deferredColors, function(y, color) {
          canvas.getPixel(0, y).color(color);
        });
      }`
    up:
      hotkeys: ["up"]
      menu: false
      perform: (canvas) ->
        #shiftImageVertical(canvas, -1)
    down:
      hotkeys: ["down"]
      menu: false
      perform: (canvas) ->
        #shiftImageVertical(canavs, 1)
    download:
      hotkeys: ["ctrl+s"]
      perform: (canvas) ->
        w = window.open()
        w.document.location = canvas.toDataURL()
    options:
      hotkeys: ["o"]
      perform: ->
        $('#optionsModal').removeAttr('style').modal(
          persist: true
          ,
          onClose: ->
            $.modal.close()
            $('#optionsModal').attr('style', 'display: none')
        )

  colorNeighbors = (color) ->
    this.color(color)
    $.each this.canvas.getNeighbors(this.x, this.y), (i, neighbor) ->
      neighbor?.color(color)

  colorTransparent = ->
    this.color(TRANSPARENT)

  tools =
    pencil:
      cursor: "url(" + IMAGE_DIR + "pencil.png) 4 14, default"
      hotkeys: ['p']
      mousedown: (e, color) ->
        this.color(color)
      mouseenter: (e, color) ->
        this.color(color)
    brush:
      cursor: "url(" + IMAGE_DIR + "paintbrush.png) 4 14, default"
      hotkeys: ['b']
      mousedown: (e, color) ->
        colorNeighbors.call(this, color)
      mouseenter: (e, color) ->
        colorNeighbors.call(this, color)
    dropper:
      cursor: "url(" + IMAGE_DIR + "dropper.png) 13 13, default"
      hotkeys: ['i']
      mousedown: ->
        this.canvas.color(this.color())
        this.canvas.setTool(tools.pencil)
      mouseup: ->
        this.canvas.setTool(tools.pencil)
    eraser:
      cursor: "url(" + IMAGE_DIR + "eraser.png) 4 11, default"
      hotkeys: ['e']
      mousedown: ->
        colorTransparent.call(this)
      mouseenter: ->
        colorTransparent.call(this)
    fill:
      cursor: "url(" + IMAGE_DIR + "fill.png) 12 13, default"
      hotkeys: ['f']
      mousedown: (e, newColor, pixel) ->
        originalColor = this.color()
        return if newColor == originalColor

        q = []
        pixel.color(newColor)
        q.push(pixel)

        canvas = this.canvas

        while(q.length)
          pixel = q.pop()

          neighbors = canvas.getNeighbors(pixel.x, pixel.y)

          $.each neighbors, (index, neighbor) ->
            if neighbor?.color() == originalColor
              neighbor.color(newColor)
              q.push(neighbor)

  $.fn.pixie = (options) ->
    Pixel = (x, y, layerCanvas, canvas, undoStack) ->
      color = TRANSPARENT

      self =
        x: x
        y: y
        canvas: canvas

        color: (newColor, skipUndo) ->
          if arguments.length >= 1
            undoStack.add(self, {pixel: self, oldColor: color, newColor: newColor}) unless skipUndo

            color = newColor || TRANSPARENT
            xPos = x * PIXEL_WIDTH
            yPos = y * PIXEL_HEIGHT

            layerCanvas.clearRect(xPos, yPos, PIXEL_WIDTH, PIXEL_HEIGHT)
            layerCanvas.fillStyle = color
            layerCanvas.fillRect(xPos, yPos, PIXEL_WIDTH, PIXEL_HEIGHT)

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
          context.clearRect(0, 0, layerWidth, layerHeight)
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

      swatches = $ DIV,
        class: 'swatches'

      colorbar = $ DIV,
        class: "toolbar"

      actionbar = $ DIV,
        class: 'actions'

      preview = $ DIV,
        class: 'preview'
        style: "width: #{width}px height: #{height}px"

      currentTool = undefined
      active = false
      mode = undefined
      undoStack = UndoStack()
      primaryColorPicker = ColorPicker().addClass('primary')
      secondaryColorPicker = ColorPicker().addClass('secondary')
      replaying = false
      initialStateData = undefined

      tilePreview = true

      colorPickerHolder = $(DIV,
        class: 'color_picker_holder'
      ).append(primaryColorPicker, secondaryColorPicker)

      colorbar.append(colorPickerHolder, swatches)

      pixie
        .bind('contextmenu', falseFn)
        .bind('mouseup keyup', (e) ->
          active = false
          mode = undefined

          canvas.preview()
        )

      $('nav.right').bind 'mousedown', (e) ->
        target = $(e.target)
        canvas.color(target.css('backgroundColor'), e.button != 0) if target.is('.swatch')

      pixels = []

      layer = Layer()
        .bind("mousedown", (e) ->
          undoStack.next()
          active = true
          if e.button == 0 then mode = "P" else mode = "S"

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

      height.times (row) ->
        pixels[row] = []

        width.times (col) ->
          pixel = Pixel(col, row, layer.get(0).getContext('2d'), canvas, undoStack)
          pixels[row][col] = pixel

      canvas.append(layer)

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
            iconImg = $ "<img />",
              src: action.icon || IMAGE_DIR + name + '.png'

            actionButton = $("<a />",
              class: 'tool button'
              title: titleText
              text: name.capitalize()
            )
            .prepend(iconImg)
            .mousedown (e) ->
              doIt() unless $(this).attr('disabled')

              _gaq.push(['_trackEvent', 'action_button', action.name])

              return false

            actionButton.appendTo(actionbar)

        addSwatch: (color) ->
          swatches.append $ DIV,
            class: 'swatch'
            style: "background-color: #{color}"

        addTool: (name, tool) ->
          alt = name.capitalize()

          tool.name = name
          tool.icon = IMAGE_DIR + name + '.png'

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

          img = $ "<img />",
            src: tool.icon
            alt: alt
            title: alt

          toolDiv = $("<div />",
            class: "tool"
          )
            .append(img)
            .mousedown (e) ->
              setMe()
              return false

          toolbar.append(toolDiv)

        color: (color, alternate) ->
          if (arguments.length == 0 || color == false)
            return (if mode == "S" then secondaryColorPicker.css('backgroundColor') else primaryColorPicker.css('backgroundColor'))
          else if color == true
            return (if mode == "S" then primaryColorPicker.css('backgroundColor') else secondaryColorPicker.css('backgroundColor'))

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

        clear: -> layer.clear()

        dirty: (newDirty) ->
          if newDirty != undefined
            if newDirty == false
              lastClean = undoStack.last()
            return this
          else
            return lastClean != undoStack.last()

        displayInitialState: ->
          this.clear()

          if initialStateData
            $.each initialStateData, (f, data) ->
              canvas.eachPixel (pixel, x, y) ->
                pos = x + y*canvas.width
                pixel.color(data[pos], true)

        eachPixel: (fn) ->
          height.times (row) ->
            width.times (col) ->
              pixel = pixels[row][col]
              fn.call(pixel, pixel, col, row)

          canvas

        fromDataURL: (dataURL) ->
          context = document.createElement('canvas').getContext('2d')

          image = new Image()
          image.onload = ->
            context.drawImage(image, 0, 0)
            imageData = context.getImageData(0, 0, image.width, image.height)

            getColor = (x, y) ->
              index = (x + y * imageData.width) * 4
              return "rgba(" + [
                imageData.data[index + 0],
                imageData.data[index + 1],
                imageData.data[index + 2],
                imageData.data[index + 3]/255
              ].join(',') + ")"

            canvas.eachPixel (pixel, x, y) ->
              pixel.color(getColor(x, y), true)

          image.src = dataURL

        getNeighbors: (x, y) ->
          return [
            this.getPixel(x+1, y)
            this.getPixel(x, y+1)
            this.getPixel(x-1, y)
            this.getPixel(x, y-1)
          ]

        getPixel: (x, y) ->
          return pixels[y][x] if (0 <= y < height) && (0 <= x < width)
          return undefined

        getReplayData: -> undoStack.replayData()

        toHex: (bits) ->
          s = parseInt(bits).toString(16)
          if s.length == 1
            s = '0' + s

          return s

        parseColor: (colorString) ->
          return false unless colorString || colorString == transparent

          bits = RGB_PARSER.exec(colorString)
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
              this.pixel.color(this.newColor, true)

        replay: (steps) ->
          if !replaying
            replaying = true
            canvas = this

            if !steps
              steps = this.getReplayData()
              canvas.displayInitialState()
            else
              canvas.clear()

            i = 0
            delay = (5000 / steps.length).clamp(1, 200)

            runStep = ->
              step = steps[i]

              if step
                $.each step, (j, p) ->
                  canvas.getPixel(p.x, p.y, p.z, p.f).color(p.color, true)

                i++

                setTimeout(runStep, delay)
              else
                replaying = false

            setTimeout(runStep, delay)

        setInitialState: (frameData) ->
          initialStateData = frameData

          this.displayInitialState()

        setTool: (tool) ->
          currentTool = tool
          canvas.css('cursor', tool.cursor || "pointer")

        toBase64: (f) ->
          data = this.toDataURL(f)
          return data.substr(data.indexOf(',') + 1)

        toCSSImageURL: -> "url(#{this.toDataURL()})"

        toDataURL: ->
          tempCanvas = $("<canvas width=#{width} height=#{height}></canvas>").get(0)

          context = tempCanvas.getContext('2d')

          this.eachPixel (pixel, x, y) ->
            color = pixel.color()
            context.fillStyle = color
            context.fillRect(x, y, 1, 1)

          return tempCanvas.toDataURL("image/png")

        undo: ->
          data = undoStack.popUndo()

          if data
            $.each data, ->
              this.pixel.color(this.oldColor, true)

        width: width
        height: height

      $.each tools, (key, tool) ->
        canvas.addTool(key, tool)

      $.each actions, (key, action) ->
        canvas.addAction(key, action)

      $.each [
        "#000", "#FFF", "#666", "#DCDCDC", "#EB070E"
        "#F69508", "#FFDE49", "#388326", "#0246E3", "#563495"
        "#58C4F5", "#E5AC99", "#5B4635", "#FFFEE9"
      ], (i, color) ->
        canvas.addSwatch(color)

      canvas.setTool(tools.pencil)

      viewport.append(canvas)
      $('nav.left').append(toolbar)
      $('nav.right').append(colorbar, preview)
      pixie.append(actionbar, viewport)
      $(this).append(pixie)

      if initializer
        initializer(canvas)

      lastClean = undoStack.last()
)(jQuery)