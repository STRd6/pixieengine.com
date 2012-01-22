# An editor module for editors that support undo/redo
namespace "Pixie.Editor", (Editor) ->

  Editor.Undo = (I, self) ->
    commandStack = CommandStack()
    lastClean = undefined

    dirty = (newDirty) ->
      if newDirty == false
        lastClean = commandStack.current()
        self.trigger('clean')

        return self
      else
        return lastClean != commandStack.current()

    updateDirtyState = ->
      if dirty()
        self.trigger('dirty')
      else
        self.trigger('clean')

    # Set dirty state on save event
    self.bind 'save', ->
      dirty(false)

    execute: (command) ->
      commandStack.execute command
      updateDirtyState()

      return self

    undo: ->
      commandStack.undo()
      updateDirtyState()

      return self

    redo: ->
      commandStack.redo()
      updateDirtyState()

      return self
