namespace "Pixie.Editor.Animation.Models", (Models) ->
  class Models.Settings extends Backbone.Model
    defaults:
      selected: 0

    initialize: ->
      @commandStack = CommandStack()

    execute: (command) ->
      @commandStack.execute command

    undo: ->
      @commandStack.undo()

    redo: ->
      @commandStack.redo()

