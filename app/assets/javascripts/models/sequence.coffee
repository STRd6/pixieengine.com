#= require underscore
#= require backbone
#= require corelib

#= require models/frame

window.Pixie ||= {}
Pixie.Models ||= {}

class Pixie.Models.Sequence extends Backbone.Collection
  initialize: ->
    @collection = new Pixie.Models.FramesCollection
