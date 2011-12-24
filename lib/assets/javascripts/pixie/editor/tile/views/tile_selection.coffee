#= require tmpls/pixie/editor/tile/tile_selection

namespace "Pixie.Editor.Tile.Views", (exports) ->
  Models = Pixie.Editor.Tile.Models

  class exports.TileSelection extends Backbone.View
    className: 'component'

    initialize: ->
      # Force jQuery Element
      @el = $(@el)

      # @collection.bind 'add', @appendLayer

      @collection.bind "change:activeTile", (model, collection) =>
        @$('ul li.tile').eq(collection.indexOf(model)).takeClass 'active'

      # Set up HTML
      @el.html $.tmpl("pixie/editor/tile/tile_selection")

      @$("ul").sortable
        update: (event, ui) =>
          @$("ul li").each (i, li) =>
            ;# cid = $(li).data("cid")
            # debugger unless cid?
            # @collection.getByCid(cid).set zIndex: i

      @collection.bind 'reset', @render

      @render()

    render: =>
      @$('ul').empty()
