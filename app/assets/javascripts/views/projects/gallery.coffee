#= require views/paginated
#= require views/projects/project
#= require views/filtered
#= require views/searchable

#= require models/projects_collection
#= require models/paginated_collection

#= require templates/pagination

namespace "Pixie.Views.Projects", (Projects) ->
  {Models, Views} = Pixie

  class Projects.Gallery extends Backbone.View
    className: "gallery"

    events:
      'click .clear_search': 'clearSearch'

    initialize: (options) ->
      pages = new Views.Paginated
        collection: @collection

      filters = new Views.Filtered
        collection: @collection
        filters: ['Arcade', 'Featured', 'Tutorials', 'Recently Edited', 'All', 'My Projects']
        activeFilter: 'Featured'

      @searchable = new Views.Searchable
        collection: @collection

      $(@el).append $ '<ul class="thumbnails items"></ul>'
      @$('.items').before(filters.render().el, @searchable.render().el)

      @collection.bind 'reset', (projects) =>
        paginationEl = $(pages.render().el)

        @$('.items').empty().before(paginationEl)

        paginationEl.toggle(!!paginationEl.find('ul').length)

        if projects.length is 0
          @$('.items').append("<p>No matching projects. Try <a href='#' class='clear_search'>clearing</a> your search.</p>")
        else
          projects.each(@addProject)

        @$('.filter').filter( ->
          return $(this).text().toLowerCase() is 'my projects'
        ).hide() unless projects.pageInfo().current_user_id

    addProject: (project) =>
      projects = new Projects.Project({ model: project, collection: @collection })
      @$('.items').append(projects.render().el)

    clearSearch: =>
      @searchable.resetSearch()


