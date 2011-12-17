#= require underscore
#= require backbone
#= require corelib

#= require models/sequence

window.Pixie ||= {}
Pixie.Models ||= {}

class Pixie.Models.SequencesCollection extends Backbone.Collection
  model: Pixie.Models.Sequence
