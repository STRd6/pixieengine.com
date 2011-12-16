#= require underscore
#= require backbone

#= require models/animation_player

#= require tmpls/lebenmeister/player

window.Pixie ||= {}
Pixie.Views ||= {}
Pixie.Views.Animations ||= {}

EMPTY_MODEL = new Backbone.Model

class Pixie.Views.Animations.Player extends Backbone.View
  el: '.player'

  events:
    'click .pause': 'pause'
    'click .play': 'play'
    'click .stop': 'stop'

  initialize: ->
    @model = new Pixie.Models.AnimationPlayer

    @frames = @options.frames

    @frames.bind 'updateSelected', (model, index) =>
      $(@el).find('.scrubber').val(index)

      @refreshImage(model)

    @frames.bind 'add', =>
      $(@el).find('.scrubber').attr('max', Math.max(0, @frames.length - 1))

    @frames.bind 'reset', =>
      $(@el).find('.scrubber').attr('max', Math.max(0, @frames.length - 1))

    @render()

  pause: (e) =>
    e.preventDefault()

    @model.pause()
    @showPlay()

  play: (e) =>
    e.preventDefault()

    @model.play()
    @showPause()

  render: =>
    $(@el).append($.tmpl('lebenmeister/player', @model.toJSON()))

    return @

  refreshImage: (model) =>
    src = (model || EMPTY_MODEL).get('src')

    $(@el).find('img').attr('src', src)

  resetScrubber: =>
    $(@el).find('.scrubber').val(0)

  showPause: =>
    $(@el).find('.pause').show()
    $(@el).find('.play').hide()

  showPlay: =>
    $(@el).find('.play').show()
    $(@el).find('.pause').hide()

  stop: (e) =>
    e.preventDefault()

    @model.stop()
    @resetScrubber()
    @showPlay()
    @trigger 'clearSelectedFrames'

    # set the preview src to be a transparent 1 x 1 image
    $(@el).find('img').attr 'src', 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQIHWP4//8/AwAI/AL+5gz/qwAAAABJRU5ErkJggg=='

