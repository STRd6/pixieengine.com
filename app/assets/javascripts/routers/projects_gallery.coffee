#= require_tree ../views/projects

namespace "Pixie.Routers.Projects", (Projects) ->
  {Models, Views} = Pixie

  class Projects.App extends Backbone.Router
    routes:
      'projects*args': 'query'

    initialize: (options) ->
      @collection = new Models.ProjectsCollection

      projects_gallery = new Views.Projects.Gallery
        collection: @collection

      @collection.bind 'navigate', (params) =>
        queryString = "?"

        queryString += "page=#{params.page}"
        queryString += "&filter=#{params.filter}" if params.filter?
        queryString += "&search=#{params.search}" if params.search?

        @navigate "projects#{queryString}", {trigger: true}

      $('.gallery').replaceWith(projects_gallery.render().el)

      Backbone.history.start(pushState: true)

      @collection.trigger 'navigate', Pixie.params

    query: =>
      unless @collection.page
        params = Pixie.params

        @collection.page = params.page || 1
        @collection.filter = params.filter || 'arcade'
        @collection.activeFilter = params.filter || 'arcade'

        @collection.params.page = @collection.page
        @collection.params.filter = @collection.filter
        @collection.params.search = params.search if params.search?

      @collection.fetch()
