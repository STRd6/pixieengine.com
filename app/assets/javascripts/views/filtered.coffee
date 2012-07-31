#= require templates/filters

namespace "Pixie.Views", (Views) ->
  class Views.Filtered extends Backbone.View
    className: 'filters'

    events:
      'click .filter': 'filterResults'

    initialize: ->
      {@filters, @activeFilter} = @options

    filterResults: (e) =>
      @filter = $(e.target).text().toLowerCase()

      @collection.filterPages(@filter)

      self = @

      $(self.el).find('.filter').filter( ->
        $(this).text().toLowerCase() == self.filter
      ).takeClass('active')

    render: =>
      $(@el).append($(JST['templates/filters']({ filters: @filters, activeFilter: @activeFilter })))

      return @

