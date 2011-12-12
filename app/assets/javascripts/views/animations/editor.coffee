#= require underscore
#= require backbone

#= require views/animations/player
#= require views/animations/tileset
#= require views/animations/frames

#= require tmpls/lebenmeister/editor_frame

window.Pixie ||= {}
Pixie.Views ||= {}
Pixie.Views.Animations ||= {}

class Pixie.Views.Animations.Editor extends Backbone.View
  el: '.backbone_lebenmeister'

  initialize: ->
    @render()

    @tilesetView = new Pixie.Views.Animations.Tileset
    @framesView = new Pixie.Views.Animations.Frames
    @playerView = new Pixie.Views.Animations.Player
      frames: @framesView.collection

    @framesView.collection.bind 'updateSelected', (model) =>
      @playerView.refreshImage(model)

    @playerView.model.bind 'nextFrame', =>
      @framesView.collection.nextFrame()

    @tilesetView.collection.bind 'addFrame', (model) =>
      @framesView.collection.add(model.clone())
      $(@el).find('.scrubber').attr('max', @framesView.collection.length)

    $(@el).find('.content .relative').append(@playerView.el)

    $(@el).dropImageReader (file, event) =>
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
    $(@el).append($.tmpl('lebenmeister/editor_frame'))

    return @
