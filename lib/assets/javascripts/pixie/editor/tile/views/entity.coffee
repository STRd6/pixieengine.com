namespace "Pixie.Editor.Tile.Views", (Views) ->
  Models = Pixie.Editor.Tile.Models

  class Views.Entity extends Pixie.View
    tagName: 'img'
    className: 'entity'

    initialize: ->
      super

      # Add cid
      @el.attr "data-cid", @model.cid
      @el.attr "data-uuid", @model.get("uuid")

      @model.bind 'change:src', @render

      @render()

    render: =>
      @el.attr "src", @model.get "src"

      if @model == @options.settings.get "activeEntity"
        @el.addClass "active"

      return this
