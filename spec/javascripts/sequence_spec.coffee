require '/assets/models/frames_collection.js'
require '/assets/models/sequence.js'

describe "Sequence model", ->
  it "should contain a frames collection", ->
    sequence = new Pixie.Models.Sequence

    expect(sequence.get 'frames').toBeDefined()
