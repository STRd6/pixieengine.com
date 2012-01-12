require '/assets/pixie/editor/animation/models/player.js'

beforeEach ->
  @model = new Pixie.Editor.Animation.Models.AnimationPlayer
  @clock = sinon.useFakeTimers()

describe "AnimationPlayer", ->
  it "should set the correct default values", ->
    expect(@model.get('paused')).toBeFalsy()
    expect(@model.get('playing')).toBeFalsy()
    expect(@model.get('stopped')).toBeTruthy()

  describe "playback", ->
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

    it "should be able to adjust the fps", ->
      @model.set
        fps: 40

      expect(@model.get('fps')).toEqual(40)

      @model.set
        fps: 0

      expect(@model.get('fps')).toEqual(40)

      @model.set
        fps: 100

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

    it "should advance the frame the correct number of times according to the frame rate", ->
      @model.set
        fps: 30

      callCount = 0

      # HAX: use spies to test this for real by checking to see that @model.get('frames').nextFrame has been called 30 times
      @model.get('settings').bind 'change:selected', ->
        callCount++

      @model.play()

      @clock.tick(1001)

      expect(callCount).toEqual(30)

    it "should advance the frame the correct number of times after changing the frame rate", ->
      @model.set
        fps: 30

      callCount = 0

      @model.get('settings').bind 'change:selected', ->
        callCount++

      @model.play()

      @clock.tick(1001)

      expect(callCount).toEqual(30)

      @model.set
        fps: 60

      callCount = 0

      @clock.tick(1001)

      expect(callCount).toEqual(60)

