#= require underscore
#= require backbone
#= require views/paginated
#= require views/comments/comment
#= require models/comments_collection

#= require tmpls/comments/header

window.Pixie ||= {}
Pixie.Views ||= {}
Pixie.Views.Comments ||= {}

class Pixie.Views.Comments.Gallery extends Backbone.View
  el: '.comments'

  initialize: ->
    @collection = new Pixie.Models.CommentsCollection

    pages = new Pixie.Views.Paginated({ collection: @collection })

    $(@el).find('.header').remove()
    $(@el).append $.tmpl('comments/header', @collection.pageInfo())

    @collection.bind 'reset', (collection) =>
      $(@el).find('.header').append(pages.render().el)

      $(@el).find('.comment').remove()
      collection.each(@addComment)
      $('.timeago').timeago()

      collection.trigger 'afterReset'

  addComment: (message) =>
    commentView = new Pixie.Views.Comments.Comment({ model: message })
    $(@el).append(commentView.render().el)

