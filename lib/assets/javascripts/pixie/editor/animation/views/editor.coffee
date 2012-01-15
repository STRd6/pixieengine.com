#= require underscore
#= require backbone
#= require corelib

#= require_tree .
#= require_tree ../models
#= require ../actions
#= require ../command

#= require tmpls/editors/animation/editor
#= require tmpls/editors/animation/help_tips

#= require pixie/editor/base
#= require pixie/view

namespace "Pixie.Editor.Animation.Views", (Views) ->
  {Animation} = Pixie.Editor
  {Command, Models} = Pixie.Editor.Animation

  class Views.Editor extends Pixie.View
    className: 'editor backbone_lebenmeister'

    template: 'editors/animation/editor'

    initialize: ->
      super

      @settings = new Models.Settings

      @sequencesCollection = new Models.SequencesCollection
      @framesCollection = new Models.FramesCollection
      @tilesCollection = new Models.TilesCollection

      helpDialog = $.tmpl 'editors/animation/help_tips'
      @el.append helpDialog

      contentEl = @$('.content')

      @tilesetView = new Views.Tileset
        collection: @tilesCollection
      contentEl.append @tilesetView.el

      @framesView = new Views.Frames
        collection: @framesCollection
        settings: @settings
      contentEl.append @framesView.el

      @playerView = new Views.Player
        frames: @framesCollection
        settings: @settings
      contentEl.find('.relative').append @playerView.el

      @sequencesView = new Views.Sequences
        collection: @sequencesCollection
      contentEl.append @sequencesView.el

      for collection in [@sequencesCollection, @tilesCollection]
        collection.bind 'addToFrames', (model) =>
          @settings.execute Command.AddFrame
            framesCollection: @framesCollection
            frame: model.clone()

      @sequencesCollection.bind 'editSequence', (sequence) =>
        @framesCollection.reset()

        for frame in sequence.get 'frames'
          @framesCollection.add
            frames: [{src: frame.src}]

        @sequencesCollection.remove sequence

      @framesCollection.bind 'createSequence', (collection) =>
        sequence = new Models.Sequence
          frames: collection.flattenFrames()

        @settings.execute Command.AddSequence
          framesCollection: collection
          sequencesCollection: @sequencesCollection
          sequence: sequence
          previousModels: collection.models.copy()

      @$('.content .relative').append(@playerView.render().el)

      @tilesetView.bindDropImageReader(@el)

      @include Pixie.Editor.Base

      for name, action of Animation.actions
        action.name ||= name

        @addAction action

      @takeFocus()

      # prevent context menu
      @el.bind "contextmenu", -> false

   takeFocus: ->
     super()

    events:
      mousemove: "takeFocus"

