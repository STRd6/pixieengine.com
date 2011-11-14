#= require underscore
#= require backbone
#= require views/paginated_view
#= require views/projects/project
#= require models/projects_collection
#= require models/paginated_collection

#= require tmpls/projects/header
#= require tmpls/pagination

window.Pixie ||= {}
Pixie.Backbone ||= {}
Pixie.Backbone.Projects ||= {}

class Pixie.Backbone.Projects.Gallery extends Pixie.Backbone.PaginatedView
  el: ".projects"

  initialize: ->
    self = @

    # merge the superclass paging related events
    @events = _.extend(@pageEvents, @events)
    @delegateEvents()

    @collection = new Pixie.Backbone.Projects.Collection

    @collection.bind 'fetching', ->
      $(self.el).find('.spinner').show()

    @collection.bind 'reset', (collection) ->
      $(self.el).find('.header').remove()
      $(self.el).find('.pagination').remove()
      $(self.el).append $.tmpl("projects/header", self.collection.pageInfo())

      $(self.el).find('.project').remove()
      $(self.el).find('.spinner').hide()
      collection.each(self.addProject)

      self.updatePagination()

  addProject: (project) =>
    view = new Pixie.Backbone.Projects.ProjectView({ model: project, collection: @collection })
    $(@el).append(view.render().el)

  updatePagination: =>
    $(@el).find('.pagination').html $.tmpl('pagination', @collection.pageInfo())


