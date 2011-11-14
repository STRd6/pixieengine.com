#= require underscore
#= require backbone

#= require tmpls/projects/project

window.Pixie ||= {}
Pixie.Backbone ||= {}
Pixie.Backbone.Projects ||= {}

class Pixie.Backbone.Projects.ProjectView extends Backbone.View
  className: 'project clickable'

  render: =>
    $(@el).html $.tmpl('projects/project', @model.toJSON())
    return @
