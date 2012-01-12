#= require pixie/view

#= require pixie/editor/animation/models/sequence

#= require tmpls/editors/animation/frames

namespace "Pixie.Editor.Animation.Views", (Views) ->
  {Models} = Pixie.Editor.Animation

  class Views.Frames extends Pixie.View
    tagName: 'nav'
    className: 'module bottom'

    template: 'editors/animation/frames'

    events:
      'click .sequence': 'select'
      'click .clear_frames': 'clear'
      'click .create_sequence': 'createSequence'

    initialize: ->
      super

      @collection.bind 'add', @appendFrame
      @collection.bind 'reset', @render

      # look into tilemaps settings object for different approach
      @collection.bind 'change:selected', (collection, selected) =>
        @$('.sequence').eq(selected).takeClass('selected')

      @render()

    appendFrame: (sequence) =>
      sequenceEl = sequence.constructStack(false)

      @$('button').removeAttr('disabled')
      @$('.create_sequence').attr('title', 'Create a sequence')
      @$('.clear_frames').attr('title', 'Clear frames')

      @$('.sprites').append sequenceEl

    clear: =>
      @collection.reset()

    clearSelected: =>
      @$('.frame').removeClass('selected')

    createSequence: =>
      @collection.trigger 'createSequence', @collection
      @collection.reset()

    render: =>
      @$(".sprites").empty()

      @$('button').attr('disabled', true)
      @$('.create_sequence').attr('title', 'Add frames to create a sequence')
      @$('.clear_frames').attr('title', 'There are no frames to clear')

      @collection.each (model) =>
        @appendFrame model

    select: (e) =>
      frame = $(e.currentTarget)

      frame.takeClass('selected')

      @collection.toFrame(frame.index())


