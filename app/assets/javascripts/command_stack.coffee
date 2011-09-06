CommandStack = ->
  stack = []
  index = 0

  execute: (command) ->
    stack[index] = command
    command.execute()

    index += 1

  undo: ->
    if @canUndo()
      index -= 1

      command = stack[index]
      command.undo()

      return command

  redo: ->
    if @canRedo()
      command = stack[index]
      command.execute()

      index += 1

      return command

  canUndo: ->
    index > 0

  canRedo: ->
    stack[index]?
