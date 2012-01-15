require '/assets/pixie/editor/animation/views/tileset.js'

beforeEach ->
  $('#test').append('<section class="backbone_lebenmeister"></section>')
  @view = new Pixie.Editor.Animation.Views.Editor

  @collection = new Backbone.Collection

  @model = new Backbone.Model
    frames: [{src: ''}]

  @framesCollectionStub = sinon.stub(Pixie.Editor.Animation.Models, "TilesCollection").returns(@collection)

afterEach ->
  Pixie.Editor.Animation.Models.TilesCollection.restore()

describe "interactions", ->
  it "should be able to add tiles to the view", ->
    addFrameSpy = sinon.spy()

    #fake adding a tile
    @view.tilesetView.addTile(@model)

    expect($(@view.el).find('.sprites').children().length).toBeTruthy()
