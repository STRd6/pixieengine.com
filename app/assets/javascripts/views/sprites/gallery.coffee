#= require underscore
#= require backbone
#= require views/paginated_view
#= require views/sprites/sprite
#= require models/sprites_collection
#= require models/paginated_collection

#= require tmpls/sprites/header
#= require tmpls/pagination

window.Pixie ||= {}
Pixie.Backbone ||= {}
Pixie.Backbone.Sprites ||= {}

class Pixie.Backbone.Sprites.Gallery extends Pixie.Backbone.PaginatedView
  el: ".sprites"

  initialize: ->
    self = @

    # merge the superclass paging related events
    @events = _.extend(@pageEvents, @events)
    @delegateEvents()

    @collection = new Pixie.Backbone.Sprites.Collection

    @collection.bind 'fetching', ->
      $(self.el).find('.spinner').show()

    @collection.bind 'reset', (collection) ->
      $(self.el).find('.header').remove()
      $(self.el).append $.tmpl("sprites/header", self.collection.pageInfo())

      $(self.el).find('.sprite_container').remove()
      $(self.el).find('.spinner').hide()
      collection.each(self.addSprite)

      self.updatePagination()

  addSprite: (sprite) =>
    view = new Pixie.Backbone.Sprites.SpriteView({ model: sprite })
    $(@el).append(view.render().el)

  updatePagination: =>
    $(@el).find('.pagination').html $.tmpl('pagination', @collection.pageInfo())

