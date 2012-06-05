#= require pixie/view

namespace "Pixie.Editor.Animation.Views", (Views) ->
  class Views.Tileset extends Pixie.View
    tagName: 'nav'
    className: 'left'

    events:
      'click img': 'addFrame'

    initialize: ->
      super

      @el.append('<h3>Sprites</h3><div class="sprites"></div>')

      @$('.sprites').sortable
        distance: 10

      @collection.bind 'add', (model) =>
        @addTile(model)

    addFrame: (e) =>
      cid = $(e.currentTarget).data('cid')
      model = @collection.getByCid(cid)

      @collection.trigger 'addToFrames', model

    addTile: (model) =>
      src = model.get('frames').first().src
      cid = model.cid

      img = "<img src=#{src} data-cid=#{cid}>"

      @$('.sprites').append img

    loadSpriteSheet: (src, rows, columns, loadedCallback) ->
      canvas = $('<canvas>').get(0)
      context = canvas.getContext('2d')

      image = new Image()

      image.onload = ->
        tileWidth = image.width / rows
        tileHeight = image.height / columns

        canvas.width = tileWidth
        canvas.height = tileHeight

        columns.times (col) ->
          rows.times (row) ->
            sourceX = row * tileWidth
            sourceY = col * tileHeight
            sourceWidth = tileWidth
            sourceHeight = tileHeight
            destWidth = tileWidth
            destHeight = tileHeight
            destX = 0
            destY = 0

            context.clearRect(0, 0, tileWidth, tileHeight)
            context.drawImage(image, sourceX, sourceY, sourceWidth, sourceHeight, destX, destY, destWidth, destHeight)

            loadedCallback?(canvas.toDataURL())

      image.src = src

    bindDropImageReader: (editorEl) =>
      editorEl.dropImageReader ({file, event}) =>
        if event.target.readyState == FileReader.DONE
          src = event.target.result
          name = file.fileName

          [dimensions, tileWidth, tileHeight] = name.match(/x(\d*)y(\d*)/) || []

          if tileWidth && tileHeight
            @loadSpriteSheet src, parseInt(tileWidth), parseInt(tileHeight), (sprite) =>
              @collection.add
                frames: [{src: sprite}]
          else
            @collection.add
              frames: [{src: src}]


