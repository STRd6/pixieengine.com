#= require underscore
#= require backbone
#= require corelib

#= require templates/tags/tag

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
    tag = $(e.target).text().toLowerCase()
    @collection.filterTagged(tag)

  render: =>
    tags = []

    $(@el).empty()

    for model in @collection.models
      if model.attributes.tags
        for tag in model.attributes.tags
          tags.push tag.name unless tags.include(tag.name)

    for name in tags
      $(@el).append($(JST['templates/tags/tag']({name: name})))

    return @
