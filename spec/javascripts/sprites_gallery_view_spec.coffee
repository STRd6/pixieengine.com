require '/assets/jquery.tmpl.min.js'
require '/assets/views/sprites/gallery.js'

describe "Sprites Gallery", ->
  beforeEach ->
    @view = new Pixie.Views.Sprites.Gallery

  describe "initialization", ->
    it "should create a top level gallery container", ->
      expect(@view.el).toEqual('.sprites')
