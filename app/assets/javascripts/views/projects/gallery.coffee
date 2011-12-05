#= require underscore
#= require backbone
#= require views/paginated
#= require views/projects/project
#= require models/projects_collection
#= require models/paginated_collection

#= require tmpls/projects/header
#= require tmpls/pagination

window.Pixie ||= {}
Pixie.Views ||= {}
Pixie.Views.Projects ||= {}

class Pixie.Views.Projects.Gallery extends Backbone.View
  el: ".projects"

  initialize: ->
    @collection = new Pixie.Models.ProjectsCollection

    pages = new Pixie.Views.Paginated({ collection: @collection })

    @collection.bind 'reset', (collection) =>
      $(@el).find('.header').remove()
      $(@el).append $.tmpl("projects/header", @collection.pageInfo())

      $(@el).find('.header').append(pages.render().el)

      $(@el).find('.project').remove()
      collection.each(@addProject)

      collection.trigger 'afterReset'

  addProject: (project) =>
    view = new Pixie.Views.Projects.Project({ model: project, collection: @collection })
    $(@el).append(view.render().el)

  updatePagination: =>
    $(@el).find('.pagination').html $.tmpl('pagination', @collection.pageInfo())

