#= require templates/projects/project

window.Pixie ||= {}
Pixie.Views ||= {}
Pixie.Views.Projects ||= {}

class Pixie.Views.Projects.Project extends Backbone.View
  className: 'project clickable'

  render: =>
    data = _.extend(@model.toJSON(), {current_user_id: @model.collection.current_user_id, owner_id: @model.collection.params.id})
    $(@el).html $(JST['templates/projects/project'](data))
    return @
