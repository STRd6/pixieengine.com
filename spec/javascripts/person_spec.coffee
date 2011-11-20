require '/assets/models/people_collection.js'
require '/assets/models/person.js'

describe "Person model", ->
  it "should have a URL based on the collection url", ->
    collection = new Pixie.Models.PeopleCollection
    model = new Pixie.Models.Person

    model.collection = collection

    expect(model.url()).toEqual("/people")
