#= require models/query_string

describe "query string model", ->
  beforeEach ->
    @model = new Pixie.Models.QueryString

  it "should have default page attribute", ->
    expect(@model.get('page')).toEqual(1)

  describe "#queryString", ->
    it "should output correctly with only a page param", ->
      expect(@model.queryString()).toEqual('?page=1')

    it "should output correctly with a page and filter param", ->
      @model.set
        filter: 'arcade'

      expect(@model.queryString()).toEqual('?page=1&filter=arcade')

    it "should output correctly with a page and filter param inserted in a different order", ->
      @model = new Pixie.Models.QueryString
        filter: 'arcade'
        page: 2

      expect(@model.queryString()).toEqual('?page=2&filter=arcade')

    it "should output correctly with a page, filter, and search param", ->
      @model.set
        filter: 'tutorial'
        search: 'red'

      expect(@model.queryString()).toEqual('?page=1&filter=tutorial&search=red')
