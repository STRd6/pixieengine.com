#= require underscore
#= require backbone

#= require models/animation_player

#= require tmpls/lebenmeister/player

window.Pixie ||= {}
Pixie.Views ||= {}
Pixie.Views.Animations ||= {}

class Pixie.Views.Animations.Player extends Backbone.View
  el: '.player'

  events:
    'click .pause': 'pause'
    'click .play': 'play'
    'click .stop': 'stop'

  initialize: ->
    @model = new Pixie.Models.AnimationPlayer

    @model.bind 'showPause', =>
      $(@el).find('.pause').show()
      $(@el).find('.play').hide()

    @model.bind 'showPlay', =>
      $(@el).find('.play').show()
      $(@el).find('.pause').hide()

    @model.bind 'change:frame', (model, frame) =>
      $(@el).find('.scrubber').val(frame)

    @render()

  pause: (e) =>
    e.preventDefault()

    @model.pause()
    @model.trigger 'showPlay'

  play: (e) =>
    e.preventDefault()

    @model.play()
    @model.trigger 'showPause'

  render: =>
    $(@el).append($.tmpl('lebenmeister/player', @model.toJSON()))

    return @

  stop: (e) =>
    e.preventDefault()

    @model.stop()
    @model.trigger 'showPlay'

