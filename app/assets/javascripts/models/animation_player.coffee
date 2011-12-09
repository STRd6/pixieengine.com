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
    frame: 0
    fps: 30
    totalFrames: 10
    playbackId: null

  fps: (fps) =>
    if 0 < fps <= 60
      @set
        fps: fps

  pause: =>
    @set
      paused: true
      playing: false
      stopped: false

  play: =>
    @set
      paused: false
      playing: true
      stopped: false
      playbackId: @get('playbackId') || setInterval(@nextFrame, @get('fps') / 1000)

  stop: =>
    clearInterval(@get('playbackId'))

    @set
      paused: false
      playing: false
      stopped: true
      playbackId: null
      frame: 0

  nextFrame: =>
    unless @get('paused')
      @set
        frame: (@get('frame') + 1).mod(@get('totalFrames'))

  previousFrame: =>
    unless @get('paused')
      @set
        frame: (@get('frame') - 1).mod(@get('totalFrames'))

  toFrame: (frame) =>
    if 0 <= frame < @get('totalFrames')
      @set
        frame: frame
