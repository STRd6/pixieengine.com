require '/assets/models/people_collection.js'

beforeEach ->
  @collection = new Pixie.Models.PeopleCollection

describe "People collection", ->
  it "should have correct url", ->
    expect(@collection.url()).toEqual("/people")

  it "should request new data when filtered", ->
    filterSpy = sinon.spy(@collection, 'filterPages')

    @collection.filterPages('all')

    expect(filterSpy).toHaveBeenCalledOnce()
