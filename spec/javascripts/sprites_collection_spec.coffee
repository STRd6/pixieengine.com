require '/assets/models/sprites_collection.js'

beforeEach ->
  @collection = new Pixie.Models.SpritesCollection

describe "Sprites collection", ->
  it "should have correct default url", ->
    expect(@collection.url()).toEqual("/sprites")

  it "should request new data when tags are provided", ->
    filterSpy = sinon.spy(@collection, 'filterTagged')

    @collection.filterTagged('Nethack')

    expect(filterSpy).toHaveBeenCalledOnce()
