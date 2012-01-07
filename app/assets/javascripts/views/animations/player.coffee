#= require models/animation_player

#= require tmpls/lebenmeister/player

EMPTY_MODEL = new Backbone.Model

namespace "Pixie.Views.Animations", (Animations) ->
  {Models} = Pixie

  class Animations.Player extends Backbone.View
    el: '.player'

    events:
      'click .pause': 'pause'
      'click .play': 'play'
      'click .stop': 'stop'

    initialize: ->
      # force jQuery el
      @el = $(@el)

      @model = new Models.AnimationPlayer
        frames: @options.frames

      @render()

      @$('.fps input').change (e) =>
        oldValue = @model.get 'fps'
        newValue = $(e.currentTarget).get(0).valueAsNumber

        $(e.currentTarget).val(oldValue) unless @model.set({ fps: newValue })

      @model.bind 'change:scrubberPosition', (model, scrubberPosition) =>
        @$('.scrubber').val(scrubberPosition)

        @refreshImage(model)

      @model.get('frames').bind 'add', (model, collection) =>
        @$('.scrubber').attr('max', Math.max(0, collection.length - 1))

    pause: (e) =>
      e.preventDefault()

      @model.pause()
      @showPlay()

    play: (e) =>
      e.preventDefault()

      @model.play()
      @showPause()

    render: =>
      @el.append $.tmpl('lebenmeister/player', @model.toJSON())

      return @

    refreshImage: (model) =>
      src = (model || EMPTY_MODEL).get('src')

      @$('img').attr('src', src)

    showPause: =>
      @$('.pause').show()
      @$('.play').hide()

    showPlay: =>
      @$('.play').show()
      @$('.pause').hide()

    stop: (e) =>
      e.preventDefault()

      @model.stop()
      @showPlay()
      @trigger 'clearSelectedFrames'

      # set the preview src to be a transparent 1 x 1 image
      @$('img').attr 'src', 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQIHWP4//8/AwAI/AL+5gz/qwAAAABJRU5ErkJggg=='

