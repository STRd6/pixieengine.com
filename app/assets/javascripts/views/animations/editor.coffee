#= require underscore
#= require backbone

#= require views/animations/player
#= require views/animations/tileset
#= require views/animations/frames
#= require views/animations/sequences

#= require tmpls/lebenmeister/editor_frame

window.Pixie ||= {}
Pixie.Views ||= {}
Pixie.Views.Animations ||= {}

class Pixie.Views.Animations.Editor extends Backbone.View
  el: '.backbone_lebenmeister'

  initialize: ->
    # force jQuery @el
    @el = $(@el)

    self = @

    @render()

    @tilesetView = new Pixie.Views.Animations.Tileset
    @framesView = new Pixie.Views.Animations.Frames
    @playerView = new Pixie.Views.Animations.Player
      frames: @framesView.collection
    @sequencesView = new Pixie.Views.Animations.Sequences

    @playerView.bind 'clearSelectedFrames', =>
      @framesView.clearSelected()

    @playerView.model.bind 'nextFrame', =>
      @framesView.collection.nextFrame()

    @framesView.collection.bind 'updateSelected', (model, index) =>
      @framesView.highlight(index)

    @framesView.collection.bind 'createSequence', =>
      @sequencesView.collection.add(new Pixie.Models.Sequence)
      @sequencesView.render()

    @tilesetView.collection.bind 'addFrame', (model) =>
      @framesView.collection.add(model.clone())

    @$('.content .relative').append(@playerView.el)

    @$('.scrubber').change ->
      index = $(this).val().parse()

      self.framesView.highlight(index)
      self.framesView.collection.toFrame(index)

    @el.dropImageReader (file, event) =>
      if event.target.readyState == FileReader.DONE
        src = event.target.result
        name = file.fileName

        # TODO Add in support for sprite sheets
        #[dimensions, tileWidth, tileHeight] = name.match(/x(\d*)y(\d*)/) || []

        #if tileWidth && tileHeight
        #  loadSpriteSheet src, parseInt(tileWidth), parseInt(tileHeight), (sprite) ->
        #    addTile(sprite)

        @tilesetView.collection.add({src: src})

  render: =>
    @el.append($.tmpl('lebenmeister/editor_frame'))

    return @
