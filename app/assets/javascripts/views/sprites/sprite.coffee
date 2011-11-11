#= require underscore
#= require backbone

#= require tmpls/sprites/sprite

window.Pixie ||= {}
Pixie.Backbone ||= {}
Pixie.Backbone.Sprites ||= {}

class Pixie.Backbone.Sprites.SpriteView extends Backbone.View
  className: 'sprite_container'

  render: =>
    $(@el).html $.tmpl('sprites/sprite', @model.toJSON())
    return @

