#= require underscore
#= require backbone
#= require corelib

window.Pixie ||= {}
Pixie.Models ||= {}

class Pixie.Models.Tile extends Backbone.Model
  defaults:
    active: false

  templateData: =>
    data = {}
    _.extend(data, {cid: @cid}, @attributes)

    return data
