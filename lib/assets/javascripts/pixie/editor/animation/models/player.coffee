#= require pixie/editor/animation/models/frames_collection
#= require pixie/editor/animation/models/settings

namespace "Pixie.Editor.Animation.Models", (Models) ->
  class Models.AnimationPlayer extends Backbone.Model
    defaults:
      paused: false
      playing: false
      stopped: true
      fps: 30
      playbackId: null
      frames: new Models.FramesCollection
      settings: new Models.Settings

    initialize: ->
      @bind 'change:fps', =>
        if id = @get('playbackId')
          clearInterval(id)

          @set
            playbackId: null

          @play()

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

    nextFrame: =>
      unless @get('paused')
        settings = @get 'settings'
        frames = @get 'frames'

        settings.set
          selected: (settings.get('selected') + 1).mod(frames.flattenFrames().length)

    validate: (attrs) ->
      if attrs.fps?
        unless 0 < attrs.fps <= 60
          return "fps must be between 0 and 60"


