#= require pixie/editor/animation/models/sequence

namespace "Pixie.Editor.Animation.Models", (Models) ->
  class Models.FramesCollection extends Backbone.Collection
    initialize: ->
      @selected = 0

      @bind 'add', =>
        @trigger 'enableFrameActions'

    model: Models.Sequence

    createSequence: =>
      @trigger 'createSequence', @

    flattenFrames: =>
      (@models.map (sequence) ->
        sequence.get 'frames'
      ).flatten()

    nextFrame: =>
      @shiftFrame(+1)

    previousFrame: =>
      @shiftFrame(-1)

    shiftFrame: (direction) =>
      @selected = (@selected + direction).mod(@length)
      @trigger 'change:selected', @, @selected

      flattenedFrames = @flattenFrames()

      @trigger 'updateSelected', flattenedFrames[@selected], @selected

    toFrame: (frame) =>
      @selected = frame
      @trigger 'change:selected', @, @selected

      flattenedFrames = @flattenFrames()

      @trigger 'updateSelected', flattenedFrames[@selected], @selected

