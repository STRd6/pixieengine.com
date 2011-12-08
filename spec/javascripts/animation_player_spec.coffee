require '/assets/models/animation_player.js'

beforeEach ->
  @model = new Pixie.Models.AnimationPlayer

describe "AnimationPlayer model", ->
  it "should set the correct default values", ->
    expect(@model.get('paused')).toBeFalsy()
    expect(@model.get('playing')).toBeFalsy()
    expect(@model.get('stopped')).toBeTruthy()

  it "should set the correct state when play is called", ->
    @model.play()

    expect(@model.get('paused')).toBeFalsy()
    expect(@model.get('playing')).toBeTruthy()
    expect(@model.get('stopped')).toBeFalsy()

  it "should set the correct state when pause is called", ->
    @model.pause()

    expect(@model.get('paused')).toBeTruthy()
    expect(@model.get('playing')).toBeFalsy()
    expect(@model.get('stopped')).toBeFalsy()

  it "should set the correct state when stop is called", ->
    @model.stop()

    expect(@model.get('paused')).toBeFalsy()
    expect(@model.get('playing')).toBeFalsy()
    expect(@model.get('stopped')).toBeTruthy()

  it "should be able to advance the frame", ->
    @model.set
      totalFrames: 3

    expect(@model.get('frame')).toEqual(0)

    @model.nextFrame()

    expect(@model.get('frame')).toEqual(1)

    @model.nextFrame()
    @model.nextFrame()

    expect(@model.get('frame')).toEqual(0)

  it "should be able to rewind the frame", ->
    @model.set
      totalFrames: 4

    expect(@model.get('frame')).toEqual(0)

    @model.previousFrame()

    expect(@model.get('frame')).toEqual(3)

  it "should be able to go to a specific frame in range", ->
    @model.set
      totalFrames: 5

    expect(@model.get('frame')).toEqual(0)

    @model.toFrame(3)

    expect(@model.get('frame')).toEqual(3)

    @model.toFrame(-1)

    expect(@model.get('frame')).toEqual(3)

    @model.toFrame(10)

    expect(@model.get('frame')).toEqual(3)

  it "should be able to adjust the fps", ->
    @model.fps(40)

    expect(@model.get('fps')).toEqual(40)

    @model.fps(0)

    expect(@model.get('fps')).toEqual(40)

    @model.fps(100)

    expect(@model.get('fps')).toEqual(40)

  it "should have a playback id when it starts playing back", ->
    expect(@model.get('playbackId')).toEqual(null)

    @model.play()

    expect(@model.get('playbackId')).toBeTruthy()

  it "should set the playback id to null when it stops playing", ->
    @model.play()

    expect(@model.get('playbackId')).toBeTruthy()

    @model.stop()

    expect(@model.get('playbackId')).toEqual(null)
