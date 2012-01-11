#= require pixie/view

#= require pixie/editor/animation/models/sequence

#= require tmpls/lebenmeister/frames

namespace "Pixie.Views.Animations", (Animations) ->
  {Models} = Pixie

  class Animations.Frames extends Pixie.View
    tagName: 'nav'
    className: 'module bottom'

    template: 'lebenmeister/frames'

    events:
      'click .frame': 'select'
      'click .clear_frames': 'clear'
      'click .create_sequence': 'createSequence'

    initialize: ->
      super

      @collection.bind 'add', (model) =>
        @addFrame(model)

      # TODO consider binding on add and remove/reset instead of custom events
      @collection.bind 'enableFrameActions', =>
        @$('button').removeAttr('disabled')
        @$('.create_sequence').attr('title', 'Create a sequence')
        @$('.clear_frames').attr('title', 'Clear frames')

      @collection.bind 'reset', =>
        @$('.sprites').empty()
        @$('button').attr('disabled', true)
        @$('.create_sequence').attr('title', 'Add frames to create a sequence')
        @$('.clear_frames').attr('title', 'There are no frames to clear')

      # look into tilemaps settings object for different approach
      @collection.bind 'change:selected', (collection, selected) =>
        @$('.sequence').eq(selected).takeClass('selected')

    addFrame: (sequence) =>
      name = sequence.get('name')
      cid = sequence.cid

      sequenceEl = $ "<div class=sequence data-cid=#{cid}></div>"
      lastFrame = sequence.get('frames').last()

      width = null
      height = null

      sequence.get('frames').each (frame) ->
        if frame == lastFrame
          src = frame.get 'src'
          img = $ "<img src=#{src}>"
          height = img.get(0).height
          width = img.get(0).width

          sequenceEl.append img
        else
          sequenceEl.append '<div class="placeholder"></div>'

      sequenceEl.find('.placeholder').css
        width: width + 4
        height: height + 4

      @$('.sprites').append sequenceEl

    # TODO Try to make Tile object into a sequence of length one in order to eliminate that class and simplify
    addSequence: (model) =>
      if model.get('frames')
        @collection.add(model)
      else
        @collection.add(new Models.Sequence({frames: [model]}))

    clear: =>
      @collection.reset()

    clearSelected: =>
      @$('.frame').removeClass('selected')

    createSequence: =>
      @collection.createSequence()
      @collection.reset()

    select: (e) =>
      frame = $(e.currentTarget)

      frame.takeClass('selected')

      @collection.toFrame(frame.index())


