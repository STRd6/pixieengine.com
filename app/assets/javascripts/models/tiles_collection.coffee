#= require underscore
#= require backbone
#= require corelib

window.Pixie ||= {}
Pixie.Models ||= {}

class Pixie.Models.TilesCollection extends Backbone.Collection
  model: Pixie.Models.Tile

