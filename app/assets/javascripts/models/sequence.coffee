#= require underscore
#= require backbone
#= require corelib

namespace "Pixie.Models", (Models) ->
  class Models.Sequence extends Backbone.Model
    defaults:
      name: "New Sequence"
      frames: []

    templateData: =>
      frame = @get('frames').first()
      _.extend({}, {cid: frame.cid}, frame.attributes)
