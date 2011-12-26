#= require tmpls/pixie/editor/tile/entity_selection

namespace "Pixie.Editor.Tile.Views", (Views) ->
  Models = Pixie.Editor.Tile.Models

  class Views.EntitySelection extends Backbone.View
    className: 'component'

    initialize: ->
      # Force jQuery Element
      @el = $(@el)
      
      # Set up HTML
      @el.html $.tmpl("pixie/editor/tile/entity_selection")

      @collection.bind 'add', @appendEntity

      @$(".entities").sortable
        distance: 10
        update: (event, ui) =>
          @$(".entities .entity").each (i, element) =>
            ;# TODO: Persist sort

      @collection.bind 'reset', @render

      @render()
      
    appendEntity: (entity) =>
      entityView = new Views.Entity
        model: entity

      @$('.entities').append entityView.render().el

    render: =>
      @$(".entities").empty()

      @collection.each (entity) =>
        @appendEntity entity

    preventDefault: (event) ->
      event.preventDefault()
      
      return

    events:
      mousedown: "preventDefault"
