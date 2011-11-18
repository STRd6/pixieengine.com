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

    outer_window = 1
    inner_window = 4

    info.prev = @page - 1 if @page > 1
    info.next = @page + 1 if @page < info.total

    window_from = @page - inner_window
    window_to = @page + inner_window

    if window_to > @total
      window_from -= (window_to - @total)
      window_to = @total

    if window_from < 1
      window_to += (1 - window_from)
      window_from = 1
      window_to = @total if window_to > @total

    middle = [window_from..window_to]

    if outer_window + 3 < middle.first()
      left = [1..(outer_window + 1)]
      left.push "..."
    else
      left = [1...middle.first()]

    if @total - outer_window - 2 > middle.last()
      right = [(@total - outer_window)..@total]
      right.unshift "..."
    else
      if middle.last() + 1 > @total
        right = []
      else
        right = [(middle.last() + 1)..@total]

    info.range = left.concat(middle).concat(right)

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

