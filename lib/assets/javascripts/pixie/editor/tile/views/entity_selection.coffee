#= require tmpls/pixie/editor/tile/entity_selection

namespace "Pixie.Editor.Tile.Views", (exports) ->
  Models = Pixie.Editor.Tile.Models

  class exports.EntitySelection extends Backbone.View
    className: 'component'

    initialize: ->
      # Force jQuery Element
      @el = $(@el)
      
      # Set up HTML
      @el.html $.tmpl("pixie/editor/tile/entity_selection")

      @collection.bind 'add', @appendEntity

      @collection.bind "change:activeTile", (model, collection) =>
        @$('ul li.tile').eq(collection.indexOf(model)).takeClass 'active'

      @$("ul").sortable
        update: (event, ui) =>
          @$("ul li").each (i, li) =>
            ;# cid = $(li).data("cid")
            # debugger unless cid?
            # @collection.getByCid(cid).set zIndex: i

      @collection.bind 'reset', @render

      @render()
      
    appendEntity: (entity) =>

    render: =>
      @$('ul').empty()

      @collection.each (entity) =>
        @appendEntity entity
