#= require pixie/editor/animation/models/frames_collection

namespace "Pixie.Editor.Animation.Models", (Models) ->
  class Models.AnimationPlayer extends Backbone.Model
    defaults:
      paused: false
      playing: false
      stopped: true
      fps: 30
      playbackId: null
      scrubberPosition: 0
      frames: new Models.FramesCollection

    initialize: ->
      @bind 'change:fps', =>
        if id = @get('playbackId')
          clearInterval(id)

          @set
            playbackId: null

          @play()

      @get('frames').bind 'change:selected', (collection, index) =>
        @set
          scrubberPosition: index

    pause: =>
      @set
        paused: true
        playing: false
        stopped: false

    play: =>
      playbackId = @get('playbackId') || setInterval(@nextFrame, 1000 / @get('fps'))

      @set
        paused: false
        playing: true
        stopped: false
        playbackId: playbackId

    stop: =>
      clearInterval(@get('playbackId'))

      @set
        paused: false
        playing: false
        stopped: true
        playbackId: null
        scrubberPosition: 0

    nextFrame: =>
      unless @get('paused')
        @get('frames').nextFrame()

    validate: (attrs) ->
      if attrs.fps?
        unless 0 < attrs.fps <= 60
          return "fps must be between 0 and 60"


