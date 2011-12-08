#= require underscore
#= require backbone

#= require views/animations/player

#= require tmpls/lebenmeister/editor_frame

window.Pixie ||= {}
Pixie.Views ||= {}
Pixie.Views.Animations ||= {}

class Pixie.Views.Animations.Editor extends Backbone.View
  el: '.backbone_lebenmeister'

  initialize: ->
    @render()
    playerView = new Pixie.Views.Animations.Player

    $(@el).find('.content').append(playerView.el)

  render: =>
    $(@el).append($.tmpl('lebenmeister/editor_frame'))

    return @
