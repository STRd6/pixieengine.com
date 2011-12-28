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
