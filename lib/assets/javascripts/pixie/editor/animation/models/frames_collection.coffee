#= require pixie/editor/animation/models/sequence

namespace "Pixie.Editor.Animation.Models", (Models) ->
  class Models.FramesCollection extends Backbone.Collection
    model: Models.Sequence

    flattenFrames: =>
      (sequence.get 'frames' for sequence in @models).flatten()

