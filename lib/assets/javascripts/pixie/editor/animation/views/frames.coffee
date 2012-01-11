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
          src = frame.src
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


