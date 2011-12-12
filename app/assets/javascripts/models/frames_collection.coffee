#= require underscore
#= require backbone
#= require corelib

#= require models/tile

window.Pixie ||= {}
Pixie.Models ||= {}

class Pixie.Models.FramesCollection extends Backbone.Collection
  initialize: ->
    @selected = 0

  model: Pixie.Models.Tile

  nextFrame: =>
    @selected = (@selected + 1).mod(@length)
    @trigger 'updateSelected', @at(@selected)

  previousFrame: =>
    @selected = (@selected - 1).mod(@length)
    @trigger 'updateSelected', @at(@selected)
