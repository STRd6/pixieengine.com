#= require underscore
#= require backbone

#= require models/animation_player

#= require tmpls/lebenmeister/player

window.Pixie ||= {}
Pixie.Views ||= {}
Pixie.Views.Animations ||= {}

class Pixie.Views.Animations.Player extends Backbone.View
  className: 'player'

  events:
    'click .pause': 'pause'
    'click .play': 'play'
    'click .stop': 'stop'

  initialize: ->
    @render()

    @model = new Pixie.Models.AnimationPlayer

    @model.bind 'showPause', ->
      $('.pause').show()
      $('.play').hide()

    @model.bind 'showPlay', ->
      console.log $('.play')
      $('.play').show()
      $('.pause').hide()

  pause: (e) =>
    e.preventDefault()
    @model.pause()
    @model.trigger 'showPlay'

  play: (e) =>
    e.preventDefault()
    @model.play()
    @model.trigger 'showPause'

  render: =>
    $(@el).append($.tmpl('lebenmeister/player'))

    return @

  stop: (e) =>
    e.preventDefault()
    @model.stop()
    @model.trigger 'showPlay'

