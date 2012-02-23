#= require models/paginated_collection

namespace "Pixie.Models", (Models) ->
  class Models.Comment extends Backbone.Model

  class Models.CommentsCollection extends Models.PaginatedCollection
    model: Models.Comment

    parse: (data) =>
      @params.id = data.owner_id || false

      super(data)

    url: ->
      '/comments'
