#= require views/paginated
#= require views/searchable
#= require views/tags/tags
#= require views/sprites/sprite

#= require models/sprites_collection
#= require models/query_string

#= require templates/sprites/header

#= require pixie/view

namespace "Pixie.Views.Sprites", (Sprites) ->
  {Models, Views} = Pixie

  class Sprites.Gallery extends Pixie.View
    el: '.sprites_gallery'

    initialize: ->
      super

      attrs = Pixie.params()

      for k, v of attrs
        attrs[k] = unescape(v) if _.isString v
        attrs[k] = parseInt(v) unless _.isNaN parseInt(v)

      attrs

      @queryString = new Models.QueryString(attrs)

      @collection = new Models.SpritesCollection
        params: @queryString

      pages = new Views.Paginated
        collection: @collection

      new Views.Tags.Tags
        collection: @collection

      searchable = new Views.Searchable
        collection: @collection

      @$('.sprites').before($(JST['templates/sprites/header'](@collection.pageInfo())))
      @$('.sprites').before(pages.render().el)

      unless @options.profile
        $('.header h2').remove()
        @$('.sprites').before(searchable.render().el)

      @collection.bind 'reset', (collection) =>
        if @options.profile
          @$('.header').replaceWith $(JST['templates/sprites/header'](@collection.pageInfo()))

        @$('.sprite_container').remove()
        collection.each(@addSprite)

        collection.trigger 'afterReset'

    addSprite: (sprite) =>
      spriteView = new Sprites.Sprite({ model: sprite })
      @$('.sprites').append(spriteView.render().el)


