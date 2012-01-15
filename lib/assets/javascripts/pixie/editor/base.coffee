# A Base editor module for backbone based editors
namespace "Pixie.Editor", (Editor) ->
  {Button} = Pixie.UI

  Editor.Base = (I, self) ->
    addHotkey: (hotkey, fn) ->
      # We need to bind hotkeys to document because non-input elements
      # can't detect key presses.
      $(document).bind 'keydown', hotkey, (event) ->
        # Only process hotkeys when this editor is "focused"
        if currentComponent == self
          event.preventDefault()
          fn()

          #TODO Be sure editors are scoped correctly so
          # that bubbling will work as expected.
          return false

    addAction: (action) ->
      name = action.name
      titleText = name.capitalize()
      undoable = action.undoable

      perform = ->
        action.perform(self)

      if action.hotkeys
        # TODO: Auto-generate hotkey documentation for UI display
        ([].concat action.hotkeys).each (hotkey) ->
          self.addHotkey(hotkey, perform)

      if action.menu != false
        actionButton = Button
          text: name.capitalize()
          title: titleText
        .on "mousedown touchstart", ->
          perform() unless $(this).attr('disabled')

          return false

        if action.icon
          actionButton.append("<span class='static-#{action.icon}'></span>")

        actionButton.appendTo(@$(".content .actions.top"))

    takeFocus: ->
      window.currentComponent = self
