#= require templates/sprites/sprite

namespace "Pixie.Views.Sprites", (Sprites) ->

  class Sprites.Sprite extends Backbone.View
    className: 'sprite_container'

    render: =>
      $(@el).html $(JST['sprites/sprite'](@model.toJSON()))
      return @
