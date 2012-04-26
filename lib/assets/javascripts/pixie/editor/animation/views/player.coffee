#= require pixie/editor/animation/models/player
#= require pixie/view

#= require templates/editors/animation/player

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
        settings: @settings

      @$('.fps input').change (e) =>
        oldValue = @model.get 'fps'
        newValue = e.currentTarget.valueAsNumber

        $(e.currentTarget).val(oldValue) unless @model.set({ fps: newValue })

      @$('.scrubber').change (e) =>
        index = e.currentTarget.valueAsNumber

        @settings.set
          selected: index

      @settings.bind 'change:selected', (model, selected) =>
        @$('.scrubber').val(selected)

        flattenedFrames = @options.frames.flattenFrames()

        @refreshImage(flattenedFrames[selected])

      @model.get('frames').bind 'add', (model, collection) =>
        @updateScrubberMax(collection)

      @model.get('frames').bind 'remove', (model, collection) =>
        @updateScrubberMax(collection)

      @model.bind 'change', (model) =>
        playing = model.get 'playing'
        paused = model.get 'paused'
        stopped = model.get 'stopped'

        if playing
          @showPause()
        else if paused
          @showPlay()
        else if stopped
          @showPlay()

    pause: (e) =>
      e.preventDefault()

      @model.pause()

    play: (e) =>
      e.preventDefault()

      @model.play()

    refreshImage: (frame) =>
      src = (frame || EMPTY_MODEL).src

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
      @settings.set
        selected: 0

      @$('img').attr 'src', EMPTY_MODEL.src

    updateScrubberMax: (collection) =>
      @$('.scrubber').attr('max', Math.max(0, collection.flattenFrames().length - 1))
