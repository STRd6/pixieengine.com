#= require underscore
#= require backbone

#= require tmpls/tags/tag

window.Pixie ||= {}
Pixie.Views ||= {}
Pixie.Views.Tags ||= {}

class Pixie.Views.Tags.Tags extends Backbone.View
  el: '.tags'

  events:
    'click .tag': 'searchTags'

  initialize: ->
    @collection.bind 'afterReset', =>
      @render()

  searchTags: (e) =>
    $('.reset').show()
    tag = $(e.target).text().toLowerCase()
    @collection.filterTagged(tag)

  render: =>
    tags = []

    $(@el).empty()

    for model in @collection.models
      for tag in model.attributes.tags
        tags.push tag.name unless $.inArray(tag.name, tags) >= 0

    for name in tags
      $(@el).append($.tmpl('tags/tag', {name: name}))

    return @
