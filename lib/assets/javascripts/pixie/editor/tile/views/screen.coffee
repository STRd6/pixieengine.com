#= require tmpls/pixie/editor/tile/screen
#= require ../command

namespace "Pixie.Editor.Tile.Views", (Views) ->
  {Command, Models} = Pixie.Editor.Tile

  tools =
    stamp:
      start: ->
      enter: ({x, y, layer, entity, execute}) ->
        if layer and entity
          instance = new Models.Instance
            x: x
            y: y
            sourceEntity: entity

          # Only allow a single instance per cell
          if previousInstance = layer.instanceAt(x, y)
            execute Command.RemoveInstance
              instance: previousInstance
              layer: layer

          execute Command.AddInstance
            instance: instance
            layer: layer
      end: ->

    eraser:
      start: ->
      enter: ({x, y, layer, execute})->
        if layer
          if instance = layer.instanceAt(x, y)

            execute Command.RemoveInstance
              instance: instance
              layer: layer
      end: ->

    fill:
      start: ->
      enter: ({x, y, layer, entity, execute, selection, settings}) ->
        return unless entity and layer

        tileWidth = settings.get "tileWidth"
        tileHeight = settings.get "tileHeight"
        tilesWide = settings.get "tilesWide"
        tilesTall = settings.get "tilesTall"

        inBounds = (x, y) ->
          (0 <= x < tileWidth * tilesWide) && (0 <= y < tileHeight * tilesTall)

        entityAt = (position) ->
          [x, y] = position

          if instance = layer.instanceAt(x, y)
            instance.get "sourceEntity"
          else
            null

        getNeighborPositions = (position) ->
          [x, y] = position

          neighbors = [
            [x - tileWidth, y]
            [x + tileWidth, y]
            [x, y - tileHeight]
            [x, y + tileHeight]
          ].select (neighborPos) ->
            inBounds(neighborPos[0], neighborPos[1])

        replaceInstance = (position, entity) ->
          [x, y] = position
          # Only allow a single instance per cell
          if previousInstance = layer.instanceAt(x, y)
            execute Command.RemoveInstance
              instance: previousInstance
              layer: layer

          instance = new Models.Instance
            x: x
            y: y
            sourceEntity: entity

          execute Command.AddInstance
            instance: instance
            layer: layer

        # Handle single tile
        if entity
          sourcePattern = [[entity]]
        else if pattern
          # TODO: Handle patterns
          sourcePattern = null

        if sourcePattern
          inSelection = selection.containsPosition(x, y)

          patternEntity = sourcePattern[0][0]

          filledSet = {}
          queue = []

          position = [x, y]

          targetEntity = entityAt(position)
          replaceInstance(position, patternEntity)
          queue.push(position)

          while position = queue.pop()
            filledSet[position] = true
            neighbors = getNeighborPositions(position)

            neighbors.each (neighbor, index) ->
              if inSelection == selection.containsPosition(neighbor[0], neighbor[1])
                currentEntity = entityAt(neighbor)

                if currentEntity == targetEntity
                  patternEntity = sourcePattern.wrap( (neighbor[1] - y) / tileHeight).wrap( (neighbor[0] - x) / tileWidth)
                  replaceInstance(neighbor, patternEntity)

                  queue.push(neighbor) unless filledSet[neighbor]

        return # Just to keep coffeescript from constructing and returning a giant array
      end: ->

    selection:
      start: ({x, y, selection}) ->
        selection.set {
          startX: x,
          startY: y,
          x,
          y,
          active: true
        }

      enter: ({x, y, selection, settings}) ->
        tileWidth = settings.get "tileWidth"
        tileHeight = settings.get "tileHeight"

        startX = selection.get "startX"
        startY = selection.get "startY"

        deltaX = x - startX
        deltaY = y - startY

        selectionWidth = deltaX.abs() + tileWidth
        selectionHeight = deltaY.abs() + tileHeight

        selectionLeft = if deltaX < 0 then x else startX
        selectionTop = if deltaY < 0 then y else startY

        selection.set
          width: selectionWidth
          height: selectionHeight
          x: selectionLeft
          y: selectionTop

      end: ->

  UI = Pixie.UI

  class Views.Screen extends Backbone.View
    className: "screen"

    initialize: ->
      # Force jQuery Element
      @el = $(@el)

      # Set up HTML
      @el.html $.tmpl("pixie/editor/tile/screen")

      @settings = @options.settings

      @selection = @settings.selection
      selectionView = new Views.ScreenSelection
        model: @selection
      @$(".canvas").append selectionView.el

      @collection.bind 'add', @appendLayer
      @collection.bind 'reset', @render

      @render()

    render: =>
      grid = GridGen
        width: @settings.get "tileWidth"
        height: @settings.get "tileHeight"

      @$('.canvas').css
        height: @settings.pixelHeight()
        width: @settings.pixelWidth()
        backgroundImage: grid.backgroundImage()

      @$(".cursor").css
        width: @settings.get("tileWidth") - 1
        height: @settings.get("tileHeight") - 1

      @$(".canvas ul.layers").empty()

      @collection.each (layer) =>
        @appendLayer layer

    appendLayer: (layer) =>
      layerView = new Views.ScreenLayer
        model: layer
        settings: @settings

      @$("ul.layers").append layerView.render().el

    execute: (command) =>
      @currentCompoundCommand.push command

    localPosition: (event) =>
      {currentTarget} = event

      cursorWidth = @settings.get "tileWidth"
      cursorHeight = @settings.get "tileHeight"

      offset = $(currentTarget).offset()

      x: (event.pageX - offset.left).clamp(0, @settings.pixelWidth() - cursorWidth).snap(cursorWidth)
      y: (event.pageY - offset.top).clamp(0, @settings.pixelHeight() - cursorHeight).snap(cursorHeight)

    mousemove: (event) =>
      {x, y} = @cursorPosition = @localPosition(event)

      unless _.isEqual(@cursorPosition, @previousCursorPosition)
        @entered(x, y)

        @$(".cursor").css
          left: x - 1
          top: y - 1

      @previousCursorPosition = @cursorPosition

    entered: (x, y) =>
      if @activeTool
        layer = @settings.get "activeLayer"
        entity = @settings.get "activeEntity"

        @activeTool.enter({x, y, layer, entity, @execute, @selection, @settings})

    actionStart: (event) =>
      event.preventDefault()

      # Reuse an empty existing compound command if present
      unless @currentCompoundCommand and @currentCompoundCommand.empty()
        @currentCompoundCommand = Command.CompoundCommand()

        @settings.execute @currentCompoundCommand

      if tool = tools[@settings.get("activeTool")]
        @activeTool = tool

        {x, y} = @localPosition(event)
        layer = @settings.get "activeLayer"
        entity = @settings.get "activeEntity"

        tool.start({x, y, layer, entity, @execute, @selection, @settings})
        tool.enter({x, y, layer, entity, @execute, @selection, @settings})

    actionEnd: (event) =>
      if @activeTool
        {x, y} = @localPosition(event)
        layer = @settings.get "activeLayer"
        entity = @settings.get "activeEntity"

        @activeTool.end()

      @activeTool = null

    events:
      "mousemove .canvas": "mousemove"
      "mousedown .canvas": "actionStart"
      "mouseup": "actionEnd"
