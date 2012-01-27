#= require codemirror/codemirror
#= require codemirror/mirrorframe

#= require tmpls/pixie/console

window.Pixie ||= {}

(($) ->
  DEFAULTS =
    evalContext: eval
    maxHistoryLength: 20

  Pixie.Console = (options) ->
    self = $.tmpl("pixie/console")

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

    run = () ->
      return unless command = editor.getCode()

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
      "shift+return": run
      "pageup": prev
      "pagedown": next

    # HACK: Don't init the editor until it's been added to DOM :(
    setTimeout ->
      editor = new CodeMirror.fromTextArea input.get(0),
        autoMatchParens: true
        # height: "100%"
        lineNumbers: true
        parserfile: ["tokenize_" + lang + ".js", "parse_" + lang + ".js"]
        path: "/assets/codemirror/"
        stylesheet: ["/assets/codemirror/main.css"]
        tabMode: "shift"
        textWrapping: false

      $(editor.win.document).find('html').addClass("light")

      for binding, handler of keyBindings
        do (handler) ->
          $(editor.win.document).bind "keydown", binding, (e) ->
            e.preventDefault()

            handler()
    , 10

    output = self.find(".output")

    actionBar = self.find(".actions")

    Object.extend self,
      val: (newVal) ->
        if newVal?
          editor.setCode(newVal)
        else
          editor.getCode()

      addAction: (action) ->
        {name} = action

        titleText = name.capitalize()

        perform = () ->
          action.perform(self)

        actionElement = $ "<button />",
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
