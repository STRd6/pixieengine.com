require '/assets/views/animations/tileset.js'

beforeEach ->
  $('#test').append($('<nav class="left"></nav>'))
  @view = new Pixie.Views.Animations.Tileset
  @collection = new Backbone.Collection

  @model = new Backbone.Model
  @model.templateData = ->
    {src: "http://fake.com/image.png", cid: "c3"}

  @framesCollectionStub = sinon.stub(Pixie.Models, "TilesCollection").returns(@collection)

afterEach ->
  Pixie.Models.TilesCollection.restore()

describe "rendering", ->
  it "should append to the correct container", ->
    expect($('nav.left').children().length).toBeTruthy()

describe "interactions", ->
  it "should call ", ->
    addFrameSpy = sinon.spy()

    #fake adding a tile
    @view.addTile(@model)

    expect($(@view.el).find('.sprites').children().length).toBeTruthy()
