require '/assets/models/frames_collection.js'

beforeEach ->
  @collection = new Pixie.Models.FramesCollection

  @model = new Backbone.Model

describe "Frames collection", ->
  it "should allow the frames to be cleared once there is a frame", ->
    frameActionsSpy = sinon.spy()

    @collection.bind 'enableFrameActions', frameActionsSpy

    @collection.add(@model)

    @expect(@collection.length).toBeTruthy()
    @expect(frameActionsSpy).toHaveBeenCalledOnce()
