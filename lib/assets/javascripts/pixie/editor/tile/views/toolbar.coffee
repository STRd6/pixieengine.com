#= require tmpls/pixie/editor/tile/toolbar

namespace "Pixie.Editor.Tile.Views", (Views) ->
  Models = Pixie.Editor.Tile.Models

  class Views.Toolbar extends Backbone.View
    className: "tools"

    tagName: "ul"

    initialize: ->
      # Force jQuery Element
      @el = $(@el)

      # Set up HTML
      @el.html $.tmpl("pixie/editor/tile/toolbar")

      @render()

      @options.settings.bind "change:activeTool", (settings) =>
        activeTool = settings.get "activeTool"
        @$("[data-tool=#{activeTool}]").takeClass("active")

      @options.settings.set
        activeTool: "stamp"

    render: =>
      return this

    selectTool: ({currentTarget}) =>
      selectedTool = $(currentTarget)

      @options.settings.set
        activeTool: selectedTool.data "tool"

    events:
      "click .tool": "selectTool"
