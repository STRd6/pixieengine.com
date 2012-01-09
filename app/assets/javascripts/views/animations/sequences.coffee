#= require models/sequences_collection
#= require pixie/view

namespace "Pixie.Views.Animations", (Animations) ->
  {Models} = Pixie

  class Animations.Sequences extends Pixie.View
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

      @collection.trigger 'addSequenceToFrames', sequence.clone()

    addSequence: (sequence) =>
      name = sequence.get('name')
      cid = sequence.cid

      sequenceEl = $ "<div class=sequence data-cid=#{cid}><span class=name>#{name}</span></div>"
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

