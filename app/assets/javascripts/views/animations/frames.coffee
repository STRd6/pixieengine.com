#= require underscore
#= require backbone

#= require models/frames_collection

#= require tmpls/lebenmeister/frames

namespace "Pixie.Views.Animations", (Animations) ->
  {Models} = Pixie

  class Animations.Frames extends Backbone.View
    el: 'nav.bottom'

    events:
      'click .frame': 'select'
      'click .clear_frames': 'clear'
      'click .create_sequence': 'createSequence'

    collection: new Models.FramesCollection

    initialize: ->
      # force jQuery el
      @el = $(@el)

      @render()

      @collection.bind 'add', (model) =>
        @addFrame(model)

      @collection.bind 'enableFrameActions', =>
        @$('button').removeAttr('disabled')

    render: =>
      @el.append $.tmpl('lebenmeister/frames')

      return @

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

    clear: =>
      @collection.reset()
      @emptyFrameTray()

    clearSelected: =>
      @$('.frame').removeClass('selected')

    createSequence: =>
      @collection.createSequence()
      @clear()

    emptyFrameTray: =>
      @$('.sprites').empty()
      @$('button').attr('disabled', true)

    highlight: (index) =>
      @$('.frame').eq(index).takeClass('selected')

    select: (e) =>
      frame = $(e.currentTarget)

      frame.takeClass('selected')

      @collection.toFrame(frame.index())

