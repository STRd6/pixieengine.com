#= require underscore
#= require backbone

#= require tmpls/projects/project

window.Pixie ||= {}
Pixie.Backbone ||= {}
Pixie.Backbone.Projects ||= {}

class Pixie.Backbone.Projects.ProjectView extends Backbone.View
  className: 'project clickable'

  render: =>
    data = _.extend(@model.toJSON(), {current_user_id: @model.collection.current_user_id, owner_id: @model.collection.owner_id})
    $(@el).html $.tmpl('projects/project', data)
    return @
