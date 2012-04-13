#= require models/paginated_collection

describe "Paginated collection", ->
  beforeEach ->
    @collection = new Pixie.Models.PaginatedCollection
    @collection.url = '/tests'
    expect(@collection.pageInfo().page).toEqual(1)

  describe "page navigation", ->
    it "should move to the next page", ->
      fetchSpy = sinon.spy(@collection, 'fetch')

      @collection.nextPage()

      expect(fetchSpy).toHaveBeenCalledOnce()
      expect(@collection.pageInfo().page).toEqual(2)

    it "should not move past the last page", ->
      @collection.total = 5
      @collection.page = 5

      expect(@collection.pageInfo().page).toEqual(5)

      @collection.nextPage()

      expect(@collection.pageInfo().page).toEqual(5)

    it "should move to the previous page", ->
      @collection.page = 2

      fetchSpy = sinon.spy(@collection, 'fetch')

      expect(@collection.pageInfo().page).toEqual(2)

      @collection.previousPage()

      expect(fetchSpy).toHaveBeenCalledOnce()
      expect(@collection.pageInfo().page).toEqual(1)

    it "should not move before the first page", ->
      @collection.previousPage()

      expect(@collection.pageInfo().page).toEqual(1)

    it "should go to the selected page", ->
      @collection.total = 5

      fetchSpy = sinon.spy(@collection, 'fetch')

      @collection.toPage(3)

      expect(fetchSpy).toHaveBeenCalledOnce()
      expect(@collection.pageInfo().page).toEqual(3)

    it "should not go to an out of range page", ->
      @collection.total = 5

      fetchSpy = sinon.spy(@collection, 'fetch')

      @collection.toPage(6)

      expect(fetchSpy.called).toBeFalsy()
      expect(@collection.pageInfo().page).toEqual(1)

      @collection.toPage(0)

      expect(fetchSpy.called).toBeFalsy()
      expect(@collection.pageInfo().page).toEqual(1)

    it "should have the correct page range when current page is at the beginning", ->
      @collection.total = 25
      @collection.page = 2

      range = @collection.pageInfo().range
      rangeLength = @collection.pageInfo().range.length

      expect(rangeLength).toEqual(12)

      expect(range.first()).toEqual(1)
      expect(range.last()).toEqual(25)

      expect(range[rangeLength - 2]).toEqual(24)
      expect(range[rangeLength - 3]).toEqual('...')

    it "should have the correct page range when current page is in the middle", ->
      @collection.total = 25
      @collection.page = 13

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
      @collection.total = 25
      @collection.page = 24

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

      expect(@collection.page).toEqual(@fixture.page)
      expect(@collection.per_page).toEqual(@fixture.per_page)
      expect(@collection.total).toEqual(@fixture.total)
      expect(@collection.current_user_id).toEqual(@fixture.current_user_id)

    it "should make requests to the server based on params passed in", ->
      @collection.params.testing = "true"

      @collection.fetch()

      expect(@server.requests[0].url).toEqual("/tests?testing=true&page=1")
