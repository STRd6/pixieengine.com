require '/assets/views/animations/frames.js'

beforeEach ->
  $('#test').append('<section class="backbone_lebenmeister"></section>')
  @view = new Pixie.Views.Animations.Editor
  @collection = new Backbone.Collection

  @model = new Backbone.Model
    frames: []

  @framesCollectionStub = sinon.stub(Pixie.Models, "FramesCollection").returns(@collection)

afterEach ->
  Pixie.Models.FramesCollection.restore()

describe "interactions", ->
  it "should have actions enabled when a frame is added", ->
    #fake adding a frame
    @view.framesView.collection.add(@model)

    expect($(@view.el).find('.bottom button')).not.toHaveAttr('disabled')

  it "should have no frames after clear is clicked", ->
    #fake adding a frame
    @view.framesView.collection.add(@model)

    $(@view.el).find('.bottom button.clear_frames').click()

    expect($(@view.el).find('.bottom .sprites').children().length).toBeFalsy()

    expect(@view.framesView.collection.length).toBeFalsy()

    expect($(@view.el).find('.bottom button')).toHaveAttr('disabled')

