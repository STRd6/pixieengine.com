#= require underscore
#= require backbone
#= require corelib

window.Pixie ||= {}
Pixie.Models ||= {}

class Pixie.Models.Frame extends Backbone.Model
  templateData: =>
    data = {}
    _.extend(data, {cid: @cid}, @attributes)

    return data
