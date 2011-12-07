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
    new Pixie.Views.Tags.Tags({ collection: @collection })

    @collection.bind 'showReset', =>
      $(@el).find('.reset').show()

    @collection.bind 'hideReset', =>
      $(@el).find('.reset').hide()

    @collection.bind 'reset', (collection) =>
      $(@el).find('.header').remove()
      $(@el).append $.tmpl('sprites/header', @collection.pageInfo())

      $(@el).find('.sprite_container').remove()
      collection.each(@addSprite)

      $(@el).find('.sprite_container:first').before(pages.render().el)

      collection.trigger 'afterReset'

  addSprite: (sprite) =>
    spriteView = new Pixie.Views.Sprites.Sprite({ model: sprite })
    $(@el).append(spriteView.render().el)

  resetSearch: =>
    @collection.resetSearch()

