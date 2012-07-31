#= require views/paginated
#= require views/projects/filtered_project
#= require views/filtered
#= require views/searchable
#= require models/projects_collection
#= require models/paginated_collection

#= require templates/projects/filtered_header
#= require templates/pagination

namespace "Pixie.Views.Projects", (Projects) ->
  {Models, Views} = Pixie

  class Projects.FilteredGallery extends Backbone.View
    el: ".gallery"

    initialize: ->
      @collection = new Models.ProjectsCollection

      pages = new Views.Paginated
        collection: @collection

      filters = new Views.Filtered
        collection: @collection
        filters: ['Arcade', 'Featured', 'Tutorials', 'Recently Edited', 'All', 'My Projects']
        activeFilter: 'Featured'

      searchable = new Views.Searchable
        collection: @collection

      $(@el).append $ '<ul class="thumbnails items"></ul>'
      @$('.items').before(filters.render().el, searchable.render().el)

      @collection.bind 'reset', (projects) =>
        @$('.items').empty().before(pages.render().el)

        @$('.filter').filter( ->
          $(this).text().toLowerCase() is @filter
        ).takeClass('active')

        projects.each(@addProject)

        @$('.filter').filter( ->
          return $(this).text().toLowerCase() is 'my projects'
        ).hide() unless projects.pageInfo().current_user_id

        projects.trigger 'afterReset'

    addProject: (project) =>
      projects = new Projects.FilteredProject({ model: project, collection: @collection })
      @$('.items').append(projects.render().el)

