namespace "Pixie.Editor.Animation.Command", (Command) ->
  {Models} = Pixie.Editor.Animation

  Object.extend Command,
    AddFrame: (I={}) ->
      execute: ->
        I.framesCollection.add I.frame
      undo: ->
        I.framesCollection.remove I.frame

    # TODO make sure to keep track of the index where the frame was deleted and add it back at the same position
    RemoveFrame: (I={}) ->
      execute: ->
        I.framesCollection.remove I.frame
      undo: ->
        I.framesCollection.add I.frame
