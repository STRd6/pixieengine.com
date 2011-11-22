#= require underscore
#= require backbone
#= require corelib

calculateRange = (page, total) ->
  outer_window = Pixie.Models.PaginatedCollection.OUTER_WINDOW
  inner_window = Pixie.Models.PaginatedCollection.INNER_WINDOW

  window_from = page - inner_window
  window_to = page + inner_window

  if window_to > total
    window_from -= (window_to - total)
    window_to = total

  if window_from < 1
    window_to += (1 - window_from)
    window_from = 1
    window_to = total if window_to > total

  middle = [window_from..window_to]

  if outer_window + 3 < middle.first()
    left = [1..(outer_window + 1)]
    left.push "..."
  else
    left = [1...middle.first()]

  if total - outer_window - 2 > middle.last()
    right = [(total - outer_window)..total]
    right.unshift "..."
  else
    if middle.last() + 1 > total
      right = []
    else
      right = [(middle.last() + 1)..total]

  return left.concat(middle).concat(right)

window.Pixie ||= {}
window.Pixie.Models ||= {}

class Pixie.Models.PaginatedCollection extends Backbone.Collection
  initialize: ->
    @page = 1
    @params ||= {}
    @params.page = @page

  fetch: (options={}) ->
    @trigger "fetching"
    self = @

    options.data = @params

    success = options.success

    options.success = (resp) ->
      self.trigger "fetched"
      success(self, resp) if success

    Backbone.Collection.prototype.fetch.call(@, options)

  parse: (resp) =>
    {@page, @per_page, @total, @current_user_id, @owner_id, @tagged} = resp

    @params.page = @page
    @params.id = @owner_id
    @params.tagged = @tagged if @tagged?.length > 0

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

    info.range = calculateRange(@page, @total)

    return info

  toPage: (pageNumber) =>
    if 1 <= pageNumber <= @total
      @page = pageNumber

      @params.page = @page

      @fetch()

  nextPage: =>
    unless @page == @total
      @page += 1

      @params.page = @page

      @fetch()

  previousPage: =>
    unless @page == 1
      @page -= 1

      @params.page = @page

      @fetch()

Pixie.Models.PaginatedCollection.INNER_WINDOW = 4
Pixie.Models.PaginatedCollection.OUTER_WINDOW = 1
