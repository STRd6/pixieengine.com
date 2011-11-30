#= require underscore
#= require backbone
#= require views/paginated
#= require views/tags/tags
#= require views/sprites/sprite
#= require models/sprites_collection

#= require tmpls/sprites/header

window.Pixie ||= {}
Pixie.Views ||= {}
Pixie.Views.Sprites ||= {}

class Pixie.Views.Sprites.Gallery extends Backbone.View
  el: '.sprites'

  events:
    'click .reset': 'resetSearch'

  initialize: ->
    @collection = new Pixie.Models.SpritesCollection

    pages = new Pixie.Views.Paginated({ collection: @collection })
    tags = new Pixie.Views.Tags.Tags({ collection: @collection })

    $(@el).find('.header').remove()
    $(@el).append $.tmpl('sprites/header', @collection.pageInfo())

    @collection.bind 'reset', (collection) =>
      $(@el).find('.header').append(pages.render().el)

      $(@el).find('.reset').show() if collection.params.tagged

      $(@el).find('.sprite_container').remove()
      collection.each(@addSprite)

      collection.trigger 'afterReset'

  addSprite: (sprite) =>
    spriteView = new Pixie.Views.Sprites.Sprite({ model: sprite })
    $(@el).append(spriteView.render().el)

  resetSearch: =>
    @collection.resetSearch()
    $(@el).find('.reset').hide()

