#= require pixie/editor/animation/views/editor

describe "Animation Editor", ->
  beforeEach ->
    @clock = sinon.useFakeTimers()

    @view = new Pixie.Editor.Animation.Views.Editor

    $('#test').append(@view.el)

    @model = new Backbone.Model
      frames: []

  afterEach ->
    @clock.restore()

  describe "initialization", ->
    it "should set up the editor DOM with the correct toolbar areas", ->
      expect($(@view.el).find('nav.left')).toExist()
      expect($(@view.el).find('nav.right')).toExist()
      expect($(@view.el).find('nav.bottom')).toExist()

    it "should have elements to contain a player with controls to manipulate the animation", ->
      expect($(@view.el).find('.player')).toExist()
      expect($(@view.el).find('.player .controls')).toExist()

    it "should have a place for tiles", ->
      expect($(@view.el).find('nav.left .sprites')).toExist()
      expect($(@view.el).find('nav.left h3')).toHaveText('Sprites')

    it "should have a place for frames", ->
      expect($(@view.el).find('nav.bottom .sprites')).toExist()
      expect($(@view.el).find('nav.bottom h3')).toHaveText('Frames')
