namespace "Pixie.Editor.Tile.Views", (exports) ->
  Models = Pixie.Editor.Tile.Models

  class exports.ScreenLayer extends Backbone.View
    className: "layer"

    tagName: "ul"

    initialize: ->
      # Force jQuery
      @el = $(@el)

      @el.attr "data-cid", @model.cid

      @settings = @options.settings

      @model.bind 'change', @render

      @render()

    render: =>
      @el.css
        zIndex: @model.get "zIndex"

      if @model.get 'visible'
        @el.fadeTo 'fast', 1
      else
        @el.fadeTo 'fast', 0

      return this
