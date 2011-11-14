#= require underscore
#= require backbone

window.Pixie ||= {}
Pixie.Backbone ||= {}

class Pixie.Backbone.PaginatedCollection extends Backbone.Collection
  initialize: ->
    @page = 1

  fetch: (options={}) ->
    @trigger "fetching"
    self = @

    options.data = {page: @page, id: @owner_id}
    success = options.success

    options.success = (resp) ->
      self.trigger "fetched"
      success(self, resp) if success

    Backbone.Collection.prototype.fetch.call(@, options)

  parse: (resp) =>
    {@page, @per_page, @total, @current_user_id, @owner_id} = resp
    return resp.models

  pageInfo: =>
    info =
      owner_id: @owner_id
      current_user_id: @current_user_id
      total: @total
      page: @page
      perPage: @per_page
      prev: false
      next: false

    info.prev = @page - 1 if @page > 1
    info.next = @page + 1 if @page < info.total
    info.range = [1..@total]

    return info

  toPage: (pageNumber) =>
    @page = pageNumber
    @fetch()

  nextPage: =>
    @page += 1
    @fetch()

  previousPage: =>
    @page -= 1
    @fetch()

