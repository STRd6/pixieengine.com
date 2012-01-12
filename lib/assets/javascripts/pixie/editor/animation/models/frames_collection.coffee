#= require pixie/editor/animation/models/sequence

namespace "Pixie.Editor.Animation.Models", (Models) ->
  class Models.FramesCollection extends Backbone.Collection
    initialize: ->
      @selected = 0

    model: Models.Sequence

    flattenFrames: =>
      (sequence.get 'frames' for sequence in @models).flatten()

    nextFrame: =>
      @shiftFrame(+1)

    previousFrame: =>
      @shiftFrame(-1)

    shiftFrame: (direction) =>
      @toFrame (@selected + direction).mod(@length)

    toFrame: (frame) =>
      @selected = frame
      @trigger 'change:selected', @, @selected

      flattenedFrames = @flattenFrames()

      @trigger 'updateSelected', flattenedFrames[@selected], @selected

