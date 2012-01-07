require '/assets/views/animations/tileset.js'

beforeEach ->
  $('#test').append('<section class="backbone_lebenmeister"></section>')
  @view = new Pixie.Views.Animations.Editor

  @collection = new Backbone.Collection

  @model = new Backbone.Model

  @framesCollectionStub = sinon.stub(Pixie.Models, "TilesCollection").returns(@collection)

afterEach ->
  Pixie.Models.TilesCollection.restore()

describe "interactions", ->
  it "should be able to add tiles to the view", ->
    addFrameSpy = sinon.spy()

    #fake adding a tile
    @view.tilesetView.addTile(@model)

    expect($(@view.el).find('.sprites').children().length).toBeTruthy()
