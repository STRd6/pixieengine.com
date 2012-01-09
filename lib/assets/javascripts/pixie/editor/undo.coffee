# An editor module for editors that support undo/redo
namespace "Pixie.Editor", (Editor) ->

  Editor.Undo = (I, self) ->
    commandStack = CommandStack()

    execute: (command) ->
      commandStack.execute command

    undo: ->
      commandStack.undo()

    redo: ->
      commandStack.redo()
