#= require underscore
#= require backbone

#= require models/tiles_collection

#= require tmpls/lebenmeister/tileset

window.Pixie ||= {}
Pixie.Views ||= {}
Pixie.Views.Animations ||= {}

class Pixie.Views.Animations.Tileset extends Backbone.View
  el: 'nav.left'

  collection: new Pixie.Models.TilesCollection

  initialize: ->
    @render()

  render: =>
    $(@el).append($.tmpl('lebenmeister/tileset'))

    return @
