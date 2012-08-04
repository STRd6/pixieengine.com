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
    initialize: (options) ->
      @params = options.params
      @router = options.router

      @params.on 'change', (model) =>
        if @router
          @router.navigate("projects#{@params.queryString()}", {trigger: true})
        else
          @fetch()

    fetch: (options={}) =>
      @trigger "fetching"

      options.data = @params.attributes

      success = options.success

      options.success = (resp) =>
        @trigger "fetched"
        success?(self, resp)

      super(options)

    parse: (resp) =>
      {@total, @current_user_id} = resp

      return resp.models

    pageInfo: =>
      page = @params.get('page')

      info =
        current_user_id: @current_user_id
        total: @total
        page: page
        prev: false
        next: false

      info.prev = page - 1 if page > 1
      info.next = page + 1 if page < @total

      info.range = calculateRange(page, @total)

      info

    toPage: (pageNumber) =>
      if 1 <= pageNumber <= @total
        @params.set
          page: pageNumber

    nextPage: =>
      unless @params.get('page') is @total
        @params.set
          page: @params.get('page') + 1

    previousPage: =>
      unless @params.get('page') is 1
        @params.set
          page: @params.get('page') - 1

    resetSearch: =>
      @params.unset 'search'
      @params.set
        page: 1

    search: (query) =>
      @params.set
        page: 1
        search: query.trim()

  Models.PaginatedCollection.INNER_WINDOW = 4
  Models.PaginatedCollection.OUTER_WINDOW = 1
