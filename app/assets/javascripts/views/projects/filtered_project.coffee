#= require underscore
#= require backbone

#= require templates/projects/filtered_project

window.Pixie ||= {}
Pixie.Views ||= {}
Pixie.Views.Projects ||= {}

class Pixie.Views.Projects.FilteredProject extends Backbone.View
  className: 'project clickable'

  render: =>
    data = _.extend(@model.toJSON(), {current_user_id: @model.collection.current_user_id, owner_id: @model.collection.params.id})
    $(@el).html $(JST['templates/projects/filtered_project'](data))
    return @

