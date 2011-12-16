#= require underscore
#= require backbone
#= require corelib

window.Pixie ||= {}
Pixie.Models ||= {}

class Pixie.Models.AnimationPlayer extends Backbone.Model
  defaults:
    paused: false
    playing: false
    stopped: true
    fps: 30
    playbackId: null

  fps: (fps) =>
    if 0 < fps <= 60
      @set({fps: fps})

      if id = @get('playbackId')
        @stop()
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
      @trigger 'nextFrame'

  previousFrame: =>
    unless @get('paused')
      @trigger 'previousFrame'

  toFrame: (frame) =>
    if 0 <= frame < @get('totalFrames')
      @set({frame: frame})
