namespace "Pixie.Editor.Tile.Views", (exports) ->
  Models = Pixie.Editor.Tile.Models

  class exports.Layer extends Backbone.View
    tagName: 'li'
    className: 'layer'

    initialize: ->
      @el = $(@el)

      @el.attr "data-cid", @model.cid

      @model.bind 'change', @render

      @render()

    render: =>
      @el.html "<div class='name'>#{@model.get 'name'}</div> <eye />"

      if @model.get 'visible'
        @el.fadeTo 'fast', 1
      else
        @el.fadeTo 'fast', 0.5

      return this

    activate: ->
      @model.trigger "activate", @model

    toggleVisible: ->
      @model.set
        visible: not @model.get 'visible'

    events:
      click: "activate"
      "click eye": "toggleVisible"
