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
        I.framesCollection.add I.frame, {at: I.index}

    AddSequence: (I={}) ->
      execute: ->
        I.sequencesCollection.add I.sequence
      undo: ->
        # TODO make sure to add the sequence's frames back to the bottom bar
        I.sequencesCollection.remove I.sequence

    RemoveSequence: (I={}) ->
      execute: ->
        I.sequencesCollection.remove I.sequence
      undo: ->
        I.sequencesCollection.add I.sequence, {at: I.index}
