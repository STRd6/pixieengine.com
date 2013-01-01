#= require templates/pixie/console

window.Pixie ||= {}

(($) ->
  DEFAULTS =
    evalContext: eval
    maxHistoryLength: 20

  Pixie.Console = (options) ->
    self = $(JST["pixie/console"]())

    config = Object.extend {}, DEFAULTS, options

    {evalContext, maxHistoryLength} = config

    #TODO: back by local storage
    history = []
    historyPosition = -1

    prev = ->
      historyPosition += 1
      self.val(history.wrap(historyPosition))

    next = ->
      historyPosition -= 1
      self.val(history.wrap(historyPosition))

    record = (command) ->
      history.unshift(command)
      history.length = maxHistoryLength if history.length > maxHistoryLength
      historyPosition = -1

    print = (message) ->
      # Prevent the hilarity that is appending whole dom elements to the output
      # TODO: Maybe do a fancier printout than just standard toString
      message = message.toString() if message?.toString?

      output.text(message)

    run = ->
      return unless command = editor.getValue()

      #TODO: Parse and process special commands

      try
        compiledCommand = CoffeeScript.compile command, bare: on

        result = evalContext(compiledCommand)

        self.val("")

        record command
      catch error
        result = error.message

      print result

      return result

    actions =
      prev:
        perform: prev
      next:
        perform: next
      run:
        perform: run

    input = self.find "textarea"

    lang = "coffeescript"

    editor = null

    keyBindings =
      "Shift-Enter": run
      "PageUp": prev
      "PageDown": next

    for binding, handler of keyBindings
      do (handler) ->
        keyBindings[binding] = ->
          # Don't set the state of the pending command
          # when doing special key commands
          keepState = false

          handler()

    # HACK: Don't init the editor until it's been added to DOM :(
    setTimeout ->
      #TODO: extraKeys: keyBindings
      editor = ace.edit input.get(0)
    , 10

    output = self.find(".output")

    actionBar = self.find(".actions")

    Object.extend self,
      val: (newVal) ->
        if newVal?
          editor.setValue(newVal)
        else
          editor.getValue()

      addAction: (action) ->
        {name} = action

        titleText = name.capitalize()

        perform = () ->
          action.perform(self)

        actionElement = $ "<button />",
          class: 'btn'
          text: titleText
          title: titleText
        .bind "mousedown touchstart", (e) ->
          perform() unless $(this).attr('disabled')

        return actionElement.appendTo(actionBar)

    $.each actions, (key, action) ->
      action.name = key

      self.addAction(action)

    return self

)(jQuery)
