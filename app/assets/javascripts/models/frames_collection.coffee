#= require underscore
#= require backbone
#= require corelib

#= require models/sequence

namespace "Pixie.Models", (Models) ->
  class Models.FramesCollection extends Backbone.Collection
    initialize: ->
      @selected = 0

      @bind 'add', =>
        @trigger 'enableFrameActions'

    model: Models.Sequence

    createSequence: =>
      @trigger 'createSequence', @

    nextFrame: =>
      @shiftFrame(+1)

    previousFrame: =>
      @shiftFrame(-1)

    shiftFrame: (direction) =>
      @selected = (@selected + direction).mod(@length)
      @trigger 'updateSelected', @at(@selected), @selected

    toFrame: (frame) =>
      @selected = frame
      @trigger 'updateSelected', @at(@selected), @selected
