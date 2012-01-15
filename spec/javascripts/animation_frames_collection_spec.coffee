require '/assets/pixie/editor/animation/models/frames_collection.js'

beforeEach ->
  @collection = new Pixie.Editor.Animation.Models.FramesCollection

  @model = new Backbone.Model

describe "Frames collection", ->
  it "should allow the frames to be cleared once there is a frame", ->
    frameActionsSpy = sinon.spy()

    @collection.bind 'add', frameActionsSpy

    @collection.add(@model)

    @expect(@collection.length).toBeTruthy()
    @expect(frameActionsSpy).toHaveBeenCalledOnce()
