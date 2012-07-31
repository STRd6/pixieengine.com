#= require templates/projects/filtered_project

namespace "Pixie.Views.Projects", (Projects) ->
  class Projects.FilteredProject extends Backbone.View
    className: 'span3 project'
    tagName: 'li'

    render: =>
      data = _.extend(@model.toJSON(), {current_user_id: @model.collection.current_user_id, owner_id: @model.collection.params.id})
      $(@el).html $(JST['templates/projects/filtered_project'](data))

      return @
