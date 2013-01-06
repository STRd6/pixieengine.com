#= require views/paginated
#= require views/comments/comment
#= require models/comment

#= require templates/comments/header

namespace "Pixie.Views.Comments", (Comments) ->
  {Models, Views} = Pixie

  class Comments.Gallery extends Backbone.View
    el: '.comments'

    initialize: ->
      attrs = Pixie.params()

      for k, v of attrs
        attrs[k] = unescape(v) if _.isString v
        attrs[k] = parseInt(v) unless _.isNaN parseInt(v)

      attrs

      @queryString = new Models.QueryString(attrs)

      @collection = new Models.CommentsCollection
        params: @queryString

      pages = new Views.Paginated({ collection: @collection })

      @$('.header').remove()
      $(@el).append $(JST['comments/header'](@collection.pageInfo()))

      @collection.bind 'reset', (collection) =>
        @$('.header').append(pages.render().el)

        @$('.comment').remove()

        collection.each(@addComment)

        @$('.timeago').timeago()

        collection.trigger 'afterReset'

    addComment: (message) =>
      commentView = new Views.Comments.Comment({ model: message })
      $(@el).append(commentView.render().el)
