namespace "Pixie.Editor.Tile.Models", (Models) ->

  class Models.Selection extends Backbone.Model
    defaults:
      startX: 0
      startY: 0
      x: 0
      y: 0
      width: 0
      height: 0
      active: false

    eachPosition: (callback) ->
      if @get 'active'
        {x, y, width, height} = @attributes
        curX = x = @get 'x'
        curY = y = @get 'y'

        yBound = y + height
        xBound = x + width

        settings = @get 'settings'
        tileWidth = settings.get 'tileWidth'
        tileHeight = settings.get 'tileHeight'

        while curY < yBound
          curX = x
          while curX < xBound
            callback(curX, curY)
            curX += tileWidth
          curY += tileHeight
