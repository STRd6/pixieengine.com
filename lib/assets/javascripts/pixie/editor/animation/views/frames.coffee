#= require pixie/view

#= require ../command

#= require pixie/editor/animation/models/sequence

#= require tmpls/editors/animation/frames

namespace "Pixie.Editor.Animation.Views", (Views) ->
  {Models, Command} = Pixie.Editor.Animation

  class Views.Frames extends Pixie.View
    tagName: 'nav'
    className: 'module bottom'

    template: 'editors/animation/frames'

    # TODO see if you can use comma separated selectors for this
    # eg: 'click .sequence img, .sequence .placeholder': 'select'
    events:
      'click .sequence img': 'select'
      'click .sequence .placeholder': 'select'
      'click .clear_frames': 'clear'
      'click .create_sequence': 'createSequence'

    initialize: ->
      super

      @collection.bind 'add', @appendFrame
      @collection.bind 'reset', @render
      @collection.bind 'remove', @removeFrame

      @settings.bind 'change:selected', (model, selected) =>
        @$('.sequence .placeholder, .sequence img').removeClass('selected').eq(selected).addClass('selected')

      @render()

    appendFrame: (sequence) =>
      sequenceEl = sequence.constructStack(false)

      @$('button').removeAttr('disabled')
      @$('.create_sequence').attr('title', 'Create a sequence')
      @$('.clear_frames').attr('title', 'Clear frames')

      @$('.sprites').append sequenceEl

    clear: =>
      @collection.reset()

    createSequence: =>
      @collection.trigger 'createSequence', @collection
      @collection.reset()

    render: =>
      @$(".sprites").empty()

      @$('button').attr('disabled', true)
      @$('.create_sequence').attr('title', 'Add frames to create a sequence')
      @$('.clear_frames').attr('title', 'There are no frames to clear')

      @settings.set
        selected: 0

      @collection.each (model) =>
        @appendFrame model

    select: (e) =>
      frame = $(e.currentTarget)

      @$('.sequence .placeholder, .sequence img').removeClass('selected')
      frame.addClass('selected')

      @settings.set
        selected: @$('.sequence .placeholder, .sequence img').index(frame)

    removeFrame: (frame) =>
      @$(".sequence[data-cid=#{frame.cid}]").remove()

    removeSelected: =>
      cid = @$('.sequence .placeholder.selected, .sequence img.selected').parent().data('cid')

      sequence = @collection.getByCid(cid)

      @settings.execute Command.RemoveFrame
        framesCollection: @collection
        frame: sequence

