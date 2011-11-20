require '/assets/jquery/jquery.min.js'
require '/assets/models/paginated_collection.js'
require '/assets/sinon.js'

beforeEach ->
  @server = sinon.fakeServer.create()

  @collection = new Pixie.Models.PaginatedCollection
  @collection.url = '/tests'
  expect(@collection.pageInfo().page).toEqual(1)

afterEach ->
  @server.restore()

describe "Paginated collection", ->
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

  describe "server response", ->
    it "should make the correct request", ->
      @collection.fetch()

      expect(@server.requests.length).toEqual(1)
      expect(@server.requests[0].method).toEqual("GET")
      expect(@server.requests[0].url).toEqual("/tests?page=1")

