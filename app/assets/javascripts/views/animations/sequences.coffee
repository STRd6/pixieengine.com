#= require models/sequences_collection

#= require tmpls/lebenmeister/sequences

namespace "Pixie.Views.Animations", (Animations) ->
  {Models} = Pixie

  class Animations.Sequences extends Backbone.View
    el: 'nav.right'

    collection: new Models.SequencesCollection

    events:
      'click .sequence': 'addToFrames'

    initialize: ->
      # force jQuery el
      @el = $(@el)

      @el.append $.tmpl('lebenmeister/sequences')

      @el.liveEdit ".name",
        change: (element, value) =>
          cid = element.parent().data("cid")

          @collection.getByCid(cid).set name: value

      @render()

    addToFrames: (e) =>
      return if $(e.target).is('.name')

      cid = $(e.currentTarget).data('cid')
      sequence = @collection.getByCid(cid)

      @collection.trigger 'addSequenceToFrames', sequence.clone()

    render: =>
      @$('.sequence').remove()

      @collection.each (sequence) =>
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

      return @

