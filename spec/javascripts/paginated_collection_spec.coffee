#= require models/paginated_collection

describe "Paginated collection", ->
  beforeEach ->
    @collection = new Pixie.Models.PaginatedCollection
      params: new Backbone.Model
        page: 1

    @collection.url = '/tests'

  describe "initialization", ->
    it "should have a params model", ->
      expect(@collection.params instanceof Backbone.Model).toBeTruthy()

  describe "page navigation", ->
    it "should move to the next page", ->
      changeSpy = sinon.spy()

      @collection.params.on 'change', changeSpy

      @collection.nextPage()

      expect(changeSpy).toHaveBeenCalledOnce()
      expect(@collection.params.get('page')).toEqual(2)

    it "should not move past the last page", ->
      @collection.params.set
        page: 5

      @collection.total = 5

      changeSpy = sinon.spy()

      @collection.params.on 'change', changeSpy

      @collection.nextPage()

      expect(changeSpy).not.toHaveBeenCalledOnce()

    it "should move to the previous page", ->
      @collection.params.set
        page: 2

      changeSpy = sinon.spy()

      @collection.params.on 'change', changeSpy

      @collection.previousPage()

      expect(changeSpy).toHaveBeenCalledOnce()
      expect(@collection.params.get('page')).toEqual(1)

    it "should not move before the first page", ->
      changeSpy = sinon.spy()

      @collection.params.on 'change', changeSpy

      @collection.previousPage()

      expect(changeSpy).not.toHaveBeenCalledOnce()

    it "should go to the selected page", ->
      @collection.total = 5

      changeSpy = sinon.spy()

      @collection.params.on 'change', changeSpy

      @collection.toPage(3)

      expect(changeSpy).toHaveBeenCalledOnce()
      expect(@collection.params.get('page')).toEqual(3)

    it "should not go to an out of range page", ->
      @collection.total = 5

      changeSpy = sinon.spy()

      @collection.params.on 'change', changeSpy

      @collection.toPage(6)

      expect(changeSpy).not.toHaveBeenCalled()

      @collection.toPage(0)

      expect(changeSpy).not.toHaveBeenCalled()

    it "should have the correct page range when current page is at the beginning", ->
      @collection.params.set
        page: 2

      @collection.total = 25

      range = @collection.pageInfo().range
      rangeLength = @collection.pageInfo().range.length

      expect(rangeLength).toEqual(12)

      expect(range.first()).toEqual(1)
      expect(range.last()).toEqual(25)

      expect(range[rangeLength - 2]).toEqual(24)
      expect(range[rangeLength - 3]).toEqual('...')

    it "should have the correct page range when current page is in the middle", ->
      @collection.params.set
        page: 13

      @collection.total = 25

      range = @collection.pageInfo().range
      rangeLength = @collection.pageInfo().range.length

      expect(rangeLength).toEqual(15)

      expect(range.first()).toEqual(1)
      expect(range.last()).toEqual(25)

      expect(range[1]).toEqual(2)
      expect(range[2]).toEqual('...')

      expect(range[rangeLength - 2]).toEqual(24)
      expect(range[rangeLength - 3]).toEqual('...')

    it "should have the correct page range when current page is at the end", ->
      @collection.params.set
        page: 24

      @collection.total = 25

      range = @collection.pageInfo().range
      rangeLength = @collection.pageInfo().range.length

      expect(rangeLength).toEqual(12)

      expect(range.first()).toEqual(1)
      expect(range.last()).toEqual(25)

      expect(range[1]).toEqual(2)
      expect(range[2]).toEqual('...')

  describe "server response", ->
    beforeEach ->
      @fixture = @fixtures.PaginatedCollection.valid
      @server = sinon.fakeServer.create()
      @server.respondWith(
        "GET",
        "/tests?page=1",
        @validResponse(@fixture)
      )

    afterEach ->
      @server.restore()

    it "should make the correct request", ->
      @collection.fetch()

      expect(@server.requests.length).toEqual(1)
      expect(@server.requests[0].method).toEqual("GET")
      expect(@server.requests[0].url).toEqual("/tests?page=1")

    it "should pull off and assign instance variables from the server data", ->
      @collection.fetch()
      @server.respond()

      expect(@collection.length).toEqual(@fixture.models.length)

      expect(@collection.params.get('page')).toEqual(@fixture.page)
      expect(@collection.total).toEqual(@fixture.total)
      expect(@collection.current_user_id).toEqual(@fixture.current_user_id)

    it "should make requests to the server based on params passed in", ->
      @collection.params.set
        testing: "true"

      @collection.fetch()

      expect(@server.requests[0].url).toEqual("/tests?page=1&testing=true")
