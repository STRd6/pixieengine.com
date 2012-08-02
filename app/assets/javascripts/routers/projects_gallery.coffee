#= require_tree ../models

#= require_tree ../views/projects

namespace "Pixie.Routers.Projects", (Projects) ->
  {Models, Views} = Pixie

  class Projects.App extends Backbone.Router
    routes:
      'projects*args': 'query'

    initialize: (options) ->
      attrs = _.extend {filter: 'featured'}, @_formatParams()

      $(window).on 'popstate', =>
        @queryString.unset 'search', {silent: true}
        @queryString.set @_formatParams(), {silent: true}

        projects_gallery.filters.activateFilter(@queryString.get('filter'))

      @queryString = new Models.QueryString(attrs)

      @queryString.on 'change', (model) =>
        @userChanged = true

        @navigate("projects#{@queryString.queryString()}", {trigger: true})

        projects_gallery.filters.activateFilter(@queryString.get('filter'))

      @collection = new Models.ProjectsCollection
        params: @queryString

      projects_gallery = new Views.Projects.Gallery
        collection: @collection

      $('.gallery').replaceWith(projects_gallery.render().el)

      Backbone.history.start(pushState: true)

    _formatParams: ->
      obj = Pixie.params()

      for k, v of obj
        obj[k] = unescape(v) if _.isString v
        obj[k] = parseInt(v) unless _.isNaN parseInt(v)

      obj

    query: =>
      @collection.fetch()
