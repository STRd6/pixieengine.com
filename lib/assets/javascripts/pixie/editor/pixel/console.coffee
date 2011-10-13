#= require pixie/console
#= require pixie/window

# Pretty close to a generic console module
Pixie.Editor.Pixel.Console = (I, self) ->
  consoleWindow = Pixie.Window
    title: "Console"
  .hide()
  .appendTo("body")
  .css
    position: "absolute"
    top: "125px"
    left: "250px"

  consoleWindow.find(".content").append(Pixie.Console(
    evalContext: self.eval
  ))

  self.addAction
    name: "console"
    perform: ->
      consoleWindow.toggle()

  return {}
