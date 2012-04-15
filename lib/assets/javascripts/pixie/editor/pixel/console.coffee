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

  console = Pixie.Console(
    evalContext: self.eval
  )

  consoleWindow.find(".content").append(console)

  recipeIndex = 0
  recipes = ["""
    # this makes a gradient
    self.eachPixel (pixel, x, y) ->
      r = x * 8
      g = y * 8
      b = 128
      pixel.color(Color(r, g, b))
  """, """
    # Flip image horizontally
    self.eachPixel (pixel, x, y) ->
      return if x >= I.width / 2
      currentColor = pixels[y][x].color()
      oppositePosition = I.width - 1 - x

      flipColor = pixels[y][oppositePosition].color()
      pixel.color(flipColor)
      pixels[y][oppositePosition].color(currentColor)
  """]

  console.addAction
    name: "Recipes"
    perform: ->
      console.val(recipes.wrap(recipeIndex))
      recipeIndex += 1

  self.addAction
    name: "console"
    perform: ->
      consoleWindow.toggle()

      # hack: this text is here to ensure
      # line numbers are visible when the console
      # is opened for the first time.
      console.val("# execute code using the editor's internal methods") if console.val() is ''

  return {}

