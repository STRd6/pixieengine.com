#= require underscore
#= require backbone
#= require views/paginated
#= require views/searchable
#= require views/tags/tags
#= require views/sprites/sprite
#= require models/sprites_collection

#= require tmpls/sprites/header

#= require pixie/view

namespace "Pixie.Views.Sprites", (Sprites) ->
  {Models, Views} = Pixie

  class Sprites.Gallery extends Pixie.View
    el: '.sprites'

    initialize: ->
      super

      @collection = new Models.SpritesCollection

      pages = new Views.Paginated
        collection: @collection

      new Views.Tags.Tags
        collection: @collection

      searchable = new Views.Searchable
        collection: @collection

      @el.append($.tmpl('tmpls/sprites/header', @collection.pageInfo()))
      @el.append(pages.render().el)

      unless @options.profile
        $('.header h2').remove()
        @el.append(searchable.render().el)

      @collection.bind 'reset', (collection) =>
        if @options.profile
          @$('.header').replaceWith $.tmpl('tmpls/sprites/header', @collection.pageInfo())

        @$('.sprite_container').remove()
        collection.each(@addSprite)

        collection.trigger 'afterReset'

    addSprite: (sprite) =>
      spriteView = new Sprites.Sprite({ model: sprite })
      @el.append(spriteView.render().el)

