#= require underscore
#= require backbone

#= require tmpls/sprites/sprite

window.Pixie ||= {}
Pixie.Views ||= {}
Pixie.Views.Sprites ||= {}

class Pixie.Views.Sprites.Sprite extends Backbone.View
  className: 'sprite_container'

  render: =>
    $(@el).html $.tmpl('sprites/sprite', @model.toJSON())
    return @

