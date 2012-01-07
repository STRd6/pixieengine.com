#= require underscore
#= require backbone

#= require models/frames_collection

#= require tmpls/lebenmeister/frames
#= require tmpls/lebenmeister/frame

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

    addFrame: (model) =>
      @$('.sprites').append $.tmpl('lebenmeister/frame', model.templateData())

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

