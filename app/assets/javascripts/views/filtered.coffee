#= require underscore
#= require backbone
#= require corelib

#= require tmpls/filters

window.Pixie ||= {}
Pixie.Views ||= {}

class Pixie.Views.Filtered extends Backbone.View
  className: 'filters'

  events:
    'click .filter': 'filterResults'

  initialize: ->
    self = @

    {@filters, @activeFilter} = @options

    @collection.bind 'afterReset', ->
      $(self.el).find('.filter').filter( ->
        $(this).text().toLowerCase() == self.filter
      ).takeClass('active')

  filterResults: (e) =>
    @filter = $(e.target).text().toLowerCase()

    @collection.filterPages(@filter)

  render: =>
    $(@el).append($.tmpl('filters', { filters: @filters, activeFilter: @activeFilter }))

    return @

