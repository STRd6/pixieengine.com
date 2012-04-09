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

  describe "interactions", ->
    it "should show the pause button after the play button is clicked", ->
      $('.play').click()

      expect($('.pause')).toBeVisible()
      expect($('.play')).toBeHidden()

    it "should show the play button after the pause button is clicked", ->
      $('.play').click()
      $('.pause').click()

      expect($('.pause')).toBeHidden()
      expect($('.play')).toBeVisible()

    it "should show the play button after the stop button is clicked", ->
      $('.play').click()
      $('.stop').click()

      expect($('.pause')).toBeHidden()
      expect($('.play')).toBeVisible()

    it "should add a sequence when create sequence is clicked", ->
      #fake adding a frame
      @view.framesView.collection.add(@model)

      $('button.create_sequence').click()

      expect($('.right .sequence')).toExist()

    it "should change fps when user edits fps value", ->
      expect(@view.playerView.model.get('fps')).toEqual(30)

      # simulate user changing fps value
      $('.fps input').val(10).change()

      expect(@view.playerView.model.get('fps')).toEqual(10)

