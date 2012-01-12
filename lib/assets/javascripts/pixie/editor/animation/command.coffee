namespace "Pixie.Editor.Animation.Command", (Command) ->
  {Models} = Pixie.Editor.Animation

  Object.extend Command,
    AddFrame: (I={}) ->
      execute: ->
        I.framesCollection.add I.frame
      undo: ->
        I.framesCollection.remove I.frame

    RemoveFrame: (I={}) ->
      execute: ->
        I.framesCollection.remove I.frame
      undo: ->
        I.framesCollection.add I.frame
