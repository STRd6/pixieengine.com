#= require models/people_collection
#= require models/person

describe "Person model", ->
  it "should have a URL based on the collection url", ->
    collection = new Pixie.Models.PeopleCollection
    model = new Pixie.Models.Person

    model.collection = collection

    expect(model.url()).toEqual("/people")
