#= require jquery.timeago
#= require views/paginated
#= require views/comments/comment
#= require models/comment

#= require tmpls/comments/header

namespace "Pixie.Views.Comments", (Comments) ->
  class Comments.Gallery extends Backbone.View
    el: '.comments'

    initialize: ->
      @collection = new Pixie.Models.CommentsCollection

      pages = new Pixie.Views.Paginated({ collection: @collection })

      $(@el).find('.header').remove()
      $(@el).append $.tmpl('tmpls/comments/header', @collection.pageInfo())

      @collection.bind 'reset', (collection) =>
        $(@el).find('.header').append(pages.render().el)

        $(@el).find('.comment').remove()
        collection.each(@addComment)
        $('.timeago').timeago()

        collection.trigger 'afterReset'

    addComment: (message) =>
      commentView = new Pixie.Views.Comments.Comment({ model: message })
      $(@el).append(commentView.render().el)
