#= require pixie/view

namespace "Pixie.Editor.Animation.Views", (Views) ->
  class Views.Sequences extends Pixie.View
    tagName: 'nav'
    className: 'right'

    events:
      'click .sequence': 'addToFrames'

    initialize: ->
      super

      @el.append('<h3>Sequences</h3><div class="sprites"></div>')

      @el.liveEdit ".name",
        change: (element, value) =>
          cid = element.parent().data("cid")

          @collection.getByCid(cid).set({ name: value })

      @collection.bind 'add', (model) =>
        @addSequence(model)

    addToFrames: (e) =>
      return if $(e.target).is('.name')

      cid = $(e.currentTarget).data('cid')
      sequence = @collection.getByCid(cid)

      @collection.trigger 'addToFrames', sequence.clone()

    addSequence: (sequence) =>
      sequenceEl = sequence.constructStack()

      @$('.sprites').append sequenceEl


