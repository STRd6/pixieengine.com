#= require pixie/console
#= require pixie/window

namespace "Pixie.Editor.Tile", (Tile) ->

  # Pretty close to a generic console module
  Tile.Console = (I, self) ->
    consoleWindow = Pixie.Window
      title: "Tilemap Console"
    .hide()
    .appendTo("body")
    .css
      position: "absolute"
      top: "125px"
      left: "250px"

    console = Pixie.Console(
      evalContext: self.eval
    )

    consoleWindow.find(".content").append(console)

    self.addAction
      name: "console"
      perform: ->
        consoleWindow.toggle()

        # hack: this text is here to ensure
        # line numbers are visible when the console
        # is opened for the first time.
        console.val("# execute code using the editor's internal methods") if console.val() is ''

    return {}
