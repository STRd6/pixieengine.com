#= require models/tiles_collection

#= require tmpls/lebenmeister/tileset
#= require tmpls/lebenmeister/tile

namespace "Pixie.Views.Animations", (Animations) ->
  {Models} = Pixie

  class Animations.Tileset extends Backbone.View
    el: 'nav.left'

    events:
      'click img': 'addFrame'

    collection: new Models.TilesCollection

    initialize: ->
      # force jQuery el
      @el = $(@el)

      @render()
      @enableSort()

      @collection.bind 'add', (model) =>
        @addTile(model)

    render: =>
      @el.append($.tmpl('lebenmeister/tileset'))

      return @

    addFrame: (e) =>
      cid = $(e.currentTarget).data('cid')
      model = @collection.getByCid(cid)

      @collection.trigger 'addFrame', model

    addTile: (model) =>
      @$('.sprites').append $.tmpl('lebenmeister/tile', model.templateData())

    bindDropImageReader: (editorEl) =>
      editorEl.dropImageReader (file, event) =>
        if event.target.readyState == FileReader.DONE
          src = event.target.result
          name = file.fileName

          # TODO Add in support for sprite sheets
          #[dimensions, tileWidth, tileHeight] = name.match(/x(\d*)y(\d*)/) || []

          #if tileWidth && tileHeight
          #  loadSpriteSheet src, parseInt(tileWidth), parseInt(tileHeight), (sprite) ->
          #    addTile(sprite)

          @collection.add({src: src})

    enableSort: =>
      @$('.sprites').sortable
        distance: 10
