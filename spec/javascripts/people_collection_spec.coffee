require '/assets/models/people_collection.js'

beforeEach ->
  @collection = new Pixie.Models.PeopleCollection

describe "People collection", ->
  it "should have correct url", ->
    expect(@collection.url()).toEqual("/people")
