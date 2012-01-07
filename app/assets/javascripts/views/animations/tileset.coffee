#= require models/tiles_collection

#= require tmpls/lebenmeister/tileset
#= require tmpls/lebenmeister/tile

namespace "Pixie.Views.Animations", (Animations) ->
  {Models} = Pixie

  class Animations.Tileset extends Backbone.View
    el: 'nav.left'

    events:
      'click img': 'addFrame'

    collection: new Models.TilesCollection

    initialize: ->
      # force jQuery el
      @el = $(@el)

      @render()
      @enableSort()

      @collection.bind 'add', (model) =>
        @addTile(model)

    render: =>
      @el.append($.tmpl('lebenmeister/tileset'))

      return @

    addFrame: (e) =>
      cid = $(e.currentTarget).data('cid')
      model = @collection.getByCid(cid)

      @collection.trigger 'addFrame', model

    addTile: (model) =>
      @$('.sprites').append $.tmpl('lebenmeister/tile', model.templateData())

    enableSort: =>
      @$('.sprites').sortable
        distance: 10
