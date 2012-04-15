#= require ./command

namespace "Pixie.Editor.Tile", (Tile) ->
  {Command, Models} = Tile
  IMAGE_DIR = '/assets/tools/'

  Tile.tools =
    stamp:
      cursor: "url(" + IMAGE_DIR + "stamp.png) 16 8, default"
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
      cursor: "url(" + IMAGE_DIR + "eraser.png) 4 14, default"
      start: ->
      enter: ({x, y, layer, execute})->
        if layer
          if instance = layer.instanceAt(x, y)

            execute Command.RemoveInstance
              instance: instance
              layer: layer
      end: ->

    fill:
      cursor: "url(" + IMAGE_DIR + "fill.png) 4 14, default"
      start: ({x, y, layer, entity, execute, selection, settings}) ->
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
      enter: ->
      end: ->

    selection:
      cursor: "url(" + IMAGE_DIR + "selection.png) 4 14, default"
      start: ({x, y, selection}) ->
        selection.set {
          active: true
          startX: x
          startY: y
          x
          y
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
