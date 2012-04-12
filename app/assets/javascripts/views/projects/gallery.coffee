#= require underscore
#= require backbone
#= require views/paginated
#= require views/projects/project
#= require models/projects_collection
#= require models/paginated_collection

#= require templates/projects/header
#= require templates/pagination

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
      $(@el).append $.tmpl("tmpls/projects/header", @collection.pageInfo())

      $(@el).find('.project').remove()
      collection.each(@addProject)

      $(@el).find('.project:first').before(pages.render().el)

      collection.trigger 'afterReset'

  addProject: (project) =>
    view = new Pixie.Views.Projects.Project({ model: project, collection: @collection })
    $(@el).append(view.render().el)

  updatePagination: =>
    $(@el).find('.pagination').html $.tmpl('tmpls/pagination', @collection.pageInfo())

