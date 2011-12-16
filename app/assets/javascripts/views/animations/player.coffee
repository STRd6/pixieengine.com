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

    @frames = @options.frames

    @model.bind 'showPause', =>
      $(@el).find('.pause').show()
      $(@el).find('.play').hide()

    @model.bind 'showPlay', =>
      $(@el).find('.play').show()
      $(@el).find('.pause').hide()

    @frames.bind 'updateSelected', (model, index) =>
      $(@el).find('.scrubber').val(index)

      if model
        @refreshImage(model)


    @frames.bind 'add', =>
      $(@el).find('.scrubber').attr('max', @frames.length)

    @frames.bind 'reset', =>
      $(@el).find('.scrubber').attr('max', @frames.length)

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

  refreshImage: (model) =>
    $(@el).find('img').attr('src', model.toJSON().src)

  resetScrubber: =>
    $(@el).find('.scrubber').val(0)

  stop: (e) =>
    e.preventDefault()

    @model.stop()
    @resetScrubber()
    @model.trigger 'showPlay'

