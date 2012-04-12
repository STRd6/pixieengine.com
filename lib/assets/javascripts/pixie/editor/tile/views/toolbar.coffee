#= require templates/pixie/editor/tile/toolbar

namespace "Pixie.Editor.Tile.Views", (Views) ->
  Models = Pixie.Editor.Tile.Models

  class Views.Toolbar extends Pixie.View
    className: "tools"

    tagName: "ul"

    template: "pixie/editor/tile/toolbar"

    initialize: ->
      super

      @render()

      @settings.bind "change:activeTool", (settings) =>
        activeTool = settings.get "activeTool"
        @$("[data-tool=#{activeTool}]").takeClass("active")

      @settings.set
        activeTool: "stamp"

    render: =>
      return this

    selectTool: ({currentTarget}) =>
      selectedTool = $(currentTarget)

      @settings.set
        activeTool: selectedTool.data "tool"

    events:
      "click .tool": "selectTool"
