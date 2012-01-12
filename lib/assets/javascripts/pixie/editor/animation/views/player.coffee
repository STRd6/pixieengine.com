#= require pixie/editor/animation/models/player
#= require pixie/view

#= require tmpls/editors/animation/player

EMPTY_MODEL =
  src: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQIHWP4//8/AwAI/AL+5gz/qwAAAABJRU5ErkJggg=='

namespace "Pixie.Editor.Animation.Views", (Views) ->
  {Models} = Pixie.Editor.Animation

  class Views.Player extends Pixie.View
    className: 'player'

    template: 'editors/animation/player'

    events:
      'click .pause': 'pause'
      'click .play': 'play'
      'click .stop': 'stop'

    initialize: ->
      super

      @model = new Models.AnimationPlayer
        frames: @options.frames

      @$('.fps input').change (e) =>
        oldValue = @model.get 'fps'
        newValue = e.currentTarget.valueAsNumber

        $(e.currentTarget).val(oldValue) unless @model.set({ fps: newValue })

      @$('.scrubber').change (e) =>
        index = e.currentTarget.valueAsNumber

        @model.set({ scrubberPosition: index })

      @model.bind 'change:scrubberPosition', (model, scrubberPosition) =>
        @$('.scrubber').val(scrubberPosition)

        @options.frames.toFrame(scrubberPosition)

        @refreshImage(model.get('frames').at(scrubberPosition))

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

    refreshImage: (model) =>
      src = (model?.get('frames').first() || EMPTY_MODEL).src

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

      @$('img').attr 'src', EMPTY_MODEL.src
