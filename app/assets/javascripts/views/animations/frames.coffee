#= require underscore
#= require backbone

#= require models/frames_collection

#= require tmpls/lebenmeister/frames
#= require tmpls/lebenmeister/frame

window.Pixie ||= {}
Pixie.Views ||= {}
Pixie.Views.Animations ||= {}

class Pixie.Views.Animations.Frames extends Backbone.View
  el: 'nav.bottom'

  events:
    'click .frame': 'select'
    'click .clear_frames': 'clear'

  collection: new Pixie.Models.FramesCollection

  initialize: ->
    @render()

    @collection.bind 'add', (model) =>
      @addFrame(model)

    @collection.bind 'enableFrameActions', =>
      $(@el).find('button').removeAttr('disabled')

  render: =>
    $(@el).append($.tmpl('lebenmeister/frames'))

    return @

  addFrame: (model) =>
    $(@el).find('.sprites').append($.tmpl('lebenmeister/frame', model.templateData()))

  clear: =>
    $(@el).find('.sprites').empty()
    @collection.reset()
    $(@el).find('button').attr('disabled', true)

  clearSelected: =>
    $(@el).find('.frame').removeClass('selected')

  highlight: (index) =>
    $(@el).find('.frame').eq(index).takeClass('selected')

  select: (e) =>
    frame = $(e.target).parent()

    frame.takeClass('selected')

    @collection.toFrame(frame.index())

