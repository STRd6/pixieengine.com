#= require underscore
#= require backbone

#= require tmpls/people/person

namespace "Pixie.Views.People", (People) ->
  class People.Person extends Backbone.View
    className: 'user clickable'

    render: =>
      data = _.extend(@model.toJSON(), {current_user_id: @model.collection.current_user_id, owner_id: @model.collection.owner_id})
      $(@el).html $.tmpl('tmpls/people/person', data)
      return @

