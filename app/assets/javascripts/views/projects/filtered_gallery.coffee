#= require underscore
#= require backbone
#= require views/paginated
#= require views/projects/filtered_project
#= require models/projects_collection
#= require models/paginated_collection

#= require tmpls/projects/filtered_header
#= require tmpls/pagination

window.Pixie ||= {}
Pixie.Views ||= {}
Pixie.Views.Projects ||= {}

class Pixie.Views.Projects.FilteredGallery extends Pixie.Views.Paginated
  el: ".gallery"

  events:
    'click .filter': 'filterResults'

  initialize: ->
    self = @

    # merge the superclass paging related events
    @events = _.extend(@pageEvents, @events)
    @delegateEvents()

    @collection = new Pixie.Models.ProjectsCollection

    @collection.bind 'fetching', ->
      $(self.el).find('.spinner').show()

    @collection.bind 'reset', (projects) ->
      $(self.el).find('nav').remove()
      $(self.el).find('.items').remove()
      $(self.el).append $.tmpl("projects/filtered_header", projects.pageInfo())
      $(self.el).find('.filter').filter( ->
        $(this).text().toLowerCase() == self.filter
      ).takeClass('active')

      projects.each(self.addProject)

      self.updatePagination()

  addProject: (project) =>
    view = new Pixie.Views.Projects.FilteredProject({ model: project, collection: @collection })
    $(@el).find('.items').append(view.render().el)

  filterResults: (e) =>
    @filter = $(e.target).text().toLowerCase()

    @collection.filterPages(@filter)

  updatePagination: =>
    $(@el).find('.pagination').html $.tmpl('pagination', @collection.pageInfo())


