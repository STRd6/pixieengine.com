namespace "Pixie.Editor.Tile.Views", (Views) ->
  Models = Pixie.Editor.Tile.Models

  class Views.ScreenSelection extends Backbone.View
    className: "selection"

    initialize: ->
      # Force jQuery
      @el = $(@el)

      @model.bind 'change', @render

      @render()

    render: =>
      @el.css
        left: @model.get "x"
        top: @model.get "y"
        width: @model.get "width"
        height: @model.get "height"

      if @model.get "active"
        @el.addClass "active"
      else
        @el.removeClass "active"

      return this
