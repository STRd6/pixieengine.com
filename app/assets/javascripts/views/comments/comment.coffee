#= require templates/comments/comment

namespace "Pixie.Views.Comments", (Comments) ->
  class Comments.Comment extends Backbone.View
    className: 'comment'

    render: =>
      data = _.extend @model.toJSON(),
        current_user_id: @model.collection.current_user_id
        owner_id: @model.collection.owner_id

      $(@el).html $(JST['comments/comment'](data))

      return this
