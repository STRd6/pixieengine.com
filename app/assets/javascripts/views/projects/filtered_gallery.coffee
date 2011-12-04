#= require underscore
#= require backbone
#= require views/paginated
#= require views/projects/filtered_project
#= require views/filtered
#= require models/projects_collection
#= require models/paginated_collection

#= require tmpls/projects/filtered_header
#= require tmpls/pagination

window.Pixie ||= {}
Pixie.Views ||= {}
Pixie.Views.Projects ||= {}

class Pixie.Views.Projects.FilteredGallery extends Backbone.View
  el: ".gallery"

  initialize: ->
    @collection = new Pixie.Models.ProjectsCollection

    pages = new Pixie.Views.Paginated({ collection: @collection })
    filters = new Pixie.Views.Filtered
      collection: @collection
      filters: ['Arcade', 'Featured', 'Tutorials', 'Recently Edited', 'All', 'My Projects']
      activeFilter: 'Featured'

    $(@el).append $ '<div class="items"></div>'
    $(@el).find('.items').before(filters.render().el)

    @collection.bind 'reset', (projects) =>
      $(@el).find('.items').empty()
      $(@el).find('.items').before(pages.render().el)

      $(@el).find('.filter').filter( ->
        $(this).text().toLowerCase() == @filter
      ).takeClass('active')

      projects.each(@addProject)

      $(@el).find('.filter').filter( ->
        return $(this).text().toLowerCase() == 'my projects'
      ).hide() unless projects.pageInfo().current_user_id

      projects.trigger 'afterReset'

  addProject: (project) =>
    projects = new Pixie.Views.Projects.FilteredProject({ model: project, collection: @collection })
    $(@el).find('.items').append(projects.render().el)

