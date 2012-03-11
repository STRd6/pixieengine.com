#= require pixie/view
#= require tmpls/pixie/editor/tile/entity_selection

namespace "Pixie.Editor.Tile.Views", (Views) ->
  Models = Pixie.Editor.Tile.Models

  class Views.EntitySelection extends Pixie.View
    className: 'component'

    template: "pixie/editor/tile/entity_selection"

    initialize: ->
      super

      @collection.bind 'add', @appendEntity
      @collection.bind 'remove', @removeEntityView
      @collection.bind 'reset', @render

      @options.settings.bind "change:activeEntity", (settings) =>
        if entity = settings.get("activeEntity")
          @$("[data-cid=#{entity.cid}]").takeClass "active"

      @$(".entities").sortable
        distance: 10
        update: (event, ui) =>
          @$(".entities .entity").each (i, element) =>
            ;# TODO: Persist sort

      @render()

    appendEntity: (entity) =>
      entityView = new Views.Entity
        model: entity
        settings: @options.settings

      @$('.entities').append entityView.render().el

    render: =>
      @$(".entities").empty()

      @collection.each (entity) =>
        @appendEntity entity

    preventDefault: (event) ->
      event.preventDefault()

      return

    activateEntity: (event) =>
      entityElement = $(event.currentTarget)
      cid = entityElement.data("cid")

      debugger unless cid

      @options.settings.set
        activeEntity: @collection.getByCid(cid)

    removeEntity: =>
      if entityToRemove = @options.settings.get "activeEntity"
        @collection.remove entityToRemove

        @options.settings.set
          activeEntity: null

    removeEntityView: (entity) =>
      @$(".entities .entity[data-cid=#{entity.cid}]").remove()

    editEntity: (event) =>
      @options.settings.editEntity?(@settings.get 'activeEntity')

    newEntity: (event) =>
      @options.settings.newEntity?()

    events:
      mousedown: "preventDefault"
      "click .entity": "activateEntity"
      "click button.remove": "removeEntity"
      "dblclick .entity": "editEntity"
      "click button.new": "newEntity"
