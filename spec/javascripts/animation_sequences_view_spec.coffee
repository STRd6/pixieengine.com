require '/assets/pixie/editor/animation/views/sequences.js'

beforeEach ->
  $('#test').append($('<nav class="right"></nav>'))
  @view = new Pixie.Editor.Animation.Views.Sequences
  @collection = new Backbone.Collection

  @sequencesCollectionStub = sinon.stub(Pixie.Editor.Animation.Models, "SequencesCollection").returns(@collection)

afterEach ->
  Pixie.Editor.Animation.Models.SequencesCollection.restore()

