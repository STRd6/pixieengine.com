namespace "Pixie.Editor.Tile.Command", (Command) ->
  Models = Pixie.Editor.Tile.Models
  
  Object.extend Command,
    AddInstance: (I={}) ->
      execute: ->
        I.layer.addObjectInstance I.instance
      undo: ->
        I.layer.removeObjectInstance I.instance

    RemoveInstance: (I={}) ->
      execute: ->
        I.layer.removeObjectInstance I.instance
      undo: ->
        I.layer.addObjectInstance I.instance

    # Be sure to push this onto the undo stack before pushing the commands
    # on to it.
    CompoundCommand: (I={}) ->
      Object.reverseMerge I,
        commands: []

      Core(I).extend
        execute: ->
          I.commands.invoke "execute"
        undo: ->
          I.commands.invoke "undo"
        push: (command) ->
          # We execute commands immediately when pushed in the compound
          # so that the effects of events during mousemove appear
          # immediately but they are all revoked together on undo/redo
          I.commands.push command
          command.execute()
        empty: ->
          I.commands.length == 0
