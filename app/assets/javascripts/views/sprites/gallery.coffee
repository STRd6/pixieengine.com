#= require underscore
#= require backbone
#= require views/paginated
#= require views/sprites/sprite
#= require models/sprites_collection

#= require tmpls/sprites/header

window.Pixie ||= {}
Pixie.Views ||= {}
Pixie.Views.Sprites ||= {}

class Pixie.Views.Sprites.Gallery extends Backbone.View
  events:
    'click .tag': 'searchTags'
    'click .reset': 'resetSearch'

  initialize: ->
    self = @

    @el = ".sprites"

    @collection = new Pixie.Models.SpritesCollection

    @collection.bind 'reset', (collection) ->
      view = new Pixie.Views.Paginated({ collection: collection })

      $(self.el).find('.header').remove()
      $(self.el).append $.tmpl('sprites/header', self.collection.pageInfo())

      $(self.el).find('.header').append(view.render().el)

      $(self.el).find('.reset').show() if self.collection.params.tagged

      $(self.el).find('.sprite_container').remove()
      collection.each(self.addSprite)

      collection.trigger 'afterReset'

      self.updateTags(collection)

    @render()

  addSprite: (sprite) =>
    view = new Pixie.Views.Sprites.Sprite({ model: sprite })
    $(@el).append(view.render().el)

  resetSearch: =>
    @collection.resetSearch()
    $(@el).find('.reset').hide()

  searchTags: (e) =>
    $(@el).find('.reset').show()
    tag = $(e.target).text().toLowerCase()
    @collection.filterTagged(tag)

  updateTags: (collection) =>
    tags = []

    $('.tags').empty()

    for model in collection.models
      for tag in model.attributes.tags
        tags.push tag.name unless $.inArray(tag.name, tags) >= 0

    for name in tags
      $('.tags').append($("<div class='tag'><a href='#'>#{name}</a></div>"))

