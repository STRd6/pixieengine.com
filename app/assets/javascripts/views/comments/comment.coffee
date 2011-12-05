#= require underscore
#= require backbone

#= require tmpls/comments/comment

window.Pixie ||= {}
Pixie.Views ||= {}
Pixie.Views.Comments ||= {}

class Pixie.Views.Comments.Comment extends Backbone.View
  className: 'comment'

  render: =>
    data = _.extend(@model.toJSON(), {current_user_id: @model.collection.current_user_id, owner_id: @model.collection.owner_id})
    $(@el).html $.tmpl('comments/comment', data)
    return @

