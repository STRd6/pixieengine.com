#= require color_util
#= require undo_stack
#= require_tree .

#= require tmpls/editors/pixel

(($) ->
  track = (action, label) ->
    trackEvent?("Pixel Editor", action, label)

  DIV = "<div />"

  palette = [
    "#000000", "#FFFFFF", "#666666", "#DCDCDC", "#EB070E"
    "#F69508", "#FFDE49", "#388326", "#0246E3", "#563495"
    "#58C4F5", "#E5AC99", "#5B4635", "#FFFEE9"
  ]

  # Import tools and actions from other files
  {
    tools
    actions
    config: {
      IMAGE_DIR
      DEBUG
    }
  } = Pixie.Editor.Pixel

  falseFn = ->
    return false

  primaryButton = (event) ->
    !event.button? || event.button == 0

  ColorPicker = ->
    $('<input/>',
      class: 'color'
    ).colorPicker({ leadingHash: false })

  Pixie.Editor.Pixel.create = (options) ->
    Pixel = (x, y, layerCanvas, canvas, undoStack) ->
      color = Color()

      redraw = () ->
        xPos = x * PIXEL_WIDTH
        yPos = y * PIXEL_HEIGHT

        layerCanvas.clearRect(xPos, yPos, PIXEL_WIDTH, PIXEL_HEIGHT)
        layerCanvas.fillStyle = color.toString()
        layerCanvas.fillRect(xPos, yPos, PIXEL_WIDTH, PIXEL_HEIGHT)

      self =
        canvas: canvas

        redraw: redraw

        color: (newColor, skipUndo, blendMode) ->
          if arguments.length >= 1
            blendMode ||= "additive"

            oldColor = Color(color)

            color = ColorUtil[blendMode](oldColor, Color(newColor))

            redraw()

            undoStack.add(self, {pixel: self, oldColor: oldColor, newColor: color}) unless skipUndo

            return self
          else
            color

        toString: ->
          "[Pixel: " + [@x, @y].join(",") + "]"
        x: x
        y: y

      return self

    Layer = ->
      layer = $ "<canvas />",
        class: "layer"

      layerWidth = -> width * PIXEL_WIDTH
      layerHeight = -> height * PIXEL_HEIGHT
      layerElement = layer.get(0)
      layerElement.width = layerWidth()
      layerElement.height = layerHeight()

      context = layerElement.getContext("2d")

      return $.extend layer,
        clear: ->
          context.clearRect(0, 0, layerWidth(), layerHeight())

        context: context

        resize: () ->
          layerElement.width = layerWidth()
          layerElement.height = layerHeight()

    options ||= {}

    width = parseInt(options.width || 8, 10)
    height = parseInt(options.height || 8, 10)
    initializer = options.initializer
    PIXEL_WIDTH = parseInt(options.pixelWidth || options.pixelSize || 16, 10)
    PIXEL_HEIGHT = parseInt(options.pixelHeight || options.pixelSize || 16, 10)

    pixie = $.tmpl("editors/pixel")

    content = pixie.find(".content")
    viewport = pixie.find(".viewport")
    canvas = pixie.find(".canvas").css
      width: width * PIXEL_WIDTH + 2
      height: height * PIXEL_HEIGHT + 2

    actionbar = pixie.find(".actions")

    toolbar = pixie.find(".toolbar.left")

    swatches = pixie.find(".swatches")
    colorbar = pixie.find(".module.right .toolbar")

    colorPickerHolder = pixie.find(".color_picker_holder")

    colorbar.append(colorPickerHolder, swatches)

    opacityVal = $ DIV,
      class: "val"
      text: 100

    opacitySlider = pixie.find(".opacity").slider(
      orientation: 'vertical'
      value: 100
      min: 5
      max: 100
      step: 5
      slide: (event, ui) ->
        opacityVal.text(ui.value)
    ).append(opacityVal)

    opacityVal.text(opacitySlider.slider('value'))

    preview = pixie.find(".preview").css
      width: width
      height: height

    currentTool = undefined
    active = false
    mode = undefined
    undoStack = UndoStack()
    primaryColorPicker = ColorPicker().addClass('primary').appendTo(colorPickerHolder)
    secondaryColorPicker = ColorPicker().addClass('secondary').appendTo(colorPickerHolder)
    replaying = false
    tilePreview = true
    initialStateData = undefined

    pixie
      .bind('contextmenu', falseFn)
      .bind('mouseup', (e) ->
        active = false
        mode = undefined

        canvas.preview()
      )

    preview.mousedown ->
      tilePreview = !tilePreview

      canvas.preview()

      track('mousedown', 'preview')

    # TODO: This global event is bad, will cause lag when multiple editors are
    # on the page
    $(document).bind 'keyup', ->
      canvas.preview()

    swatches.bind 'mousedown touchstart', (e) ->
      target = $(e.target)

      if target.is('.swatch')
        color = Color(target.css('backgroundColor'))
        canvas.color(color, !primaryButton(e))

        track(e.type, color.toString())

    pixels = []

    lastPixel = undefined

    handleEvent = (event, element) ->
      opacity = opacityVal.text() / 100

      offset = element.offset()

      local =
        y: event.pageY - offset.top
        x: event.pageX - offset.left

      row = Math.floor(local.y / PIXEL_HEIGHT)
      col = Math.floor(local.x / PIXEL_WIDTH)

      pixel = canvas.getPixel(col, row)
      eventType = undefined

      if (event.type == "mousedown") || (event.type == "touchstart")
        eventType = "mousedown"
      else if pixel && pixel != lastPixel && (event.type == "mousemove" || event.type == "touchmove")
        eventType = "mouseenter"

      if pixel && active && currentTool && currentTool[eventType]
        c = canvas.color().toString()

        currentTool[eventType].call(pixel, event, Color(c, opacity), pixel)

      lastPixel = pixel

    layer = Layer()
    guideLayer = Layer()
      .bind("mousedown touchstart", (e) ->
        #TODO These triggers aren't perfect like the `dirty` method that queries.
        pixie.trigger('dirty')
        undoStack.next()
        active = true
        if primaryButton(e)
          mode = "P"
        else
          mode = "S"

        e.preventDefault()
      )
      .bind("mousedown mousemove", (event) ->
        handleEvent event, $(this)
      )
      .bind("touchstart touchmove", (e) ->
        # NOTE: global event object
        Array::each.call event.touches, (touch) =>
          touch.type = e.type
          handleEvent touch, $(this)
      )

    layers = [layer, guideLayer]

    height.times (row) ->
      pixels[row] = []

      width.times (col) ->
        pixel = Pixel(col, row, layer.get(0).getContext('2d'), canvas, undoStack)
        pixels[row][col] = pixel

    canvas.append(layer, guideLayer)

    #TODO: These methods should be on the top-level editor, or modularized into
    # sensible components
    $.extend canvas,
      addAction: (action) ->
        name = action.name
        titleText = name.capitalize()
        undoable = action.undoable

        doIt = ->
          if undoable != false
            pixie.trigger('dirty')
            undoStack.next()

          action.perform(canvas)

        if action.hotkeys
          titleText += " (#{action.hotkeys}) "

          $.each action.hotkeys, (i, hotkey) ->
            #TODO Add action hokey json data

            $(document).bind 'keydown', hotkey, (e) ->
              if currentComponent == pixie
                e.preventDefault()
                doIt()

                track('hotkey', action.name)

                return false

        if action.menu != false
          iconImg = $ "<img />",
            src: action.icon || IMAGE_DIR + name + '.png'

          actionButton = $("<a />",
            class: 'tool button'
            title: titleText
            text: name.capitalize()
          )
          .prepend(iconImg)
          .bind "mousedown touchstart", (e) ->
            doIt() unless $(this).attr('disabled')

            # These currently get covered by the global link click tracking
            # track(e.type, action.name)

            return false

          actionButton.appendTo(actionbar)

      addSwatch: (color) ->
        swatches.append $ DIV,
          class: 'swatch'
          style: "background-color: #{color.toString()}"

      addTool: (tool) ->
        name = tool.name
        alt = name.capitalize()

        tool.icon ||= IMAGE_DIR + name + '.png'

        setMe = ->
          canvas.setTool(tool)

        if tool.hotkeys
          alt += " (" + tool.hotkeys + ")"

          $.each tool.hotkeys, (i, hotkey) ->
            $(document).bind 'keydown', hotkey, (e) ->
              #TODO Generate tool hotkeys json data

              if currentComponent == pixie
                e.preventDefault()
                setMe()

                track("hotkey", tool.name)

                return false

        img = $ "<img />",
          src: tool.icon
          alt: alt
          title: alt

        tool.elementSet = toolDiv = $("<div class='tool'></div>")
          .append(img)
          .bind("mousedown touchstart", (e) ->
            setMe()

            track(e.type, tool.name)

            return false
          )

        toolbar.append(toolDiv)

      color: (color, alternate) ->
        if (arguments.length == 0 || color == false)
          if mode == "S"
            return Color(secondaryColorPicker.css('backgroundColor'))
          else
            return Color(primaryColorPicker.css('backgroundColor'))
        else if color == true
          if mode == "S"
            Color(primaryColorPicker.css('backgroundColor'))
          else
            Color(secondaryColorPicker.css('backgroundColor'))

        if (mode == "S") ^ alternate
          secondaryColorPicker.val(color.toHex().substr(1))
          secondaryColorPicker[0].onblur()
        else
          primaryColorPicker.val(color.toHex().substr(1))
          primaryColorPicker[0].onblur()

        return this

      clear: ->
        layer.clear()

      dirty: (newDirty) ->
        if newDirty != undefined
          if newDirty == false
            lastClean = undoStack.last()
          return this
        else
          return lastClean != undoStack.last()

      displayInitialState: (stateData) ->
        @clear()

        stateData ||= initialStateData

        if stateData
          $.each stateData, (f, data) ->
            canvas.eachPixel (pixel, x, y) ->
              pos = x + y*canvas.width
              pixel.color(Color(data[pos]), true, "replace")

      eachPixel: (fn) ->
        height.times (row) ->
          width.times (col) ->
            pixel = pixels[row][col]
            fn.call(pixel, pixel, col, row)

        canvas

      eval: (code) ->
        eval(code)

      fromDataURL: (dataURL) ->
        context = document.createElement('canvas').getContext('2d')

        maxDimension = 256

        image = new Image()
        image.onload = ->
          if image.width * image.height < maxDimension * maxDimension
            canvas.resize(image.width, image.height)

            context.drawImage(image, 0, 0)
            imageData = context.getImageData(0, 0, image.width, image.height)

            getColor = (x, y) ->
              index = (x + y * imageData.width) * 4

              return Color(imageData.data[index + 0], imageData.data[index + 1], imageData.data[index + 2], imageData.data[index + 3] / 255)

            canvas.eachPixel (pixel, x, y) ->
              pixel.color(getColor(x, y), true)
          else
            alert("This image is too big for our editor to handle, try #{maxDimension}x#{maxDimension} and smaller")

          return

        image.src = dataURL

      getNeighbors: (x, y) ->
        return [
          @getPixel(x+1, y)
          @getPixel(x, y+1)
          @getPixel(x-1, y)
          @getPixel(x, y-1)
        ]

      getPixel: (x, y) ->
        return pixels[y][x] if (0 <= y < height) && (0 <= x < width)
        return undefined

      getReplayData: ->
        undoStack.replayData()

      preview: ->
        tileCount = if tilePreview then 4 else 1

        preview.css
          backgroundImage: @toCSSImageURL()
          width: tileCount * width
          height: tileCount * height

      redo: ->
        data = undoStack.popRedo()

        if data
          pixie.trigger("dirty")

          $.each data, ->
            this.pixel.color(this.newColor, true, "replace")

      replay: (steps, parentData) ->
        unless replaying
          replaying = true
          canvas = this

          if !steps
            steps = canvas.getReplayData()
            canvas.displayInitialState()
          else
            if parentData
              canvas.displayInitialState(parentData)
            else
              canvas.clear()

          i = 0
          delay = (5000 / steps.length).clamp(1, 200)

          runStep = ->
            step = steps[i]

            if step
              $.each step, (j, p) ->
                canvas.getPixel(p.x, p.y).color(p.color, true, "replace")

              i++

              setTimeout(runStep, delay)
            else
              replaying = false

          setTimeout(runStep, delay)

      resize: (newWidth, newHeight) ->
        @width = width = newWidth
        @height = height = newHeight

        pixels = pixels.slice(0, newHeight)

        pixels.push [] while pixels.length < newHeight

        pixels.each (row, y) ->
          row.pop() while row.length > newWidth
          row.push Pixel(row.length, y, layer.get(0).getContext('2d'), canvas, undoStack) while row.length < newWidth

        layers.each (layer) ->
          layer.clear()
          layer.resize()

        canvas.css
          width: width * PIXEL_WIDTH + 2
          height: height * PIXEL_HEIGHT + 2

        pixels.each (row) ->
          row.each (pixel) ->
            pixel.redraw()

      setInitialState: (frameData) ->
        initialStateData = frameData

        this.displayInitialState()

      setTool: (tool) ->
        currentTool = tool
        canvas.css('cursor', tool.cursor || "pointer")
        tool.elementSet.takeClass("active")

      toBase64: (f) ->
        data = @toDataURL(f)
        return data.substr(data.indexOf(',') + 1)

      toCSSImageURL: ->
        "url(#{@toDataURL()})"

      toDataURL: ->
        tempCanvas = $("<canvas width=#{width} height=#{height}></canvas>").get(0)

        context = tempCanvas.getContext('2d')

        @eachPixel (pixel, x, y) ->
          color = pixel.color()
          context.fillStyle = color.toString()
          context.fillRect(x, y, 1, 1)

        return tempCanvas.toDataURL("image/png")

      undo: ->
        data = undoStack.popUndo()

        if data
          pixie.trigger("dirty")

          $.each data, ->
            this.pixel.color(this.oldColor, true, "replace")

      width: width
      height: height

    $.each tools, (key, tool) ->
      tool.name = key
      canvas.addTool(tool)

    $.each actions, (key, action) ->
      action.name = key
      canvas.addAction(action)

    $.each palette, (i, color) ->
      canvas.addSwatch(Color(color))

    canvas.setTool(tools.pencil)

    pixie.bind 'mouseenter', ->
      window.currentComponent = pixie

    pixie.bind 'touchstart touchmove touchend', ->
      event.preventDefault()

    # TODO: Refactor this to be a real self.include
    Pixie.Editor.Pixel.Console(options, canvas)

    window.currentComponent = pixie

    if initializer
      initializer(canvas)

    lastClean = undoStack.last()

    return pixie
)(jQuery)
