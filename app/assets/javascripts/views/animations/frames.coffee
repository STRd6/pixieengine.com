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

  select: (e) =>
    $(e.target).toggleClass('selected')

