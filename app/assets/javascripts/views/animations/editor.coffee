#= require underscore
#= require backbone

#= require views/animations/player
#= require views/animations/tileset

#= require tmpls/lebenmeister/editor_frame

window.Pixie ||= {}
Pixie.Views ||= {}
Pixie.Views.Animations ||= {}

class Pixie.Views.Animations.Editor extends Backbone.View
  el: '.backbone_lebenmeister'

  initialize: ->
    @render()
    @playerView = new Pixie.Views.Animations.Player
    @tilesetView = new Pixie.Views.Animations.Tileset

    $(@el).find('.content .relative').append(@playerView.el)

  render: =>
    $(@el).append($.tmpl('lebenmeister/editor_frame'))

    return @
