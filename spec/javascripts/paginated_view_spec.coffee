require '/assets/views/paginated.js'

describe "Paginated View", ->
  beforeEach ->
    @collection = new Backbone.Collection()
    @view = new Pixie.Views.Paginated
      collection: @collection

  describe "initialization", ->
    it "should create a page link container", ->
      expect(@view.el.nodeName).toEqual('NAV')
      expect($(@view.el)).toHaveClass('pagination')
