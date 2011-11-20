#= require underscore
#= require backbone

#= require tmpls/people/person

window.Pixie ||= {}
Pixie.Views ||= {}
Pixie.Views.People ||= {}

class Pixie.Views.People.Person extends Backbone.View
  className: 'person clickable'

  render: =>
    data = _.extend(@model.toJSON(), {current_user_id: @model.collection.current_user_id, owner_id: @model.collection.owner_id})
    $(@el).html $.tmpl('people/person', data)
    return @

