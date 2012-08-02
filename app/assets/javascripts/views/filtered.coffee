#= require templates/filters

namespace "Pixie.Views", (Views) ->
  class Views.Filtered extends Backbone.View
    className: 'filters'

    events:
      'click .filter': 'filterResults'

    initialize: ->
      {@filters} = @options

    activateFilter: (value) =>
      @$('.filter').filter( ->
        $(this).text().toLowerCase() is value.toLowerCase()
      ).takeClass('active')

    filterResults: (e) =>
      @filter = $(e.target).text().toLowerCase()

      @collection.filterPages(@filter)

      self = @

      @$('.filter').filter( ->
        $(this).text().toLowerCase() is self.filter
      ).takeClass('active')

    render: =>
      @$el.append(
        $ JST['templates/filters']
          filters: @filters
          activeFilter: @collection.params.get('filter')
      )

      return @
