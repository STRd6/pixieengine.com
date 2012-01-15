#= require ./models/sequence

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
        I.framesCollection.reset()
      undo: ->
        I.sequencesCollection.remove I.sequence

        I.framesCollection.add I.previousModels

    RemoveSequence: (I={}) ->
      execute: ->
        I.sequencesCollection.remove I.sequence
      undo: ->
        I.sequencesCollection.add I.sequence, {at: I.index}

    # TODO it would be cool to maintain
    # selected state when you undo this
    ClearFrames: (I={}) ->
      execute: ->
        I.framesCollection.reset()
      undo: ->
        I.framesCollection.add I.previousModels
