#= require underscore
#= require backbone

#= require templates/search

#= require pixie/view

namespace "Pixie.Views", (Views) ->
  class Views.Searchable extends Pixie.View
    className: 'search'

    initialize: ->
      super

    events:
      'click button.search': 'search'
      'keyup .search_field': 'searchOnEnter'
      'click button.clear': 'resetSearch'
      'blur .search_field': 'searchOnEnter'

    resetSearch: (e) =>
      @$('.search_field').val ""
      @$('button.search').attr('disabled', 'disabled')

      @collection.resetSearch()

    search: (e) =>
      query = @$('.search_field').val()

      @collection.search(query) if query.length

    searchOnEnter: (e) =>
      query = $(e.target).val()

      if query.length
        @$('button.search').removeAttr('disabled')

        @collection.search(query) if e.keyCode == 13
      else
        @$('button.search').attr('disabled', 'disabled')

    render: =>
      @el.html $.tmpl('tmpls/search')
      return @
