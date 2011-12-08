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
    totalFrames: 1
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
      playbackId: setInterval(@nextFrame, @get('fps') / 1000)

  stop: =>
    @set
      paused: false
      playing: false
      stopped: true
      playbackId: null

  nextFrame: =>
    @set
      frame: (@get('frame') + 1).mod(@get('totalFrames'))

  previousFrame: =>
    @set
      frame: (@get('frame') - 1).mod(@get('totalFrames'))

  toFrame: (frame) =>
    if 0 <= frame < @get('totalFrames')
      @set
        frame: frame
