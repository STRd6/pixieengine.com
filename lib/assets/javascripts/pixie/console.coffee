#= require tmpls/pixie/console

window.Pixie ||= {}

(($) ->
  DEFAULTS =
    evalContext: eval
    maxHistoryLength: 20

  Pixie.Console = (options) ->
    self = $.tmpl("pixie/console")

    config = $.extend {}, DEFAULTS, options

    {evalContext, maxHistoryLength} = config

    #TODO: back by local storage
    history = []
    historyPosition = -1

    prev = ->
      historyPosition += 1
      input.val(history.wrap(historyPosition))

    next = ->
      historyPosition -= 1
      input.val(history.wrap(historyPosition))

    record = (command) ->
      history.unshift(command)
      history.length = maxHistoryLength if history.length > maxHistoryLength
      historyPosition = -1

    print = (message) ->
      # Prevent the hilarity that is appending whole dom elements to the output
      message = message.toString() if message?.toString?

      output.text(message)

    recipe = (event) ->
      event.preventDefault() if event

      gradient = """
        # this makes a gradient
        self.eachPixel (pixel, x, y) ->
          r = x * 8
          g = y * 8
          b = 128
          pixel.color(Color(r, g, b))
      """

      input.val(gradient)

    run = (event) ->
      event.preventDefault() if event

      return unless command = input.val()

      #TODO: Parse and process special commands

      try
        compiledCommand = CoffeeScript.compile command, bare: on

        result = evalContext(compiledCommand)

        input.val("")

        record command
      catch error
        result = error.message

      print result

      return result

    input = self.find "input, textarea"

    keyBindings =
      "shift+return": run
      "pageup": prev
      "pagedown": next

    for binding, handler of keyBindings
      input.bind "keydown", binding, handler

    output = self.find(".output")

    self.find("button.run").click run
    self.find("button.recipe").click recipe

    return self

)(jQuery)
