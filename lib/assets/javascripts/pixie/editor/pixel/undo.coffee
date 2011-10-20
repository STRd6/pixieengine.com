#= require undo_stack

(($) ->
  Pixie.Editor.Pixel.Undo = (I, self) ->

    undoStack = UndoStack()
    noUndo = 0
    lastClean = undefined

    $.extend self,
      # TODO: Switch this to actions and command pattern
      addUndoData: (pixel, oldColor, newColor) ->
        unless noUndo
          undoStack.add(pixel, {pixel, oldColor, newColor})

      dirty: (newDirty) ->
        if newDirty?
          if newDirty == false
            lastClean = undoStack.last()
          return this
        else
          return lastClean != undoStack.last()

      getReplayData: ->
        undoStack.replayData()

      nextUndo: ->
        undoStack.next()

      redo: ->
        data = undoStack.popRedo()

        if data
          self.trigger("dirty")

          self.withoutUndo ->
            $.each data, ->
              this.pixel.color(this.newColor, "replace")

      undo: ->
        data = undoStack.popUndo()

        if data
          self.trigger("dirty")

          self.withoutUndo ->
            $.each data, ->
              this.pixel.color(this.oldColor, "replace")

      withoutUndo: (fn) ->
        noUndo += 1
        fn()
        noUndo -= 1

    self.bind "initialized", ->
      self.dirty(false)

)(jQuery)
