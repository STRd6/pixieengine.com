#= require underscore
#= require backbone
#= require models/paginated_collection
#= require models/comment

window.Pixie ||= {}
Pixie.Models ||= {}

class Pixie.Models.CommentsCollection extends Pixie.Models.PaginatedCollection
  model: Pixie.Models.Comment

  parse: (data) =>
    @params.id = data.owner_id || false

    super(data)

  url: ->
    '/comments'

