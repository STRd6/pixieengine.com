require '/assets/views/animations/frames.js'

beforeEach ->
  $('#test').append($('<nav class="bottom"></nav>'))
  @view = new Pixie.Views.Animations.Frames
  @collection = new Backbone.Collection

  @model = new Backbone.Model
    frames: []

  @model.templateData = ->
    src: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQIHWP4//8/AwAI/AL+5gz/qwAAAABJRU5ErkJggg=="
    cid: "c3"

  @framesCollectionStub = sinon.stub(Pixie.Models, "FramesCollection").returns(@collection)

afterEach ->
  Pixie.Models.FramesCollection.restore()

describe "rendering", ->
  it "should append to the correct container", ->
    expect($('nav.bottom').children().length).toBeTruthy()

describe "interactions", ->
  it "should have actions enabled when a frame is added", ->
    #fake adding a frame
    @view.collection.add(@model)

    expect($(@view.el).find('button')).not.toHaveAttr('disabled')

  it "should have no frames after clear is clicked", ->
    #fake adding a frame
    @view.collection.add(@model)

    $(@view.el).find('button.clear_frames').click()

    expect($(@view.el).find('.sprites').children().length).toBeFalsy()

    expect(@view.collection.length).toBeFalsy()

    expect($(@view.el).find('button')).toHaveAttr('disabled')

