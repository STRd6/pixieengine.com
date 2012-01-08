#= require underscore
#= require backbone
#= require corelib

#= require views/animations/player
#= require views/animations/tileset
#= require views/animations/frames
#= require views/animations/sequences

#= require tmpls/lebenmeister/editor_frame

#= require pixie/view

namespace "Pixie.Views.Animations", (Animations) ->
  {Models} = Pixie

  class Animations.Editor extends Pixie.View
    el: '.backbone_lebenmeister'

    initialize: ->
      super

      @render()

      @sequencesCollection = new Pixie.Models.SequencesCollection
      @framesCollection = new Pixie.Models.FramesCollection
      @tilesCollection = new Pixie.Models.TilesCollection

      @tilesetView = new Animations.Tileset
        collection: @tilesCollection

      @framesView = new Animations.Frames
        collection: @framesCollection

      @playerView = new Animations.Player
        frames: @framesCollection

      @sequencesView = new Animations.Sequences
        collection: @sequencesCollection

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

    render: =>
      @el.append $.tmpl('lebenmeister/editor_frame')

      return @
