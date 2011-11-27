require '/assets/views/paginated.js'

describe "Paginated View", ->
  beforeEach ->
    @view = new Pixie.Views.Paginated

  describe "initialization", ->
    it "should create a page link container", ->
      expect(@view.el.nodeName).toEqual('DIV')
