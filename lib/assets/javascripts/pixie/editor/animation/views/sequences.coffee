#= require tmpls/editors/animation/sequences

#= require pixie/view

namespace "Pixie.Editor.Animation.Views", (Views) ->
  class Views.Sequences extends Pixie.View
    tagName: 'nav'
    className: 'right'

    template: 'editors/animation/sequences'

    events:
      'click .sequence': 'addToFrames'
      'click .edit_sequences': 'toggleEdit'

    initialize: ->
      super

      @el.liveEdit ".name",
        change: (element, value) =>
          cid = element.parent().data("cid")

          @collection.getByCid(cid).set { name: value }

      @collection.bind 'add', @addSequence
      @collection.bind 'remove', @removeSequence

    addToFrames: (e) =>
      return if $(e.target).is('.name')

      cid = $(e.currentTarget).data('cid')
      sequence = @collection.getByCid(cid)

      @collection.trigger 'addToFrames', sequence.clone()

    addSequence: (sequence) =>
      @$('button').removeAttr('disabled')
      @$('.edit_sequences').attr('title', 'Edit the frames in your sequences')

      sequenceEl = sequence.constructStack()

      @$('.sprites').append sequenceEl

    removeSequence: (sequence) =>
      @$(".sequence[data-cid=#{sequence.cid}]").remove()

      if @$('.sequence').length == 0
        @$('.edit_sequences').attr
          disabled: true
          title: 'There are no sequences to edit. Create one first.'

    toggleEdit: =>
      button = @$('.edit_sequences')
      button.toggleClass('active')

      if button.hasClass('active')
        @$('.sequence').addClass('edit')
      else
        @$('.sequence').removeClass('edit')

