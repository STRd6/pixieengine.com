#= require tmpls/pixie/editor/tile/toolbar

namespace "Pixie.Editor.Tile.Views", (exports) ->
  Models = Pixie.Editor.Tile.Models

  class exports.Toolbar extends Backbone.View
    className: "tools"

    tagName: "ul"

    initialize: ->
      # Force jQuery Element
      @el = $(@el)

      # Set up HTML
      @el.html $.tmpl("pixie/editor/tile/toolbar")

      @render()

    render: =>
      return this

    selectTool: ({currentTarget}) =>
      $(currentTarget).takeClass("primary")

    events:
      "click .tool": "selectTool"
