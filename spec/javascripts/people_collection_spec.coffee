#= require models/people_collection

describe "People collection", ->
  beforeEach ->
    @collection = new Pixie.Models.PeopleCollection

  it "should have correct url", ->
    expect(@collection.url()).toEqual("/people")

  it "should request new data when filtered", ->
    filterSpy = sinon.spy(@collection, 'filterPages')

    @collection.filterPages('all')

    expect(filterSpy).toHaveBeenCalledOnce()
