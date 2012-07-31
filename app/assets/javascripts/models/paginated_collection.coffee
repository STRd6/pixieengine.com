namespace "Pixie.Models", (Models) ->
  calculateRange = (page, total) ->
    outerWindow = Models.PaginatedCollection.OUTER_WINDOW
    innerWindow = Models.PaginatedCollection.INNER_WINDOW

    window_from = page - innerWindow
    window_to = page + innerWindow

    if window_to > total
      window_from -= (window_to - total)
      window_to = total

    if window_from < 1
      window_to += (1 - window_from)
      window_from = 1
      window_to = total if window_to > total

    middle = [window_from..window_to]

    if outerWindow + 3 < middle.first()
      left = [1..(outerWindow + 1)]
      left.push "..."
    else
      left = [1...middle.first()]

    if total - outerWindow - 2 > middle.last()
      right = [(total - outerWindow)..total]
      right.unshift "..."
    else
      if middle.last() + 1 > total
        right = []
      else
        right = [(middle.last() + 1)..total]

    return left.concat(middle).concat(right)

  class Models.PaginatedCollection extends Backbone.Collection
    initialize: ->
      @page = 1
      @params ||= {}

    fetch: (options={}) ->
      @trigger "fetching"

      @params.page = @page
      @params.per_page = @per_page

      options.data = @params

      success = options.success

      options.success = (resp) =>
        @trigger "fetched"
        success(self, resp) if success

      super(options)

    parse: (resp) =>
      {@page, @per_page, @total, @current_user_id} = resp

      return resp.models

    pageInfo: =>
      info =
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

        @fetch()

    nextPage: =>
      unless @page == @total
        @page += 1

        @fetch()

    previousPage: =>
      unless @page == 1
        @page -= 1

        @fetch()

    resetSearch: =>
      @page = 1
      delete @params.search
      delete @params.tagged
      @fetch()

    search: (query) =>
      @page = 1
      @params.search = query.trim()
      @fetch()

  Models.PaginatedCollection.INNER_WINDOW = 4
  Models.PaginatedCollection.OUTER_WINDOW = 1
