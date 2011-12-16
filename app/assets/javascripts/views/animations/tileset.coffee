#= require underscore
#= require backbone

#= require models/tiles_collection

#= require tmpls/lebenmeister/tileset
#= require tmpls/lebenmeister/tile

window.Pixie ||= {}
Pixie.Views ||= {}
Pixie.Views.Animations ||= {}

class Pixie.Views.Animations.Tileset extends Backbone.View
  el: 'nav.left'

  events:
    'click img': 'addFrame'

  collection: new Pixie.Models.TilesCollection

  initialize: ->
    @render()
    @enableSort()

    @collection.bind 'add', (model) =>
      @addTile(model)

  render: =>
    $(@el).append($.tmpl('lebenmeister/tileset'))

    return @

  addFrame: (e) =>
    id = $(e.target).data('id')
    model = @collection.getByCid(id)

    @collection.trigger 'addFrame', model

  addTile: (model) =>
    $(@el).find('.sprites').append($.tmpl('lebenmeister/tile', model.templateData()))

  enableSort: =>
    $(@el).find('.sprites').sortable
      distance: 10
