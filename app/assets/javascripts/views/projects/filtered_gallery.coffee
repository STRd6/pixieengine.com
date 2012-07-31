#= require views/paginated
#= require views/projects/filtered_project
#= require views/filtered
#= require views/searchable
#= require models/projects_collection
#= require models/paginated_collection

#= require templates/projects/filtered_header
#= require templates/pagination

namespace "Pixie.Views.Projects", (Projects) ->
  class Pixie.Views.Projects.FilteredGallery extends Backbone.View
    el: ".gallery"

    initialize: ->
      @collection = new Pixie.Models.ProjectsCollection

      pages = new Pixie.Views.Paginated
        collection: @collection

      filters = new Pixie.Views.Filtered
        collection: @collection
        filters: ['Arcade', 'Featured', 'Tutorials', 'Recently Edited', 'All', 'My Projects']
        activeFilter: 'Featured'

      searchable = new Pixie.Views.Searchable
        collection: @collection

      $(@el).append $ '<ul class="thumbnails items"></ul>'
      @$('.items').before(filters.render().el)

      @$('.items').before(searchable.render().el)

      @collection.bind 'reset', (projects) =>
        @$('.items').empty()
        @$('.items').before(pages.render().el)

        @$('.filter').filter( ->
          $(this).text().toLowerCase() == @filter
        ).takeClass('active')

        projects.each(@addProject)

        @$('.filter').filter( ->
          return $(this).text().toLowerCase() == 'my projects'
        ).hide() unless projects.pageInfo().current_user_id

        projects.trigger 'afterReset'

    addProject: (project) =>
      projects = new Pixie.Views.Projects.FilteredProject({ model: project, collection: @collection })
      @$('.items').append(projects.render().el)

