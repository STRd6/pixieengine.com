#= require underscore
#= require backbone
#= require corelib

#= require views/animations/player
#= require views/animations/tileset
#= require views/animations/frames
#= require views/animations/sequences

#= require tmpls/lebenmeister/editor_frame

namespace "Pixie.Views.Animations", (Animations) ->
  {Models} = Pixie

  class Animations.Editor extends Backbone.View
    el: '.backbone_lebenmeister'

    initialize: ->
      # force jQuery @el
      @el = $(@el)

      @render()

      @tilesetView = new Animations.Tileset
      @framesView = new Animations.Frames
      @playerView = new Animations.Player({ frames: @framesView.collection })
      @sequencesView = new Animations.Sequences

      @sequencesView.collection.bind 'addSequenceToFrames', (sequence) =>
        @framesView.collection.add sequence

      @playerView.bind 'clearSelectedFrames', =>
        @framesView.clearSelected()

      @playerView.model.bind 'nextFrame', =>
        @framesView.collection.nextFrame()

      @framesView.collection.bind 'createSequence', (frameCollection) =>
        sequence = new Models.Sequence
          frames: frameCollection.flattenFrames()

        @sequencesView.collection.add(sequence)
        @sequencesView.render()

      @tilesetView.collection.bind 'addFrame', (model) =>
        sequence = new Models.Sequence({frames: [model]})

        @framesView.collection.add sequence

      @$('.content .relative').append(@playerView.el)

      @tilesetView.bindDropImageReader(@el)

    render: =>
      @el.append $.tmpl('lebenmeister/editor_frame')

      return @
