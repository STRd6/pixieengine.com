#= require underscore
#= require backbone
#= require corelib

#= require views/animations/player
#= require views/animations/tileset
#= require views/animations/frames
#= require views/animations/sequences

#= require tmpls/lebenmeister/editor_frame

#= require pixie/editor/base
#= require pixie/view

namespace "Pixie.Views.Animations", (Animations) ->
  {Models} = Pixie

  class Animations.Editor extends Pixie.View
    className: 'editor backbone_lebenmeister'

    template: 'lebenmeister/editor_frame'

    initialize: ->
      super

      @sequencesCollection = new Models.SequencesCollection
      @framesCollection = new Models.FramesCollection
      @tilesCollection = new Models.TilesCollection

      contentEl = @$('.content')

      @tilesetView = new Animations.Tileset
        collection: @tilesCollection
      contentEl.append @tilesetView.el

      @framesView = new Animations.Frames
        collection: @framesCollection
      contentEl.append @framesView.el

      @playerView = new Animations.Player
        frames: @framesCollection
      @$('.content .relative').append @playerView.el

      @sequencesView = new Animations.Sequences
        collection: @sequencesCollection
      contentEl.append @sequencesView.el

      @sequencesCollection.bind 'addSequenceToFrames', (sequence) =>
        @framesView.addSequence(sequence)

      @tilesCollection.bind 'addFrame', (model) =>
        @framesView.addSequence(model)

      @playerView.bind 'clearSelectedFrames', =>
        @framesView.clearSelected()

      @framesCollection.bind 'createSequence', (collection) =>
        sequence = new Models.Sequence
          frames: collection.flattenFrames()

        @sequencesCollection.add(sequence)

      @$('.content .relative').append(@playerView.render().el)

      @tilesetView.bindDropImageReader(@el)

      @include Pixie.Editor.Base

      @takeFocus()

   takeFocus: ->
     super()

    events:
      mousemove: "takeFocus"
