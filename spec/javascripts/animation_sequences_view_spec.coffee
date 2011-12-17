require '/assets/views/animations/sequences.js'

beforeEach ->
  $('#test').append($('<nav class="right"></nav>'))
  @view = new Pixie.Views.Animations.Sequences
  @collection = new Backbone.Collection

  @sequencesCollectionStub = sinon.stub(Pixie.Models, "SequencesCollection").returns(@collection)

afterEach ->
  Pixie.Models.SequencesCollection.restore()

describe "rendering", ->
  it "should append to the correct container", ->
    expect($('nav.right').children().length).toBeTruthy()

