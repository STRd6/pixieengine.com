require '/assets/pixie/editor/animation/models/frames_collection.js'
require '/assets/pixie/editor/animation/models/sequence.js'

describe "Sequence model", ->
  it "should contain a frames collection", ->
    sequence = new Pixie.Editor.Animation.Models.Sequence

    expect(sequence.get 'frames').toBeDefined()
