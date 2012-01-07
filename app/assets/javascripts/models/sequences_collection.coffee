#= require underscore
#= require backbone
#= require corelib

#= require models/sequence

namespace "Pixie.Models", (Models) ->
  class Models.SequencesCollection extends Backbone.Collection
    model: Models.Sequence

